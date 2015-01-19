# Copyright 2011 The Android Open Source Project

# Available flags
#    BOARD_ALLOW_SUSPEND_IN_BETTERCHARGER
#    BOARD_BATTERY_DEVICE_NAME
#    BOARD_BETTERCHARGER_DISABLE_INIT_BLANK
#    BOARD_BETTERCHARGER_ENABLE_SUSPEND
#    BOARD_BETTERCHARGER_RES
#    BOARD_IMAGES_ON_SYSTEM
#    FORCE_REBOOT_WHEN_FULL
#    BOARD_SAMSUNG_DEVICE

ifneq ($(BUILD_TINY_ANDROID),true)

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	bettercharger.c

ifeq ($(strip $(BOARD_BETTERCHARGER_DISABLE_INIT_BLANK)),true)
LOCAL_CFLAGS := -DBETTERCHARGER_DISABLE_INIT_BLANK
endif

ifeq ($(strip $(BOARD_BETTERCHARGER_ENABLE_SUSPEND)),true)
LOCAL_CFLAGS += -DBETTERCHARGER_ENABLE_SUSPEND
endif

LOCAL_MODULE := bettercharger
LOCAL_MODULE_TAGS := optional
LOCAL_FORCE_STATIC_EXECUTABLE := true
ifeq ($(strip $(BOARD_IMAGES_ON_SYSTEM)),true)
# Binary files on /system
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)/system/bettercharger
else
# Binary files on /recovery
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)
endif

LOCAL_UNSTRIPPED_PATH := $(TARGET_ROOT_OUT_UNSTRIPPED)

LOCAL_C_INCLUDES := $(call project-path-for, recovery)

LOCAL_STATIC_LIBRARIES := libminui libpixelflinger_static libpng
ifeq ($(strip $(BOARD_BETTERCHARGER_ENABLE_SUSPEND)),true)
LOCAL_STATIC_LIBRARIES += libsuspend
endif
LOCAL_STATIC_LIBRARIES += libz libstdc++ libcutils liblog libm libc

ifneq ($(BOARD_BATTERY_DEVICE_NAME),)
LOCAL_CFLAGS += -DBATTERY_DEVICE_NAME=\"$(BOARD_BATTERY_DEVICE_NAME)\"
endif

ifeq ($(strip $(BOARD_SAMSUNG_DEVICE)),true)
LOCAL_CFLAGS += -DSAMSUNG_DEVICE
endif

ifeq ($(strip $(FORCE_REBOOT_WHEN_FULL)),true)
LOCAL_CFLAGS += -DFORCE_REBOOT_WHEN_FULL
endif

ifeq ($(strip $(BOARD_ALLOW_SUSPEND_IN_BETTERCHARGER)),true)
LOCAL_CFLAGS += -DALLOW_SUSPEND_IN_BETTERCHARGER
endif

ifeq ($(strip $(BOARD_IMAGES_ON_SYSTEM)),true)
LOCAL_CFLAGS += -DIMAGES_ON_SYSTEM
endif

include $(BUILD_EXECUTABLE)

define _add-bettercharger-image
include $$(CLEAR_VARS)
LOCAL_MODULE := system_core_bettercharger_$(notdir $(1))
LOCAL_MODULE_STEM := $(notdir $(1))
_img_modules += $$(LOCAL_MODULE)
LOCAL_SRC_FILES := $1
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
ifeq ($(strip $(BOARD_IMAGES_ON_SYSTEM)),true)
# Binary files on /system
LOCAL_MODULE_PATH := $$(TARGET_ROOT_OUT)/system/bettercharger/images
else
# Binary files on /recovery
LOCAL_MODULE_PATH := $$(TARGET_ROOT_OUT)/res/images
endif
include $$(BUILD_PREBUILT)
endef

_img_modules :=
_images :=
ifneq ($(BOARD_BETTERCHARGER_RES),)
$(foreach _img, $(call find-subdir-subdir-files, ../../../$(BOARD_BETTERCHARGER_RES), "*.png"), \
  $(eval $(call _add-bettercharger-image,$(_img))))
else
$(foreach _img, $(call find-subdir-subdir-files, "images", "*.png"), \
  $(eval $(call _add-bettercharger-image,$(_img))))
endif

include $(CLEAR_VARS)
LOCAL_MODULE := bettercharger_res_images
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(_img_modules)
include $(BUILD_PHONY_PACKAGE)

_add-bettercharger-image :=
_img_modules :=

endif
