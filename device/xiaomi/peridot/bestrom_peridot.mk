#
# BestROM — pure AOSP Android 17 product for peridot
#
BESTROM_BUILD := true
BESTROM_BUILD_TYPE ?= UNOFFICIAL
BESTROM_VERSION ?= 17.0.0-UNOFFICIAL

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

$(call inherit-product-if-exists, vendor/bestrom/config/common_full_phone.mk)
$(call inherit-product-if-exists, vendor/bestrom/config/common.mk)

$(call inherit-product, device/xiaomi/peridot/device.mk)

PRODUCT_NAME := bestrom_peridot
PRODUCT_DEVICE := peridot
PRODUCT_BRAND := BestROM
PRODUCT_MODEL := POCO F6
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_SYSTEM_NAME := peridot_global
PRODUCT_SYSTEM_DEVICE := peridot

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildFingerprint=BestROM/peridot/peridot:17/CP2A.260605.016/eng.bestrom:user/release-keys \
    DeviceName=peridot \
    DeviceProduct=peridot_global

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
TARGET_BOOT_ANIMATION_RES := 2560

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.bestrom.build=1 \
    ro.bestrom.ui.theme=dark \
    ro.bestrom.battery.first=1


# BestROM boot-first: allow OTA packaging despite incomplete vendor VINTF
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false
# BestROM_VINTF_SKIP
