[app]

# -------------------------------------
# BASIC APP SETTINGS
# -------------------------------------
title = Jibu
package.name = jibu
package.domain = org.jibu

# Version is required to avoid "version.regex missing" errors
version = 0.1

# Main source directory
source.dir = app_src
source.include_exts = py,kv,png,jpg,jpeg,ttf,otf,json,txt

# App orientation & fullscreen
orientation = portrait
fullscreen = 0

# -------------------------------------
# PYTHON REQUIREMENTS
# -------------------------------------
# Include only stable packages that compile with python-for-android
requirements = python3,kivy,kivymd,requests

# Prevent versions from breaking the build
android.requirements_rtxt = False

# -------------------------------------
# GRAPHICS (MUST EXIST OR BUILD FAILS)
# -------------------------------------
icon.filename = app_src/assets/icons/icon.png
presplash.filename = app_src/presplash.png

# -------------------------------------
# ANDROID RUNTIME SETTINGS
# -------------------------------------

# Supported architectures (ARM64 recommended)
android.archs = arm64-v8a

# Required API levels (33 is best for 2024/2025)
android.api = 33
android.minapi = 21

# Force stable build-tools to avoid Buildozer trying to download 36.1
android.build_tools_version = 33.0.2

# Permissions your app needs
android.permissions = INTERNET

# Use modern packaging
android.gradle_dependencies = com.android.tools.build:gradle:7.3.1

# -------------------------------------
# AUDIO / VIDEO / FONTS / STORAGE (optional but safe)
# -------------------------------------
android.allow_backup = True
android.enable_androidx = True

# -------------------------------------
# PREVENT ALL INTERACTIVE ERRORS
# -------------------------------------

# Remove "Buildozer is running as root" prompt
warn_on_root = 0

# Accept Android SDK licenses automatically
android.accept_sdk_license = True

# Prevent jdk errors by explicitly naming Java version (GitHub uses JDK 17)
android.java_toolchain = 17

# Fix "android.ndk_path not set" errors
android.ndk_path = $ANDROID_HOME/ndk/25.2.9519653

# -------------------------------------
# BUILD OUTPUT SETTINGS
# -------------------------------------
log_level = 2
