! Copyright (C) 2020 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: base64.private byte-arrays endian kernel kernel.private
literals math math.functions sequences ;

IN: base36

ERROR: malformed-base36 ;

<PRIVATE

<<
CONSTANT: alphabet $[
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    >byte-array
]
>>

PRIVATE>

: ch>base36 ( ch -- ch )
    alphabet nth ; inline

: base36>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base36 ] unless* { fixnum } declare ; inline

:: >base36 ( seq -- base36 )
    BV{ } clone :> accum
    seq [ zero? not ] find [ drop seq length ] unless :> i
    seq i tail-slice be>
    [ 36 /mod ch>base36 accum push ] until-zero
    i alphabet first '[ _ accum push ] times
    accum reverse! B{ } like ;

:: base36> ( base36 -- seq )
    BV{ } clone :> accum
    base36 alphabet first '[ _ = not ] find
    [ drop base36 length ] unless :> i
    0 base36 [ [ 36 * ] dip base36>ch + ] i each-from
    [ 256 /mod accum push ] until-zero
    i [ 0 accum push ] times
    accum reverse! B{ } like ;

: n>base36 ( n -- base36 )
    dup log2 1 + 8 / ceiling >integer >be >base36 ;

: base36>n ( base36 -- n )
    base36> be> ;
