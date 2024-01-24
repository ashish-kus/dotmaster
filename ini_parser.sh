#!/usr/bin/env bash

parse_ini() {
    local ini_file="$1"
    current_section=""
    while IFS= read -r line; do
        line=$(echo "$line" | sed -e 's/^[ \t]*//;s/[ \t]*$//')
        if [[ "$line" =~ ^\; ]] || [[ "$line" =~ ^\# ]] || [[ -z "$line" ]]; then
            continue
        fi
        if [[ "$line" =~ ^\[.*\]$ ]]; then
            current_section=$(echo "$line" | sed -e 's/^\[\(.*\)\]$/\1/')
        else
            key=$(echo "$line" | cut -d '=' -f 1)
            value=$(echo "$line" | cut -d '=' -f 2-)
            export "${current_section}_${key}"="$value"
        fi
    done < "$ini_file"
}

# Parse the INI file
parse_ini "$1"
# echo $SECTION1_KEY3
echo $REPOSITORY_URL
echo $PACKAGE_INSTALL_LIST
