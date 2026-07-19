#!/bin/bash
# BestROM helpers for AOSP 17 (product-release-variant)

_bestrom_pick_release() {
  local r
  for r in trunk_staging bp2a cp2a ap4a ap3a next canary; do
    if [ -d "build/release/flag_values/$r" ] || [ -f "build/release/release_configs/${r}.textproto" ] || [ -d "build/release/build_config/$r" ]; then
      echo "$r"
      return 0
    fi
  done
  if [ -d build/release/flag_values ]; then
    ls build/release/flag_values 2>/dev/null | head -1
    return 0
  fi
  if [ -d build/release/release_configs ]; then
    ls build/release/release_configs 2>/dev/null | sed 's/\.textproto$//' | head -1
    return 0
  fi
  echo "trunk_staging"
}

bestrom_lunch() {
  local device="${1:-peridot}"
  local variant="${2:-user}"
  local release
  release="$(_bestrom_pick_release)"
  echo "bestrom_lunch: bestrom_${device}-${release}-${variant}"
  lunch "bestrom_${device}-${release}-${variant}"
}

bestrom_brunch() {
  local device="${1:-peridot}"
  bestrom_lunch "$device" user || return 1
  m bacon -j${BESTROM_JOBS:-$(nproc)}
}

echo "BestROM: bestrom_lunch [device] [variant] · bestrom_brunch [device]"
