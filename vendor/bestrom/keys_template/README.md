# bestrom-priv keys (template)

Mirror of VoltageOS `vendor/voltage-priv/keys`:

1. Create private repo or local path `vendor/bestrom-priv/keys`
2. Copy Voltage/Lineage-style `keys.sh` + `make_key.sh` + `keys.mk`
3. Run `./keys.sh` once per build machine
4. Never commit real `.pk8` secrets to a public repo

Public template only — generate secrets offline.
