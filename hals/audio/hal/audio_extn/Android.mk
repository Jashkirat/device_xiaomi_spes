ifneq ($(strip $(TARGET_PROVIDES_AUDIO_EXTNS)),true)

#AudioHal-primaryHal-Hal path
ifneq ($(BOARD_OPENSOURCE_DIR), )
  PRIMARY_HAL_PATH := $(BOARD_OPENSOURCE_DIR)/audio-hal/primary-hal/hal
  AUDIO_KERNEL_INC := $(TARGET_OUT_INTERMEDIATES)/$(BOARD_OPENSOURCE_DIR)/audio-kernel/include
else
  PRIMARY_HAL_PATH := $(TARGET_HALS_PATH)/audio/hal
  AUDIO_KERNEL_INC := $(TARGET_OUT_INTERMEDIATES)/vendor/qcom/opensource/audio-kernel/include
endif # BOARD_OPENSOURCE_DIR

ifneq ($(TARGET_BOARD_AUTO),true)
  LIBRARY_TINYCOMPRESS := libtinycompress
  LIBRARY_TINYCOMPRESS_INC := external/tinycompress/include
else
  LIBRARY_TINYCOMPRESS := libqti-tinycompress
  LIBRARY_TINYCOMPRESS_INC := $(TOP)/vendor/qcom/opensource/tinycompress/include
endif

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
ifeq ($(TARGET_BOARD_AUTO),true)
  LIBRARY_TINYCOMPRESS := libqti-tinycompress
  LIBRARY_TINYCOMPRESS_INC := $(TOP)/vendor/qcom/opensource/tinycompress/include
else
  LIBRARY_TINYCOMPRESS := libtinycompress
  LIBRARY_TINYCOMPRESS_INC := external/tinycompress/include
endif
  LOCAL_CFLAGS += -DENABLE_AUDIO_LEGACY_PURE
endif
#--------------------------------------------
#          Build SND_MONITOR LIB
#--------------------------------------------
LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libsndmonitor
LOCAL_MODULE_OWNER := third_party
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

LOCAL_SRC_FILES:= \
        sndmonitor.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable \

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libaudioroute \
    libdl \
    libexpat

LOCAL_C_INCLUDES := \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    system/media/audio_utils/include \
    external/expat/lib \
    $(call include-path-for, audio-route) \
    $(PRIMARY_HAL_PATH) \
    $(call include-path-for, audio-effects)

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DYNAMIC_LOG)), true)
    LOCAL_CFLAGS += -DDYNAMIC_LOG_ENABLED
    LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-log-utils
    LOCAL_SHARED_LIBRARIES += libaudio_log_utils
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#--------------------------------------------
#          Build COMPRESS_CAPTURE LIB
#--------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := libcomprcapture
LOCAL_MODULE_OWNER := third_party
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 qcs605 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= \
        compress_capture.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable \

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libaudioroute \
    libdl \
    libexpat

LOCAL_C_INCLUDES := \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    system/media/audio_utils/include \
    external/expat/lib \
    $(call include-path-for, audio-route) \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    $(call include-path-for, audio-effects)

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include
LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DYNAMIC_LOG)), true)
    LOCAL_CFLAGS += -DDYNAMIC_LOG_ENABLED
    LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-log-utils
    LOCAL_SHARED_LIBRARIES += libaudio_log_utils
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------
#            Build SSREC LIB
#-------------------------------------------
ifeq ($(strip $(AUDIO_FEATURE_ENABLED_SSR)),true)
include $(CLEAR_VARS)

LOCAL_MODULE := libssrec
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= ssr.c \
                  device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

ifeq ($(QCPATH),)
  LOCAL_CFLAGS += -D_OSS
endif

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libaudioroute \
    libdl \
    libexpat \
    libprocessgroup

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \
    $(call include-path-for, audio-effects) \
    $(TARGET_OUT_HEADERS)/mm-audio/surround_sound_3mic/ \
    $(TARGET_OUT_HEADERS)/common/inc/

