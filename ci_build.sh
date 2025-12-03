#!/usr/bin/env bash
# ci_build.sh -- Hardened Buildozer installer + build runner
# Put this in repo root and run: ./ci_build.sh
set -euo pipefail
IFS=$'\n\t'

# ---------- Configuration (edit only if necessary) ----------
CMDLINE_ZIP_URL="${ANDROID_CMDLINE_TOOLS_URL:-https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip}"
ANDROID_API="${ANDROID_API:-33}"
BUILD_TOOLS_VER="${BUILD_TOOLS_VER:-33.0.2}"
ANDROID_NDK_VER="${ANDROID_NDK_VER:-25.2.9519653}"
VENV_DIR=".venv_ci_build"
# -----------------------------------------------------------

log(){ printf "\n==== %s\n" "$*"; }
err(){ printf "\n!!!! ERROR: %s\n" "$*" >&2; }

log "Starting CI build script"
log "Workdir: $PWD"

# ------------- Basic environment checks -------------
if [ "$(uname -m 2>/dev/null || echo unknown)" = "aarch64" ]; then
  log "Host architecture: aarch64"
fi

# Check disk free percent for root
avail_percent=$(df / --output=pcent | tail -1 | tr -dc '0-9' || echo 0)
log "Root disk usage: ${avail_percent}%"
if [ "${avail_percent}" -ge 95 ]; then
  err "Disk usage is ${avail_percent}%. Not enough space. Abort."
  exit 1
fi

# ------------- Prepare python venv -------------
log "Creating python venv at ${VENV_DIR}"
python3 -m venv "${VENV_DIR}" || true
. "${VENV_DIR}/bin/activate"

log "Upgrading pip & installing pinned build tools"
pip install --upgrade pip setuptools wheel
# Pin buildozer to an available version and python-for-android to a stable version
pip install --upgrade buildozer==1.5.0 python-for-android==0.11.0 Cython==0.29.34

# Print installed versions for debugging
log "Installed versions:"
python --version
pip show buildozer | sed -n '1,3p' || true
pip show python-for-android | sed -n '1,3p' || true
pip show Cython | sed -n '1,3p' || true

