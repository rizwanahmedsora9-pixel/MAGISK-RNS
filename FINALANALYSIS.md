# MAGISK-RNS — FINAL ANALYSIS

> **Master consolidated document.** Prepared 2026-09-25 · Branch `arena/01a0d7dc-magisk-rns` · Base commit `9bdf11bf`
>
> **Reading status: 20 / 20 files read — nothing left unread.** (Full inventory in §2.)
> This file supersedes and corrects the earlier `DOCUMENTATION.md`; where the two disagree, trust this one.

---

## 1. What this repository is (one paragraph)

This is **not a software project**. It is the complete evidence trail and design journal for one real-world goal:

> **Take full root-level control of the Wi-Fi hotspot on a rooted Infinix HOT 8 (MediaTek MT6765, Android 9) and force it to broadcast a permanent open network named `RNS` on 2.4 GHz channel 6 with a raised client limit — then build a voucher / captive-portal billing layer on top of it.**

Everything was captured live on the phone between **2026-09-23 and 2026-09-25** (Pakistan time, carrier **Jazz**), using **Termux + `su` + Magisk 30.7**. The deliverables are: (a) the evidence/log dumps, and (b) the `RNS_Hotspot.zip` Magisk module.

The newly added file `RNS - Rooted Hotspot Billing App.md` (16 820 lines / 329 KB) is the **complete verbatim ChatGPT transcript of the entire project** — it is the single most important document in the repo and is the source for most of the conclusions below.

---

## 2. COMPLETE FILE INVENTORY — every file, read

### 2.1 Documentation
| # | File | Size | Role | Read |
|---|---|---|---|---|
| 1 | `README.md` | 544 B | Stub entry point pointing at `DOCUMENTATION.md` | ✅ |
| 2 | `DOCUMENTATION.md` | 18 KB | Earlier full analysis + "the real position" (§6) + approach decision (§9) | ✅ |
| 3 | `RNS - Rooted Hotspot Billing App.md` | **329 KB / 16 820 lines** | **NEW — the full project transcript** (idea → recon → manual AP → stock-hotspot reverse engineering → Magisk module → install logs) | ✅ |

### 2.2 Deliverable
| # | File | Size | Role | Read |
|---|---|---|---|---|
| 4 | `RNS_Hotspot.zip` | 1 164 B | **The Magisk module (v1.0)** — contains `module.prop` + `service.sh` at zip root | ✅ (extracted & inspected) |

### 2.3 Config / evidence artifacts
| # | File | Size | Role | Read |
|---|---|---|---|---|
| 5 | `ap_backup.conf` | 438 B | Backup of the live `/data/vendor/wifi/hostapd/hostapd_ap0.conf` (open AP on `ap0`, hex SSID = "Infinix HOT 8", channel 157, `hw_mode=a`, `max_num_sta=10`) | ✅ |
| 6 | `hotspot_report.txt` | 65 KB | Phase-1 capability report (device, driver modules, interfaces, iptables chains, routes) | ✅ |
| 7 | `hotspot_files.txt` | 1.4 KB | Inventory of every hotspot-related path on the phone | ✅ |

