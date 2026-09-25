# APPROACH ANALYSIS — APK vs System App vs Magisk-with-UI

> Decision document for the RNS Hotspot Controller · based on the evidence in this repo · 2026-09-25

## 0. The goal, restated

On a rooted **Infinix HOT 8 (X650C, MT6765, Android 9 / SDK 28, Magisk 30.7)**:

| Control | Target value |
|---|---|
| SSID | **RNS** |
| Security | Open (no password) |
| Band / channel | 2.4 GHz, **channel 6** |
| Max clients | **128** |
| Automation | Apply on boot + every time hotspot starts, ideally with a UI |

---

## 1. Option A — Normal (unprivileged) APK

### What Android 9 legally allows a normal app
- `WifiManager.startLocalOnlyHotspot()` → only a *local-only* hotspot, random SSID, dies when the app goes background. **Not our use-case.**
- `ConnectivityManager.startTethering()` → **hidden API**, guarded by `android.permission.TETHER_PRIVILEGED` (added in Android 9, `signature|privileged`). Normal apps cannot hold it.
- `WifiManager.setWifiApConfiguration()` → deprecated **@hide** method; on Pie it is on the hidden-API list. Even if you bypass it with reflection hacks (freeReflection/HiddenApiBypass), the framework still re-generates everything on its own schedule.
- Android 9 enforces the **hidden-API blacklist by default**, so reflection routes are fragile and break on updates.

### What a normal APK can NEVER control, even with hacks
- **Specific channel (6)** — the framework picks the channel; there is no public API for it.
- **max_num_sta (128)** — not in `WifiConfiguration`/`SoftApConfiguration` at all; it is written into `hostapd_ap0.conf` by `MtkSoftApManager` from vendor defaults.
- Guaranteed persistence across hotspot toggles.

### Verdict A
❌ **A normal APK alone cannot do this project.** It can at best be a *settings shortcut* / status viewer. The privileged work (patching `hostapd_ap0.conf`, reloading hostapd, NAT checks) needs root either way — and we already HAVE root, so there is no reason to limit ourselves to public APIs.

---

## 2. Option B — System app (`/system/priv-app`)

### How it would work
1. Build APK, sign it (regular debug/platform-agnostic signature).
2. Push to `/system/priv-app/RnsHotspot/RnsHotspot.apk`.
3. Add a privileged-permission whitelist:
   `/system/etc/permissions/privapp-permissions-rns.xml` granting `TETHER_PRIVILEGED`.
4. The app could then call hidden tethering APIs legally.

### Problems on THIS device
- **`/system` is dm-verity protected.** Direct writes need remount + verity disable; mistakes cause bootloops. Magisk *can* inject files systemlessly (a module with a `system/` folder), but then you are already building a Magisk module anyway.
- Missing whitelist entry or wrong permission = log spam / hard-fail on some MTK ROMs.
- **OTA updates break** when /system is modified.
- Still only gets you framework APIs: SSID ✔, open ✔, band ✔ — but **no channel choice, no max_num_sta**. Those still require patching `hostapd_ap0.conf` → back to root file-patching.
- Hard to uninstall cleanly, hard to update.

### Verdict B
❌ **Not worth it.** Highest risk (verity/OTA/brick), and it STILL doesn't unlock channel + max-client control. A system app gives zero advantage over the root approach on a phone that is already rooted.

---

## 3. Option C — Magisk module with UI

This is where the project already lives (`RNS_Hotspot.zip` = the engine). The only question is *what form the UI takes*.

### C1. Pure-shell UI (no UI at all)
Termux one-liners only. Fine for the developer, unusable for daily operation. ❌

### C2. Web UI inside the module
Module runs `busybox httpd` on `127.0.0.1:8080` with tiny CGI scripts:
- `GET /status` → hostapd process, `iw dev ap0 info`, ARP clients, dnsmasq leases, NAT counters
- `POST /apply` → writes config, patches conf, `hostapd_cli RELOAD`

✔ No APK to install. ✖ Clunky UX (open a browser, type localhost), no notifications, no background monitoring. ⚠️ Acceptable fallback only.

