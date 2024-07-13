#!/bin/bash

make clean
make
cd ./.theos/obj/debug/PikabuSettings.bundle
/Users/jeffrey/Downloads/jtool/jtool -e arch -arch arm64 PikabuSettings
/Users/jeffrey/Downloads/jtool/jtool --sign --ent ~/platform.ent --inplace PikabuSettings.arch_arm64
rm PikabuSettings
mv PikabuSettings.arch_arm64 PikabuSettings
cd ../

sshpass -p "<----password---->" scp -r PikabuSettings.bundle root@192.168.1.108:/bootstrap/Library/PreferenceBundles

cd ./arm64
/Users/jeffrey/Downloads/jtool/jtool --sign --ent ~/platform.ent --inplace Pikabu.dylib
#/Users/jeffrey/Downloads/jtool/jtool --sign --ent ~/platform.ent --inplace PikabuUIKit.dylib

sshpass -p "<----password---->" scp Pikabu.dylib root@192.168.1.108:/bootstrap/Library/SBInject
cd ../../../
sshpass -p "<----password---->" ssh -l root 192.168.1.108 "killall 9 SpringBoard"
