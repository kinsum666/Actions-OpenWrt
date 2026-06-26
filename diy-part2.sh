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

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# ========== 修正设备名和 DTS 文件 ==========
echo "开始修正设备名和 DTS 文件..."

# 1. 修改 ipq60xx.mk（将下划线改为连字符，并设置 DEVICE_DTS）
MK_FILE="target/linux/qualcommax/image/ipq60xx.mk"
if [ -f "$MK_FILE" ]; then
    cp "$MK_FILE" "$MK_FILE.bak"
    # 将设备名中的下划线改为连字符
    sed -i 's/jdcloud_re-ss-01/jdcloud-re-ss-01/g' "$MK_FILE"
    sed -i 's/ipq-wifi-jdcloud_re-ss-01/ipq-wifi-jdcloud-re-ss-01/g' "$MK_FILE"

    # 确保设备定义块中包含 DEVICE_DTS := ipq6000-jdcloud-re-ss-01
    # 先删除可能存在的旧 DEVICE_DTS 行（包含 qcom/ 或其它）
    sed -i '/^define Device\/jdcloud-re-ss-01/,/^endef/ { /DEVICE_DTS/d; }' "$MK_FILE"
    # 在 endef 前插入新行
    sed -i '/^define Device\/jdcloud-re-ss-01/,/^endef/ { /^endef/ i\	DEVICE_DTS := ipq6000-jdcloud-re-ss-01
    }' "$MK_FILE"

    echo "✅ ipq60xx.mk 已修改，并添加 DEVICE_DTS"
else
    echo "⚠️ 未找到 ipq60xx.mk，跳过"
fi

# 2. 查找 DTS 源文件（优先从 $GITHUB_WORKSPACE/patch/ 获取）
DTS_SRC=""
if [ -n "$GITHUB_WORKSPACE" ] && [ -f "$GITHUB_WORKSPACE/patch/ipq6000-jdcloud-re-ss-01.dts" ]; then
    DTS_SRC="$GITHUB_WORKSPACE/patch/ipq6000-jdcloud-re-ss-01.dts"
    echo "✅ 在 \$GITHUB_WORKSPACE/patch/ 找到 DTS 源文件"
else
    # 检查当前目录下的 patch/（兼容本地运行）
    if [ -f "patch/ipq6000-jdcloud-re-ss-01.dts" ]; then
        DTS_SRC="patch/ipq6000-jdcloud-re-ss-01.dts"
        echo "✅ 在当前目录的 patch/ 下找到 DTS 源文件"
    else
        echo "⚠️ patch/ 目录下未找到，尝试在 target/linux/qualcommax 中搜索..."
        DTS_CANDIDATE=$(find target/linux/qualcommax -name "ipq6000-jdcloud-re-ss-01.dts" 2>/dev/null | head -n1)
        if [ -n "$DTS_CANDIDATE" ]; then
            DTS_SRC="$DTS_CANDIDATE"
        else
            DTS_CANDIDATE=$(find target/linux/qualcommax -name "ipq6000-jdcloud_re-ss-01.dts" 2>/dev/null | head -n1)
            if [ -n "$DTS_CANDIDATE" ]; then
                DTS_SRC="$DTS_CANDIDATE"
            fi
        fi
    fi
fi

# 3. 如果找到 DTS，复制到 files/ 目录（构建系统使用的路径，注意不带 qcom/）
if [ -n "$DTS_SRC" ]; then
    DTS_DEST_DIR="target/linux/qualcommax/files/arch/arm64/boot/dts"
    mkdir -p "$DTS_DEST_DIR"
    DTS_DEST="$DTS_DEST_DIR/ipq6000-jdcloud-re-ss-01.dts"
    cp "$DTS_SRC" "$DTS_DEST"
    echo "✅ DTS 文件已复制到 $DTS_DEST"
else
    echo "❌ 错误：未找到任何 jdcloud 的 DTS 源文件！"
    echo "   请将 ipq6000-jdcloud-re-ss-01.dts 放在 $GITHUB_WORKSPACE/patch/ 或 openwrt/patch/ 下"
    exit 1
fi

# 4. 最终校验：目标文件是否成功创建
if [ -f "target/linux/qualcommax/files/arch/arm64/boot/dts/ipq6000-jdcloud-re-ss-01.dts" ]; then
    echo "✅ 最终校验通过：DTS 文件已就位"
else
    echo "❌ 错误：未能成功创建 ipq6000-jdcloud-re-ss-01.dts，编译将失败！"
    exit 1
fi

echo "修正完成。"
echo "建议执行以下命令清理并重新编译："
echo "  make target/linux/clean"
echo "  make target/linux/compile"
