[app]

# (name displayed on device)
title = Jibu
package.name = jibu
package.domain = org.jibu
source.dir = app_src
source.include_exts = py,kv,png,jpg,ttf,json,txt
# App version (required)
version = 0.1

# Python / Kivy requirements
requirements = python3,kivy,kivymd,requests

# Orientation and other app settings
orientation = portrait
fullscreen = 0

# Android settings
# Set the icon path relative to the project directory
# (must match the files you upload: see instructions below)
icon.filename = app_src/assets/icons/icon.png
presplash.filename = app_src/presplash.png

# Any other android options (example)
android.arch = arm64-v8a
android.permissions = INTERNET

[buildozer]
# Make CI non-interactive when running as root (DO NOT PROMPT)
# This prevents Buildozer asking "Are you sure you want to continue [y/n]?"
warn_on_root = 0

log_level = 2
