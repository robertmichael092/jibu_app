[app]

# (name displayed on device)
title = Jibu

package.name = jibu
package.domain = org.jibu
source.dir = app_src
source.include_exts = py,kv,png,jpg,ttf,json,txt
version = 0.1

# Python / Kivy requirements
requirements = python3,kivy,kivymd,requests

# Orientation and other app settings
orientation = portrait
fullscreen = 0

# Android settings
icon.filename = app_src/assets/icons/icon.png
presplash.filename = app_src/presplash.png

android.arch = arm64-v8a
android.permissions = INTERNET

# Force a working build-tools version (critical fix)
android.build_tools_version = 33.0.2

# Skip root warnings during CI builds
warn_on_root = 0

log_level = 2
