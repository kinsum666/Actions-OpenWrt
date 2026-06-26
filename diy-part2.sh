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

# ========== 修正设备名和 DTS 文件 ==========
echo "开始修正设备名和 DTS 文件..."

# 1. 备份并修改 ipq60xx.mk（将下划线改为连字符）
MK_FILE="target/linux/qualcommax/image/ipq60xx.mk"
if [ -f "$MK_FILE" ]; then
    cp "$MK_FILE" "$MK_FILE.bak"
    sed -i 's/jdcloud_re-ss-01/jdcloud-re-ss-01/g' "$MK_FILE"
    sed -i 's/ipq-wifi-jdcloud_re-ss-01/ipq-wifi-jdcloud-re-ss-01/g' "$MK_FILE"
    echo "✅ ipq60xx.mk 已修改"
else
    echo "⚠️ 未找到 ipq60xx.mk，跳过"
fi

# 2. 查找 DTS 源文件（优先从 patch/ 目录获取，其次在 target/linux/qualcommax 下搜索）
DTS_SRC=""
if [ -f "patch/ipq6000-jdcloud-re-ss-01.dts" ]; then
    DTS_SRC="patch/ipq6000-jdcloud-re-ss-01.dts"
    echo "✅ 在 patch/ 目录找到 DTS 源文件"
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

# 3. 如果找到 DTS，将其复制到 files/ 目录（构建系统实际使用的路径）
if [ -n "$DTS_SRC" ]; then
    DTS_DEST_DIR="target/linux/qualcommax/files/arch/arm64/boot/dts/qcom"
    mkdir -p "$DTS_DEST_DIR"
    DTS_DEST="$DTS_DEST_DIR/ipq6000-jdcloud-re-ss-01.dts"
    cp "$DTS_SRC" "$DTS_DEST"
    echo "✅ DTS 文件已复制到 $DTS_DEST"
else
    echo "❌ 错误：未找到任何 jdcloud 的 DTS 源文件！"
    echo "   请手动将 ipq6000-jdcloud-re-ss-01.dts 放入 patch/ 目录"
    echo "   或放入 target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"
    echo "   或检查补丁是否正确应用。"
fi

# 4. 最终校验：目标文件是否存在
if [ -f "target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6000-jdcloud-re-ss-01.dts" ]; then
    echo "✅ 最终校验通过：DTS 文件已就位"
else
    echo "❌ 错误：未能成功创建 ipq6000-jdcloud-re-ss-01.dts，编译将失败！"
    exit 1
fi

echo "修正完成。"
echo "建议执行以下命令清理并重新编译："
echo "  make target/linux/clean"
echo "  make target/linux/compile"
