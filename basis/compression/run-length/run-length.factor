! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators grouping kernel locals math
math.matrices math.order multiline sequences.parser sequences
tools.continuations ;
IN: compression.run-length

: run-length-uncompress ( byte-array -- byte-array' )
    2 group [ first2 <array> ] map B{ } concat-as ;

: 8hi-lo ( byte -- hi lo )
    [ HEX: f0 bitand -4 shift ] [ HEX: f bitand ] bi ; inline

:: run-length-uncompress-bitmap4 ( byte-array m n -- byte-array' )
    byte-array <sequence-parser> :> sp
    m  1 + n zero-matrix :> matrix
    n 4 mod n + :> stride
    0 :> i!
    0 :> j!
    f :> done?!
    [
        ! i j [ number>string ] bi@ " " glue .
        sp next dup 0 = [
            sp next dup HEX: 03 HEX: ff between? [
                nip [ sp ] dip dup odd?
                [ 1 + take-n but-last ] [ take-n ] if
                [ j matrix i swap nth copy ] [ length j + j! ] bi
            ] [
                nip {
                    { 0 [ i 1 + i!  0 j! ] }
                    { 1 [ t done?! ] }
                    { 2 [ sp next j + j!  sp next i + i! ] }
                } case
            ] if
        ] [
            [ sp next 8hi-lo 2array <repetition> concat ] [ head ] bi
            [ j matrix i swap nth copy ] [ length j + j! ] bi
        ] if
        
        ! j stride >= [ i 1 + i!  0 j! ] when
        j stride >= [ 0 j! ] when
        done? not
    ] loop
    matrix B{ } concat-as ;

:: run-length-uncompress-bitmap8 ( byte-array m n -- byte-array' )
    byte-array <sequence-parser> :> sp
    m  1 + n zero-matrix :> matrix
    n 4 mod n + :> stride
    0 :> i!
    0 :> j!
    f :> done?!
    [
        ! i j [ number>string ] bi@ " " glue .
        sp next dup 0 = [
            sp next dup HEX: 03 HEX: ff between? [
                nip [ sp ] dip dup odd?
                [ 1 + take-n but-last ] [ take-n ] if
                [ j matrix i swap nth copy ] [ length j + j! ] bi
            ] [
                nip {
                    { 0 [ i 1 + i!  0 j! ] }
                    { 1 [ t done?! ] }
                    { 2 [ sp next j + j!  sp next i + i! ] }
                } case
            ] if
        ] [
            sp next <array> [ j matrix i swap nth copy ] [ length j + j! ] bi
        ] if
        
        ! j stride >= [ i 1 + i!  0 j! ] when
        j stride >= [ 0 j! ] when
        done? not
    ] loop
    matrix B{ } concat-as ;
