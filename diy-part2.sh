#!/bin/bash
set -e

echo "===== DIY Part2 ====="

# 修改默认IP
sed -i 's/192.168.1.1/192.168.50.1/g' \
package/base-files/files/bin/config_generate

echo "===== Target Check ====="

make defconfig

echo
echo "Selected target:"
grep "^CONFIG_TARGET" .config

echo
echo "Selected device:"
grep "^CONFIG_TARGET_DEVICE" .config

echo
echo "JDCloud devices in source:"
grep -n "define Device" target/linux/qualcommax/image/ipq60xx.mk | grep jdcloud || true

echo
echo "===== End ====="
