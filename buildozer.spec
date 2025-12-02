[app]

title = Jibu
package.name = jibu
package.domain = org.jibu
version = 0.1

# FORCE Buildozer to use OUR SDK (installed in workflow)
android.sdk_dir = /home/runner/android-sdk

# Use Buildozer’s default NDK location (it installs NDK correctly)
android.ndk_dir = /home/runner/.buildozer/android/platform/android-ndk-r25b

# Auto-accept Google SDK licenses
android.accept_sdk_license = True

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

requirements = python3==3.10.12,kivy==2.3.0,kivymd==1.1.1,urllib3,certifi,chardet,idna

presplash.filename = ./app_src/assets/images/presplash.png
icon.filename = ./app_src/assets/icons/icon.png
