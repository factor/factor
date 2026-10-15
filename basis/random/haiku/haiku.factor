! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax byte-arrays init kernel
libc locals math math.order namespaces random unix ;
IN: random.haiku

LIBRARY: libc
FUNCTION: int getentropy ( void* buffer, size_t length )

: get-entropy ( buffer length -- )
    [ getentropy ] unix-system-call drop ;

TUPLE: haiku-random ;
INSTANCE: haiku-random base-random

! Haiku random devices reject F_SETFL. Its getentropy interface
! reads the same cryptographic entropy source without a descriptor.
M:: haiku-random random-bytes* ( n rnd -- bytes )
    n <byte-array> :> bytes
    0 :> offset!
    [ offset n < ] [
        n offset - 256 min :> chunk
        offset bytes <displaced-alien> chunk
        get-entropy
        offset chunk + offset!
    ] while
    bytes ;

STARTUP-HOOK: [
    haiku-random new
    dup secure-random-generator set-global
    system-random-generator set-global
]
