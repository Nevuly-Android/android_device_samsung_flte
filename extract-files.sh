#!/bin/bash
#
# Copyright (C) 2014-2016 The CyanogenMod Project
# Copyright (C) 2017-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

export DEVICE=flte
export VENDOR=samsung

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function blob_fixup() {
    case "${1}" in
        vendor/lib/libsec-ril.*)
            "${PATCHELF}" --replace-needed libcutils.so libcutils-v29.so "${2}"
            ;;
        vendor/bin/thermal-engine)
            sed -i 's|/system/etc|/vendor/etc|g' "${2}"
            ;;
        vendor/lib/libmmcamera2_sensor_modules.so)
            sed -i 's|system/etc|vendor/etc|g;
                    s|/system/lib|/vendor/lib|g' "${2}"
            ;;
    esac
}

if [ $# -eq 0 ]; then
    SRC=adb
else
    if [ $# -eq 1 ]; then
        SRC=$1
    else
        echo "$0: bad number of arguments"
        echo ""
        echo "usage: $0 [PATH_TO_EXPANDED_ROM]"
        echo ""
        echo "If PATH_TO_EXPANDED_ROM is not specified, blobs will be extracted from"
        echo "the device using adb pull."
        exit 1
    fi
fi
export SRC

setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

extract "${MY_DIR}/proprietary-files.txt" "${SRC}"

export BOARD_COMMON=msm8974-common

"./../../${VENDOR}/${BOARD_COMMON}/extract-files.sh" "$@"

"${MY_DIR}/setup-makefiles.sh"
