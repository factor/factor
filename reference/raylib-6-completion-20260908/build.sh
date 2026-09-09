#!/bin/sh
set -eu
# An existing exact tagged checkout can be supplied as the first argument.
raylib_source=${1:-/tmp/factor-raylib-varargs-6.0}
cd "$(dirname "$0")/../.."
cc -Wall -Wextra -Werror -dynamiclib -I "$raylib_source/src" \
  extra/raylib/native/api60.c -L "$raylib_source/src" -lraylib \
  -o /tmp/libraylib-api60.dylib
cc -Wall -Wextra -Werror -DRAYLIB_API60_MAIN \
  -I "$raylib_source/src" extra/raylib/native/api60.c \
  -L "$raylib_source/src" -lraylib -o /tmp/raylib-api60-controls
/tmp/raylib-api60-controls "$raylib_source/examples/text/resources/anonymous_pro_bold.ttf"
