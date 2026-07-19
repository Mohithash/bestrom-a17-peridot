# Why some devs keep full source on a laptop

## Short answer

They keep the **entire AOSP/ROM tree + `out/`** locally so builds don’t depend on a rented server that can expire, get wiped, or go offline. The laptop *is* the build machine (or a clone of it).

## What “keeping source” usually means

Not just the GitHub device-tree repo. Typically:

```text
~/android/bestrom-a17/     # full repo sync (80–300+ GB)
  .repo/
  frameworks/ base/ ...
  device/xiaomi/peridot/   # your changes (also on GitHub)
  vendor/...
  out/                     # build products (50–150+ GB)
```

| On GitHub (this repo) | On laptop / big disk |
|----------------------|----------------------|
| Device tree, stubs, docs | Full platform source |
| Flash scripts, notes | `out/` incremental builds |
| OTA as Release asset | Local bacon / ccache |

## Why they do it

1. **No server expiry** — ServerHive/VPS ends → tree gone unless archived. Laptop disk is yours.  
2. **Incremental builds** — Second `m bacon` is much faster if `out/` stays. Cloud rebuilds from zero are painful.  
3. **Offline / control** — Work without SSH, quota fights, or noisy neighbors.  
4. **Debug cycle** — Change sepolicy → rebuild module → flash image is tighter when everything is local.  
5. **ccache** — Tens of GB of compiler cache pay off only if the machine is stable long-term.

## Cost / requirements

| Resource | Practical minimum for A17 |
|----------|---------------------------|
| Disk | **500 GB–1 TB+ free** (source + out + ccache) |
| RAM | **32 GB** comfortable (16 GB painful) |
| CPU | 8+ cores helps; still slower than big cloud boxes |
| Time | First sync/build can be many hours |

If the laptop is weak, people still keep the **tree** on an external NVMe and only use cloud for heavy builds — then **rsync patches + out** carefully.

## How this GitHub repo fits

| Workflow | Role of GitHub |
|----------|----------------|
| Day to day on laptop | Commit device/`vendor/bestrom` changes → push |
| Server dies | Clone this repo onto new machine, drop into a fresh `repo sync` tree |
| Share with other devs | They don’t need your full `out/`; they need **your deltas + docs** |
| Testers | Download OTA from Releases / SourceForge |

So: **laptop = full kitchen**; **GitHub = recipe card + special ingredients you invented**. Both matter.

## Recommendation for you

1. Keep this GitHub repo (done).  
2. Keep OTA on Releases (+ SourceForge if you want).  
3. If you continue BestROM: put a full tree on a **large local disk** or a **long-lived** VPS you control — not a 1-day hire that wipes tomorrow.  
4. You do **not** need full source on the laptop *only* to preserve work if GitHub + OTA + NOTES are solid — but for real bring-up speed, local (or dedicated) source wins.
