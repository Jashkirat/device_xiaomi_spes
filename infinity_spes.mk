#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from spes/spesn device
$(call inherit-product, device/xiaomi/spes/device.mk)

# Inherit some common Project Infinity-X stuff.
$(call inherit-product, vendor/infinity/config/common_full_phone.mk)

# Product Specifics
PRODUCT_NAME := infinity_spes
PRODUCT_DEVICE := spes
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Note 11
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# Boot Animaton
TARGET_BOOT_ANIMATION_RES := 1080

# Project InfinityX Flags
WITH_GAPPS := true
INFINITY_MAINTAINER := JASSIV07
INFINITY_BUILD_TYPE := OFFICIAL
TARGET_SUPPORTS_QUICK_TAP := true
TARGET_SUPPORTS_BLUR := true

# Overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay-lineage

# Fingerprint
BUILD_FINGERPRINT := "Redmi/spes/spes:13/TKQ1.221114.001/V816.0.7.0.TGCMIXM:user/release-keys"
