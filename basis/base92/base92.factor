! Copyright (C) 2019 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: base64.private byte-arrays combinators kernel
kernel.private literals math sequences sequences.private ;
IN: base92

ERROR: malformed-base92 ;

<PRIVATE

<<
CONSTANT: alphabet $[
    "!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}"
    >byte-array
]
>>

: ch>base92 ( ch -- ch )
    alphabet nth ; inline

: base92>ch ( ch -- ch )
    $[ alphabet alphabet-inverse ] nth
    [ malformed-base92 ] unless* { fixnum } declare ; inline

PRIVATE>

:: >base92 ( seq -- base92 )
    0 :> b!
    0 :> n!
    BV{ } clone :> accum

    seq [
        b 8 shift bitor b!
        n 8 + n!
        n 13 >= [
            b n 13 - neg shift 0x1fff bitand
            91 /mod [ ch>base92 accum push ] bi@
            n 13 - n!
        ] when
    ] each

    n 0 > [
        n 7 < [
            b 6 n - shift 0x3f bitand ch>base92 accum push
        ] [
            b 13 n - shift 0x1fff bitand
            91 /mod [ ch>base92 accum push ] bi@
        ] if
    ] when

    accum [ CHAR: ~ 1byte-array ] [ B{ } like ] if-empty ;

:: base92> ( base92 -- seq )
    base92 length :> len
    {
        { [ len 0 = ] [ B{ } clone ] }
        { [ len 1 = base92 first CHAR: ~ = and ] [ B{ } clone ] }
        { [ len 2 < ] [ f ] }
        [
            0 :> b!
            0 :> n!
            BV{ } clone :> accum

            len 2/ <iota> [
                2 * dup 1 + [ base92 nth-unsafe base92>ch ] bi@
                [ 91 * ] dip + b 13 shift bitor b!
                n 13 + n!
                [ n 8 >= ] [
                    b n 8 - neg shift 0xff bitand accum push
                    n 8 - n!
                ] while
            ] each

            len odd? [
                len 1 - base92 nth-unsafe base92>ch b 6 shift bitor b!
                n 6 + n!
                [ n 8 >= ] [
                    b n 8 - neg shift 0xff bitand accum push
                    n 8 - n!
                ] while
            ] when

            accum B{ } like
        ]
    } cond ;
