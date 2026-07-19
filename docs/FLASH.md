# Flashing guide

## Prerequisites

- Unlocked bootloader
- [platform-tools](https://developer.android.com/tools/releases/platform-tools) (`fastboot`)
- [payload-dumper-go](https://github.com/ssut/payload-dumper-go)
- ~15 GB free disk for extract
- USB data cable (prefer USB 2.0 port if sparse flash fails)

## Voltage OS (known good recovery)

```powershell
.\scripts\flash_from_ota.ps1 `
  -OtaZip "C:\path\to\voltage-....zip" `
  -WorkDir ".\extract-voltage"
```

Expect first boot setup after wipe (several minutes on logo is normal).

## BestROM OTA

```powershell
.\scripts\flash_from_ota.ps1 `
  -OtaZip "C:\path\to\bestrom_peridot-ota.zip" `
  -WorkDir ".\extract-bestrom" `
  -SkipTinyModem
```

If fastbootd never shows `is-userspace: yes` after BestROM vendor_boot:

1. Flash a known-good `vendor_boot` (Voltage) + reboot fastboot  
2. Flash BestROM `system` `system_ext` `product` `vendor` `odm` `*_dlkm`  
3. Flash BestROM boot/dtbo/vendor_boot/init_boot/vbmeta  
4. Wipe userdata  

## Manual checklist

```text
fastboot devices
fastboot getvar is-userspace   # no = bootloader, yes = fastbootd

# bootloader
fastboot flash boot boot.img
fastboot flash dtbo dtbo.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash init_boot init_boot.img
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_system vbmeta_system.img
# firmware: abl xbl modem ... (skip <8KB stubs)

fastboot reboot fastboot
fastboot getvar is-userspace   # MUST be yes

fastboot flash system system.img
fastboot flash system_ext system_ext.img
fastboot flash product product.img
fastboot flash vendor vendor.img
fastboot flash odm odm.img
fastboot flash system_dlkm system_dlkm.img
fastboot flash vendor_dlkm vendor_dlkm.img

fastboot -w
# or OFox Format Data
fastboot reboot
```

## Verify ROM after flash (from OFox)

Mount system, then:

```bash
adb shell grep -E "ro.build.flavor|ro.voltage|ro.bestrom" /system_root/system/build.prop
```

Ignore recovery’s own `getprop ro.build.display.id` (shows fox_*).
