#!/usr/bin/env bash

#### log_libcamera_controls.sh - wrapper for printing avail. libcamera ctrls.

#### crowsnest - A webcam Service for multiple Cams and Stream Services.
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2021 - till today
#### https://github.com/mainsail-crew/crowsnest
####
#### This File is distributed under GPLv3
####

# shellcheck enable=require-variable-braces

# Exit upon Errors
set -Ee

CN_LIBCAMERA_CTRLS_ARRAY=()

cn_get_libcamera_controls() {
    python - << EOL
from picamera2 import Picamera2
picam = Picamera2()
ctrls = picam.camera_controls

for key, value in ctrls.items():
        min, max, default = value
        if type(min) is int:
            ctrl_type = "int"
        elif type(min) is float:
            ctrl_type = "float"
        elif type(min) is bool:
            ctrl_type = "bool"
        elif type(min) is tuple:
            ctrl_type = "tuple"
        else:
            ctrl_type=type(min)

        print(f"{key} ({ctrl_type}) :\t\tmin={min} max={max} default={default}\n")

EOL
}

cn_set_libcamera_controls() {
    while read -r line; do
        if [[ -n "${line}" ]]; then
            CN_LIBCAMERA_CTRLS_ARRAY+=("${line}")
        fi
    done < <(cn_get_libcamera_controls 2> /dev/null)
    # shellcheck disable=SC2034
    declare -gar CN_LIBCAMERA_CTRLS_ARRAY
}

cn_init_libcamera_controls() {
    if [[ "${CN_LIBCAMERA_AVAIL}" = "1" ]]; then
        cn_set_libcamera_controls
    fi

    if [[ "${CN_DEV_MSG}" = "1" ]]; then
        printf "log_libcamera_controls:\n###########\n"
        declare -p | grep "CN_LIBCAMERA_CTRLS_ARRAY"
        printf "###########\n"
    fi
}

if [[ "${CN_DEV_MSG}" = "1" ]]; then
    printf "Sourced component: log_libcamera_controls.sh\n"
fi

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    printf "This is a component of crowsnest!\n"
    printf "Components are not meant to be executed, therefore...\n"
    printf "DO NOT EXECUTE %s ON ITS OWN!\n" "$(basename "${0}")"
    exit 1
fi