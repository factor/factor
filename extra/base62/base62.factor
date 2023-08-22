! Copyright (C) 2020 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: base64.private byte-arrays endian kernel kernel.private
literals math sequences ;

IN: base62

ERROR: malformed-base62 ;

<PRIVATE

<<
CONSTANT: alphabet $[
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    >byte-array
]
>>

PRIVATE>

: ch>base62 ( ch -- ch )
    alphabet nth ; inline

: base62>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base62 ] unless* { fixnum } declare ; inline

:: >base62 ( seq -- base62 )
    BV{ } clone :> accum
    seq [ zero? not ] find [ drop seq length ] unless :> i
    seq i tail-slice be>
    [ 62 /mod ch>base62 accum push ] until-zero
    i alphabet first '[ _ accum push ] times
    accum reverse! B{ } like ;

:: base62> ( base62 -- seq )
    BV{ } clone :> accum
    base62 alphabet first '[ _ = not ] find
    [ drop base62 length ] unless :> i
    0 base62 [ [ 62 * ] dip base62>ch + ] i each-from
    [ 256 /mod accum push ] until-zero
    i [ 0 accum push ] times
    accum reverse! B{ } like ;
