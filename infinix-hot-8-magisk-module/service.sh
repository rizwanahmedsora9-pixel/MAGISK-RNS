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


    # wait for AP interface
    sleep 1


    if ip link show ap0 >/dev/null 2>&1
    then
        IP=$(ip addr show ap0 | grep "inet " | awk '{print $2}')

        echo "$(date) AP IP $IP" >> $LOG
    fi


    # prevent endless patching
    sleep 10

fi

sleep 1

done

) &
