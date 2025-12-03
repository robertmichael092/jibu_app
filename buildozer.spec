[app]

# Basic metadata
title = Jibu
package.name = jibu
package.domain = org.jibu
version = 0.1

# Source directory (repo root)
source.dir = .
source.include_exts = py,kv,png,jpg,jpeg,ttf,otf,json,txt

# Application requirements
requirements = python3,kivy==2.1.0,kivymd,requests

# Orientation / UI
orientation = portrait
fullscreen = 0

# Graphics (update these to match your repo paths)
icon.filename = app_src/assets/icons/icon.png
presplash.filename = app_src/assets/images/presplash.png

# Android config
android.archs = arm64-v8a
android.api = 33
android.minapi = 21
android.build_tools_version = 33.0.2
android.ndk = 25b

# Permissions
android.permissions = INTERNET

# Logging
log_level = 2


[buildozer]
# Prevent interactive prompt errors in GitHub Actions
warn_on_root = 0
