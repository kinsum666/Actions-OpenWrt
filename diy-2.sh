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
sed -i 's/192.168.1.1/192.168.50.1/g' package/base-files/files/bin/config_generate

sed -i 's/jdcloud_re-ss-01/jdcloud-re-ss-01/g' target/linux/qualcommax/image/ipq60xx.mk
# 同时修改 .config 中的设备符号
sed -i 's/CONFIG_TARGET_DEVICE_qualcommax_ipq60xx_DEVICE_jdcloud_re-ss-01=y/CONFIG_TARGET_DEVICE_qualcommax_ipq60xx_DEVICE_jdcloud-re-ss-01=y/g' .config

