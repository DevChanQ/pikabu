export ARCHS = arm64

MODULES = jailed
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PikabuUIKit

PikabuUIKit_FILES = Tweak.xm
PikabuUIKit_FRAMEWORKS = UIKit CoreGraphics QuartzCore Foundation AVFoundation
PikabuUIKit_LIBRARIES = substrate
PikabuUIKit_CFLAGS = -I../include

include $(THEOS_MAKE_PATH)/tweak.mk
