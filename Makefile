export ARCHS = arm64

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = Pikabu Preferences

include $(THEOS_MAKE_PATH)/aggregate.mk
