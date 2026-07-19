<p align="center">
  <img src="https://raw.githubusercontent.com/Mohithash/bestrom-project/main/brand/logo/bestrom-icon.jpg" width="96" alt="BestROM" />
</p>

# android_vendor_bestrom

**BestROM** product vendor for **pure AOSP Android 17** (`vendor/bestrom` in tree).

## Philosophy

**Battery is the most important feature. Pure dark by default.**  
Modern Android spends too much on cosmetic skins, animations, artworks, and placebo effects — that tax steals **smoothness**, **fluidity**, and **battery juice**.

BestROM’s product layer stays **light and AOSP-compliant**: **pure black** UI, **Nothing-like monochrome** (**grey dotted** marks only — **no brand violet/cyan**), thrifty defaults.

> *Black. Grey dots. Ultra minimal. More battery. Still Android — pure AOSP 17.*

Full story: [bestrom-project/docs/PHILOSOPHY.md](https://github.com/Mohithash/bestrom-project/blob/main/docs/PHILOSOPHY.md)

## Layout (VOS-aligned structure, AOSP soul)

```
config/
  common.mk              # brand, battery/dark props, overlays, backuptool
  common_full_phone.mk
  packages.mk            # minimal PRODUCT_PACKAGES
  version.mk
  BoardConfigBestROM.mk
build/
  envsetup.sh
  tasks/bacon.mk
overlay/                 # dark color tokens, brand RRO
prebuilt/common/
bootanimation/           # black-led (media later)
device_example/
keys_template/
```

## Inherit

```make
$(call inherit-product, vendor/bestrom/config/common_full_phone.mk)
```

## Design kit

- [Philosophy](https://github.com/Mohithash/bestrom-project/blob/main/docs/PHILOSOPHY.md)  
- [Design system](https://github.com/Mohithash/bestrom-project/blob/main/design/DESIGN_SYSTEM.md)  
- [Battery UI](https://github.com/Mohithash/bestrom-project/blob/main/docs/BATTERY_UI.md)  
- [Branding kit](https://github.com/Mohithash/bestrom-project/tree/main/brand)  

## Branches

| Branch | Meaning |
|--------|---------|
| `17` | Android 17 AOSP BestROM |
| `16.2` | Experimental |
| `main` | Default |

## License

Apache-2.0 for BestROM original files.
