# HOW TO PREPARE IT

In case of Samsung devices using CM11:

- Requires edit "CM11/android/device/samsung/smdk4412-common/BoardCommonConfig.mk" adding:

	```bash
	...
	#Charging mode
	BOARD_CHARGING_MODE_BOOTING_LPM := /sys/class/power_supply/battery/batt_lp_charging
	BOARD_BATTERY_DEVICE_NAME := "battery"
	BOARD_ALLOW_SUSPEND_IN_BETTERCHARGER := true
	BOARD_SAMSUNG_DEVICE := true
	BOARD_IMAGES_ON_SYSTEM := true
	FORCE_REBOOT_WHEN_FULL := true
	...
	```

- Requires edit "CM11/android/device/samsung/smdk4412-common/common.mk" adding/replacing:

	```bash
	...
	#Charger
	PRODUCT_PACKAGES += \
		bettercharger \
		bettercharger_res_images
	...
	```
	
	NOTE: By default CM not use "charger" for Samsung devices, it use private binary blobs playlpm

- Requires edit "CM11/android/device/samsung/i9300/BoardConfig.mk" adding/replacing:

	```bash
	...
	#Charging mode
	BOARD_BETTERCHARGER_RES := device/samsung/i9300/bettercharger/images
	...
	```

- Create folders "bettercharger/images" on "CM11/android/device/samsung/i9300/"

NOTE: We don't modify lpm.rc because all prior ROMs use private playlpm binary, and we use the same path for this reason.

# HOW TO COMPILE IT

By default charger is integrated on recovery for Nexus devices, maybe its required compile it the first time:

	THREADS=1
	croot
	time make recoveryimage showcommands -j${THREADS}

And the rest compilations, you can only compile bettercharger:

	THREADS=1
	cd ~/CM11/android
	source build/envsetup.sh
	breakfast i9300
	export USE_CCACHE=1
	cd system/core/bettercharger/
	time mm

The compiled output must be in:
	~/CM11android/out/target/product/i9300/root/system/bettercharger
Using the same structure that goes to internal memory

But for correct execution we need to replace the original binary "/system/bin/playlpm" with a script like this:

	#!/system/bin/sh
	mkdir -p /res/images
	/system/bettercharger/bettercharger
	
The "mkdir" line is a "workaround" because ower binary expects to find this folder in recovery, but we don't use this folder.
