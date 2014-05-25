# Copyright 2011 The Android Open Source Project

ifneq ($(BUILD_TINY_ANDROID),true)

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	bettercharger.c

ifeq ($(strip $(BOARD_CHARGER_DISABLE_INIT_BLANK)),true)
LOCAL_CFLAGS := -DCHARGER_DISABLE_INIT_BLANK
endif

ifeq ($(strip $(BOARD_CHARGER_ENABLE_SUSPEND)),true)
LOCAL_CFLAGS += -DCHARGER_ENABLE_SUSPEND
endif

LOCAL_MODULE := bettercharger
LOCAL_MODULE_TAGS := optional
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)/system/bettercharger
LOCAL_UNSTRIPPED_PATH := $(TARGET_ROOT_OUT_UNSTRIPPED)

LOCAL_C_INCLUDES := $(call include-path-for, recovery)

LOCAL_STATIC_LIBRARIES := libminui libpixelflinger_static libpng
ifeq ($(strip $(BOARD_CHARGER_ENABLE_SUSPEND)),true)
LOCAL_STATIC_LIBRARIES += libsuspend
endif
LOCAL_STATIC_LIBRARIES += libz libstdc++ libcutils liblog libm libc

ifneq ($(BOARD_BATTERY_DEVICE_NAME),)
LOCAL_CFLAGS += -DBATTERY_DEVICE_NAME=\"$(BOARD_BATTERY_DEVICE_NAME)\"
endif

ifeq ($(BOARD_SAMSUNG_DEVICE),true)
LOCAL_CFLAGS += -DSAMSUNG_DEVICE
endif

ifeq ($(BOARD_IMAGES_ON_SYSTEM),true)
LOCAL_CFLAGS += -DIMAGES_ON_SYSTEM
endif

ifeq ($(FORCE_REBOOT_WHEN_FULL),true)
LOCAL_CFLAGS += -DFORCE_REBOOT_WHEN_FULL
endif

ifeq ($(BOARD_ALLOW_SUSPEND_IN_CHARGER),true)
LOCAL_CFLAGS += -DALLOW_SUSPEND_IN_CHARGER
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
LOCAL_MODULE_PATH := $$(TARGET_ROOT_OUT)/system/bettercharger/images
include $$(BUILD_PREBUILT)
endef

_img_modules :=
_images :=
ifneq ($(BOARD_CHARGER_RES),)
$(foreach _img, $(call find-subdir-subdir-files, ../../../$(BOARD_CHARGER_RES), "*.png"), \
  $(eval $(call _add-bettercharger-image,$(_img))))
else
$(foreach _img, $(call find-subdir-subdir-files, "images", "*.png"), \
  $(eval $(call _add-bettercharger-image,$(_img))))
endif

include $(CLEAR_VARS)
LOCAL_MODULE := bettercharger_system_bettercharger_images
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(_img_modules)
include $(BUILD_PHONY_PACKAGE)

_add-bettercharger-image :=
_img_modules :=

endif
