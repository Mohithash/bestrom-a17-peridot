# BestROM A17 · peridot (POCO F6) — WIP

**Status (2026-07-19):** Builds a full A17 OTA + images. **Boot to Android UI not confirmed.**  
VoltageOS 5.11 EOL boots with the same image-flash method and was used for recovery.

**Progress report:** [docs/PROGRESS.md](docs/PROGRESS.md)

This repository is for **continuing bring-up from source**: device tree, BestROM stubs, notes, and flash scripts. It is **not** a full AOSP mirror and **not** a finished daily-driver ROM.

## What is in this repo

| Path | Purpose |
|------|---------|
| `device/xiaomi/peridot/` | Device tree changes (Theettam kernel, BoardConfig, sepolicy toggles, radio packaging) |
| `vendor/bestrom/` | Soong stubs and BestROM packaging helpers |
| `docs/` | Boot failure notes, flash guide, autofix summary |
| `scripts/` | Local fastboot/payload flash helpers (**no server secrets**) |
| `autofix_log.json` | Chronological log of build fixes applied during bring-up |

## Downloads (OTA)

| Host | Link |
|------|------|
| **GitHub Releases** | [v0.1-wip — `bestrom_peridot-ota.zip`](https://github.com/Mohithash/bestrom-a17-peridot/releases/tag/v0.1-wip) |
| **SourceForge** | *(optional mirror — see `docs/SOURCEFORGE.md` to publish)* |

Flash with [`scripts/flash_from_ota.ps1`](scripts/flash_from_ota.ps1) / [`docs/FLASH.md`](docs/FLASH.md).  
**WIP:** not a confirmed daily driver.

## What is **not** in this repo

- Full AOSP / BestROM source tree (sync with your own manifest)
- `out/` build intermediates
- Multi‑GB OTA/images live in **Releases** / SourceForge (not git history)
- Xiaomi proprietary blobs (obtain via extract / your vendor dump)
- SSH passwords or server credentials

## How this helps next time (work from source)

1. **New server / PC**  
   - Repo-sync AOSP 17 + BestROM + device/vendor blobs as usual.  
   - Overlay or cherry-pick `device/xiaomi/peridot` and `vendor/bestrom` from this repo.  
   - Apply any extra patches under `patches/` if present.

2. **Skip rediscovering failures**  
   - Read `docs/NOTES.md` and `autofix_log.json` for sepolicy, WFD, qcwcn, radio `add-radio-file`, VINTF packaging, etc.

3. **Flash without OFox-only OTA**  
   - A/B `payload.bin` zips need **image extract + bootloader + fastbootd**.  
   - Use `scripts/flash_from_ota.ps1` (same path that restored VoltageOS).

4. **Known BestROM install pitfalls**  
   - BestROM `vendor_boot` may fail to enter **fastbootd** (`is-userspace: no`).  
     Workaround: temporarily use a known-good `vendor_boot` (e.g. Voltage) to enter fastbootd, flash logical partitions, then flash BestROM boot chain.  
   - Do **not** flash BestROM `modem.img` if it is a tiny stub; keep stock/Voltage modem.  
   - Always flash `vbmeta` / `vbmeta_system` with verity/verification disabled for test-keys builds.  
   - **Format Data** after first full flash.

## Build (high level)

```bash
# On a synced BestROM A17 tree with device + vendor present:
source build/envsetup.sh
lunch bestrom_peridot-trunk_staging-user   # or -userdebug for bring-up
m bacon -j$(nproc)
```

Artifacts:

- `out/target/product/peridot/bestrom_peridot-ota.zip`
- `out/target/product/peridot/obj/PACKAGING/target_files_intermediates/.../IMAGES/*.img`

## Flash (Windows example)

```powershell
# Requires: platform-tools (fastboot), payload-dumper-go
.\scripts\flash_from_ota.ps1 -OtaZip "C:\path\to\bestrom_peridot-ota.zip" -WorkDir ".\extract"
```

Phone must be unlocked and in **bootloader** fastboot first.

## Kernel

- Prebuilt **Theettam 2.1** `Image` + `dtb.img` / `dtbo.img` under `device/xiaomi/peridot/prebuilt/` (when present in tree export).
- GKI-style boot: `boot` (kernel), `init_boot` (ramdisk), `vendor_boot` (vendor ramdisk + DTB).

## License

- Scripts and documentation: Apache-2.0 (see `LICENSE`) unless noted.
- Device/vendor code may include third-party licenses (AOSP Apache-2.0, Qualcomm, Xiaomi proprietary).  
  **Do not treat proprietary blobs as free to redistribute** without rights.

## Disclaimer

Unofficial WIP. Flashing can brick; unlock bootloader at your own risk. Not affiliated with Xiaomi/POCO.
