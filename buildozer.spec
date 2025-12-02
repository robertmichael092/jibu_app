[app]

title = jibu
package.name = jibu
package.domain = org.jibu

# The app root folder (your main.py and jibu.kv are here)
source.dir = .

# Stable compatible versions
requirements = python3,kivy==2.2.1,kivymd==1.1.1,urllib3,certifi,chardet,idna

# Include common file types
source.include_exts = py,kv,png,jpg,ttf,wav,mp3,json,bin,txt

# App settings
orientation = portrait
fullscreen = 0

# Android build settings
android.api = 33
android.minapi = 21
android.sdk = 33
android.ndk = 25b
android.ndk_api = 21
android.archs = arm64-v8a,armeabi-v7a

# Let buildozer auto-accept licenses
android.accept_sdk_license = True

# Use SDL2 (required)
bootstrap = sdl2

# Permissions
android.permissions = INTERNET
