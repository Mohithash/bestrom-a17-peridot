# BestROM prebuilt DTB/DTBO (LineageOS peridot vendor_boot / dtbo)
THEETTAM_DTB := device/xiaomi/peridot/prebuilt/dtb.img
THEETTAM_DTBO := device/xiaomi/peridot/prebuilt/dtbo.img
ifneq ($(wildcard $(THEETTAM_DTB)),)
$(PRODUCT_OUT)/dtb.img: $(THEETTAM_DTB)
	@echo "Installing prebuilt dtb.img"
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -f $< $@
endif
ifneq ($(wildcard $(THEETTAM_DTBO)),)
BOARD_PREBUILT_DTBOIMAGE := $(THEETTAM_DTBO)
endif