### C3. Companion APK (normal install) + Magisk module (root engine) ← **RECOMMENDED**
Split the architecture the way mature rooted projects do (Viper4Android, KernelAdiutor style):

```
┌──────────────────────────────┐          ┌─────────────────────────────────────┐
│  RNS Hotspot APK (user app)  │   su     │  RNS_Hotspot Magisk module (engine) │
│  • SSID/band/channel/clients │ ───────► │  • reads /data/adb/rns/config       │
│  • open/WPA toggle           │          │  • inotifyd on hostapd dir          │
│  • start/stop hotspot        │          │  • patches hostapd_ap0.conf         │
│  • live status: clients,     │ ◄─────── │  • hostapd_cli -i ap0 RELOAD        │
│    IPs, traffic, log viewer  │   su     │  • NAT/forward sanity checks        │
└──────────────────────────────┘          │  • boot-persistent service.sh       │
                                          └─────────────────────────────────────┘
```

- APK is installed **normally** (no system changes) but uses **root via `su`** (library: TopJohnwu `libsu`) for every privileged action. Magisk Superuser controls the grant.
- Module survives/fixes the race condition **without** needing the APK at all (boot-time automation keeps working even if the app is uninstalled).
- ✔ Full UI + notifications + widgets. ✔ OTA-safe, systemless, clean uninstall (module disable/remove + app uninstall). ✔ Every target control achievable (channel 6 and 128 clients included, because we own the conf file).

### The race condition — solved inside the module (mandatory fix for ALL options)
Evidence from `hotspot_log.txt`: framework writes `hostapd_ap0.conf` and hostapd reads it within **~50 ms** (11:55:58.230 → 11:55:58.251). Current `service.sh` polls every 1 s → **too late**. Fix, two layers:

1. **Upstream hook (no race):** framework reads `/data/misc/wifi/softap.conf` (31-byte legacy store, seen in `hotspot_report.txt`) *before* generating the hostapd conf. Engine writes SSID/band/security there.
2. **Downstream hook (catch-all):** `busybox inotifyd` on `/data/vendor/wifi/hostapd/` → instant patch of `hostapd_ap0.conf` (ssid2=524e53, channel=6, hw_mode=g, max_num_sta=128, strip WPA lines) → `/vendor/bin/hostapd_cli -i ap0 RELOAD` so changes apply to the *running* AP.

---

## 4. Comparison

| Criterion | A. Normal APK | B. System app | C2. Magisk + Web UI | C3. Magisk + APK ✅ |
|---|---|---|---|---|
| Set SSID "RNS" | ⚠️ unreliable hacks | ✔ | ✔ | ✔ |
| Open network | ⚠️ | ✔ | ✔ | ✔ |
| Force channel 6 | ❌ impossible | ❌ no API | ✔ (conf patch) | ✔ (conf patch) |
| 128 max clients | ❌ impossible | ❌ no API | ✔ | ✔ |
| Boot persistence | ❌ | ✔ | ✔ | ✔ |
| UI / UX | app-like | app-like | browser, clunky | **app-like** |
| Install risk | none | **high** (verity/OTA) | low | low |
| Clean uninstall | ✔ | ✖ | ✔ | ✔ |
| Effort | small but useless | large | medium | medium |

---

## 5. FINAL VERDICT

> **Do NOT make a normal APK alone (it physically can't control channel/client-limit), and do NOT convert it to a system app (maximum risk, zero extra power).**
> **Build it as a Magisk module (root engine, already 70 % done in `RNS_Hotspot.zip`) + a small companion APK for the UI that talks to the engine through `su`.**
> If you want zero APK, the fallback is the same module with a localhost web UI — same engine, worse UX.

### Implementation plan (ordered)
1. **Fix the engine first** (works with or without UI): rewrite `service.sh` → inotifyd watcher + `hostapd_cli RELOAD` + `softap.conf` writer + status file `/data/adb/rns/status`.
2. Flash, verify SSID=RNS / ch6 / open / clients connect (proves the foundation).
3. Build the companion APK (Kotlin, `libsu`): screens = Config, Start/Stop, Live Clients, Logs; writes `/data/adb/rns/config`, triggers engine, polls status file.
4. Optional later: Magisk boot-splash free — keep it simple.
