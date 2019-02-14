[![Build Status](https://travis-ci.org/mmcc007/test_emulators.svg?branch=master)](https://travis-ci.org/mmcc007/test_emulators)

# Test Android Emulators on Travis

Update: see [article](https://medium.com/@nocnoc/android-emulators-in-thcloud-f39e11c15bfa) on Medium about this.

Since travis hypervisor does not support nested VMs, it is not possible to run the x86 emulators on travis.

This project tests which ARM emulators run on travis and shows their start-up times.

Click on the travis badge to find out the start-up times of the tested emulators.

Note: starting an emulator is not a guarantee that the emulator will work (though some do). 
Plus there are many other possible configurations that have not been tried.

I have however found at least one emulator that is usable and reliable. 
````yaml
        - EMULATOR_API_LEVEL=22
        - ANDROID_ABI="default;armeabi-v7a"
        - sdkmanager "system-images;android-$EMULATOR_API_LEVEL;$ANDROID_ABI"
````

You can see this emulator working reliably, for the past several months, at https://travis-ci.org/brianegan/flutter_architecture_samples

If more emulators are found, by me or by others, I can maintain a list here. Might be useful for others trying to do android integration testing in the cloud.

## Useful Emulators
| Emulator  | Example of use |
| ------------- | ------------- |
| SYS=22 ABI="default;armeabi-v7a"  | https://travis-ci.org/brianegan/flutter_architecture_samples  |

## Issues and Pull Requests
Feel free to submit an issue or a PR if you find more arm emulators that run on travis.
