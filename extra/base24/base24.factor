! Copyright (C) 2020 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ascii base64.private byte-arrays endian grouping
kernel kernel.private literals math sequences ;

IN: base24

ERROR: malformed-base24 ;

<PRIVATE

<<
CONSTANT: alphabet $[ "ZAC2B3EF4GH5TK67P8RS9WXY" >byte-array ]
>>

: ch>base24 ( ch -- ch )
    alphabet nth ;

: base24>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base24 ] unless* { fixnum } declare ;

PRIVATE>

:: base24> ( base24 -- seq )
    BV{ } clone :> accum
    base24 [ "- " member? ] reject >upper
    dup length 7 mod 0 assert=
    7 <groups> [
        0 [ base24>ch swap 24 * + ] reduce
        4 >be accum push-all
    ] each
    accum B{ } like ;

:: >base24 ( seq -- base24 )
    BV{ } clone :> accum
    seq length 4 mod 0 assert=
    seq 4 <groups> [
        be> 7 [
            24 /mod ch>base24 accum push
        ] times drop
    ] each
    accum reverse! B{ } like ;
