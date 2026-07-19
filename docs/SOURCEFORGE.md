# SourceForge (BestROM project)

**Project:** [bestrom](https://sourceforge.net/projects/bestrom/)  
**Peridot folder:** https://sourceforge.net/projects/bestrom/files/peridot/  

**WIP A17 OTA (uploaded 2026-07-19):**  
https://sourceforge.net/projects/bestrom/files/peridot/bestrom_peridot-ota.zip/download  

Also present on SF: Voltage unofficial zip, `index.html` landing assets under `peridot/`.

## One-time setup

1. Create account: https://sourceforge.net/user/registration  
2. Create project e.g. `bestrom-a17-peridot` (or use an existing one)  
3. Enable **File management** / FRS  
4. Create an SSH key and add it under Account → SSH keys  
5. Note your **Unix username** (often same as SF login)

## Upload (Windows OpenSSH)

```powershell
$ota = "C:\Users\HP\Documents\bestrom_peridot-ota.zip"
$user = "YOUR_SF_UNIX_USERNAME"
$project = "bestrom-a17-peridot"   # project unix name
# path: /home/frs/project/<project>/
scp $ota "${user}@frs.sourceforge.net:/home/frs/project/${project}/"
```

Or interactive SFTP:

```text
sftp YOUR_SF_UNIX_USERNAME@frs.sourceforge.net
cd /home/frs/project/bestrom-a17-peridot
put bestrom_peridot-ota.zip
bye
```

## Public URL form

```text
https://sourceforge.net/projects/PROJECT/files/bestrom_peridot-ota.zip/download
```

Add that URL to the Downloads table in `README.md`.

## Why both GitHub + SourceForge?

| | GitHub Release | SourceForge |
|--|----------------|-------------|
| Tied to this repo | Yes | Optional |
| Large files | OK (within limits) | Excellent for big ROMs |
| Auth we already had | Yes (`gh`) | Needs your SF account |
