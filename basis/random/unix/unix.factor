! Copyright (C) 2008 Doug Coleman
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types io io.files kernel namespaces random
io.encodings.binary init accessors system destructors
hints math ;
IN: random.unix

TUPLE: unix-random reader ;

: <unix-random> ( path -- random )
    binary <file-reader> unix-random boa ;

M: unix-random dispose reader>> dispose ;

M: unix-random random-bytes*
    reader>> stream-read ;

HINTS: M\ unix-random random-bytes* { fixnum unix-random } ;

STARTUP-HOOK: [
    "/dev/random" <unix-random> &dispose
    secure-random-generator set-global

    "/dev/urandom" <unix-random> &dispose
    system-random-generator set-global
]
