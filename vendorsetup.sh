#!/bin/bash

color="\033[0;32m"
end="\033[0m"

echo -e "${color}Applying patches${end}"
sleep 1

# Remove pixel headers to avoid conflicts
rm -rf hardware/google/pixel/kernel_headers/Android.bp

# Remove hardware/lineage/compat to avoid conflicts
rm -rf hardware/lineage/compat/Android.bp

# Sepolicy fix for imsrcsd
echo -e "${color}Switch back to legacy imsrcsd sepolicy${end}"
rm -rf device/qcom/sepolicy_vndr/legacy-um/qva/vendor/bengal/ims/imsservice.te
cp device/qcom/sepolicy_vndr/legacy-um/qva/vendor/bengal/legacy-ims/hal_rcsservice.te device/qcom/sepolicy_vndr/legacy-um/qva/vendor/bengal/ims/hal_rcsservice.te

# Rename conflicting qti_kernel_headers in source
sed -i 's/"qti_kernel_headers"/"qti_kernel_headers_old"/g' vendor/lineage/build/soong/Android.bp

# Clone specific repositories for (spes|spesn)
echo -e "${color}Cloning vendor and kernel trees for spes|spesn${end}"

# Clone vendor tree
if [ ! -d "vendor/xiaomi/spes" ]; then
    git clone https://github.com/Jabiyeff/android_vendor_xiaomi_spes vendor/xiaomi/spes
else
    echo -e "${color}vendor/xiaomi/spes already exists, skipping clone${end}"
fi

# Clone kernel tree
if [ ! -d "kernel/xiaomi/sm6225" ]; then
    git clone https://github.com/Jabiyeff/kernel_xiaomi_sm6225 kernel/xiaomi/sm6225
else
    echo -e "${color}kernel/xiaomi/sm6225 already exists, skipping clone${end}"
fi

# Replace hardware/xiaomi
echo -e "${color}Resetting hardware/xiaomi${end}"
rm -rf hardware/xiaomi
git clone https://github.com/LineageOS/android_hardware_xiaomi hardware/xiaomi

echo -e "${color}All done.${end}"