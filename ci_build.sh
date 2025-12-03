#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# --- Basic logging helpers ---
log() { printf "\n==== %s\n" "$*" ; }
err() { printf "\n!!!! ERROR: %s\n" "$*" >&2 ; }

# Fail early if disk is nearly full
log "Checking available disk space..."
df -h /
avail_percent=$(df / --output=pcent | tail -1 | tr -dc '0-9')
if [ "${avail_percent:-0}" -ge 95 ]; then
  err "Disk usage is ${avail_percent}%. Device nearly full. Abort."
  exit 1
fi

# Working directories
WORKDIR="$PWD"
ANDROID_ROOT="$HOME/.buildozer/android/platform/android-sdk"
CMDLINE_ZIP_URL="${ANDROID_CMDLINE_TOOLS_URL:-https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip}"
ANDROID_API="${ANDROID_API:-33}"
BUILD_TOOLS_VER="${BUILD_TOOLS_VER:-33.0.2}"
ANDROID_NDK_VER="${ANDROID_NDK_VER:-25.2.9519653}"

log "WORKDIR=$WORKDIR"
log "ANDROID_ROOT=$ANDROID_ROOT"
log "Target android api=$ANDROID_API build-tools=$BUILD_TOOLS_VER ndk=$ANDROID_NDK_VER"

# Ensure python packages in venv to keep environment stable
log "Creating Python venv for build tools..."
python3 -m venv .venv || true
. .venv/bin/activate

log "Upgrading pip & installing buildozer and dependencies..."
pip install --upgrade pip setuptools wheel
pip install --upgrade cython==0.29.34 virtualenv
pip install --upgrade buildozer==1.5.2 python-for-android==0.11.0

# Install command-line tools if not present
if [ ! -x "$ANDROID_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
  log "Installing Android command-line tools to $ANDROID_ROOT ..."
  mkdir -p "$ANDROID_ROOT"
  tmpd="$(mktemp -d)"
  cd "$tmpd"
  wget -qO cmdline.zip "$CMDLINE_ZIP_URL"
  unzip -q cmdline.zip
  mkdir -p "$ANDROID_ROOT/cmdline-tools/latest"
  # move extracted tools into place (handles different zip layouts)
  if [ -d "cmdline-tools" ]; then
    mv cmdline-tools/* "$ANDROID_ROOT/cmdline-tools/latest/" || true
  else
    mv * "$ANDROID_ROOT/cmdline-tools/latest/" || true
  fi
  rm -rf "$tmpd"
else
  log "Android command-line tools already present."
fi

export ANDROID_SDK_ROOT="$ANDROID_ROOT"
export ANDROID_HOME="$ANDROID_ROOT"
export PATH="$ANDROID_ROOT/cmdline-tools/latest/bin:$ANDROID_ROOT/platform-tools:$PATH"

log "sdkmanager path: $(command -v sdkmanager || echo 'not found')"
log "sdkmanager --version:"
sdkmanager --version || true

# Ensure 'yes' is available. If not, emulate it
if ! command -v yes >/dev/null 2>&1; then
  log "'yes' command not found; creating a small shim..."
  # create a shim in .venv/bin
  cat > .venv/bin/yes <<'YEOF'
#!/usr/bin/env bash
while true; do printf '%s\n' "y"; sleep 0.01; done
YEOF
  chmod +x .venv/bin/yes
  export PATH="$PWD/.venv/bin:$PATH"
fi

# Accept licenses non-interactively:
log "Accepting Android SDK licenses (non-interactive)..."
mkdir -p "$ANDROID_ROOT/licenses"

# Try normal sdkmanager license accept first
set +e
yes | sdkmanager --licenses >/tmp/sdk_licenses_install.log 2>&1
LIC_RC=$?
set -e

if [ $LIC_RC -ne 0 ]; then
  log "sdkmanager --licenses failed (rc=$LIC_RC). Will write license files directly as a fallback."
  # Common license hashes used by sdkmanager (safe fallback)
  cat > "$ANDROID_ROOT/licenses/android-sdk-license" <<'L1'
24333f8a63b6825ea9efcc6f4140f001e6f5f46d
L1
  cat > "$ANDROID_ROOT/licenses/android-sdk-preview-license" <<'L2'
84831b9409646a918e30573bab4c9c91346d8abd
L2
  chmod 644 "$ANDROID_ROOT/licenses/"*
fi

# Install required SDK packages (platform-tools, platforms, build-tools, ndk)
log "Installing platform-tools, platforms, and build-tools..."
# Use --sdk_root to be explicit
yes | sdkmanager --sdk_root="$ANDROID_ROOT" "platform-tools" "platforms;android-${ANDROID_API}" "build-tools;${BUILD_TOOLS_VER}" "ndk;${ANDROID_NDK_VER}" || true

# Confirm installed
log "Installed SDK contents (summary):"
ls -la "$ANDROID_ROOT" || true
ls -la "$ANDROID_ROOT/build-tools" || true
ls -la "$ANDROID_ROOT/platforms" || true

# Ensure aapt/aidl exist
if [ ! -x "$ANDROID_ROOT/build-tools/$BUILD_TOOLS_VER/aidl" ] && [ ! -x "$ANDROID_ROOT/build-tools/$BUILD_TOOLS_VER/aidl.exe" ]; then
  err "aidl not found in build-tools/$BUILD_TOOLS_VER - build will fail. Listing build-tools folder:"
  ls -la "$ANDROID_ROOT/build-tools" || true
  exit 1
fi

log "Set environment for Buildozer"
export ANDROID_HOME="$ANDROID_ROOT"
export ANDROID_SDK_ROOT="$ANDROID_ROOT"
export PATH="$ANDROID_ROOT/platform-tools:$ANDROID_ROOT/build-tools/$BUILD_TOOLS_VER:$PATH"

# Prevent buildozer prompting about running as root in some environments
# (We still avoid running as root; Buildozer checks warn_on_root setting.)
sed -n '1,200p' buildozer.spec || true

# Ensure buildozer.spec exists
if [ ! -f buildozer.spec ]; then
  err "No buildozer.spec found in repository root. Aborting."
  exit 1
fi

# Run build in a dedicated directory so .buildozer gets created under project
log "Running Buildozer: android debug (this can take 10-30+ minutes on CI)"
# we run non-interactive; -v for verbose logs
buildozer -v android debug || {
  rc=$?
  err "Buildozer failed with exit code $rc"
  echo "==== Last 200 lines of buildozer log for quick debugging ===="
  tail -n 200 ./.buildozer/android/platform/build/dists/*/build.log || true
  exit $rc
}

log "Build complete. APK artifacts (if any):"
ls -la bin || true
