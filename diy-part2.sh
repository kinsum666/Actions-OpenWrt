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
sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# ========== 修正设备名和 DTS 文件名 ==========
echo "开始修正设备名和 DTS 文件..."

# 1. 备份并修改 ipq60xx.mk，将 jdcloud_re-ss-01 统一改为 jdcloud-re-ss-01
if [ -f "target/linux/qualcommax/image/ipq60xx.mk" ]; then
    cp target/linux/qualcommax/image/ipq60xx.mk target/linux/qualcommax/image/ipq60xx.mk.bak
    sed -i 's/jdcloud_re-ss-01/jdcloud-re-ss-01/g' target/linux/qualcommax/image/ipq60xx.mk
    sed -i 's/ipq-wifi-jdcloud_re-ss-01/ipq-wifi-jdcloud-re-ss-01/g' target/linux/qualcommax/image/ipq60xx.mk
    echo "✅ ipq60xx.mk 已修改"
else
    echo "⚠️ 未找到 ipq60xx.mk，跳过"
fi

# 2. 查找并重命名 DTS 文件（下划线 → 连字符）
DTS_FILE=$(find target/linux/qualcommax -name "ipq6000-jdcloud_re-ss-01.dts" 2>/dev/null | head -n1)
if [ -n "$DTS_FILE" ]; then
    DTS_DIR=$(dirname "$DTS_FILE")
    mv "$DTS_FILE" "$DTS_DIR/ipq6000-jdcloud-re-ss-01.dts"
    echo "✅ DTS 文件已重命名: $DTS_FILE -> $DTS_DIR/ipq6000-jdcloud-re-ss-01.dts"
else
    echo "⚠️ 未找到 ipq6000-jdcloud_re-ss-01.dts，尝试查找是否已经是连字符版本..."
    # 检查是否已存在连字符版本（可能已经存在，那就无需操作）
    if [ -f "$(find target/linux/qualcommax -name "ipq6000-jdcloud-re-ss-01.dts" 2>/dev/null | head -n1)" ]; then
        echo "✅ 已存在 ipq6000-jdcloud-re-ss-01.dts，无需重命名"
    else
        echo "❌ 未找到任何 jdcloud 的 DTS 文件，编译可能会失败"
    fi
fi

echo "修正完成。"
