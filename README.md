# MAGISK-RNS

Root/Magisk hotspot-control project for a rooted **Infinix HOT 8 (X650C, MT6765, Android 9)** — goal: force a custom open 2.4 GHz hotspot named **"RNS"** (channel 6, raised client limit) via a Magisk module that live-patches MTK's generated `hostapd_ap0.conf`, and eventually layer a **voucher / captive-portal billing system** on top of it.

This repo holds the full Termux/logcat/dumpsys evidence trail (2026-09-23 → 25) plus the `RNS_Hotspot` Magisk module zip.

📄 **Read [`FINALANALYSIS.md`](FINALANALYSIS.md) — the master consolidated analysis (complete file inventory, confirmed facts, open questions, corrections, and next steps).**

Platform folders:

- [`infinix-hot-8-magisk-module/`](infinix-hot-8-magisk-module/) — the HOT 8 Magisk module (`module.prop`, `service.sh`), extracted from `RNS_Hotspot.zip`.
- [`routeros/`](routeros/) — the 24/7, 200-user build: RB5009, PoE switch, 11 wired APs.
- [`linux/`](linux/) — lab only. The same stack works here. It is not the shop.
- [`windows/`](windows/) — not a target. Kept so the dead end is written down.

Secondary docs:
- [`DOCUMENTATION.md`](DOCUMENTATION.md) — original file-by-file analysis and the APK-vs-system-app-vs-Magisk architecture decision (superseded in places by FINALANALYSIS.md §12).
- [`RNS - Rooted Hotspot Billing App.md`](RNS%20-%20Rooted%20Hotspot%20Billing%20App.md) — the full verbatim project transcript (idea → recon → manual AP → stock-hotspot reverse engineering → Magisk module build & install).
