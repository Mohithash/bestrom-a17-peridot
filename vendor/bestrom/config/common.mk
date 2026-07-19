# BestROM common product layer — structure aligned with vendor/voltage/config/common.mk
# Path in tree: vendor/bestrom/config/common.mk

PRODUCT_BRAND ?= BestROM
PRODUCT_COMPANY ?= BestROM

$(call inherit-product-if-exists, vendor/bestrom/config/version.mk)
$(call inherit-product-if-exists, vendor/bestrom/config/packages.mk)

# Pure dark by default — battery-first AMOLED product intent.
# Wire real Settings/SystemUI night-mode + RROs at bring-up; these mark product policy.
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.build.software.version=BestROM \
    ro.product.system.brand=BestROM \
# BestROM: do not override manufacturer (device is Xiaomi; avoids build.prop dup)
#    ro.product.system.manufacturer=BestROM \
    ro.bestrom.ui.theme=dark \
    ro.bestrom.ui.theme.default=dark \
    ro.bestrom.ui.battery_first=1 \
    ro.bestrom.ui.canvas=black \
    ro.bestrom.ui.pure_dark=1 \
    ro.carrier=unknown \
    ro.com.android.dataroaming=false \
    ro.storage_manager.enabled=true \
    persist.sys.disable_rescue=true

# Hint dark mode when the platform reads this (verify on A17 device trees)
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.ui_night_mode=2

ifeq ($(TARGET_BUILD_VARIANT),eng)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.strictmode.disable=true
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += log.tag=I
endif

# Material / expressive (AOSP 16+ style flag; harmless if ignored)
PRODUCT_PRODUCT_PROPERTIES += is_expressive_design_enabled=true

# Overlays (RRO)
PRODUCT_PACKAGE_OVERLAYS += vendor/bestrom/overlay

# Backuptool (OTA / dirty flash) — scripts under prebuilt/common/bin
PRODUCT_COPY_FILES += \
    vendor/bestrom/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/bestrom/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions

# Wallpapers / media placeholders
PRODUCT_COPY_FILES += \
    vendor/bestrom/prebuilt/common/etc/permissions/privapp-permissions-bestrom.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-bestrom.xml

# Signing keys (optional include — generate with keys.sh)
ifeq ($(BESTROM_BUILD_TYPE),OFFICIAL)
-include vendor/bestrom-priv/keys/keys.mk
else
-include vendor/bestrom-priv/keys/keys.mk
endif

TARGET_BOOT_ANIMATION_RES ?= 1080

# Early bring-up (device BoardConfig may also set these)
# BUILD_BROKEN_DUP_RULES := true
