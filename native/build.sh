rm *.o

export CC=gcc34
export CFLAGS="-pedantic -Wall -Winline -O4 -Os -march=pentium4 -fomit-frame-pointer -falign-functions=8"

$CC $CFLAGS -o f *.c

strip f

#export CC=gcc
#export CFLAGS="-g"

#$CC $CFLAGS -o f-debug *.c
