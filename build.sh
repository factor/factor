export CC=gcc
export CFLAGS="-lm -g -Wall -Wno-long-long -Wno-inline"

$CC $CFLAGS -o f native/*.c
