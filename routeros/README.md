# RouterOS

This is the 24/7, 200-user build. The Infinix and a Windows or Linux PC are not.

## Shape

Eleven access points is a sane radio count, about 18 phones each. Ten of them must not hang off one access point. A ceiling AP has one Ethernet port, and a wireless backhaul would put all 200 phones on one radio.

```
Fiber / PTCL
      |
  RB5009                 vouchers, kick, DHCP, NAT. No Wi-Fi job.
      |  one cable
  16-port PoE switch     the thing the APs connect to
      |
  11 access points       bridge mode, same SSID: RNS, cable each one
```

APs must not run their own DHCP or NAT. The RB5009 has to see every phone MAC, or the voucher and the kick only work for some APs.

## Buy

- Main board: MikroTik RB5009 (1 GB RAM, fanless, about 14 W). Pakistan listings seen around Rs 61,000–73,000.
- License: a normal RB5009 is level 4, which stops at **200 active hotspot users**. That is the ceiling, not headroom. A second device per person blows past it. Buy the level-5 upgrade (500 hotspot users) before calling it a 200-user network.
- Switch: 16-port PoE, about 150 W budget. An 8-port switch does not have the ports or the power for 11 APs.
- Radios: 11 wired APs in bridge mode. TP-Link EAP610 or EAP225 is the cheap set. Same SSID `RNS`. No mesh, no repeater.
- Internet: fiber into the RB5009 WAN. The Jazz phone cannot feed 200 users.
- Power: one small UPS on the RB5009, the switch, and the fiber modem. A phone power bank cannot run the PoE switch.

## Radio rules

Use 5 GHz for the phones. 2.4 GHz only has three clean channels, so eleven APs left on high power will shout over each other. Spread them and turn the power down.

Configs for the RB5009 hotspot and the AP bridge profile go in this folder when they are written. Nothing is flashed yet.
