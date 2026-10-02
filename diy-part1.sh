#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
# 修改 Newifi D2 DTS 16M → 64M
sed -i 's,reg = <0x050000 0x1fb0000>,reg = <0x050000 0x3fb0000>,g' target/linux/ramips/dts/mt7621_d-team_newifi-d2.dts
sed -i 's/IMAGE_SIZE := $(ralink_default_fw_size_32M)/IMAGE_SIZE := $(ralink_default_fw_size_64M)/g' target/linux/ramips/image/Makefile
sed -i '/ralink_default_fw_size_32M/a ralink_default_fw_size_64M=67108864' target/linux/ramips/image/Makefile
