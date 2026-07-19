# How GuidixX ports peridot (CLO-based) — lessons for BestROM A17

**Sources reviewed (2026-07-19):**

| Repo | Role |
|------|------|
| [GuidixX/device_xiaomi_peridot](https://github.com/GuidixX/device_xiaomi_peridot) `16.2` | Device tree (VoltageOS official maintainer) |
| [GuidixX/vendor_xiaomi_peridot](https://github.com/GuidixX/vendor_xiaomi_peridot) `16.2` | Proprietary vendor |
| [GuidixX/kernel_xiaomi_sm8635](https://github.com/GuidixX/kernel_xiaomi_sm8635) `16.2` | GKI kernel (CLO/QCOM) |
| [VoltageOS-Devices/kernel_xiaomi_sm8635](https://github.com/VoltageOS-Devices/kernel_xiaomi_sm8635) `16` | Same family, used via `voltage.dependencies` |
| `sm8635-modules` + `sm8635-devicetrees` | **Required** module + DT companions |
| [Mohithash/kernel_xiaomi_sm8635](https://github.com/Mohithash/kernel_xiaomi_sm8635) Theettam | Custom Image **forked/merged from GuidixX CLO** |

GuidixX does **not** ship a pure “drop A16 tree on A17 and hope” zip. He keeps a **full CLO GKI stack** + **stock HyperOS extract** + **ROM product** (Voltage), and re-extracts / re-labels every major stock bump.

---

## 1. Stack architecture (what “CLO source” means here)

Peridot is **SM8635** (Snapdragon 8s Gen 3), board platform name **`pineapple`**, audio/display SKU **`cliffs`**, CAF HALs under **`hardware/qcom-caf/sm8650`**.

GuidixX’s `voltage.dependencies` (branch `16.2`) always pulls **three** kernel repos + vendor + Xiaomi HALs:

```text
vendor/xiaomi/peridot              ← proprietary from stock OTA
hardware/xiaomi                    ← shared Xiaomi HALs
kernel/xiaomi/sm8635               ← GKI Image + module load lists
kernel/xiaomi/sm8635-modules       ← out-of-tree Qualcomm/Xiaomi .ko tree
kernel/xiaomi/sm8635-devicetrees   ← DTB merge (BOARD_USES_QCOM_MERGE_DTBS_SCRIPT)
```

**Rule he never breaks:** kernel `Image` and `vendor_dlkm` / first-stage modules are **built together** from the same CLO tree.  
Theettam release notes even say AnyKernel only replaces `Image` and **keeps stock/ROM `vendor_dlkm`** — confirming modules are half the boot story.

### BoardConfig kernel pattern (GuidixX / Lineage / Voltage)

```make
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_BOOT_HEADER_VERSION := 4          # boot = kernel only
BOARD_INIT_BOOT_HEADER_VERSION := 4     # init_boot = system ramdisk
# vendor_boot = vendor ramdisk + fstab + DTB + first-stage modules

TARGET_KERNEL_SOURCE := kernel/xiaomi/sm8635
TARGET_KERNEL_CONFIG := gki_defconfig vendor/pineapple_GKI.config vendor/peridot_GKI.config
TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm8635-modules
TARGET_KERNEL_EXT_MODULES := \
    qcom/opensource/mmrm-driver \
    … display / audio / wlan / camera / touch / xiaomi drivers …
```

Module **load order** is explicit:

- `BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD` ← first stage (from kernel tree lists)
- `BOARD_VENDOR_KERNEL_MODULES_LOAD` ← second stage + vendor_dlkm list
- `BOARD_SYSTEM_KERNEL_MODULES_LOAD` ← system_dlkm GKI modules

---

## 2. Port history (branch model)

| Branch | Meaning | Notes |
|--------|---------|--------|
| `15` | Earlier A15-era tree | Older product |
| `16` / `sixteen` | Android 16 bring-up | Voltage product |
| **`16.2`** | Current (default) | HyperOS **OS3.0.6.0.WNPMIXM** extract; force-push warning |
| experimental | `inline`, `sepol`, `thermal`, `power`, … | Topic branches, squashed into 16.2 |

There is **no public GuidixX A17 / BestROM branch** yet. A16→A17 would be another stock extract + CAF/GKI bump, not a zip repack.

### Product makefile fingerprint (stock-aligned)

From `voltage_peridot.mk`:

```text
BuildFingerprint=POCO/peridot_global/peridot:16/BP2A.250605.031.A3/OS3.0.6.0.WNPMIXM:user/release-keys
```

Blobs header:

```text
# extracted from peridot OS3.0.6.0.WNPMIXM - peridot_global-ota_full-OS3.0.6.0.WNPMIXM
```

Firmware (`proprietary-firmware.txt`) pins **SHA1** for modem, abl, xbl, tz, … from the **same** full OTA.

**Method:** every major bump = re-run extract from new stock full OTA, commit “Update from OSx.x.x.x”.

---

## 3. What his commits show about *how* he ports

Recent `16.2` work is incremental CLO/device hygiene, not magic:

| Theme | Examples |
|-------|----------|
| **Stock re-extract** | `peridot: Update from OS3.0.6.0.WNPMIXM` |
| **Kernel module lists** | `modules: Simplify kernel modules list` |
| **Boot cmdline** | `force_sysfs_fallback=1` via cmdline (firmware sysfs) |
| **Sepolicy** | Label thermal, camera, denials — **policy stays on** |
| **Camera ABI** | Patch `camera.xiaomi.so` GraphicBuffer size; shims then **reverted** when fixed properly |
| **Thermal** | Drop `mi_thermald` → **AIDL thermal HAL**; dump thermal-engine |
| **Init/rootdir** | Stop wrong ownership on cpufreq; remove test apps; post-boot thermal perms |
| **Power** | powerhint INTERACTION / Expensive Rendering tweaks |
| **Build-from-source** | `Build libvmmem from source` (don’t stub forever) |
| **Upstream picks** | Commits authored by ArianK16a, AdarshGrewal, mikeNG — LOS/CAF community |

Pattern: **boot with full stack first**, then fix denials/blobs; do **not** disable whole device sepolicy or empty module trees to force a bacon.

---

## 4. CAF / CLO pieces he depends on (platform side)

Beyond device tree:

- `hardware/qcom-caf/common` + **`hardware/qcom-caf/sm8650`** (audio primary-hal, display, …)
- `device/qcom/sepolicy_vndr`
- QTI boot HAL, USB, thermal, display composer/allocator services
- `BOARD_USES_QCOM_HARDWARE := true`, platform `pineapple`
- Virtual A/B + **vendor_ramdisk** (`launch_with_vendor_ramdisk.mk`)
- GKI partitions: `boot`, `init_boot`, `vendor_boot`, `system_dlkm`, `vendor_dlkm`

Audio is **PAL/AGM** (`TARGET_PROVIDES_AUDIO_HAL`, `sound_trigger.primary.pineapple`), SKU path `sku_cliffs`.

---

## 5. BestROM A17 vs GuidixX — gap analysis

| Area | GuidixX (boots Voltage) | BestROM A17 WIP (logo risk) |
|------|-------------------------|-----------------------------|
| Kernel | Full CLO tree + modules + DTs **compiled in bacon** | Prebuilt **Theettam Image only**; `TARGET_KERNEL_SOURCE` / `EXT_MODULES` **cleared** |
| vendor_dlkm / system_dlkm | Real sizes from module build | Documented **tiny/empty** vs Voltage |
| vendor_boot | Built with first-stage modules + fstab + DTB | Fastbootd often broken (`is-userspace: no`) |
| Sepolicy | Device + qcom sepolicy **enabled** | Device sepolicy **commented out** (boot-first tradeoff) |
| Vendor blobs | Fresh extract OS3.0.6.0.WNPMIXM | Depends on whatever was on the build server; stubs for missing pieces |
| VINTF | Expected to match | Soft-skipped for packaging |
| Product | VoltageOS 16 | Pure AOSP BestROM 17 + many HAL stubs |
| Modem | Full stock radio images | Stub-sized modem historically — **must not flash** |

Theettam is valuable (GuidixX CLO + root), but **Image-only without matching modules in the ROM** is the opposite of GuidixX’s bacon path.

---

## 6. How GuidixX would approach A17 (inferred playbook)

There is no public A17 tree yet; this is the method consistent with his A15→A16 work:

1. **Wait for / pick CLO GKI** tag that matches Android 17 framework expectations (or keep 6.1 GKI if still valid for that vendor interface generation).
2. **Bump** `kernel` + `modules` + `devicetrees` together (never Image alone in the full ROM).
3. **New stock full OTA** (when HyperOS A17 exists for peridot) → `extract-files.py` → new `proprietary-files.txt` / firmware SHAs.
4. **Keep shipping API** (`BOARD_SHIPPING_API_LEVEL := 34`) unless Google requires otherwise.
5. **CAF sm8650** / VINTF manifests: fix matrix, don’t skip forever.
6. **Sepolicy:** fix denials with audit2allow; don’t delete device policy.
7. **userdebug** first; capture `pstore` / `last_kmsg` on logo loop.
8. Product makefile: new fingerprint from stock; Voltage/BestROM branding on top.

Until stock A17 + matching CLO exist, people usually **stay on A16 Voltage/Lineage** rather than hybrid A17 system + A16 vendor (VINTF death).

---

## 7. What BestROM must do for a *bootable* zip (GuidixX-aligned)

### Rebuild (only real path to “BestROM A17 boots”)

On a machine with full tree:

```text
1. repo sync BestROM A17 + hardware/qcom-caf/sm8650 + device/qcom/sepolicy_vndr
2. device/xiaomi/peridot  ← this repo, BUT restore GuidixX-style kernel block:
     - do NOT clear TARGET_KERNEL_SOURCE / EXT_MODULES for bacon
     - either:
         A) build GuidixX/VoltageOS-Devices sm8635 + modules + DTs (branch 16.2 / 16), or
         B) use Theettam only as Image override AFTER modules still built from matching CLO modules tree
3. vendor/xiaomi/peridot ← GuidixX 16.2 extract (or re-extract OS3.0.6.0.WNPMIXM)
4. Re-enable device sepolicy; fix remaining denials
5. lunch bestrom_peridot-…-userdebug
6. m bacon
7. Flash with scripts/flash_from_ota.ps1 (full images, real modem, Format Data)
```

### Do **not** expect

- Repacking the current ~2 GB BestROM OTA with Voltage `system`/`vendor` into a true “A17 BestROM” without rebuild.
- Image-only Theettam AnyKernel on top of broken BestROM dlkm to magically fix first boot (helps only if base ROM already had correct modules).

### Hybrid debug only (not a product zip)

- Voltage **vendor_boot** to enter fastbootd, flash BestROM logicals, then BestROM boot chain — already documented in `FLASH.md`.
- Prefer Voltage daily driver until BestROM rebuild has real dlkm.

---

## 8. Key URLs

- Device: https://github.com/GuidixX/device_xiaomi_peridot/tree/16.2  
- Vendor: https://github.com/GuidixX/vendor_xiaomi_peridot/tree/16.2  
- Kernel: https://github.com/GuidixX/kernel_xiaomi_sm8635  
- Voltage downloads: https://www.voltageos.com/devices/download/peridot  
- Lineage reference tree: https://github.com/LineageOS/android_device_xiaomi_peridot/tree/lineage-23.2  
- Theettam (your kernel): https://github.com/Mohithash/kernel_xiaomi_sm8635/releases  

---

## 9. One-sentence takeaway

**GuidixX ports by CLO GKI triple (kernel+modules+DT) + stock HyperOS full-OTA extract + full sepolicy, rebuilt every stock bump — not by prebuilt Image and disabled policy.** BestROM must copy that bacon path before the zip can be bootable.
