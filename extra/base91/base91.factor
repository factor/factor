! Copyright (C) 2019 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: base64.private byte-arrays kernel kernel.private
literals math sequences ;
IN: base91

ERROR: malformed-base91 ;

<PRIVATE

<<
CONSTANT: alphabet $[
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~\""
    >byte-array
]
>>

: ch>base91 ( ch -- ch )
    alphabet nth ; inline

: base91>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base91 ] unless* { fixnum } declare ; inline

PRIVATE>

:: >base91 ( seq -- base91 )
    0 :> b!
    0 :> n!
    BV{ } clone :> accum

    seq [
        n shift b bitor b!
        n 8 + n!
        n 13 > [
            b 0x1fff bitand dup 88 > [
                b -13 shift b!
                n 13 - n!
            ] [
                drop b 0x3fff bitand
                b -14 shift b!
                n 14 - n!
            ] if 91 /mod swap [ ch>base91 accum push ] bi@
        ] when
    ] each

    n 0 > [
        b 91 mod ch>base91 accum push
        n 7 > b 90 > or [
            b 91 /i ch>base91 accum push
        ] when
    ] when

    accum B{ } like ;

:: base91> ( base91 -- seq )
    f :> v!
    0 :> b!
    0 :> n!
    BV{ } clone :> accum

    base91 [
        base91>ch
        v [
            91 * v + v!
            v n shift b bitor b!
            v 0x1fff bitand 88 > 13 14 ? n + n!
            [ n 7 > ] [
                b 0xff bitand accum push
                b -8 shift b!
                n 8 - n!
            ] do while
            f v!
        ] [
            v!
        ] if
    ] each

    v [
        b v n shift bitor 0xff bitand accum push
    ] when

    accum B{ } like ;
