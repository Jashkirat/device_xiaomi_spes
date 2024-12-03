# ROM source patches

color="\033[0;32m"
end="\033[0m"

echo -e "${color}Applying patches${end}"
sleep 1

# Remove pixel headers to avoid conflicts
rm -rf hardware/google/pixel/kernel_headers/Android.bp

# Remove hardware/lineage/compat to avoid conflicts
rm -rf hardware/lineage/compat/Android.bp

# Kernel & Vendor Sources
git clone https://github.com/sayann70/vendor_xiaomi_spes -b 15 vendor/xiaomi/spes
git clone https://github.com/muralivijay/kernel_xiaomi_sm6225 kernel/xiaomi/sm6225

# MiuiCamera(Lecia 5.0)
git clone https://gitlab.com/ItzDFPlayer/vendor_xiaomi_miuicamera -b leica-5.0 vendor/xiaomi/miuicamera

# Sepolicy fix for imsrcsd
echo -e "${color}Switch back to legacy imsrcsd sepolicy${end}"
rm -rf device/qcom/sepolicy_vndr/legacy-um/qva/vendor/bengal/ims/imsservice.te
cp device/qcom/sepolicy_vndr/legacy-um/qva/vendor/bengal/legacy-ims/hal_rcsservice.te device/qcom/sepolicy_vndr/legacy-um/qva/vendor/bengal/ims/hal_rcsservice.te

# Custom KeyGen
#curl -O https://raw.githubusercontent.com/ofcsayan/Key-Gen-signed-script/main/generate_all_keys.sh
#chmod +x generate_all_keys.sh
#./generate_all_keys.sh

# Rename conflicting qti_kernel_headers in source
sed -i 's/"qti_kernel_headers"/"qti_kernel_headers_old"/g' vendor/lineage/build/soong/Android.bp
