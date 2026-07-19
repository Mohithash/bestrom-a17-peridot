# BestROM packages — keep minimal until A17 boots (VOS-style list lives here later)
# Mirror: vendor/voltage/config/packages.mk

# AOSP defaults already pull many apps via full_base_telephony / mainline.
# Add BestROM-owned packages only when repos exist in the tree.

PRODUCT_PACKAGES += \
    LatinIME

# When ready, uncomment / add:
# PRODUCT_PACKAGES += \
#     BestROMSetupWizard \
#     ThemePicker \
#     ExactCalculator

# Official OTA only when you have a channel
# ifeq ($(BESTROM_BUILD_TYPE),OFFICIAL)
# PRODUCT_PACKAGES += Updater
# endif

# Camera: use AOSP Camera2 / Aperture fork only after bring-up
# ifneq ($(PRODUCT_NO_CAMERA),true)
# PRODUCT_PACKAGES += Camera2
# endif
