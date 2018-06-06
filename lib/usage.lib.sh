#!/usr/bin/env bash

#>|          mark 'synopsis' line
#+|          mark 'usage' lines
#%|          mark 'purpose' line
#-|          mark 'authorship' line
#[%+-=>]|    mark 'man' lines

# inspired by https://stackoverflow.com/a/29579226
extract_from_header() {
    local -r pattern="${1:-'#'}"
    local -r source_file="${2:-}"

    [[ -r $source_file ]] || exit 1
    grep -e "$pattern" ${source_file} | sed -e "s/$pattern//g" -e "s/^ //" ;
}

extract_command_main_source() {
    # In "devkit" framework, usage documentation is in "main.sh" script
    # and it's always in the second place of calling stack
    for (( idx=${#BASH_SOURCE[@]}-1 ; idx>=0 ; idx-- )) ; do
        if [[ ${BASH_SOURCE[idx]##*/} = main.sh ]]; then
            echo "${BASH_SOURCE[idx]}"
            return 0
        fi
    done
    return 1
}

help() {
    extract_from_header "^#+|" "${1:-}"
}

synopsis() {
    extract_from_header "^#>|" "${1:-}"
}

purpose() {
    extract_from_header "^#%|[ ]*" "${1:-}"
}

authorship() {
    extract_from_header "^#-|" "${1:-}"
}

manual() {
    extract_from_header "^#[%+-=>]|" "${1:-}"
}

#
# Add usage options when it is sourced
#
if [[ $_ != $0 ]]; then
    for option in "$@"; do
        case ${option:-} in
        --manual)
            manual "$(extract_command_main_source)"
            exit 0
        ;;
        --purpose)
            purpose "$(extract_command_main_source)"
            exit 0
        ;;
        --synopsis)
            synopsis "$(extract_command_main_source)"
            exit 0
        ;;
        --authorship)
            authorship "$(extract_command_main_source)"
            exit 0
        ;;
        --help)
            help "$(extract_command_main_source)"
            exit 0
        ;;
        esac
    done
fi
