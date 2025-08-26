#!/bin/bash

cp icon.png icon_512x512@2x.png
magick icon.png -resize 512x512 icon_512x512.png
cp icon_512x512.png icon_256x256@2x.png
magick icon.png -resize 256x256 icon_256x256.png
cp icon_256x256.png icon_128x128@2x.png
magick icon.png -resize 128x128 icon_128x128.png
cp icon_128x128.png icon_64x64@2x.png
magick icon.png -resize 64x64 icon_64x64.png
cp icon_64x64.png icon_32x32@2x.png
magick icon.png -resize 32x32 icon_32x32.png
cp icon_32x32.png icon_16x16@2x.png
magick icon.png -resize 16x16 icon_16x16.png
magick icon.png -resize 96x96 icon_48x48@2x.png
magick icon.png -resize 48x48 icon_48x48.png
