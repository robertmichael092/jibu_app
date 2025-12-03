[app]
title = Jibu
package.name = jibu
package.domain = org.jibu
source.dir = app_src
source.include_exts = py,kv,png,jpg,ttf,json,txt
version = 0.1
requirements = python3,kivy==2.1.0,kivymd,requests

orientation = portrait
fullscreen = 0

icon.filename = app_src/assets/icons/icon.png
presplash.filename = app_src/presplash.png

# Android settings
android.arch = armeabi-v7a
android.permissions = INTERNET

[buildozer]
# Make CI non-interactive if running as root (prevents prompt)
warn_on_root = 0
log_level = 2

# Force known stable targets to avoid SDK manager pulling weird versions
android.api = 33
android.build_tools_version = 33.0.2
