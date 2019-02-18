SYS=23
ANDROID_ABI="google_apis;armeabi-v7a"
GPU=off
    #if [[ "$SYS$ANDROID_ABI" == "25google_apis;armeabi-v7a" || "$SYS$ANDROID_ABI" == "24google_apis;armeabi-v7a"]]; then
    if [[ "$SYS$ANDROID_ABI" == "25google_apis;armeabi-v7a" || "$SYS$ANDROID_ABI" == "24google_apis;armeabi-v7a" ]]; then
      GPU='swiftshader'
    fi

echo $GPU
