# BestROM: prebuilt Theettam Kernel 2.1 → $(PRODUCT_OUT)/kernel
# https://github.com/Mohithash/kernel_xiaomi_sm8635/releases/tag/v2.1
# Single rule only — do not also BUILD_PREBUILT a module named kernel.
THEETTAM_IMAGE := device/xiaomi/peridot/prebuilt/Image

ifeq ($(wildcard $(THEETTAM_IMAGE)),)
$(error Theettam prebuilt Image missing at $(THEETTAM_IMAGE))
endif

# Provide the path AOSP packaging/VINTF expect. Do NOT redefine INSTALLED_KERNEL_TARGET
# if main.mk already set it — only add the recipe if missing.
ifndef THEETTAM_KERNEL_RULE_ADDED
THEETTAM_KERNEL_RULE_ADDED := true

$(PRODUCT_OUT)/kernel: $(THEETTAM_IMAGE)
	@echo "Installing Theettam prebuilt kernel: $< -> $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -f $< $@
	$(hide) chmod 0644 $@

endif
