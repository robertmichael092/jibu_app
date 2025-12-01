[app]

title = Jibu
package.name = jibu
package.domain = org.jibu
version = 0.1

source.dir = .
source.include_exts = py,kv,png,jpg,ttf,wav,mp3,json,bin,txt

orientation = portrait
fullscreen = 0

android.api = 31
android.minapi = 21
android.sdk = 31
android.ndk = 25b
android.ndk_api = 21
android.archs = arm64-v8a, armeabi-v7a

requirements = python3,kivy,kivymd,requests

presplash.filename = ./app_src/assets/images/presplash.png
icon.filename = ./app_src/assets/icons/icon.png

# (We will add permissions later)
