include $(THEOS)/makefiles/common.mk

TARGET = iphone:clang:9.3:latest

BUNDLE_NAME = PikabuSettings

PikabuSettings_FILES = preferences.mm PikabuBehaviourListController.m PikabuColorListController.m
PikabuSettings_INSTALL_PATH = /Library/PreferenceBundles
PikabuSettings_FRAMEWORKS = UIKit
PikabuSettings_PRIVATE_FRAMEWORKS = Preferences
PikabuSettings_CFLAGS = -I../include

include $(THEOS_MAKE_PATH)/bundle.mk
