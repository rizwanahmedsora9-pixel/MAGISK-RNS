# MAGISK-RNS — Full Repository Documentation

> Prepared: 2026-09-25 · Branch: `arena/01a0d7cc-magisk-rns` · Base commit: `46f0037` ("Add files via upload")

## 1. What this repository actually is

This is **not a software project**. It is a **working journal / evidence folder** for a single real-world task:

> **Taking full root-level control of the Wi-Fi hotspot on a rooted Infinix HOT 8 (MediaTek) phone, using Magisk + Termux, and forcing it to broadcast a custom open network named “RNS” on 2.4 GHz channel 6 with a high client limit.**

The 18 files are: Termux shell-session recordings, logcat dumps, `dumpsys` outputs, config backups, one Magisk module zip, and a stub README. Everything was captured on **2026-09-23 → 2026-09-25** (Pakistan time, carrier “Jazz”).

---

## 2. The device (from `hotspot_report.txt`, `full test.txt`, `magisk v and boot control.txt`)

| Property | Value |
|---|---|
| Manufacturer / Model | INFINIX MOBILITY LIMITED — **Infinix X650C** (“Infinix HOT 8”) |
| Android | **9 (Pie), SDK 28** |
| SoC / Board | MediaTek **MT6765** (Helio P35) |
| Wi-Fi chip | MTK MT66xx combo (`wlan_drv_gen4m`, `wmt_drv` kernel modules) |
| Wi-Fi HAL | `android.hardware.wifi@1.0-service-mediatek` (legacy HIDL) |
| hostapd | `/vendor/bin/hw/hostapd`, **v2.7-devel**, vendor HAL `vendor.mediatek.hardware.wifi.hostapd@2.0` |
| DHCP/DNS | `/system/bin/dnsmasq` v2.51 (run by `netd` as user `dns_tether`) |
| Firewall | iptables v1.6.1 with Android chains (`tetherctrl_*`, `bw_*`, `fw_*`, `oem_*`) |
| Root | **Magisk 30.7 (MAGISK:R)** — installed module list at capture time: only `ARCore_enabler` |
| Termux | installed, with `tsu busybox coreutils grep iw iproute2 procps` |
| Cellular uplink | `ccmni0` (Jazz, IP 10.60.99.185, DNS 119.160.80.146 / 119.160.112.48) |
| Known Wi-Fi profile | `PTCL-BB`, WPA-PSK `B9173461` (visible in plaintext in `WifiConfigStore.xml` dump) |

Key property: `wifi.tethering.interface = ap0` — Android creates a **dedicated AP interface `ap0`** (STA `wlan0` is torn down when the hotspot starts; this MTK chip does not do concurrent STA+AP).

Driver capability (from Termux `iw list`): supported interface modes = **IBSS, managed, AP, P2P-client, P2P-GO** → AP mode is fully supported.

---

## 3. File-by-file documentation

### Config / artifact files
| File | Content |
|---|---|
| `README.md` | Stub: `# MAGISK-RNS` |
| `ap_backup.conf` | Backup copy of `/data/vendor/wifi/hostapd/hostapd_ap0.conf` — open AP on `ap0`, hex SSID `496e66696e697820484f542038` = **“Infinix HOT 8”**, channel **157**, `hw_mode=a` (5 GHz), `ieee80211n=1`, `ieee80211ac=0`, `max_num_sta=10`, `macaddr_acl=0`, accept-file `/data/vendor/wifi/hostapd/accept_mac_update.conf`. |
| `RNS_Hotspot.zip` | **The Magisk module (v1.0, author “Ahmed”)** — the actual deliverable of the project. Contains `module.prop` + `service.sh`. Details in §5. |
| `hotspot_files.txt` | Inventory of every hotspot-related path on the phone: `/data/misc/wifi/softap.conf`, vendor hostapd dir, GMS “magictether” prefs, hostapd binaries/HAL libs, tetheroffload VNDK libs. |

