# BestROM versioning — mirror of vendor/voltage/config/version.mk (structure only)
BESTROM_VERSION := 17.0
BESTROM_ANDROID := 17
BESTROM_CODENAME := Aurora
BESTROM_BUILD_DATE := $(shell date -u +%Y%m%d)
BESTROM_BUILD_TYPE ?= UNOFFICIAL

BESTROM_DISPLAY_VERSION := $(BESTROM_VERSION)-$(BESTROM_BUILD_TYPE)-$(BESTROM_BUILD_DATE)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.bestrom.version=$(BESTROM_VERSION) \
    ro.bestrom.android=$(BESTROM_ANDROID) \
    ro.bestrom.codename=$(BESTROM_CODENAME) \
    ro.bestrom.display.version=$(BESTROM_DISPLAY_VERSION) \
    ro.bestrom.build.type=$(BESTROM_BUILD_TYPE) \
    ro.bestrom.build.date=$(BESTROM_BUILD_DATE) \
    ro.bestrom.device=$(TARGET_DEVICE) \
    ro.bestrom.base=aosp-17