### 2.4 Session logs (chronological story)
| # | File | Size | Phase | Read |
|---|---|---|---|---|
| 8 | `Hoyspot test 1.txt` | 32 KB | **P1 — Recon + first manual AP attempt.** Termux pkgs installed; `iw list` proves AP mode; `/vendor/bin/hw/hostapd`, `/system/bin/dnsmasq`, `iptables v1.6.1` located; manual kit built in `/data/local/tmp/ahmed_hotspot/` (`hostapd.conf` SSID `AhmedNet` ch6, `dnsmasq.conf`, `start_ap.sh`, `stop_ap.sh`). Failure: `svc wifi disable` deletes `wlan0` entirely. | ✅ |
| 9 | `hotspot 3.txt` | 26 KB | **P2 — Manual AP verification.** hostapd pid 2988 on `wlan0`, `type AP / ssid AhmedNet`; **a real client associated** (`AP-STA-CONNECTED a4:4e:31:83:ec:3c` @ 11:33). DHCP never leased → L2 OK, L3 incomplete. | ✅ |
| 10 | `joyspot4.txt` | 24 KB | **P3 — Stock Android hotspot path.** hostapd on **`ap0`**, dnsmasq as `dns_tether`, route `192.168.43.0/24 dev ap0`, NAT `tetherctrl_nat_POSTROUTING → MASQUERADE out ccmni0` (634 pkts), **client 192.168.43.228 leased on ap0** → stock tethering fully functional end-to-end. | ✅ |
| 11 | `hotspot_log.txt` | 22 KB | **logcat of the stock `startTethering` flow.** `startSoftAp` → STA `wlan0` torn down → `ap0` created → `MtkSoftApManager` cosmetic `FileNotFoundException /data/misc/wifi/allowed_list.conf` → hostapd reads generated conf → `AP-ENABLED` → dnsmasq pools 192.168.42–49.x → upstream `ccmni0`. | ✅ |
| 12 | `config wifi.txt` | 4.8 KB | Dumps of `/data/vendor/wifi/hostapd/` (conf + ctrl socket `ap0` + empty accept list), `/data/misc/wifi/`, and the full **`WifiConfigStore.xml`** (contains plaintext PTCL-BB PSK). | ✅ |
| 13 | `config location.txt` | 11 KB | System-wide `find` for wifi/softap/tether/hostap files; `settings list global` (mostly empty → tether config lives in the MTK framework, not global settings). | ✅ |
| 14 | `appcontrol.txt` | 11 KB | `ip link` snapshot (`ccmni0` UP, `ap0` UP), empty tether settings, dumpsys wifi SoftAp metrics + client connect/disconnect event log. | ✅ |
| 15 | `full test.txt` | 45 KB | **`dumpsys wifi` deep-dive**: `SoftApManager` in `StartedState`, `mApInterfaceName=ap0`, `mIfaceIsUp=true`, `mCountryCode=PK`, `mApConfig.SSID: Infinix HOT 8`, `apBand: 1` (5 GHz); SoftAp counters **SUCCESS: 2, failures 0**. | ✅ |
| 16 | `testm.txt` | 45 KB | "RNS next full control test": services list, `cmd wifi` transaction failure, tether/netd dumps, `getprop` filter → **`wifi.tethering.interface = ap0`**. Contains the **only DHCP lease record**: `a4:4e:31:83:ec:3c 192.168.43.228 DESKTOP-EIQ7K6O`. | ✅ |
| 17 | `test lsdt open.txt` | ~28 KB | Background logcat with hotspot left open: SystemUI tiles (Jazz), benign `PowerMonitorHookClient: unkown network interface:ap0`, `PowerSaveUtils ... wifiApEnable->true`. | ✅ |
| 18 | `Stack Info .txt` | ~30 KB | Verbose MTK Wi-Fi HAL / `WifiConnectivityManager` log (roaming config, feature matrix, scans) during hotspot operation. | ✅ |
| 19 | `permannet wifi.txt` | 1.1 KB | "Make Wi-Fi stack persistent" recon: Wi-Fi HAL binary + init rc, netd/netdiag/netdagent processes, kernel module list. | ✅ |
| 20 | `magisk v and boot control.txt` | 882 B | `magisk -v` → **30.7:MAGISK:R**; `/data/adb/modules` contains **only `ARCore_enabler`**; `post-fs-data.d` and `service.d` **empty**. | ✅ |

> **Nothing is left unread.** All 20 files (including the binary zip, which was extracted and both members inspected) have been fully reviewed.

---

## 3. What the NEW file adds (`RNS - Rooted Hotspot Billing App.md`)

This transcript is the missing half of the story — `DOCUMENTATION.md` stopped at "module authored", the transcript continues to **install attempts, live patch tests, race-condition measurement and the billing-app vision**.

### 3.1 The original goal (verbatim intent)
> *"make a app which give internet by hotspot … custom permanent ssid and password or if no password open then better because we r going to control it by voucher system and auto expiry and kicking system … when any connects to wifi a captive portal opens and voucher binds its mac."*

So the real product is a **pocket MikroTik-style hotspot billing controller** running on the rooted phone — not just an SSID rename.