ifeq ($(TARGET_BOARD_AUTO),true)
LOCAL_HEADER_LIBRARIES += libsurround_3mic_proc_headers
endif

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include
LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(PRIMARY_HAL_PATH)
endif

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DYNAMIC_LOG)), true)
    LOCAL_CFLAGS += -DDYNAMIC_LOG_ENABLED
    LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-log-utils
    LOCAL_SHARED_LIBRARIES += libaudio_log_utils
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)
endif
#--------------------------------------------
#          Build HDMI_EDID LIB
#--------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := libhdmiedid
LOCAL_MODULE_OWNER := third_party
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
endif

LOCAL_SRC_FILES:= \
        edid.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable \

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libaudioroute \
    libdl \
    libexpat

LOCAL_C_INCLUDES := \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    system/media/audio_utils/include \
    external/expat/lib \
    $(call include-path-for, audio-route) \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    $(call include-path-for, audio-effects)

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DYNAMIC_LOG)), true)
    LOCAL_CFLAGS += -DDYNAMIC_LOG_ENABLED
    LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-log-utils
    LOCAL_SHARED_LIBRARIES += libaudio_log_utils
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#--------------------------------------------
#          Build SPKR_PROTECT LIB
#--------------------------------------------
include $(CLEAR_VARS)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
endif

LOCAL_MODULE := libspkrprot
LOCAL_MODULE_OWNER := third_party
LOCAL_VENDOR_MODULE := true

LOCAL_SRC_FILES:= \
        spkr_protection.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable \

LOCAL_CFLAGS += -DSPKR_PROT_ENABLED

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libaudioroute \
    libdl \
    libexpat

LOCAL_C_INCLUDES := \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    system/media/audio_utils/include \
    external/expat/lib \
    $(call include-path-for, audio-route) \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/audio_extn \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    $(call include-path-for, audio-effects)
ifneq ($(BOARD_OPENSOURCE_DIR), )
   LOCAL_C_INCLUDES += $(BOARD_OPENSOURCE_DIR)/audio-kernel/include/uapi/
else
   LOCAL_C_INCLUDES += vendor/qcom/opensource/audio-kernel/include/uapi/
endif # BOARD_OPENSOURCE_DIR

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DYNAMIC_LOG)), true)
    LOCAL_CFLAGS += -DDYNAMIC_LOG_ENABLED
    LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-log-utils
    LOCAL_SHARED_LIBRARIES += libaudio_log_utils
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)
#====================================================================================================
# --- enable 3rd Party Spkr-prot lib
#====================================================================================================

include $(CLEAR_VARS)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
endif

LOCAL_MODULE := libcirrusspkrprot
LOCAL_MODULE_OWNER := third_party
LOCAL_VENDOR_MODULE := true

LOCAL_SRC_FILES:= \
        cirrus_playback.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable \

LOCAL_CFLAGS += -DENABLE_CIRRUS_DETECTION
LOCAL_CFLAGS += -DCIRRUS_FACTORY_CALIBRATION

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    libaudioroute \
    libdl \
    libexpat

LOCAL_C_INCLUDES := \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    system/media/audio_utils/include \
    external/expat/lib \
    $(call include-path-for, audio-route) \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/audio_extn \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    $(call include-path-for, audio-effects)
ifneq ($(BOARD_OPENSOURCE_DIR), )
   LOCAL_C_INCLUDES += $(BOARD_OPENSOURCE_DIR)/audio-kernel/include/uapi/
else
   LOCAL_C_INCLUDES += vendor/qcom/opensource/audio-kernel/include/uapi/
endif # BOARD_OPENSOURCE_DIR


LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------
#            Build A2DP_OFFLOAD LIB
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := liba2dpoffload
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= \
        a2dp.c \
        device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libaudioroute \
    libdl \
    libexpat

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DYNAMIC_LOG)), true)
    LOCAL_CFLAGS += -DDYNAMIC_LOG_ENABLED
    LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-log-utils
    LOCAL_SHARED_LIBRARIES += libaudio_log_utils
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------

#            Build EXT_HW_PLUGIN LIB
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := libexthwplugin

LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= \
        ext_hw_plugin.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DAEMON_SUPPORT)), true)
  LOCAL_CFLAGS += -DDAEMON_SUPPORT_AUTO
