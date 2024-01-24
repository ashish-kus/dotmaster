#!/bin/bash
#!/bin/bash

# parse_ini() {
#     local ini_file="$1"
#     declare -A config

#     current_section=""
#     while IFS= read -r line; do
#         line=$(echo "$line" | sed -e 's/^[ \t]*//;s/[ \t]*$//')
#         if [[ "$line" =~ ^\; ]] || [[ -z "$line" ]]; then
#             continue
#         fi

#         if [[ "$line" =~ ^\[.*\]$ ]]; then
#             current_section=$(echo "$line" | sed -e 's/^\[\(.*\)\]$/\1/')
#         else
#             key=$(echo "$line" | cut -d '=' -f 1)
#             value=$(echo "$line" | cut -d '=' -f 2-)
#             config["$current_section.$key"]=$value
#         fi
#     done < "$ini_file"

#     # Export the variables to make them available in the current shell
#     for key in "${!config[@]}"; do
#         export "$key=${config[$key]}"
#     done
# }

# # Parse the INI file
# ini_file="$1"
# parse_ini "$ini_file"

# # Example usage of the variables
# echo "Section1_key1: $Section1_key1"
# echo "Section1_key2: $Section1_key2"
# echo "Section2_key3: $Section2_key3"
# echo "Section2_key4: $Section2_key4"

# #!/bin/bash

parse_ini() {
    local ini_file="$1"
    declare -A config

    current_section=""
    while IFS= read -r line; do
        line=$(echo "$line" | sed -e 's/^[ \t]*//;s/[ \t]*$//')
        if [[ "$line" =~ ^\; ]] || [[ -z "$line" ]]; then
            continue
        fi

        if [[ "$line" =~ ^\[.*\]$ ]]; then
            current_section=$(echo "$line" | sed -e 's/^\[\(.*\)\]$/\1/')
        else
            key=$(echo "$line" | cut -d '=' -f 1)
            value=$(echo "$line" | cut -d '=' -f 2-)
            config["$current_section.$key"]=$value
        fi
    done < "$ini_file"

    # Export the variables to make them available in the current shell
    for key in "${!config[@]}"; do
        # export "${key^^}=${config[$key]}"
         # export "${key//./_}=${config[$key]}"
        # export "${key^^}=${config[$key]}"
        # echo $key
    done
}

# Parse the INI file
ini_file="$1"
parse_ini "$ini_file"
echo $SECTION1.KEY3
# Example usage of the variables
# echo "SECTION1_KEY1: $SECTION1_KEY1"
# echo "SECTION1_KEY2: $SECTION1_KEY2"
# echo "SECTION2_KEY3: $SECTION2_KEY3"
# echo "SECTION2_KEY4: $SECTION2_KEY4"
