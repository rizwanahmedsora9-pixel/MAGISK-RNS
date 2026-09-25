# Linux

This is the lab copy of the RNS stack, not the 200-user shop.

The tools are the normal Linux ones: `hostapd`, `dnsmasq`, `nftables` or `iptables`, and a small voucher page. That is cleaner than the Infinix, because nothing rewrites the config behind your back.

Limits:

- The PC's built-in Wi-Fi often cannot be the access point and the internet source at the same time.
- A USB access-point adapter is required. Random Realtek "300 Mbps" sticks usually fail. MediaTek or Atheros sticks usually work.
- One dongle is comfortable around 8–32 phones, not 200.
- A laptop sleeps, heats, and is a bad box to leave on. A fanless mini PC is acceptable only as the billing brain, with real access points in front of it.

For 200 users and 24/7, use `../routeros/` plus wired access points. This folder is for proving the portal, the voucher database, and the kick on a machine you already have.
