#!/bin/bash
set -e

echo "==== Starting CI build script"

echo "==== Workdir: $(pwd)"

# Create virtual environment
echo "==== Creating python venv at .venv_ci_build"
python3 -m venv .venv_ci_build
source .venv_ci_build/bin/activate

echo "==== Upgrading pip & installing pinned build tools"
pip install --upgrade pip setuptools wheel

# --- FIXED HERE: use valid versions ---
pip install buildozer==1.5.0
pip install python-for-android==2024.1.21

# Make sure buildozer is visible
which buildozer

echo "==== Initialize buildozer if missing"
if [ ! -f buildozer.spec ]; then
    buildozer init
fi

echo "==== Running Buildozer Android Debug"
buildozer android debug