# ------------- Install Android command-line tools -------------
ANDROID_ROOT="${HOME}/.buildozer/android/platform/android-sdk"
log "ANDROID_ROOT set to: ${ANDROID_ROOT}"
mkdir -p "${ANDROID_ROOT}"
log "Ensure cmdline-tools present"
if [ ! -x "${ANDROID_ROOT}/cmdline-tools/latest/bin/sdkmanager" ]; then
  tmpd="$(mktemp -d)"
  log "Downloading command-line tools to temp dir ${tmpd}"
  cd "$tmpd"
  wget -qO cmdline.zip "${CMDLINE_ZIP_URL}"
  unzip -q cmdline.zip || {
    err "Failed to unzip commandline tools"
    ls -la
    exit 1
  }
  # Normalize layout to cmdline-tools/latest
  mkdir -p "${ANDROID_ROOT}/cmdline-tools/latest"
  if [ -d cmdline-tools ]; then
    mv cmdline-tools/* "${ANDROID_ROOT}/cmdline-tools/latest/" || true
  else
    mv * "${ANDROID_ROOT}/cmdline-tools/latest/" || true
  fi
  rm -rf "$tmpd"
  cd "${PWD:-$HOME}"
else
  log "Command-line tools already installed"
fi

export ANDROID_SDK_ROOT="${ANDROID_ROOT}"
export ANDROID_HOME="${ANDROID_ROOT}"
export PATH="${ANDROID_ROOT}/cmdline-tools/latest/bin:${ANDROID_ROOT}/platform-tools:${PATH}"

log "sdkmanager path: $(command -v sdkmanager || echo 'sdkmanager not found')"
log "sdkmanager version (if available):"
sdkmanager --version || true

# ------------- Ensure 'yes' exists (shim if necessary) -------------
if ! command -v yes >/dev/null 2>&1; then
  log "'yes' not found; creating shim in venv bin"
  cat > "${VENV_DIR}/bin/yes" <<'YEOF'
#!/usr/bin/env bash
while true; do printf 'y\n'; sleep 0.01; done
YEOF
  chmod +x "${VENV_DIR}/bin/yes"
  export PATH="${VENV_DIR}/bin:$PATH"
fi

# ------------- Accept licenses (non-interactive) -------------
log "Accepting Android SDK licenses (non-interactive)"
mkdir -p "${ANDROID_ROOT}/licenses"

# Try sdkmanager --licenses first (preferred)
set +e
yes | sdkmanager --sdk_root="${ANDROID_ROOT}" --licenses > /tmp/sdk_licenses_install.log 2>&1
LIC_RC=$?
set -e

if [ ${LIC_RC} -ne 0 ]; then
  log "sdkmanager --licenses returned non-zero (rc=${LIC_RC}). Will write common license files as fallback."
  # Common license tokens; these are standard and used as fallback in CI environments
  cat > "${ANDROID_ROOT}/licenses/android-sdk-license" <<'L1'
24333f8a63b6825ea9efcc6f4140f001e6f5f46d
L1
  cat > "${ANDROID_ROOT}/licenses/android-sdk-preview-license" <<'L2'
84831b9409646a918e30573bab4c9c91346d8abd
L2
  chmod 644 "${ANDROID_ROOT}/licenses/"* || true
fi

# ------------- Install required SDK components -------------
log "Installing platform-tools, platforms;android-${ANDROID_API}, build-tools;${BUILD_TOOLS_VER}, ndk;${ANDROID_NDK_VER}"
set +e
yes | sdkmanager --sdk_root="${ANDROID_ROOT}" "platform-tools" "platforms;android-${ANDROID_API}" "build-tools;${BUILD_TOOLS_VER}" "ndk;${ANDROID_NDK_VER}" > /tmp/sdk_install.log 2>&1
SDK_RC=$?
set -e

if [ ${SDK_RC} -ne 0 ]; then
  log "sdkmanager returned ${SDK_RC}. Showing relevant log tail:"
  tail -n 200 /tmp/sdk_install.log || true
  # If build-tools 36.x was skipped due to license, attempt to explicitly install only the pinned version and continue
  log "Attempting to install only build-tools;${BUILD_TOOLS_VER} and platform-tools again..."
  yes | sdkmanager --sdk_root="${ANDROID_ROOT}" "platform-tools" "build-tools;${BUILD_TOOLS_VER}" "platforms;android-${ANDROID_API}" || true
fi

# ------------- Validate SDK install -------------
log "SDK directory listing (summary):"
ls -la "${ANDROID_ROOT}" || true
ls -la "${ANDROID_ROOT}/build-tools" || true
ls -la "${ANDROID_ROOT}/platforms" || true

# Confirm aidl presence
if [ ! -x "${ANDROID_ROOT}/build-tools/${BUILD_TOOLS_VER}/aidl" ]; then
  err "aidl not found under build-tools/${BUILD_TOOLS_VER}. Build will fail. Listing build-tools folder:"
  ls -la "${ANDROID_ROOT}/build-tools" || true
  exit 1
fi

log "aidl found: ${ANDROID_ROOT}/build-tools/${BUILD_TOOLS_VER}/aidl"

# ------------- Prepare Buildozer env & config -------------
# Ensure buildozer.spec exists
if [ ! -f buildozer.spec ]; then
  err "buildozer.spec not present in repo root. Aborting."
  exit 1
fi

# Set environment variables expected by Buildozer/p4a
export ANDROIDHOME="${ANDROID_ROOT}"
export ANDROID_SDK_ROOT="${ANDROID_ROOT}"
export ANDROID_HOME="${ANDROID_ROOT}"
export ANDROID_NDK_HOME="${ANDROID_ROOT}/ndk/${ANDROID_NDK_VER}"
export PATH="${ANDROID_ROOT}/platform-tools:${ANDROID_ROOT}/build-tools/${BUILD_TOOLS_VER}:$PATH"

# Ensure buildozer non-interactive behavior
# (We already set warn_on_root=0 in buildozer.spec; ensure buildozer binary available)
command -v buildozer >/dev/null 2>&1 || { err "buildozer not found in PATH"; exit 1; }

log "Starting Buildozer build (this may take 10-40+ minutes on first run)"
set -x
buildozer -v android debug || {
  rc=$?
  err "Buildozer failed with exit code ${rc}"
  log "==== Last 400 lines from buildozer log files (if present) ===="
  # Attempt to show the most likely build log paths
  if [ -d ./.buildozer/android/platform/build ]; then
    tail -n 400 ./.buildozer/android/platform/build/dists/*/build.log || true
  else
    tail -n 400 ./.buildozer/android/platform/*/build.log || true
  fi
  exit $rc
}
set +x

log "Build succeeded (if no errors above). APK (if created) is listed below:"
ls -la bin || true

log "CI build script finished."
