rm *.o

export CC=gcc34
export CFLAGS="-pedantic -Wall -Winline -O3 -march=pentium4 -fomit-frame-pointer"

$CC $CFLAGS -o f native/*.c

strip f
