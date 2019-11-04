#!/usr/bin/env bash

set -x
# exit on error
#set -e

# Originally written by Maurice McCabe <mmcc007@gmail.com>, but placed in the public domain.

# Flutter CI/CD utilities

show_help() {
    printf "usage: $0 [command]

Utility for managing Flutter in a CI/CD environment.

Commands:
    --install-android-tools version android-home
        installs the android SDK tools on a Mac or Linux machine.
        version can be one of:
            28
        android-home
            home of android SDK
    --install-canary-emulator version android-home
        installs the canary emulator on a Mac or Linux machine.
        <version> can be one of:
            28.1.9-1
        <android-home>
            home of android SDK
    --create-hot-emulator name sys abi screen android-home [canary=true/false]
        creates and starts emulator to generate default snapshot
        name:
            name of emulator
        sys:
            emulator system image, eg 22
        abi:
            emulator image type, eg default;armeabi-v7a
        screen:
            dimensions of screen, eg 1440x2560
        android-home
            home of android SDK
        canary (optional, defaults to false)
            use the pre-installed canary emulator
    --start-hot-emulator name android-home
        starts an emulator with default snapshot
        name:
            name of emulator
            can be one of:
                Nexus_5X
        android-home
            home of android SDK
    --move-avd name directory android-home
        move an avd created by Android Studio to a directory
        name:
            name of AVD
        directory:
            directory to move to
        android-home
            home of android SDK
    --rename-avd name new-name android-home
        rename an avd in .android/avd
        name:
            name of AVD
        new-name:
            new name of AVD
        android-home
            home of android SDK

"
    exit 1
}

# installs the android sdk tools in specified directory
# note: does not update or export PATH or ANDROID_HOME
install_android_tools(){
    android_tools=$1
    android_home=$2

    # get android sdk tools file id
    case $android_tools in
        28)
            android_tools_id=4333796 # android-28
            ;;
        *)
            echo Unknown android SDK: $android_tools
            show_help
            ;;
    esac

    # download android SDK tools
    if [ $OSTYPE == "darwin"* ]; then
        sdk_filename=https://dl.google.com/android/repository/sdk-tools-darwin-$android_tools_id.zip
    else
        sdk_filename=https://dl.google.com/android/repository/sdk-tools-linux-$android_tools_id.zip
    fi

    # install android SDK tools
    wget -q $sdk_filename -O android-sdk-tools.zip
    unzip -qo android-sdk-tools.zip -d ${android_home}
    rm android-sdk-tools.zip
    PATH=${android_home}/tools:${android_home}/tools/bin:${android_home}/platform-tools:${PATH}
    # Silence warning.
    mkdir -p ~/.android
    touch ~/.android/repositories.cfg
    # install correct version of java on osx
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ $(java -version 2>&1) != *"java version \"1.8."* ]]; then
            echo Install java ??
            # skip brew update
#            HOMEBREW_NO_AUTO_UPDATE=1
#            brew cask uninstall java; brew tap caskroom/versions; brew cask install java8;
        fi
    fi
    # Accept licenses before installing components, no need to echo y for each component
    yes | sdkmanager --licenses
    # install android tools
    sdkmanager "emulator" "tools" "platform-tools" > /dev/null
    sdkmanager --list | head -15

    echo To use this sdk set ANDROID_HOME with:
    echo export ANDROID_HOME=${android_home}
    echo Set PATH with:
    echo export PATH=${android_home}/tools:${android_home}/tools/bin:${android_home}/platform-tools:\${PATH}

}

# installs experimental emulator to canary directory
install_canary_emulator(){
    emulator_version=$1
    android_home=$2
    # get canary emulator file id
    case $emulator_version in
        28.1.9-1)
            emulator_version_id=5346014
            ;;
        *)
            echo Unknown canary emulator: $emulator_version
            show_help
            ;;
    esac
    # EMULATOR_VERSION=5329922
    if [[ "$OSTYPE" == "darwin"* ]]; then
      wget -q "https://dl.google.com/android/repository/emulator-darwin-$emulator_version_id.zip" -O emulator.zip
    else
      sudo apt-get install -y libunwind8 libc++1
      wget -q "https://dl.google.com/android/repository/emulator-linux-$emulator_version_id.zip" -O emulator.zip
    fi
    # delete existing emulator
    rm -rf $android_home/emulator
    unzip -qo emulator.zip -d ${android_home}
    rm emulator.zip
}

