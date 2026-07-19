# Current progress (2026-07-19)

## Summary

BestROM A17 for **POCO F6 (peridot)** was brought to a **buildable** state on a cloud builder. An official-style **A/B OTA** and full partition images were produced. **Stable boot to Android UI was not confirmed** as a daily driver. **VoltageOS 5.11 EOL** was used successfully as a recovery ROM via image flash.

| Item | Status |
|------|--------|
| Source builds (`m bacon`) | Done |
| OTA zip produced | Done (~2 GB A/B payload) |
| Device tree + BestROM stubs saved | Done (this repo) |
| Flash method documented | Done |
| Boot to setup / UI | Not confirmed |
| Product-ready ROM | No |

## What works

1. **Full platform build** for `bestrom_peridot-trunk_staging-user` (incremental bacon, test-keys).
2. **Artifacts**: `bestrom_peridot-ota.zip` + target_files `IMAGES/` (boot, vendor_boot, init_boot, system, vendor, odm, …).
3. **Install path proven on device** (with VoltageOS): extract payload → bootloader flash → **fastbootd** logical partitions → wipe → reboot.
4. **This repo** preserves device tree, `vendor/bestrom` stubs, autofix history, and flash scripts for continued work after the build server expires.

## What does not work / known issues

1. **OFox sideload of A/B OTA alone** is unreliable for this zip type (incomplete apply → logo loop).
2. **BestROM `vendor_boot`** often fails to enter **fastbootd** (`is-userspace: no` after `fastboot reboot fastboot`). Workaround: temporary known-good vendor_boot (e.g. Voltage) to enter fastbootd, flash BestROM system/vendor/…, then BestROM boot chain.
3. **Boot logo loop** still possible after full image flash — needs `pstore` / `last_kmsg` for root cause (kernel / dlkm / sepolicy / init).
4. **Modem** images in BestROM payload were stub-sized at times — do not flash tiny modem imgs.
5. **system_dlkm / vendor_dlkm** much smaller than Voltage — suspect for module-related boot issues.
6. **Device sepolicy** largely disabled (qcom sepolicy_vndr kept) — boot-first tradeoff.
7. Many QTI paths stubbed/disabled (WFD, some camera AIDL, HIDL strips) — boot-first / build-unblock.
8. **VINTF** packaging check skipped for OTA generation.

## Kernel

- Prebuilt **Theettam 2.1** `Image` + dtb/dtbo under `device/xiaomi/peridot/prebuilt/`.
- GKI layout: kernel in `boot`, ramdisk in `init_boot`, vendor ramdisk + DTB in `vendor_boot`.

## Flash (short)

See [FLASH.md](FLASH.md). High level:

```text
payload-dumper-go OTA
fastboot flash boot/dtbo/vendor_boot/init_boot + vbmeta (disable verity)
fastboot reboot fastboot   # need is-userspace: yes
fastboot flash system system_ext product vendor odm *_dlkm
wipe userdata / Format Data
fastboot reboot
```

## Repo contents

- `device/xiaomi/peridot/` — device tree used for the build  
- `vendor/bestrom/` — stubs, bacon packaging helpers, overlays  
- `scripts/flash_from_ota.ps1` — automated extract + flash  
- `autofix_log.json` — chronological build fixes  
- `docs/` — NOTES, FLASH, PROGRESS, SourceForge notes  

## Not in this repo

- Full AOSP/BestROM platform tree  
- `out/`  
- Xiaomi proprietary vendor dump (still required to rebuild)  
- Guaranteed bootable daily driver  

## Next steps for a bootable BestROM

1. Long-lived build machine (or large local disk) + `repo sync`.  
2. Overlay this `device/` + `vendor/bestrom`.  
3. Prefer `userdebug` + capture boot logs.  
4. Full image flash; on logo loop pull pstore immediately.  
5. Fix kernel/modules/sepolicy/HALs from logs; re-enable sepolicy gradually.  
6. Ship real modem/dlkm; fix fastbootd in BestROM vendor_boot.

## Related

- Release tag: [v0.1-wip](https://github.com/Mohithash/bestrom-a17-peridot/releases/tag/v0.1-wip) (OTA asset when upload completes)  
- VoltageOS used as reference recovery ROM (flash method), not part of BestROM source.  
