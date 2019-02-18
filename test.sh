#!/usr/bin/env bash
SYS=23
ANDROID_ABI="google_apis;armeabi-v7a"
    #if [[ "$SYS$ANDROID_ABI" == "25google_apis;armeabi-v7a" || "$SYS$ANDROID_ABI" == "24google_apis;armeabi-v7a"]]; then
    if [[ "$SYS$ANDROID_ABI" == "25google_apis;armeabi-v7a"
       || "$SYS$ANDROID_ABI" == "24google_apis;armeabi-v7a" ]]; then
      GPU='swiftshader'
    else
      GPU='off'
    fi

echo $GPU