# creates, starts and stops emulator to generate default snapshot
create_hot_emulator(){
    emu_name=$1
    emu_sys=$2
    emu_abi=$3
    screen_size=$4
    android_home=$5
    [ -z $6 ] || is_canary=$?

    # set path
#    PATH=${android_home}/emulator:${android_home}/tools:${android_home}/tools/bin:${android_home}/platform-tools:${PATH}
#    PATH=${android_home}/emulator:${android_home}/tools/bin:${PATH}

    # download avd system images
#    "platforms;android-<api_level>"
#    sdkmanager "system-images;android-$emu_sys;$emu_abi" > /dev/null
#    sdkmanager --list | head -15

    # create emulator
#    if [ -d ~/.android/avd/$emu_name.avd ]; then
#        avdmanager delete avd -n $emu_name
#    fi
#    echo no | avdmanager create avd -n $emu_name -k "system-images;android-$emu_sys;$emu_abi" --force --device "Nexus 6P" -c 100M -p $PWD/.android/avd/$emu_name.avd
    echo no | avdmanager create avd --force --name $emu_name --abi google_apis/x86 --package "system-images;android-$emu_sys;$emu_abi" --device "Nexus 6P" -c 100M -p $PWD/.android/avd/$emu_name.avd
    # fix timezone warning on osx
#    if [[ "$OSTYPE" == "darwin"* ]]; then
#        sudo ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime;
#    fi
exit 1

    # start emulator
    if [ $is_canary ]; then
        emu_command="emulator/emulator-headless"
    else
        emu_command="emulator/emulator"
    fi
      #  - EMU_DEBUG="-debug all -logcat *:e -verbose -show-kernel"
      #  - EMU_ADDITIONAL_OPTIONS="-memory 2048"
#    emu_options="-no-window  -no-audio -camera-back none -camera-front none"
#    emu_options="-no-accel -no-audio -camera-back none -camera-front none"
#-use-system-libs
    emu_options="-no-snapshot-load -no-audio -camera-back none -camera-front none -no-boot-anim"
#    if [[ $emu_abi =~ "x86" ]]; then
##      emu_command="emulator/emulator-headless -no-accel"
##      emu_command="emulator/emulator"
#      emu_additional_options="-gpu swiftshader_indirect"
##      emu_additional_options="-gpu swiftshader"
#    else
##      emu_command="emulator/emulator"
#      emu_additional_options="-gpu swiftshader"
#    fi
#    export ANDROID_HOME=$android_home
#    export ANDROID_SDK_ROOT=$android_home
#    $android_home/$emu_command -avd $emu_name $emu_options $emu_additional_options $emu_debug &
    (cd $android_home/emulator; emulator -avd $emu_name $emu_options $emu_additional_options $emu_debug & )

    # wait for emulator to startup
#    script/android-wait-for-emulator.sh

    # shutdown emulator
#    adb emu kill

}

# start an emulator that has been snapshotted with all options preset
# found in the avd directory
start_hot_emulator(){
    emu_name=$1
    android_home=$2
    if ! [ -d ~/.android/avd/$emu_name.avd ]; then
        echo Unknown emulator: $emu_name
        show_help
    fi
#    case $emu_name in
#        Nexus_5X)
#            ;;
#        *)
#            echo Unknown emulator: $emu_name
#            show_help
#            ;;
#    esac

    PATH=${android_home}/emulator:${android_home}/tools/bin:${PATH}
    PATH=${android_home}/emulator:${PATH}
    export ANDROID_EMULATOR_HOME=.android
#    export ANDROID_AVD_HOME=$ANDROID_EMULATOR_HOME/avd # this is the default
    $android_home/emulator/emulator -avd $emu_name -no-snapshot-save -no-accel -no-boot-anim
}

# move avd created by Android Studio
move_avd(){
    avd_name=$1
    dst_dir=$2
#    android_home=$3

#    PATH=${android_home}/tools/bin:${PATH}

#    export ANDROID_EMULATOR_HOME=.android
#    export ANDROID_HOME=$android_home
    which avdmanager
    avdmanager list avd
    avdmanager move avd -n $avd_name -p $dst_dir

}

rename_avd(){
    avd_name=$1
    avd_new_name=$2
    android_home=$3

    PATH=${android_home}/tools/bin:${PATH}

    export ANDROID_EMULATOR_HOME=.android
    export ANDROID_AVD_HOME=$ANDROID_EMULATOR_HOME/avd
    export ANDROID_HOME=$android_home
    which avdmanager
    avdmanager list avd
#    avdmanager move avd -n $avd_name -r $avd_new_name

}

# if no command passed
if [ -z $1 ]; then show_help; fi

case $1 in
    --install-android-tools)
        if [ -z $2 ]; then
            echo Argument error: no android version specified
            show_help;
        fi
        if [ -z $3 ]; then
            echo Argument error: no android home specified
            show_help;
        fi
        install_android_tools $2 $3
        ;;
    --install-canary-emulator)
        if [ -z $2 ]; then
            echo Argument error: no canary emulator version specified
            show_help;
        fi
        if [ -z $3 ]; then
            echo Argument error: no android home specified
            show_help;
        fi
        install_canary_emulator $2 $3
        ;;
    --create-hot-emulator)
        if [[ -z $2 || -z $3 || -z $4 || -z $5 || -z $6 ]]; then
            echo Argument error
            show_help;
        fi
        create_hot_emulator $2 $3 $4 $5 $6
        ;;
    --start-hot-emulator)
        if [[ -z $2 || -z $3 ]]; then
            echo Argument error
            show_help;
        fi
        start_hot_emulator $2 $3
        ;;
    --move-avd)
        if [[ -z $2 || -z $3 ]]; then
            echo Argument error
            show_help;
        fi
        move_avd $2 $3
        ;;
    --rename-avd)
        if [[ -z $2 || -z $3 || -z $4 ]]; then
            echo Argument error
            show_help;
        fi
        rename_avd $2 $3 $4
        ;;
    *)
        echo Unknown command: $1
        show_help
        ;;
esac