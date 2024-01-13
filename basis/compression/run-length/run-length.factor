! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators grouping kernel math math.matrices
math.order sequences sequences.parser ;
IN: compression.run-length

: run-length-uncompress ( byte-array -- byte-array' )
    2 group [ first2 <array> ] map B{ } concat-as ;

: 8hi-lo ( byte -- hi lo )
    [ 0xf0 bitand -4 shift ] [ 0xf bitand ] bi ; inline

:: run-length-uncompress-bitmap4 ( byte-array m n -- byte-array' )
    byte-array <sequence-parser> :> sp
    m  1 + n <zero-matrix> :> matrix
    n 4 mod n + :> stride
    0 :> i!
    0 :> j!
    f :> done?!
    [
        ! i j [ number>string ] bi@ " " glue .
        sp consume dup 0 = [
            sp consume dup 0x03 0xff between? [
                nip [ sp ] dip dup odd?
                [ 1 + take-n but-last ] [ take-n ] if
                [ j matrix i swap nth copy ] [ length j + j! ] bi
            ] [
                nip {
                    { 0 [ i 1 + i!  0 j! ] }
                    { 1 [ t done?! ] }
                    { 2 [ sp consume j + j!  sp consume i + i! ] }
                } case
            ] if
        ] [
            [ sp consume 8hi-lo 2array <repetition> concat ] [ head ] bi
            [ j matrix i swap nth copy ] [ length j + j! ] bi
        ] if

        ! j stride >= [ i 1 + i!  0 j! ] when
        j stride >= [ 0 j! ] when
        done? not
    ] loop
    matrix B{ } concat-as ;

:: run-length-uncompress-bitmap8 ( byte-array m n -- byte-array' )
    byte-array <sequence-parser> :> sp
    m  1 + n <zero-matrix> :> matrix
    n 4 mod n + :> stride
    0 :> i!
    0 :> j!
    f :> done?!
    [
        ! i j [ number>string ] bi@ " " glue .
        sp consume dup 0 = [
            sp consume dup 0x03 0xff between? [
                nip [ sp ] dip dup odd?
                [ 1 + take-n but-last ] [ take-n ] if
                [ j matrix i swap nth copy ] [ length j + j! ] bi
            ] [
                nip {
                    { 0 [ i 1 + i!  0 j! ] }
                    { 1 [ t done?! ] }
                    { 2 [ sp consume j + j!  sp consume i + i! ] }
                } case
            ] if
        ] [
            sp consume <array> [ j matrix i swap nth copy ] [ length j + j! ] bi
        ] if

        ! j stride >= [ i 1 + i!  0 j! ] when
        j stride >= [ 0 j! ] when
        done? not
    ] loop
    matrix B{ } concat-as ;
