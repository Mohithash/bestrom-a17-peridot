# Patterns from other peridot (and SM8635) developers

**Scope:** GitHub device trees for POCO F6 / Redmi Turbo 3 (`peridot`), SoC **SM8635**, platform **`pineapple`**, CAF **`sm8650` / SKU cliffs**.  
**Surveyed:** 2026-07-19 (~125 `device_xiaomi_peridot` repos; active maintainers below).

Related: [GUIDIXX_PORT_METHOD.md](GUIDIXX_PORT_METHOD.md) (Voltage / CLO deep dive).

---

## 1. Who is shipping what (ecosystem map)

| Maintainer / org | Product | Branch | Kernel style | Notes |
|------------------|---------|--------|--------------|--------|
| **[LineageOS](https://github.com/LineageOS/android_device_xiaomi_peridot)** | LOS 23.2 (A16) | `lineage-23.2` | Full GKI triple | **Canonical upstream**; wiki build guide |
| **[GuidixX](https://github.com/GuidixX/device_xiaomi_peridot)** | VoltageOS | `16.2` | Full GKI triple | Official Voltage; stock OS3.0.6 extract |
| **[crdroidandroid](https://github.com/crdroidandroid/android_device_xiaomi_peridot)** | crDroid 12 / 16.0 | `16.0` | Full GKI triple | “Based on Official Lineage”; GitLab kernel too |
| **[Evolution-X-Devices](https://github.com/Evolution-X-Devices/device_xiaomi_peridot)** | EvoX | `bka` | Full GKI triple | **EROFS** vendor/odm; file-based module loads |
| **[sm8635-dev](https://github.com/sm8635-dev/device_xiaomi_peridot)** | YAAP | `sixteen` | Full GKI triple | SoC-named org; EROFS + compress hints; shims/ |
| **[Blazing-Forest](https://github.com/Blazing-Forest/device_xiaomi_peridot)** | LOS forks | `lineage-23.2` / `16-qpr2` | Full triple | Own modules/DT forks |
| **[AetheriaOS-Devices](https://github.com/AetheriaOS-Devices)** | Aetheria | `aetheria-1.0` | Full triple | Own kernel/modules/DT forks |
| **[SwapnilVicky](https://github.com/SwapnilVicky/android_device_xiaomi_peridot)** | Waterlily | `waterlily` | Full triple | Custom ROM brand |
| **[TheXPerienceProject](https://github.com/TheXPerienceProject/android_device_xiaomi_peridot)** | XPE 20.2 | `xpe-20.2` | Full triple | |
| **[peridot-dev](https://github.com/peridot-dev)** | LOS ecosystem | `lineage-23.2` | Full triple | Shared camera/kernel hubs |
| **[AzzyC](https://github.com/AzzyC/ofox_device_xiaomi_peridot)** | OrangeFox | `fox_14.1` | Recovery tree | Not a full ROM DT |
| **[khargosxh18](https://github.com/khargosxh18)** | sakura-16.3 + prebuilt | various | Often prebuilt Image | **Outlier** — prebuilt-oriented forks |

Almost every **bootable daily-driver ROM** (LOS / Voltage / crDroid / Evo / YAAP) uses the **same CLO skeleton**. Prebuilt-only trees exist but are edge cases (custom kernels like Theettam AnyKernel, not full bacon).

---

## 2. Universal SoC patterns (what everyone agrees on)

### 2.1 Partition / boot layout (GKI)

```text
boot          header v4   → kernel Image only (empty ramdisk)
init_boot     header v4   → system ramdisk
vendor_boot               → vendor ramdisk + fstab + DTB + 1st-stage modules
dtbo
system_dlkm / vendor_dlkm → GKI + vendor modules
super: system, system_ext, product, vendor, odm, *_dlkm
```

Flags seen **everywhere**:

```make
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_BOOT_HEADER_VERSION := 4
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_USES_QCOM_MERGE_DTBS_SCRIPT := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
TARGET_NEEDS_DTBOIMAGE := true
BOARD_RAMDISK_USE_LZ4 := true
TARGET_BOARD_PLATFORM := pineapple
BOARD_USES_QCOM_HARDWARE := true
```

### 2.2 Kernel config fragment stack

```make
TARGET_KERNEL_SOURCE := kernel/xiaomi/sm8635
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/pineapple_GKI.config \
    vendor/peridot_GKI.config
TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm8635-modules
```

**WLAN path is always** `qcacld-3.0/.qca6750` (not a random chip).

### 2.3 CAF / HAL stack

| Piece | Path / name |
|-------|-------------|
| Audio HAL | `hardware/qcom-caf/sm8650/audio/primary-hal` |
| Audio SKU | `sku_cliffs` / `sound_trigger.primary.pineapple` |
| PAL / AGM | `TARGET_PROVIDES_AUDIO_HAL`, `LIBAGM`, `LIBAR_PAL` |
| Display | QTI composer/allocator (sm8650 family) |
| Sepolicy base | `device/qcom/sepolicy_vndr` |
| Xiaomi HALs | `hardware/xiaomi` |

### 2.4 Dependencies JSON (Lineage-style) — **always three kernel repos**

**Lineage `lineage.dependencies`:**

```json
hardware/xiaomi
kernel/xiaomi/sm8635
kernel/xiaomi/sm8635-devicetrees
kernel/xiaomi/sm8635-modules
```

**crDroid `crdroid.dependencies`:** same triple + **vendor** + **miuicamera** (+ Dolby/BCR extras).

**GuidixX `voltage.dependencies`:** same triple under VoltageOS-Devices remotes + vendor + hardware/xiaomi.

**No serious maintainer** ships bacon with only `kernel/…` and no modules/DTs.

### 2.5 AVB (test-key bring-up pattern)

```make
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true
# per-chain: boot, recovery, vbmeta_system → testkey_rsa2048
```

### 2.6 Cmdline / bootconfig staples

| Flag | Who |
|------|-----|
| `androidboot.hardware=qcom` | All |
| `androidboot.usbcontroller=a600000.dwc3` | All |
| `androidboot.load_modules_parallel=true` | All |
| `androidboot.vendor.qspa=true` | All |
| `sysctl.kernel.firmware_config.force_sysfs_fallback=1` | GuidixX, crDroid, LOS, Evo |
| `androidboot.init_fatal_reboot_target=recovery` | Evo, YAAP (safer debug) |
| RCU expedite / lazy tweaks | GuidixX, YAAP |

### 2.7 Shipping API

```make
BOARD_SHIPPING_API_LEVEL := 34   # device launched on A14
```

Kept by GuidixX/Voltage even on A16 ROMs — standard for Treble.

---

## 3. Where maintainers **diverge** (useful forks of the same base)

### 3.1 Module load list style

| Style | Trees | How |
|-------|--------|-----|
| **A. Kernel + device lists** | GuidixX, LOS, crDroid | `modules.list.msm.pineapple` + `modules.list.first_stage` / `second_stage` / `vendor_dlkm` |
| **B. Device-local load files** | Evolution-X, YAAP (sm8635-dev) | `modules.load.vendor_boot`, `.vendor_dlkm`, `.system_dlkm`, `.recovery` + blocklists under `configs/modules/` |

Both still **compile** modules from `sm8635-modules`. Style B is easier to edit without touching kernel tree.

### 3.2 Filesystem type

| FS | Trees |
|----|--------|
| **ext4** all dynamic | LOS, GuidixX/Voltage, crDroid |
| **erofs** vendor/odm/system | Evolution-X, YAAP (`BOARD_EROFS_COMPRESSOR := lz4`, compress hints) |

EROFS is a size/perf choice, not required for boot.

### 3.3 Xiaomi extras

| Feature | Pattern |
|---------|---------|
| **MiuiCamera** | Separate `device/xiaomi/peridot-miuicamera` + vendor; optional `-include` BoardConfig |
| **UDFPS** | `udfps/` + Xiaomi fingerprint V2 soong config |
| **Sensor notifier** | In-tree `sensors/` helper (GuidixX/Voltage, others) |
| **XiaomiParts / Dolby / Viper** | Product-level; optional |
| **Shims** | YAAP/sm8635-dev has dedicated `shims/`; Evo patches camera GraphicBuffer |

### 3.4 Sepolicy completeness

| | |
|--|--|
| **Enforcing + device te** | LOS, GuidixX, crDroid, Evo, YAAP |
| **Strip device sepolicy** | BestROM WIP only (known anti-pattern for “boot later”) |

### 3.5 CPU variant tuning (cosmetic / ART)

- LOS/crDroid: `kryo300` runtime  
- Evo: `cortex-a76` / armv8-2a-dotprod  
- YAAP: `kryo785` / armv9-2a  

Does not change GKI/module strategy.

### 3.6 Recovery packaging

- Many include **`recovery`** in `AB_OTA_PARTITIONS` (LOS, crDroid, Evo, YAAP).  
- `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true` is universal (recovery uses vendor_boot modules).

---

## 4. Lineage official build workflow (gold standard process)

From [wiki.lineageos.org/devices/peridot/build](https://wiki.lineageos.org/devices/peridot/build/variant1/):

1. `repo init` **lineage-23.2**  
2. `breakfast peridot` → pulls DT + **kernel triple** via dependencies  
3. **`./extract-files.py`** from a device already on that LOS (or extract from zip)  
4. `brunch peridot`  

Implications for BestROM:

- Blobs are **not invented** — extracted from a **matching** running build or stock/LOS zip.  
- Kernel is never optional for breakfast.  
- Vendor lives in `vendor/xiaomi/peridot` generated by extract scripts.

---

## 5. Same-SoC note (SM8635 / pineapple)

Public GitHub is **dominated by peridot** for this chip. Other SM8635 codenames are rare in open trees; the reusable SoC layer is already abstracted as:

```text
kernel configs:  pineapple_GKI + peridot_GKI
modules root:    sm8635-modules (qcom opensource + xiaomi + nxp)
CAF:             sm8650 (pineapple family)
audio sku:       cliffs
```

So “port from same SoC” ≈ **copy peridot’s CLO triple + replace only device-specific** (DT overlays, panels, camera sensors, NFC, fingerprint, overlays, prop SKUs). There is no separate large “pineapple common” tree like `sm8250-common` for most ROMs — commonality is **inside the kernel/modules repos**.

---

## 6. Anti-patterns (seen rarely / avoid)

| Anti-pattern | Why it fails |
|--------------|--------------|
| Prebuilt `Image` only, clear `TARGET_KERNEL_EXT_MODULES` | Empty/tiny `vendor_dlkm` / ramdisk modules → logo loop |
| Disable all device sepolicy to “boot first” | Hides denials; GuidixX/LOS fix labels instead |
| Skip VINTF forever | OTA packaging may work; runtime HAL death |
| Flash stub modem from incomplete radio packaging | No signal / boot oddities |
| Mix A17 system with A16 vendor without VINTF work | Classic Treble break |
| OFox-sideload A/B payload only | Incomplete apply (BestROM notes) |

**khargosxh18 prebuilt** and **Theettam AnyKernel** are valid as **kernel swaps on a working ROM**, not as a substitute for building modules into a new ROM.

---

## 7. Consensus checklist for a bootable peridot ROM (any Android major)

Copy this; every major maintainer effectively follows it:

- [ ] `TARGET_BOARD_PLATFORM := pineapple`  
- [ ] GKI header v4 boot + init_boot + vendor_boot  
- [ ] `kernel/xiaomi/sm8635` + **`-modules`** + **`-devicetrees`** in sync  
- [ ] `TARGET_KERNEL_EXT_MODULES` full qcom opensource list + nxp (+ xiaomi drivers if present)  
- [ ] Module load lists (style A or B) non-empty  
- [ ] `hardware/qcom-caf/sm8650` audio/display manifests  
- [ ] `hardware/xiaomi` + `device/qcom/sepolicy_vndr` + device sepolicy dirs  
- [ ] Vendor extract from **known-good** stock or LOS zip (`extract-files.py`)  
- [ ] Real firmware images (SHA-pinned) — never 4K stubs  
- [ ] AVB flags 3 / test keys for unofficial  
- [ ] `force_sysfs_fallback=1` (or equivalent firmware access)  
- [ ] Prefer `userdebug` until first UI boot; pstore on failure  

---

## 8. What BestROM should steal from *which* tree

| Need | Prefer |
|------|--------|
| Cleanest base / official process | **LineageOS** `lineage-23.2` |
| Closest “CLO + stock HyperOS” daily | **GuidixX** Voltage `16.2` |
| Module load files easy to edit | **Evolution-X** / **YAAP** style `modules.load.*` |
| Official A16 product packaging | **crDroid** `crdroid.dependencies` |
| Camera extras | GuidixX / crDroid / LOS `peridot-miuicamera` forks |
| Custom kernel Image only | Theettam **on top of** a ROM that already has matching dlkm |

---

## 9. Links (quick)

| | |
|--|--|
| LOS DT | https://github.com/LineageOS/android_device_xiaomi_peridot |
| LOS kernel | https://github.com/LineageOS/android_kernel_xiaomi_sm8635 |
| LOS wiki build | https://wiki.lineageos.org/devices/peridot/build/variant1/ |
| GuidixX DT | https://github.com/GuidixX/device_xiaomi_peridot/tree/16.2 |
| crDroid DT | https://github.com/crdroidandroid/android_device_xiaomi_peridot/tree/16.0 |
| Evo DT | https://github.com/Evolution-X-Devices/device_xiaomi_peridot/tree/bka |
| YAAP / sm8635-dev | https://github.com/sm8635-dev/device_xiaomi_peridot/tree/sixteen |

---

## 10. One-line synthesis

**Across Lineage, Voltage/GuidixX, crDroid, Evolution-X, and YAAP, bootable peridot always means the same SM8635 CLO triple (kernel + modules + DTs), sm8650 CAF, pineapple platform, stock-aligned vendor extract, and live sepolicy — differences are mostly EROFS, module list file layout, and camera extras. BestROM’s gap is not “missing a secret A17 flag”; it is departing from this consensus stack.**
