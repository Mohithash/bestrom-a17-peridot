# Optional: bacon target convenience (VOS has vendor/voltage/build/tasks/bacon.mk)
# Device/ROM may rely on AOSP otapackage instead.

.PHONY: bacon
bacon: otapackage
	$(hide) echo "BestROM package built (otapackage)."
