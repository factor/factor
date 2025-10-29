#!/bin/bash

ICONS=(
  "icon_16x16.png:16x16"
  "icon_16x16@2x.png:32x32"
  "icon_16x16@3x.png:48x48"
  "icon_32x32.png:32x32"
  "icon_32x32@2x.png:64x64"
  "icon_32x32@3x.png:96x96"
  "icon_128x128.png:128x128"
  "icon_128x128@2x.png:256x256"
  "icon_128x128@3x.png:384x384"
  "icon_256x256.png:256x256"
  "icon_256x256@2x.png:512x512"
  "icon_256x256@3x.png:768x768"
  "icon_512x512.png:512x512"
  "icon_512x512@2x.png:1024x1024"
  "icon_512x512@3x.png:1536x1536"
)

IMAGE_DIR="$(pwd)"

# Check if needed files exist
for ICON in "${ICONS[@]}"; do
  IFS=":" read -r NAME SIZE <<< "$ICON"
  if [[ ! -f "$IMAGE_DIR/$NAME" ]]; then
    echo "error: $NAME missing in $IMAGE_DIR"
    exit 1
  fi
done

ICONSET_DIR="icon.iconset"
mkdir -p "$ICONSET_DIR"

for ICON in "${ICONS[@]}"; do
  IFS=":" read -r NAME SIZE <<< "$ICON"
  cp "$IMAGE_DIR/$NAME" "$ICONSET_DIR/"
done

iconutil -c icns "$ICONSET_DIR"

if [[ -f "icon.icns" ]]; then
  echo "The .icns was succesfully created."
else
  echo "There was a problem while creating the .icns file."
  exit 1
fi
