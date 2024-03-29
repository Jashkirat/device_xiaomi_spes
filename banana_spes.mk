#
# Copyright (C) 2022 The BananaDroid Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from spes/spesn device
$(call inherit-product, device/xiaomi/spes/device.mk)

# Inherit some common BananaDroid stuff.
$(call inherit-product, vendor/banana/config/common.mk)

# Product Specifics
PRODUCT_NAME := banana_spes
PRODUCT_DEVICE := spes
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Note 11
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# BananaDroid
BANANA_MAINTAINER := JassiV07
TARGET_BOOT_ANIMATION_RES := 1080

# Overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay-lineage

# LiveDisplay
PRODUCT_PACKAGES += \
    vendor.lineage.livedisplay@2.0-service-sdm