### 3.2 Confirmed target configuration (from the transcript)
| Setting | Target | Status |
|---|---|---|
| SSID | **`RNS`** (hex `524e53`) | patch proven |
| Security | **Open, no password** (strip `wpa*` lines) | already open on device |
| Band | **2.4 GHz** — *"wait use 2.4 as most devices have it"* (user overrode an earlier "both bands" preference) | patch proven |
| Channel | **6** | patch proven |
| Max clients | **as high as possible** (128 chosen; "infinite" is physically impossible) | patch proven |
| Gateway IP | prefer `192.168.50.1`, **fallback keep `192.168.43.x`** | not attempted — deferred |
| Auto-start hotspot on boot | **not required** | — |

### 3.3 The decisive new experiments
1. **Android always wins the file race.** Edit `hostapd_ap0.conf` while the hotspot is OFF → the edit survives. Toggle hotspot ON → `MtkSoftApManager` **regenerates** the file (`ssid2=496e66696e697820484f542038` = "Infinix HOT 8", `hw_mode=a`, channel 157/161/165 varies, `max_num_sta=10`) and hostapd reads the fresh copy. *Conclusion: a one-shot file edit is useless; the module must patch every generation.*
2. **The window is real and patchable.** A `while true; sleep 0.05` watcher proved the config file appears **~2 s before hostapd is running** (`13:05:15 FILE FOUND` → `13:05:17 HOSTAPD RUNNING`). A `sed` patch fired inside that window and produced:
   ```
   PATCHED
   ssid2=524e53
   channel=6
   hw_mode=g
   max_num_sta=128
   ```
3. **`HUP` does not reload.** `kill -HUP $(pidof hostapd)` left the process alive but did **not** apply the new SSID — the vendor hostapd ignores SIGHUP.
4. **`hostapd_cli` is missing from PATH but the binary exists.** `hostapd_cli: not found` under `su -c`, yet `hotspot_files.txt` line 12 proves **`/vendor/bin/hostapd_cli` is present on the device.** The socket `/data/vendor/wifi/hostapd/ctrl/ap0` also exists. → **A real `RELOAD` control path is available; it was simply never tried with the absolute path.**
5. **`cmd wifi` / `cmd connectivity` are dead ends** — both fail with `Failed transaction (2147483646)`. No framework shell API is usable; everything must be done at the file/socket/iptables layer.
6. **`/system/framework/services.jar` is only 183 bytes** — a placeholder. The real bytecode lives in `/system/framework/oat/arm{64}/services.{odex,vdex}`. Patching the framework is therefore high-risk and was correctly rejected.

### 3.4 The module install saga (new — not in `DOCUMENTATION.md`)
- **Attempt 1 failed:** `magisk_install_log_2026-09-25T13.15.58.log` → *"! This zip is not a Magisk module! ! Installation failed"*. Cause: the zip contained a nested `RNS_Hotspot/` folder, so `module.prop` was not at the zip root.
- **Attempt 2 succeeded:** `magisk_install_log_2026-09-25T13.18.46.log` → *"Installing RNS_Hotspot.zip … Device is system-as-root … inflating: module.prop … inflating: service.sh … Extracting module files … Done"*. Rebuilt with `cd /sdcard/RNS_Hotspot && zip -r ../RNS_Hotspot.zip module.prop service.sh`.
- **The transcript ends here** — with instructions to reboot, toggle the hotspot on, and check `/data/local/tmp/rns_hotspot.log`. **No post-install verification log exists in the repo.** The `magisk v and boot control.txt` snapshot predates the install (it shows only `ARCore_enabler` and empty `service.d`).

---

## 4. The device & its hotspot stack (proven, not assumed)

