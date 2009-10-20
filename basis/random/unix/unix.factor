! Copyright (C) 2008 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io io.files kernel namespaces random
io.encodings.binary init accessors system destructors ;
IN: random.unix

TUPLE: unix-random reader ;

: <unix-random> ( path -- random )
    binary <file-reader> unix-random boa ;

M: unix-random dispose reader>> dispose ;

M: unix-random random-bytes* ( n tuple -- byte-array )
    reader>> stream-read ;

os openbsd? [
    [
        "/dev/srandom" <unix-random> secure-random-generator set-global
        "/dev/arandom" <unix-random> system-random-generator set-global
    ] "random.unix" add-startup-hook
] [
    [
        "/dev/random" <unix-random> secure-random-generator set-global
        "/dev/urandom" <unix-random> system-random-generator set-global
    ] "random.unix" add-startup-hook
] if

[
    [
        secure-random-generator get-global &dispose drop
        system-random-generator get-global &dispose drop
    ] with-destructors
] "random.unix" add-shutdown-hook
