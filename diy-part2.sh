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

# ========== 修正设备名和 DTS 文件 ==========
echo "开始修正设备名和 DTS 文件..."

MK_FILE="target/linux/qualcommax/image/ipq60xx.mk"

# 1. 统一设备名为连字符版本（jdcloud-re-ss-01）
if [ -f "$MK_FILE" ]; then
    cp "$MK_FILE" "$MK_FILE.bak"
    sed -i 's/jdcloud_re-ss-01/jdcloud-re-ss-01/g' "$MK_FILE"
    sed -i 's/ipq-wifi-jdcloud_re-ss-01/ipq-wifi-jdcloud-re-ss-01/g' "$MK_FILE"
    echo "✅ ipq60xx.mk 设备名已统一为 jdcloud-re-ss-01"
else
    echo "⚠️ 未找到 ipq60xx.mk，跳过"
fi

# 2. 确定 DTS 源文件（官方优先）
DTS_DEST_DIR="target/linux/qualcommax/dts"
OFFICIAL_DTS="$DTS_DEST_DIR/ipq6000-re-ss-01.dts"
PATCH_DTS="patch/ipq6000-re-ss-01.dts"
DTS_SRC=""
DTS_DEST=""
DEVICE_DTS_VALUE="ipq6000-re-ss-01"   # 默认值，不包含路径前缀

if [ -f "$OFFICIAL_DTS" ]; then
    DTS_SRC="$OFFICIAL_DTS"
    echo "✅ 使用官方自带的 DTS: $DTS_SRC"
else
    # 尝试从 patch/ 目录获取
    if [ -n "$GITHUB_WORKSPACE" ] && [ -f "$GITHUB_WORKSPACE/$PATCH_DTS" ]; then
        DTS_SRC="$GITHUB_WORKSPACE/$PATCH_DTS"
    elif [ -f "$PATCH_DTS" ]; then
        DTS_SRC="$PATCH_DTS"
    elif [ -f "../$PATCH_DTS" ]; then
        DTS_SRC="../$PATCH_DTS"
    else
        # 最后尝试在 target/linux/qualcommax 中搜索任何相关文件（以防万一）
        DTS_SRC=$(find target/linux/qualcommax -name "ipq6000-re-ss-01.dts" -o -name "ipq6000-jdcloud*.dts" 2>/dev/null | head -n1)
    fi

    if [ -n "$DTS_SRC" ]; then
        # 复制到 dts/ 根目录（不带 qcom/ 子目录）
        mkdir -p "$DTS_DEST_DIR"
        DTS_DEST="$DTS_DEST_DIR/ipq6000-re-ss-01.dts"
        cp "$DTS_SRC" "$DTS_DEST"
        echo "✅ 从 $DTS_SRC 复制到 $DTS_DEST"
    else
        echo "❌ 错误：未找到任何可用的 DTS 源文件！"
        echo "   请确保 patch/ipq6000-re-ss-01.dts 存在"
        exit 1
    fi
fi

# 3. 修改 ipq60xx.mk 中的 DEVICE_DTS 设置（统一为无前缀的 ipq6000-re-ss-01）
if [ -f "$MK_FILE" ]; then
    # 删除现有的 DEVICE_DTS 行
    sed -i '/^define Device\/jdcloud-re-ss-01/,/^endef/ { /DEVICE_DTS/d; }' "$MK_FILE"
    # 插入新的 DEVICE_DTS（使用 Tab 缩进）
    sed -i "/^define Device\/jdcloud-re-ss-01/,/^endef/ { /^endef/ i\\\tDEVICE_DTS := $DEVICE_DTS_VALUE
    }" "$MK_FILE"
    echo "✅ 已设置 DEVICE_DTS := $DEVICE_DTS_VALUE"
else
    echo "⚠️ 未找到 ipq60xx.mk，无法设置 DEVICE_DTS"
fi

# 4. 最终校验：确保目标文件存在
if [ -f "$OFFICIAL_DTS" ] || [ -f "$DTS_DEST" ]; then
    echo "✅ 最终校验通过：DTS 文件已就位 ($([ -f "$OFFICIAL_DTS" ] && echo "$OFFICIAL_DTS" || echo "$DTS_DEST"))"
else
    echo "❌ 错误：DTS 文件未正确放置，编译将失败！"
    exit 1
fi

echo "修正完成。"
