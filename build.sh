rm *.o

export CC=gcc34
export CFLAGS="-pedantic -Wall -Winline -O4 -Os -march=pentium4 -fomit-frame-pointer -falign-functions=8"

$CC $CFLAGS -o f native/*.c

strip f
