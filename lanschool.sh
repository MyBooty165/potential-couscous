#!/bin/bash

check_chrome_installed() {
    if command -v google-chrome > /dev/null 2>&1; then
        echo "Google Chrome is installed."
    else
        echo "Google Chrome is not installed. Please install it first."
        exit 1
    fi
}

ext-dir() {
    local extension-path=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        extension-path="$HOME/.config/google-chrome/Default/Extensions"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        extension-path="$HOME/Library/Application Support/Google/Chrome/Default/Extensions"
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        extension-path="$APPDATA/Google/Chrome/User Data/Default/Extensions"
    else
        echo "Unsupported OS."
        exit 1
    fi

    if [ ! -d "$extension-path" ]; then
        echo "Chrome extensions directory not found."
        exit 1
    fi

    echo "$extension-path"
}

destroy() {
    local ext_id="$1"
    local ext_dir="$2/$ext_id"
    
    if [ ! -d "$ext_dir" ]; then
        echo "Extension directory not found."
        exit 1
    fi

    local ext_version_dir=$(ls -td -- "$ext_dir"/*/ | head -n 1)
    ext_version_dir="${ext_version_dir%/}"

    if [ ! -d "$ext_version_dir" ]; then
        echo "Extension version directory not found."
        exit 1
    fi

    echo "Modifying manifest file in $ext_version_dir"

    local manifest_file="$ext_version_dir/manifest.json"
    if [ ! -f "$manifest_file" ]; then
        echo "Manifest file not found."
        exit 1
    fi

    jq 'del(.background.scripts) | .background.scripts = [] |
        del(.web_accessible_resources) | .web_accessible_resources = [] |
        del(.content_scripts) | .content_scripts = [] |
        del(.permissions) | .permissions = [] |
        del(.permissions[] | select(. == "webRequestBlocking"))' \
        "$manifest_file" > "${manifest_file}.tmp" && mv "${manifest_file}.tmp" "$manifest_file"
    
    echo "Manifest file modified successfully."
}

main() {
    check_chrome_installed
    local extension-path=$(ext-dir)
    local target_extension="honjcnefekfnompampcpmcdadibmjhlk"

    echo "Scanning for extension: $target_extension"
    
    if [ -d "$extension-path/$target_extension" ]; then
        echo "Extension $target_extension found."
        destroy "$target_extension" "$extension-path"
    else
        echo "Extension $target_extension not found."
        exit 1
    fi
}

main
