#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from spes/spesn device
$(call inherit-product, device/xiaomi/spes/device.mk)

# Inherit some common SuperiorOS Extended stuff.
$(call inherit-product, vendor/superior/config/common.mk)

# Product Specifics
PRODUCT_NAME := superior_spes
PRODUCT_DEVICE := spes
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Note 11
PRODUCT_MANUFACTURER := Xiaomi

# Superior Official Stuff
TARGET_BOOT_ANIMATION_RES := 1080
TARGET_FACE_UNLOCK_SUPPORTED := true
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
TARGET_INCLUDE_PIXEL_CHARGER := true
BUILD_WITH_GAPPS := true

# Maintainer
PRODUCT_SYSTEM_PROPERTIES += \
     ro.spos.maintainer=Jashkirat Virdi

# Overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay-lineage

# LiveDisplay
PRODUCT_PACKAGES += \
    vendor.lineage.livedisplay@2.0-service-sdm
