! Copyright (C) 2020 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: base64.private byte-arrays checksums checksums.sha
endian kernel kernel.private literals math sequences ;

IN: base58

ERROR: malformed-base58 ;

<PRIVATE

<<
CONSTANT: alphabet $[
    "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    >byte-array
]
>>

PRIVATE>

: ch>base58 ( ch -- ch )
    alphabet nth ; inline

: base58>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base58 ] unless* { fixnum } declare ; inline

:: >base58 ( seq -- base58 )
    BV{ } clone :> accum
    seq [ zero? not ] find [ drop seq length ] unless :> i
    seq i tail-slice be>
    [ 58 /mod ch>base58 accum push ] until-zero
    i alphabet first '[ _ accum push ] times
    accum reverse! B{ } like ;

:: base58> ( base58 -- seq )
    BV{ } clone :> accum
    base58 alphabet first '[ _ = not ] find
    [ drop base58 length ] unless :> i
    0 base58 [ [ 58 * ] dip base58>ch + ] i each-from
    [ 256 /mod accum push ] until-zero
    i [ 0 accum push ] times
    accum reverse! B{ } like ;

<PRIVATE

: base58-check ( base58 -- base58-check )
    2 [ sha-256 checksum-bytes ] times ;

PRIVATE>

: >base58-check ( seq -- base58-check )
    dup base58-check 4 head-slice append >base58 ;

: base58-check> ( base58-check -- seq )
    base58> 4 cut* [ dup base58-check 4 head-slice ] [ assert-sequence= ] bi* ;
