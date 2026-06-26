#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# 备份原文件
cp target/linux/qualcommax/image/ipq60xx.mk target/linux/qualcommax/image/ipq60xx.mk.bak

# 将所有 jdcloud_re-ss-01 替换为 jdcloud-re-ss-01
sed -i 's/jdcloud_re-ss-01/jdcloud-re-ss-01/g' target/linux/qualcommax/image/ipq60xx.mk

# 同时将可能存在的包名 ipq-wifi-jdcloud_re-ss-01 也改为 ipq-wifi-jdcloud-re-ss-01（如果有）
sed -i 's/ipq-wifi-jdcloud_re-ss-01/ipq-wifi-jdcloud-re-ss-01/g' target/linux/qualcommax/image/ipq60xx.mk
