# Phone product glue — mirror vendor/voltage/config/common_full_phone.mk pattern

$(call inherit-product, vendor/bestrom/config/common.mk)

# Telephony is expected from device:
# $(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
