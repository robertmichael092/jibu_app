#!/bin/bash
set -e

echo "==== Starting CI build script"

# Create isolated venv
python3 -m venv .venv_ci_build
source .venv_ci_build/bin/activate

pip install --upgrade pip setuptools wheel

# Install stable buildozer + python-for-android
pip install "buildozer==1.5.0"
pip install "python-for-android==2024.1.21"

# Auto-install Android SDK build-tools and accept licenses
mkdir -p $HOME/.buildozer/android/platform/android-sdk/cmdline-tools/latest
yes | sdkmanager --licenses || true
sdkmanager "platforms;android-33" "build-tools;33.0.2" "platform-tools"

# Run buildozer
buildozer -v android debug