| Property | Value | Source |
|---|---|---|
| Model | **Infinix X650C** ("Infinix HOT 8"), INFINIX MOBILITY LIMITED | `hotspot_report.txt` |
| Android | **9 (Pie), SDK 28** | `hotspot_report.txt` |
| SoC | **MediaTek MT6765** (Helio P35) | `hotspot_report.txt` |
| Wi-Fi driver | `wlan_drv_gen4m` + `wmt_drv`, `wmt_chrdev_wifi` | `hotspot_report.txt`, `permannet wifi.txt` |
| Wi-Fi HAL | `android.hardware.wifi@1.0-service-mediatek` (legacy HIDL) + `vendor.mediatek.hardware.wifi.hostapd@2.0` | `permannet wifi.txt`, `hotspot_log.txt` |
| AP interface | **`ap0`** (`wifi.tethering.interface=ap0`) — STA `wlan0` is destroyed when the AP starts (single-radio chip, no concurrent STA+AP) | `testm.txt`, `hotspot_log.txt` |
| hostapd | `/vendor/bin/hw/hostapd`, **v2.7-devel-9** | `hotspot_report.txt`, `hotspot_log.txt` |
| hostapd_cli | **`/vendor/bin/hostapd_cli` (exists)** + ctrl socket `/data/vendor/wifi/hostapd/ctrl/ap0` | `hotspot_files.txt`, `config wifi.txt` |
| DHCP/DNS | `/system/bin/dnsmasq` v2.51, run by `netd` as user `dns_tether` | `hotspot_log.txt`, `testm.txt` |
| Firewall | iptables v1.6.1, Android chains `tetherctrl_*`, `bw_*`, `fw_*`, `oem_*`, `st_*` | `hotspot_report.txt` |
| Uplink | `ccmni0` (Jazz LTE, e.g. 10.60.99.185; DNS 119.160.112.48 / 119.160.80.146) | `hotspot_log.txt`, `testm.txt` |
| Root | **Magisk 30.7 (MAGISK:R)**; only module at capture = `ARCore_enabler`; `service.d` & `post-fs-data.d` empty | `magisk v and boot control.txt` |
| Country code | `PK` | `appcontrol.txt`, `full test.txt` |

### 4.1 How the stock hotspot actually works (the proven chain)
```
SystemUI tile → ConnectivityManager.startTethering
   → WifiService.startSoftAp
      → MtkSoftApManager (MTK fork of SoftApManager) state machine
         → vendor HAL creates AP iface ap0  (STA wlan0 torn down)
         → writes /data/vendor/wifi/hostapd/hostapd_ap0.conf   ← the patch point
         → launches /vendor/bin/hw/hostapd  →  AP-ENABLED
   → netd launches dnsmasq (dns_tether) with pools 192.168.42–49.x
   → netd installs tetherctrl_nat_POSTROUTING → MASQUERADE out ccmni0
   → client gets 192.168.43.x, reaches the internet
```

### 4.2 Measured timing — **correction to `DOCUMENTATION.md` §4**
`DOCUMENTATION.md` claims "config generation → hostapd start happens within **~50 ms**". The actual `hotspot_log.txt` timestamps are:

| Event | Time |
|---|---|
| `MtkSoftApManager` writes conf (`allowed_list.conf` missing error) | `11:55:58.230` |
| hostapd reads `hostapd_ap0.conf` | `11:55:58.240` |
| `ap0: AP-ENABLED` | `11:55:58.251` |

→ **21 ms**, not 50 ms. The window is *tighter* than previously documented, which makes the 1-second poll in `service.sh` even less likely to win. However, the later watcher experiment in the transcript observed a **~2 s** gap between the conf file appearing and hostapd being visible in `ps` — the discrepancy is explained by HAL/process-spawn latency happening *after* the file is written. **Practical rule: patch as early as possible after the file appears; do not rely on a fixed sleep.**

---

## 5. The deliverable: `RNS_Hotspot` Magisk module

### 5.1 `module.prop` (exact, from the zip)
```
id=RNS_Hotspot
name=RNS Hotspot Controller
version=1.0
versionCode=1
author=Ahmed
description=Force RNS hotspot SSID, 2.4GHz open mode, channel 6 and increase clients on MediaTek Android devices
```

### 5.2 `service.sh` (exact, from the zip)
```sh
#!/system/bin/sh
MODDIR=${0%/*}
LOG=/data/local/tmp/rns_hotspot.log
echo "$(date) RNS Hotspot Service Started" >> $LOG

(
while true
do
CONF=/data/vendor/wifi/hostapd/hostapd_ap0.conf
if [ -f "$CONF" ]; then
    echo "$(date) hostapd config detected" >> $LOG
    # Patch SSID
    sed -i \
    -e 's/^ssid2=.*/ssid2=524e53/' \
    -e 's/^channel=.*/channel=6/' \
    -e 's/^hw_mode=.*/hw_mode=g/' \
    -e 's/^max_num_sta=.*/max_num_sta=128/' \
    "$CONF"
    # Remove security if Android adds it later
    sed -i \
    -e '/^wpa=/d' \
    -e '/^wpa_passphrase=/d' \
    -e '/^wpa_key_mgmt=/d' \
    -e '/^rsn_pairwise=/d' \
    "$CONF"
    echo "$(date) Config patched" >> $LOG
    sleep 1
    if ip link show ap0 >/dev/null 2>&1
    then
        IP=$(ip addr show ap0 | grep "inet " | awk '{print $2}')
        echo "$(date) AP IP $IP" >> $LOG
    fi
    sleep 10
fi
sleep 1
done
) &
```

