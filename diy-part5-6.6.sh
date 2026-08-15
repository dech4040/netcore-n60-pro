#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part5-6.6.sh
# Description: OpenWrt DIY script part 5 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

DEFAULT_IP="192.168.0.1"
HOSTNAME="N60Pro"
WIFI_SSID_2G="N60Pro-2.4G"
WIFI_SSID_5G="N60Pro-5G"
WIFI_PASSWORD="12345678"

# Modify default IP
sed -i "s/192.168.1.1/${DEFAULT_IP}/g" package/base-files/files/bin/config_generate

# Modify default theme
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i "s/OpenWrt/${HOSTNAME}/g" package/base-files/files/bin/config_generate

# 添加组播防火墙规则
cat >> package/network/config/firewall/files/firewall.config <<EOF

config rule
        option name 'Allow-UDP-igmpproxy'
        option src 'wan'
        option dest 'lan'
        option dest_ip '224.0.0.0/4'
        option proto 'udp'
        option target 'ACCEPT'
        option family 'ipv4'

config rule
        option name 'Allow-UDP-udpxy'
        option src 'wan'
        option dest_ip '224.0.0.0/4'
        option proto 'udp'
        option target 'ACCEPT'
EOF

# Turn on wifi and set up SSID and password
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-enable-wifi << EOF
#!/bin/sh

sleep 5

# Turn on wifi
uci set wireless.radio0.disabled='0'
uci set wireless.radio1.disabled='0'

# 2.4 GHz
uci set wireless.default_radio0.ssid='${WIFI_SSID_2G}'
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio0.key='${WIFI_PASSWORD}'
uci set wireless.default_radio0.disabled='0'

# 5 GHz
uci set wireless.default_radio1.ssid='${WIFI_SSID_5G}'
uci set wireless.default_radio1.encryption='psk2'
uci set wireless.default_radio1.key='${WIFI_PASSWORD}'
uci set wireless.default_radio1.disabled='0'

uci commit wireless
/sbin/wifi up

exit 0
EOF

chmod +x files/etc/uci-defaults/99-enable-wifi

echo "diy-part5-6.6.sh DONE"
