[app]

title = jibu
package.name = jibu
package.domain = org.jibu

source.dir = .
version = 1.0.0
source.include_exts = py,kv,png,jpg,ttf,json,bin

presplash.filename = ./app_src/assets/images/presplash.png
icon.filename = ./app_src/assets/icons/icon.png

orientation = portrait
fullscreen = 0

requirements = python3==3.10.12, kivy==2.3.0, kivymd==1.1.1, urllib3, certifi, chardet, idna

android.api = 33
android.minapi = 21
android.sdk = 33
android.ndk = 25b
android.ndk_api = 21
android.archs = arm64-v8a

android.accept_sdk_license = True

bootstrap = sdl2

android.permissions = INTERNET
