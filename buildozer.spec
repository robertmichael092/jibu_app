[app]

# -------------------------
# Basic app meta
# -------------------------
title = Jibu
package.name = jibu
package.domain = org.jibu

# Required version
version = 0.1

# Source layout
source.dir = app_src
source.include_exts = py,kv,png,jpg,jpeg,ttf,otf,json,txt

# Orientation & UI
orientation = portrait
fullscreen = 0

# -------------------------
# Python / dependencies
# -------------------------
# Pick stable requirements compatible with p4a
requirements = python3,kivy==2.1.0,kivymd,requests

# -------------------------
# Graphics -- these MUST exist
# -------------------------
icon.filename = app_src/assets/icons/icon.png
presplash.filename = app_src/presplash.png

# -------------------------
# Android configuration
# -------------------------
# Architectures
android.archs = arm64-v8a

# API / build tools
android.api = 33
android.minapi = 21
android.build_tools_version = 33.0.2

# NDK configuration (matches workflow that installs ndk;25.2.9519653)
android.ndk = 25b
# Path: keep this pointing at where the CI installs the NDK via .buildozer structure
android.ndk_path = ~/.buildozer/android/platform/android-sdk/ndk/25b

# Permissions
android.permissions = INTERNET

# Prevent p4a from selecting a very new toolchain automatically
android.accept_sdk_license = True

# -------------------------
# Build output and logging
# -------------------------
log_level = 2

# -------------------------
# Buildozer section (required)
# -------------------------
[buildozer]
# avoid the interactive "running as root" prompt on CI
warn_on_root = 0

# Some CI runners look for this; ensures buildozer uses non-interactive behaviour
# If your CI sets BUILDOZER_FORCE_ACCEPT or BUILDOZER_WARN_ON_ROOT via env, it will still override these.