### Session logs (chronological story)
| File | What it records |
|---|---|
| `Hoyspot test 1.txt` | **Phase 1 — Recon & manual AP attempt.** Termux packages installed; capability report script generated `hotspot_report.txt`; `iw list` confirms AP mode; located hostapd/dnsmasq/iptables; built a **manual hotspot kit** in `/data/local/tmp/ahmed_hotspot/` (`hostapd.conf` SSID=AhmedNet ch6, `dnsmasq.conf`, `start_ap.sh`, `stop_ap.sh`). First run **failed**: after `svc wifi disable` the framework deleted `wlan0` (“Device wlan0 does not exist”). Later got `wlan0` up in **type AP, ssid AhmedNet**, assigned `192.168.50.1/24`, started standalone dnsmasq DHCP pool 192.168.50.10–100. |
| `hotspot 3.txt` | **Phase 2 — Manual AP verification.** hostapd (pid 2988) running on wlan0; **a real client associated**: `AP-STA-CONNECTED a4:4e:31:83:ec:3c` at 11:33. But DHCP leases file stayed empty / station dump empty → L2 association OK, L3 (DHCP/IP) incomplete. Also confirms wlan0 vanishes whenever the Android Wi-Fi framework stops. |
| `joyspot4.txt` | **Phase 3 — Stock Android hotspot path.** `hostapd` (pid 8779) on **ap0**, `dnsmasq` as `dns_tether` (pid 8782), route `192.168.43.0/24 dev ap0`, NAT chain `tetherctrl_nat_POSTROUTING → MASQUERADE out ccmni0` (634 pkts already masqueraded), ARP shows **client 192.168.43.228 got an IP on ap0** → stock tethering is fully functional end-to-end. |
| `hotspot_log.txt` | **logcat of the stock startTethering flow** (SystemUI → `WifiService.startSoftAp`): STA wlan0 torn down → `ap0` created → `MtkSoftApManager` error (non-fatal): `FileNotFoundException /data/misc/wifi/allowed_list.conf` → hostapd reads generated `hostapd_ap0.conf` (**SSID “Infinix HOT 8”, channel 161, hw_mode=a, open, max 10 STAs**) → `AP-ENABLED` → dnsmasq DHCP pools 192.168.43.x–49.x → upstream `ccmni0` found. Some SELinux `avc: denied { getattr }` warnings for dnsmasq pipes (harmless here). |
| `config wifi.txt` | Dumps of `/data/vendor/wifi/hostapd/` (conf + ctrl socket `ap0` + empty accept list), `/data/misc/wifi/` (softap.conf, dhcp_lease.conf), full **WifiConfigStore.xml** (contains PTCL-BB SSID+PSK), hostapd process alive. |
| `config location.txt` | System-wide `find` for wifi/softap/tether/hostap files across `/data`, `/vendor`, `/system`; `settings list global` for tether/wifi keys (mostly empty → tether config lives in the MTK framework, not global settings). |
| `appcontrol.txt` | `ip link` snapshot (`ccmni0` UP, `ap0` UP), empty tether settings, dumpsys wifi SoftAp metrics (client connect/disconnect event log, WPS counters all zero). |
| `full test.txt` | **dumpsys wifi deep-dump**: `SoftApManager` in `StartedState`, `mApInterfaceName=ap0`, `mIfaceIsUp=true`, `mCountryCode=PK`, `mApConfig.SSID: Infinix HOT 8`, `apBand: 1` (5 GHz); SoftAp start counters **SUCCESS: 2, failures: 0**; Wi-Fi state-machine history. |
| `testm.txt` | “RNS next full control test”: services list, `cmd wifi` transaction failure (framework refuses shell), connectivity/netd tether dumps, getprop filter → `wifi.tethering.interface=ap0`, viwifi disabled. |
| `test lsdt open.txt` | Background logcat while hotspot left open: SystemUI tiles (Jazz), repeated benign `PowerMonitorHookClient: unkown network interface:ap0`, `PowerSaveUtils ... wifiApEnable->true`. |
| `Stack Info .txt` | Verbose MTK Wi-Fi HAL / WifiConnectivityManager log (roaming config, feature matrix, scans) during hotspot operation. |
| `permannet wifi.txt` | “Make Wi-Fi stack persistent” recon: Wi-Fi HAL binary/init rc, netd/netdiag/netdagent processes, kernel module list (`wlan_drv_gen4m` etc.). |
| `magisk v and boot control.txt` | `magisk -v` → **30.7:MAGISK:R**; `/data/adb/modules` contains **only `ARCore_enabler`**; `post-fs-data.d` and `service.d` **empty**. |

---

## 4. How the phone’s hotspot actually works (proven from the logs)

1. User toggles hotspot → SystemUI calls `ConnectivityManager.startTethering`.
2. `WifiService.startSoftAp` → `MtkSoftApManager` (MTK fork of SoftApManager) state machine.
3. The **STA interface `wlan0` is destroyed** and an **AP interface `ap0` is created** (single-radio chip).
4. MtkSoftApManager **generates `/data/vendor/wifi/hostapd/hostapd_ap0.conf`** (hex SSID, auto 5 GHz channel 157/161, open, max 10 clients) and starts `/vendor/bin/hw/hostapd` via the vendor HIDL HAL.
5. `netd` launches **dnsmasq** (`dns_tether`) giving each tether iface a pool (192.168.43–49.x).
6. netd installs **iptables NAT** (`tetherctrl_nat_POSTROUTING → MASQUERADE`) and FORWARD rules toward the cellular uplink `ccmni0`.
7. Toggling hotspot off regenerates/overwrites the conf every time — which is exactly why the Magisk module patches it at runtime instead of editing it once.

