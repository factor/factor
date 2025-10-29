#!/bin/bash
magick favicon.png -resize 16x16 favicon-16x16.png
magick favicon.png -resize 32x32 favicon-32x32.png
magick favicon.png -resize 48x48 favicon-48x48.png
magick favicon.png -resize 96x96 favicon-96x96.png
magick favicon-16x16.png favicon-32x32.png favicon-48x48.png favicon-96x96.png favicon.ico