### 5.3 What the module gets right
- `module.prop` at zip root → installs cleanly (proven by the successful install log).
- Targets the correct file (`hostapd_ap0.conf`) and the correct values (`524e53`, `channel=6`, `hw_mode=g`, `max_num_sta=128`).
- Strips WPA lines → guarantees an open network even if Android later adds security.
- Runs from `service.sh` (late boot) as a detached background loop → survives reboot.
- Fully reversible: uninstall the module → stock behaviour returns. No framework/system modification, no bootloop risk.

### 5.4 Known defects in v1.0 (must be fixed in v1.1)
| # | Defect | Impact | Fix |
|---|---|---|---|
| 1 | **Race condition.** The loop polls every 1 s; the conf→hostapd window is ~21 ms (observed up to ~2 s). | The patch usually lands **after** hostapd has already parsed the conf → SSID/channel change only takes effect on the *next* hotspot restart, and Android may overwrite it. | Replace polling with `busybox inotifyd` on `/data/vendor/wifi/hostapd/`, **or** patch upstream at `/data/misc/wifi/softap.conf` which `MtkSoftApManager` reads *before* generating the conf. |
| 2 | **No reload.** After patching, nothing tells the running hostapd to re-read. | Changes never hit the live AP even when the patch does win the race. | `/vendor/bin/hostapd_cli -i ap0 RELOAD` (binary confirmed present) — fall back to `killall -HUP hostapd` (known ineffective) or restart SoftAp. |
| 3 | **Re-patches every 10 s forever.** | Writes to a `wifi`-owned file continuously; wasteful, and could fight the framework. | Patch only when the conf content actually differs from the desired state (checksum/grep guard). |
| 4 | **No `ip_forward` / NAT sanity check.** | If Android's tether rules are ever lost, clients connect but get no internet. | Assert `ip_forward=1` and the `MASQUERADE` rule after `ap0` appears. |
| 5 | **No `192.168.50.1` support.** | The user's preferred subnet is unimplemented (deliberately deferred). | Optional Phase-3 work; keep `192.168.43.x` fallback. |
| 6 | **No post-install verification artifact.** | The transcript stops at "reboot and check the log"; there is **no `rns_hotspot.log` and no `iw dev ap0 info` showing `ssid RNS`** anywhere in the repo. | Must be captured to close the project. |

---

## 6. Confirmed facts vs. open questions

### ✅ Proven (evidence-backed)
1. Device is fully rooted; Magisk 30.7 works; Termux toolchain (`tsu busybox coreutils grep iw iproute2 procps`) works.
2. Wi-Fi chipset **supports AP mode** (`iw list` → IBSS, managed, **AP**, P2P-client, P2P-GO).
3. `hostapd` v2.7, `dnsmasq` v2.51 and `iptables` v1.6.1 are all present and usable.
4. **Stock Android hotspot works end-to-end**: `AP-ENABLED` on `ap0`, a real client (`192.168.43.228` / `a4:4e:31:83:ec:3c`) got a DHCP lease, and NAT masqueraded through `ccmni0`. SoftAp success counter = 2, zero failures.
5. Manual hostapd on `wlan0` **can** create an AP and a client **can** associate (`AP-STA-CONNECTED a4:4e:31:83:ec:3c`) — but DHCP never completes, and `wlan0` vanishes when the Wi-Fi framework stops. This path was correctly abandoned.
6. `MtkSoftApManager` regenerates `hostapd_ap0.conf` on every hotspot start; the file is writable by root.
7. A `sed` patch fired inside the window **does** produce the desired values.
8. `kill -HUP hostapd` does **not** reload the config.
9. `/vendor/bin/hostapd_cli` **exists**; the `ctrl/ap0` socket exists.
10. `cmd wifi` / `cmd connectivity` shell APIs are unusable on this build.
11. The zip now installs successfully as a Magisk module.

