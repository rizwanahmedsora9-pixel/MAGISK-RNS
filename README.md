# MAGISK-RNS

Root/Magisk hotspot-control project for a rooted **Infinix HOT 8 (X650C, MT6765, Android 9)** — goal: force a custom open 2.4 GHz hotspot named **"RNS"** (channel 6, raised client limit) via a Magisk module that live-patches MTK's generated `hostapd_ap0.conf`, and eventually layer a **voucher / captive-portal billing system** on top of it.

This repo holds the full Termux/logcat/dumpsys evidence trail (2026-09-23 → 25) plus the `RNS_Hotspot` Magisk module zip.

📄 **Read [`FINALANALYSIS.md`](FINALANALYSIS.md) — the master consolidated analysis (complete file inventory, confirmed facts, open questions, corrections, and next steps).**

Secondary docs:
- [`DOCUMENTATION.md`](DOCUMENTATION.md) — original file-by-file analysis and the APK-vs-system-app-vs-Magisk architecture decision (superseded in places by FINALANALYSIS.md §12).
- [`RNS - Rooted Hotspot Billing App.md`](RNS%20-%20Rooted%20Hotspot%20Billing%20App.md) — the full verbatim project transcript (idea → recon → manual AP → stock-hotspot reverse engineering → Magisk module build & install).