endif

LOCAL_SHARED_LIBRARIES := \
    libaudioroute \
    libaudioutils \
    libcutils \
    libdl \
    libexpat \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS)

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------
#            Build HFP LIB
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := libhfp
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

ifeq ($(TARGET_BOARD_AUTO),true)
  LOCAL_CFLAGS += -DPLATFORM_AUTO
endif

LOCAL_SRC_FILES:= \
        hfp.c \
        device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

LOCAL_SHARED_LIBRARIES := \
    libaudioroute \
    libaudioutils \
    libcutils \
    libdl \
    libexpat \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS)

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DYNAMIC_LOG)), true)
    LOCAL_CFLAGS += -DDYNAMIC_LOG_ENABLED
    LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-log-utils
    LOCAL_SHARED_LIBRARIES += libaudio_log_utils
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------
#            Build ICC LIB
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := libicc
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

ifeq ($(TARGET_BOARD_AUTO),true)
  LOCAL_CFLAGS += -DPLATFORM_AUTO
endif

LOCAL_SRC_FILES:= \
        icc.c \
        device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

LOCAL_SHARED_LIBRARIES := \
    libaudioroute \
    libaudioutils \
    libcutils \
    libdl \
    libexpat \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS)

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------
#            Build SYNTH LIB
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := libsynth
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

ifeq ($(TARGET_BOARD_AUTO),true)
  LOCAL_CFLAGS += -DPLATFORM_AUTO
endif

LOCAL_SRC_FILES:= \
        synth.c  \
        device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

LOCAL_SHARED_LIBRARIES := \
    libaudioroute \
    libaudioutils \
    libcutils \
    libdl \
    libexpat \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS)

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------
#            Build HDMI PASSTHROUGH
#-------------------------------------------
ifneq ($(QCPATH),)

include $(CLEAR_VARS)

LOCAL_MODULE := libhdmipassthru
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= \
        passthru.c \
        device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable \
    -DDTSHD_PARSER_ENABLED

LOCAL_SHARED_LIBRARIES := \
    libaudioparsers \
    libaudioroute \
    libaudioutils \
    libcutils \
    libdl \
    libexpat \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS)

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(TARGET_OUT_HEADERS)/mm-audio/audio-parsers \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DYNAMIC_LOG)), true)
    LOCAL_CFLAGS += -DDYNAMIC_LOG_ENABLED
    LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-log-utils
    LOCAL_SHARED_LIBRARIES += libaudio_log_utils
endif

# Kernel specific feature
ifeq ($(strip $(AUDIO_FEATURE_ENABLED_GKI)), true)
    LOCAL_CFLAGS += -DAUDIO_GKI_ENABLED
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)
endif

ifneq ($(TARGET_BOARD_AUTO),true)
#-------------------------------------------
#            Build BATTERY_LISTENER
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := libbatterylistener
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= \
        battery_listener.cpp

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable \
    -DDTSHD_PARSER_ENABLED

LOCAL_SHARED_LIBRARIES := \
    android.hardware.health@1.0 \
    android.hardware.health@2.0 \
    android.hardware.health@2.1 \
    android.hardware.power@1.2 \
    libaudioroute \
    libaudioutils \
    libbase \
    libcutils \
    libdl \
    libexpat \
    libhidlbase \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libutils \

LOCAL_STATIC_LIBRARIES := \
    libhealthhalutils

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include
LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)
endif

#-------------------------------------------
#            Build HWDEP_CAL
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := libhwdepcal
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito bengal atoll sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

# LOCAL_SRC_FILES:= \
#         hwdep_cal.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

LOCAL_SHARED_LIBRARIES := \
    libaudioroute \
    libaudioutils \
    libcutils \
    libdl \
    libexpat \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS)

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include
LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
#include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------
#            Build MAXX_AUDIO
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE:= libmaxxaudio
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi sdm660 msm8937 msm8953 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM = msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= \
        maxxaudio.c \
        device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libaudioroute \
    libdl \
    libexpat

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)
#-------------------------------------------
#            Build AUDIOZOOM
#-------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE:= libaudiozoom
LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi sdm660 msm8937 msm8953 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM = msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= \
        audiozoom.c \
        device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    liblog \
    libtinyalsa \
    $(LIBRARY_TINYCOMPRESS) \
    libaudioroute \
    libdl \
    libexpat

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)

