# Technical notes — BestROM A17 peridot

## Build environment (original)

- Server: ServerHive-style Linux builder (expired/ephemeral)
- Tree: BestROM A17 (`bestrom-a17`)
- Lunch: `bestrom_peridot-trunk_staging-user`
- Policy: incremental `m bacon`, no `make clean` during bring-up
- Disk: large `out/` (~85G) during build

## Packaging

- OTA type: **A/B** (`payload.bin` only) — not a classic recovery `update-binary` zip
- Signed with **test-keys**
- VINTF compatibility check was soft-skipped for packaging (`BESTROM_SKIP_VINTF` / `CheckVintfIfTrebleEnabled` stub) because device manifest vs framework matrix was INCOMPATIBLE after stubbing HALs
- Radio firmware: `vendor/xiaomi/peridot/Android.mk` originally used `add-radio-file-sha1-checked` which **does not exist** on this AOSP tree; fixed to `add-radio-file`

## AVB

- `BOARD_AVB_ENABLE := true`
- `BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3` (disable verification + verity on top vbmeta)
- Flash both `vbmeta` and `vbmeta_system` with `--disable-verity --disable-verification`

## Kernel

- Theettam prebuilt Image wired via `theettam_kernel.mk` / `TARGET_PREBUILT_KERNEL`
- Prebuilt dtb/dtbo included
- `boot.img` header v4: kernel only, **empty** ramdisk
- `init_boot` holds system ramdisk; `vendor_boot` holds vendor ramdisk + fstab + DTB

## Sepolicy

- Device-specific Xiaomi sepolicy dirs were **disabled** (boot-first) after incomplete sepolicy errors
- Still includes `device/qcom/sepolicy_vndr`
- Long-term: re-enable and fix denials; short-term debug: `userdebug` + permissive

## Major bring-up tradeoffs (boot-first)

- WFD modules disabled (AIDL conflicts)
- Various QTI camera AIDL service-impl / offline / aon paths reduced
- HIDL interface shared_libs stripped from many prebuilts; `check_elf_files: false` on vendor prebuilts
- `lib_driver_cmd_qcwcn`: sole nop stub with P2P symbols (real caf sources need netlink includes)
- Empty/stub modem in OTA payload historically (~4KB) — **do not flash** those stubs
- `system_dlkm` / `vendor_dlkm` in BestROM payload were unusually small vs Voltage

## Flash method that worked for Voltage

1. `payload-dumper-go` extract all imgs  
2. Bootloader: boot, dtbo, vendor_boot, init_boot, vbmeta×2, firmware  
3. `fastboot reboot fastboot` → **must** show `is-userspace: yes`  
4. Flash system, system_ext, product, vendor, odm, dlkm  
5. Erase userdata/metadata or OFox Format Data  
6. Reboot system  

## BestROM-specific flash issue

- After flashing BestROM `vendor_boot`, `fastboot reboot fastboot` often returned **bootloader** (`is-userspace: no`), so logical partitions could not be written.
- Workaround: flash **Voltage** (or other known-good) `boot`+`vendor_boot` → enter fastbootd → flash BestROM logical imgs → flash BestROM boot chain → wipe → reboot.

## Boot status

- Full image flash of BestROM was eventually completed once (logical + boot + wipe).
- Stable UI boot was **not** confirmed as a daily driver; logo loop still possible (kernel/modules/sepolicy/HAL).
- Voltage 5.11 EOL Official (20260718) **does** boot with the image flash method.

## Next debug if logo loops after full flash

1. Immediately recovery/OFox before overwriting  
2. `adb pull /sys/fs/pstore` and/or `last_kmsg`  
3. Grep: panic, AVB, mount, init, SELinux  
4. Rebuild `userdebug`, permissive sepolicy, fix dlkm/kernel alignment  
