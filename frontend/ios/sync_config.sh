#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"

CONFIG_FILE="../lib/config.dart"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found."
    exit 1
fi

# Extract API Key from config.dart
API_KEY=$(grep 'static const String googleApiKey' "$CONFIG_FILE" | sed -E 's/.*"(.*)".*/\1/')

if [ -z "$API_KEY" ]; then
    echo "Error: Could not find googleApiKey in $CONFIG_FILE"
    exit 1
fi

echo "Updating iOS configuration with key: $API_KEY"

# Update xcconfigs
# Note: Using a temporary file to be safe with sed across different OS versions
update_config() {
    local file=$1
    if [ -f "$file" ]; then
        if grep -q "GOOGLE_MAPS_API_KEY=" "$file"; then
            sed -i '' "s/GOOGLE_MAPS_API_KEY=.*/GOOGLE_MAPS_API_KEY=$API_KEY/" "$file"
        else
            echo "GOOGLE_MAPS_API_KEY=$API_KEY" >> "$file"
        fi
        echo "Updated $file"
    else
        echo "Warning: $file not found."
    fi
}

update_config "Flutter/Debug.xcconfig"
update_config "Flutter/Release.xcconfig"

echo "Sync complete!"
