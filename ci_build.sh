
#!/bin/bash
set -e

# Skip the "Buildozer is running as root" prompt
export BUILDOZER_WARN_ON_ROOT=0

# Force yes to all prompts
export BUILDOZER_ACCEPT=1
export BUILDOZER_ALLOW_ROOT=1

# Navigate to the app folder (GitHub mounts repo at /app)
cd /app

# Run buildozer
buildozer -v android debug
