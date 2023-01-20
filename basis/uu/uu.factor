! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: io io.streams.string kernel locals make math math.bitwise
math.order namespaces sequences ;

IN: uu

<PRIVATE

ERROR: bad-length seq ;

: check-length ( seq -- seq )
    dup length 45 > [ bad-length ] when ; inline

:: binary>ascii ( seq -- seq' )
    0 :> char!
    0 :> bits!
    seq check-length [
        dup length CHAR: \s + ,

        [ dup empty? bits zero? and ] [

            char 8 shift char!
            bits 8 + bits!

            dup empty? [
                unclip-slice char bitor char!
            ] unless

            [ bits 6 >= ] [
                bits 6 -
                [ char swap neg shift 0x3f bitand CHAR: \s + , ]
                [ bits! ] bi
            ] while

        ] until drop
    ] "" make ;

ERROR: illegal-character ch ;

: check-illegal-character ( ch -- ch )
    dup CHAR: \s dup 64 + between? [ illegal-character ] unless ;

:: ascii>binary ( seq -- seq' )
    0 :> char!
    0 :> bits!

    seq unclip-slice CHAR: \s - :> len!

    [
        [ dup empty? not len 0 > and ] [
            dup empty? [ 0 ] [ unclip-slice ] if
            dup "\r\n\0" member? [
                drop 0
            ] [
                check-illegal-character
                CHAR: \s -
            ] if

            char 6 shift bitor char!
            bits 6 + bits!

            bits 8 >= [
                bits 8 -
                [ char swap neg shift 0xff bitand , ]
                [ on-bits char bitand char! ]
                [ bits! ] tri
                len 1 - len!
            ] when
        ] while drop

    ] "" make ;

PRIVATE>

: uu-encode ( -- )
    "begin" print
    input-stream get [ binary>ascii print ] 45 (each-stream-block)
    "end" print ;

: string>uu ( seq -- seq' )
    [ [ uu-encode ] with-string-writer ] with-string-reader ;

: uu-decode ( -- )
    [ [ "begin" head? ] [ not ] bi or ] [ readln ] do until
    [
        dup [ "end" head? ] [ not ] bi or
        [ drop t ] [ ascii>binary write f ] if
    ] [ readln ] do until ;

: uu>string ( seq -- seq )
    [ [ uu-decode ] with-string-writer ] with-string-reader ;