Observed weaknesses / quirks found along the way:
- `wlan0` **does not exist** when the Wi-Fi framework is off → standalone hostapd on `wlan0` is fragile on this MTK driver (interface lifecycle owned by wificond/HAL).
- Client associated to the manual AP but DHCP never leased (no NAT set up, dnsmasq pool on a different subnet than what clients expected, no iptables masquerade for the manual setup).
- `MtkSoftApManager` stack-traces about missing `/data/misc/wifi/allowed_list.conf` (cosmetic; it creates/ignores it).
- Config generation → hostapd start happens within **~50 ms** (see hotspot_log.txt timestamps 11:55:58.230 → 11:55:58.251). Anything that wants to modify the conf has a very small race window.

---

## 5. The RNS_Hotspot Magisk module (the project’s deliverable)

`module.prop`:
```
id=RNS_Hotspot · name=RNS Hotspot Controller · version=1.0
author=Ahmed
description=Force RNS hotspot SSID, 2.4GHz open mode, channel 6
           and increase clients on MediaTek Android devices
```

`service.sh` logic (runs in `service.d`, i.e. late boot):
1. Starts a background `while true` loop, logs to `/data/local/tmp/rns_hotspot.log`.
2. Whenever `/data/vendor/wifi/hostapd/hostapd_ap0.conf` exists, `sed`-patches it in place:
   - `ssid2=524e53` (= hex **“RNS”**)
   - `channel=6`, `hw_mode=g` (2.4 GHz)
   - `max_num_sta=128`
   - deletes `wpa=`, `wpa_passphrase=`, `wpa_key_mgmt=`, `rsn_pairwise=` lines (keep it open)
3. Waits for `ap0`, records its IP.
4. `sleep 10` between patches to avoid endless rewriting.

---

## 6. THE REAL POSITION (current true status)

**What is DONE and WORKING:**
1. Device fully rooted (Magisk 30.7), Termux toolchain installed, full recon of the Wi-Fi/tethering stack completed.
2. Hardware/driver capability confirmed: AP mode supported; hostapd v2.7 + dnsmasq present on-device.
3. **Stock hotspot verified end-to-end**: AP-ENABLED on `ap0`, real client got a DHCP lease (192.168.43.228), NAT masquerading active through `ccmni0` (Jazz mobile data). SoftAp success counter = 2, zero failures.
4. Manual “AhmedNet” hostapd experiment proved root can start hostapd directly and a client associated (L2 success); it was abandoned in favor of patching the stock flow.
5. The `RNS_Hotspot` Magisk module (zip) is **built and present in the repo**.

**What is NOT done yet (the gap):**
1. **The RNS_Hotspot module is NOT installed on the phone** — the Magisk evidence dump (`magisk v and boot control.txt`, 2026-09-24 22:14) shows `/data/adb/modules` contains only `ARCore_enabler`, and `service.d` is empty. No `rns_hotspot.log` appears in any capture.
2. Consequently, no log anywhere shows SSID “RNS” being broadcast; every observed hotspot session still used the stock “Infinix HOT 8” config.
3. **Race-condition risk in service.sh:** the framework writes `hostapd_ap0.conf` and starts hostapd ~50 ms later; the module polls every 1 s, so it usually patches the file **after hostapd has already read it** → the SSID/channel change won’t apply until the *next* hotspot restart, and Android may rewrite the conf over the patch.
4. The module never forces a reload — after patching it should `hostapd_cli -i ap0 RELOAD` (or restart hostapd) so changes take effect immediately.

**Bottom line:** *Recon 100 % complete, stock hotspot proven working with clients and internet sharing, RNS module authored — but it has never been flashed/tested on the device. Project is at “ready to install and verify”, not “done”.*

---

## 7. Recommended next steps (in order)

1. **Install**: `Magisk → Modules → Install from storage → RNS_Hotspot.zip → reboot`.
2. Toggle hotspot ON, then check:
   ```sh
   su -c 'cat /data/local/tmp/rns_hotspot.log'
   su -c 'cat /data/vendor/wifi/hostapd/hostapd_ap0.conf'   # should show ssid2=524e53, channel=6, hw_mode=g
   su -c 'iw dev ap0 info'                                   # ssid RNS, type AP
   ```
3. **Harden the module against the race**: replace the 1 s poll with `inotifyd` (busybox) on the hostapd dir, and add after patching:
   ```sh
   /vendor/bin/hostapd_cli -i ap0 RELOAD 2>/dev/null || killall -HUP hostapd
   ```
4. Verify a client connects to **RNS**, gets DHCP from `dns_tether`’s dnsmasq, and reaches the internet via `ccmni0` MASQUERADE.
5. Optional polish: keep `max_num_sta` realistic (driver firmware may cap clients far below 128), consider adding `ignore_broadcast_ssid=0` explicitly, and test 2.4 GHz congestion on channel 6.

## 8. Security notes

- `config wifi.txt` contains the **plaintext Wi-Fi password** for PTCL-BB (`B9173461`) and the phone’s DHCP/MAC details — treat this repo accordingly; consider rotating that password.
- The target hotspot design is an **open network** (no WPA) with up to 128 clients — anyone in range can join; intentional for the “RNS” use-case, but worth noting.
