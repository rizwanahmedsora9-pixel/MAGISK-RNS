# Infinix HOT 8 — Magisk module

Phone: **Infinix HOT 8 (X650C, MT6765, Android 9)**, Magisk 30.7.

`module.prop` and `service.sh` are the v1.0 module, extracted from `../RNS_Hotspot.zip`. That zip is the original artifact. Edit the files in this folder, then rebuild the zip from here:

```sh
cd infinix-hot-8-magisk-module
zip -r ../RNS_Hotspot.zip module.prop service.sh
```

`module.prop` must stay at the zip root. A nested folder makes Magisk say "This zip is not a Magisk module!"

## What v1.0 tries to do

When `/data/vendor/wifi/hostapd/hostapd_ap0.conf` exists, patch it to:

- SSID `RNS` (`ssid2=524e53`)
- 2.4 GHz, channel 6 (`hw_mode=g`)
- open network (strip `wpa*` lines)
- `max_num_sta=128`

## What is not proven

The module installed on the second attempt. No capture yet shows a live AP named `RNS`. The loop polls every 1 second. The phone rewrites the conf and hostapd reads it in about 21 ms, so the patch usually loses. `service.sh` never runs `/vendor/bin/hostapd_cli -i ap0 RELOAD`. `kill -HUP` does not reload this hostapd.

The voucher page, MAC bind, expiry, and kick are not in this module. They are design only.

## Do not use this phone for the shop

One radio. No concurrent station + AP. Charging all day swells the battery. Android kills the hotspot. A few dozen phones is the realistic ceiling, and 128 in the conf is not a real client limit. The 200-user, 24/7 build belongs in `../routeros/`.