#-------------------------------------------

#            Build AUTO_HAL LIB
#-------------------------------------------
ifeq ($(strip $(AUDIO_FEATURE_ENABLED_AUTO_HAL)), true)
include $(CLEAR_VARS)

LOCAL_MODULE := libautohal

LOCAL_VENDOR_MODULE := true

AUDIO_PLATFORM := $(TARGET_BOARD_PLATFORM)

ifneq ($(filter sdm845 sdm710 sdmshrike msmnile gen4 kona lahaina holi lito atoll bengal sdm660 msm8937 msm8953 msm8998 $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
  # B-family platform uses msm8974 code base
  AUDIO_PLATFORM := msm8974
  MULTIPLE_HW_VARIANTS_ENABLED := true
endif

LOCAL_SRC_FILES:= \
        auto_hal.c \
        device_utils.c

LOCAL_CFLAGS += \
    -Wall \
    -Werror \
    -Wno-unused-function \
    -Wno-unused-variable

LOCAL_SHARED_LIBRARIES := \
    libaudioutils \
    libcutils \
    libdl \
    libexpat \
    liblog \
    libtinyalsa

LOCAL_C_INCLUDES := \
    $(PRIMARY_HAL_PATH) \
    $(PRIMARY_HAL_PATH)/$(AUDIO_PLATFORM) \
    external/tinyalsa/include \
    $(LIBRARY_TINYCOMPRESS_INC) \
    external/expat/lib \
    system/media/audio_utils/include \
    $(call include-path-for, audio-route) \

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include/audio
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/techpack/audio/include

ifeq ($(ENABLE_AUDIO_LEGACY_TECHPACK),true)
LOCAL_HEADER_LIBRARIES += qti_legacy_audio_kernel_uapi
endif

LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DLKM)),true)
  LOCAL_HEADER_LIBRARIES += audio_kernel_headers
  LOCAL_C_INCLUDES += $(AUDIO_KERNEL_INC)
endif

ifeq ($(AUDIO_FEATURE_ENABLED_HAL_V7), true)
LOCAL_CFLAGS += -DANDROID_U_HAL7
endif

LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif
include $(BUILD_SHARED_LIBRARY)
endif
#-------------------------------------------

#            Build Power_Policy_Client LIB
#-------------------------------------------
ifeq ($(strip $(AUDIO_FEATURE_ENABLED_POWER_POLICY)),true)

include $(CLEAR_VARS)

LOCAL_MODULE := libaudiopowerpolicy

LOCAL_VENDOR_MODULE := true

ifeq ($(call is-board-platform-in-list,$(MSMSTEPPE)),true)
        LOCAL_CFLAGS := -DPLATFORM_MSMSTEPPE
endif

LOCAL_SRC_FILES:= \
        PowerPolicyClient.cpp \
        power_policy_launcher.cpp

LOCAL_C_INCLUDES:= \
        $(PRIMARY_HAL_PATH) \
        system/media/audio/include

LOCAL_SHARED_LIBRARIES:= \
        libbase \
        libbinder_ndk \
        libcutils \
        liblog \
        libpowerpolicyclient

# *-ndk_platform migrated to *-ndk from Android T onwards
ifeq ($(call math_gt_or_eq, $(PLATFORM_SDK_VERSION), 33), true)
    LOCAL_SHARED_LIBRARIES += android.frameworks.automotive.powerpolicy-V1-ndk
else
    LOCAL_SHARED_LIBRARIES += android.frameworks.automotive.powerpolicy-V1-ndk_platform
endif

ifneq ($(filter kona lahaina holi,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SANITIZE := integer_overflow
endif

ifeq ($(strip $(AUDIO_FEATURE_ENABLED_DAEMON_SUPPORT)),true)
  LOCAL_CFLAGS += -DDAEMON_SUPPORT_AUTO
endif

include $(BUILD_SHARED_LIBRARY)
endif
endif