### ❓ Open / unverified
1. **Does the module actually produce SSID `RNS` on a live AP?** — no verification log exists.
2. Does `hw_mode=g` + `channel=6` survive the MTK driver/regulatory domain (`mCountryCode: PK`)?
3. Does `max_num_sta=128` hold, or does the MTK firmware cap associations far lower (the driver enforces its own limit)?
4. Does `/vendor/bin/hostapd_cli -i ap0 RELOAD` actually work against the vendor hostapd?
5. Is `192.168.50.1` achievable at all (requires touching netd's tether DHCP ranges, not just the hostapd conf)?
6. Does the module survive repeated hotspot ON/OFF cycles and a reboot?

---

## 7. Beyond the hotspot: the billing-app vision (from the new transcript)

The transcript's title is *"RNS - Rooted Hotspot Billing App"* — the hotspot rename is only **Phase 1**. The intended end state:

```
Client connects to RNS (open)
        │
        ▼
DHCP lease from Android's dns_tether dnsmasq
        │
        ▼
DNS / iptables REDIRECT  →  http://<gateway>/login
        │
        ▼
Captive portal page (voucher entry)
        │
        ▼
Voucher validated + MAC bound in SQLite
        │
        ▼
iptables ACCEPT for that MAC  →  internet unlocked
        │
        ▼
Timer / quota watchdog  →  expiry ⇒ DROP or deauth (kick)
```

Components discussed: voucher DB (`code, duration, expiry, status, mac, speed_limit`), MAC binding via `/proc/net/arp` / `ip neigh`, per-client kick via `iptables -m mac --mac-source … -j DROP` or `hostapd_cli deauthenticate`, bandwidth shaping via `tc`, and data quotas via iptables counters. **None of this is built yet** — it is design intent only.

---

## 8. Architecture decision (carried forward and confirmed)

Evaluated in `DOCUMENTATION.md` §9 and re-confirmed by the transcript:

| Option | Verdict |
|---|---|
| **A. Normal unprivileged APK** | ❌ `startTethering` / `setWifiApConfiguration` need `TETHER_PRIVILEGED` (`signature\|privileged`); Android 9 hidden-API blacklist; **no API exists for channel 6 or `max_num_sta`** — those only exist in the generated hostapd conf. |
| **B. System app (`/system/priv-app`)** | ❌ dm-verity protected → bootloop/OTA risk; needs a privapp-permissions whitelist; still gives **no** channel or client-limit control. |
| **C1. Magisk + Web UI (busybox httpd CGI)** | ⚠️ works, clunky UX, no notifications. |
| **C2. Magisk engine + companion APK (Kotlin + libsu)** | ✅ **chosen.** Engine keeps boot automation alive even if the app is uninstalled; all four targets achievable; OTA-safe; clean two-tap uninstall. |

```
┌──────────────────────────────┐    su    ┌─────────────────────────────────────┐
│  RNS Hotspot APK (user app)  │ ◄──────► │  RNS_Hotspot Magisk module (engine) │
│  SSID / band / channel /     │          │  reads /data/adb/rns/config         │
│  clients / open-WPA toggle   │          │  inotifyd on hostapd dir            │
│  start / stop hotspot        │          │  patches hostapd_ap0.conf           │
│  live clients, IPs, traffic  │          │  hostapd_cli -i ap0 RELOAD          │
│  log viewer                  │          │  NAT / ip_forward sanity checks     │
└──────────────────────────────┘          │  boot-persistent service.sh         │
                                          └─────────────────────────────────────┘
```

---

## 9. THE REAL POSITION (current true status)

**Done & working**
- Recon 100 % complete; the whole MTK Wi-Fi/tethering stack is mapped.
- Hardware + driver capability confirmed (AP mode, nl80211).
- **Stock hotspot proven working with a real client and internet sharing.**
- Manual-hostapd experiment completed and correctly retired.
- `RNS_Hotspot.zip` v1.0 authored **and successfully installed on the device** (per the 13:18:46 Magisk log).

**Not done (the gap)**
1. **No verification that `RNS` is actually broadcast.** No `rns_hotspot.log`, no `iw dev ap0 info` showing `ssid RNS` exists in any capture. Every observed hotspot session still used the stock "Infinix HOT 8" config.
2. **The v1.0 race condition is unresolved** (§5.4 #1) — the 1 s poll almost certainly loses to the ~21 ms conf→hostapd window.
3. **No reload is ever triggered** (§5.4 #2), so even a winning patch wouldn't reach the live AP.
4. **Captive portal + voucher + MAC binding + kick/expiry: 0 % built.**
5. **`192.168.50.1` subnet: not attempted.**

> **Bottom line:** *Recon complete, stock hotspot proven, module authored and flashed — but the module's core promise (SSID `RNS`, 2.4 GHz, channel 6, 128 clients on a live AP) has never been demonstrated. The project is at "installed, unverified, and racy", not "done".*

---

## 10. Recommended next steps (in order)

1. **Close the verification loop.** Reboot, toggle hotspot ON, then capture:
   ```sh
   su -c 'cat /data/local/tmp/rns_hotspot.log'
   su -c 'cat /data/vendor/wifi/hostapd/hostapd_ap0.conf'      # expect ssid2=524e53, channel=6, hw_mode=g, max_num_sta=128
   su -c '/data/data/com.termux/files/usr/bin/iw dev ap0 info' # expect ssid RNS, type AP
   ```
   Commit the output to the repo as `verify_rns.txt`.

2. **Fix the race — two layers:**
   - **Upstream:** write the desired SSID/band/security into `/data/misc/wifi/softap.conf` (the 31-byte legacy store `MtkSoftApManager` reads *before* generating the conf).
   - **Downstream:** `busybox inotifyd` on `/data/vendor/wifi/hostapd/` → instant `sed` patch → **`/vendor/bin/hostapd_cli -i ap0 RELOAD`** (binary confirmed present at that path).

3. **Add a re-patch guard** (only write when the conf differs) plus `ip_forward` and `MASQUERADE` assertions.

4. **End-to-end test:** connect a client to `RNS`, confirm a DHCP lease on `192.168.43.x`, confirm internet via `ccmni0`, confirm >10 simultaneous clients.

5. **Then, and only then**, build the billing layer: portal web server → voucher DB → MAC allow/deny via iptables → expiry watchdog → kick.

6. **Optional polish:** keep `max_num_sta` realistic if MTK firmware caps below 128; test 2.4 GHz congestion on channel 6; decide on `192.168.50.1`.

---

## 11. Security notes

- `config wifi.txt` contains the **plaintext Wi-Fi password for `PTCL-BB` (`B9173461`)** plus the phone's DHCP/MAC details — treat this repo as sensitive and rotate that password.
- The design is an **open network (no WPA) with up to 128 clients** — anyone in range can join. Intentional for the RNS use-case, but it means the billing/captive-portal layer is the *only* access control, so it must be treated as a security boundary.
- `hotspot_report.txt` and the logs expose internal IPs, MACs, carrier DNS servers and the device's regulatory country — useful for debugging, noisy for publication.

---

## 12. Corrections applied to earlier documentation

| Claim in `DOCUMENTATION.md` | Corrected value | Evidence |
|---|---|---|
| "The 18 files are …" | **20 files** (see §2) | `find` |
| conf→hostapd window "~50 ms" | **~21 ms** (file write 58.230 → read 58.240 → AP-ENABLED 58.251); a later watcher observed up to ~2 s of HAL spawn latency | `hotspot_log.txt`; transcript watcher test |
| "`hostapd_cli` not found" (transcript mid-point) | **`/vendor/bin/hostapd_cli` exists** | `hotspot_files.txt` line 12 |
| "The RNS_Hotspot module is NOT installed on the phone" | It **was installed successfully** on the second attempt (13:18:46 log); the empty-modules snapshot simply predates it | transcript install logs |
| Module "never forces a reload" — still true, and now we know the correct binary path to use | `/vendor/bin/hostapd_cli -i ap0 RELOAD` | `hotspot_files.txt` |

---

*End of FINALANALYSIS.md — generated after a complete read of all 20 repository files.*
