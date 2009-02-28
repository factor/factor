! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs byte-arrays combinators io io.encodings
io.encodings.ascii io.encodings.iana io.files kernel locals math
math.order math.parser values multiline sequences splitting
values hashtables io.binary io.encodings.asian math.ranges
namespaces ;
IN: io.encodings.korean


SINGLETON: cp949

cp949 "EUC-KR" register-encoding

SINGLETON: johab

SINGLETON: iso2022kr



<PRIVATE

:: encode-char-mb
( c stream quot-conv: ( c -- c2 ) quot-mb?: ( c -- ? ) -- )
    c quot-conv call quot-mb? call
    [
        c quot-conv call
        h>b/b swap 2byte-array
        stream stream-write
    ]
    [
        c 1byte-array
        stream stream-write
    ]
    if ; inline

:: decode-char-mb
( stream quot-conv: ( c -- c2 ) quot-mb?: ( c -- ? ) -- char/f )
    stream stream-read1
    {
        { [ dup not ] [ drop f ] }
        {
            [ dup quot-mb? call ]
            [
                stream stream-read1
                [ 2byte-array be> quot-conv call ]
                [ drop replacement-char ]
                if*
            ]
        }
        [ ]
    } cond ; inline

! cp949 encodings

VALUE: cp949-table

"vocab:io/encodings/korean/data/cp949.txt" <code-table>*
    to: cp949-table

: cp949>unicode ( b -- u )
    cp949-table n>u ;

: unicode>cp949 ( u -- b )
    cp949-table u>n ;

: cp949-1st? ( n -- ? )
    dup [ HEX: 81 HEX: fe between? ] when ;

: byte? ( n -- ? )
    0 HEX: ff between? ;

M: cp949 encode-char ( char stream encoding -- )
    drop [ unicode>cp949 ] [ byte? not ] encode-char-mb ;

M: cp949 decode-char ( stream encoding -- char/f )
    drop [ cp949>unicode ] [ cp949-1st? ] decode-char-mb ;


! johab encodings

VALUE: johab-table

"vocab:io/encodings/korean/data/johab.txt" <code-table>*
    to: johab-table

: johab>unicode ( n -- u ) johab-table n>u ;

: unicode>johab ( u -- n ) johab-table u>n ;

: johab-1st? ( n -- ? )
    [ HEX: 84 HEX: D3 between? ]
    [ HEX: D8 HEX: DE between? ]
    [ HEX: E0 HEX: F9 between? ]
    tri { } 3sequence [ t? ] any? ;

M: johab encode-char ( char stream encoding -- )
    drop [ unicode>johab ] [ byte? not ] encode-char-mb ;

M: johab decode-char ( stream encoding -- char/f )
    drop [ johab>unicode ] [ johab-1st? ] decode-char-mb ;


! iso-2022-kr encodings

: shift-in ( -- c ) HEX: 0F ;
: shift-out ( -- c ) HEX: 0E ;
: designator ( -- s ) { CHAR: $ CHAR: \ CHAR: ) CHAR: C } ;

: GR-range ( -- r ) HEX: A1 HEX: FE [a,b] ;
: GL-range ( -- r ) HEX: 21 HEX: 7E [a,b] ;

: GR>GL ( -- assoc )
    GR-range GL-range zip >hashtable ;

: GL>GR ( -- assoc )
    GL-range GR-range zip >hashtable ;


SYMBOL: *iso2022kr-status*

H{ } *iso2022kr-status* set-global

: iso2022kr-stream-get-status ( stream -- so/si/f )
    *iso2022kr-status* get-global swap at ;

: iso2022kr-stream-get-status* ( stream -- so/si )
    iso2022kr-stream-get-status
    [ shift-in ] unless* ;

:: iso2022kr-stream-set-status ( stream so/si -- )
    so/si stream *iso2022kr-status* get-global set-at ;

: iso2022kr-stream-shift-out? ( stream -- ? )
    iso2022kr-stream-get-status* shift-out = ;


M: iso2022kr encode-char ( char stream encoding -- )
    drop
    [let | stream [ ]
           char [ ] |
        char unicode>cp949 byte?
        [
            ! if <SO> written, then enclose with <SI>.
            stream iso2022kr-stream-shift-out?
            [ shift-in 1byte-array stream stream-write ] [ ] if
            ! plain ascii
            char 1byte-array stream stream-write
        ]
        [
            ! if <SO> is closed, then start it.
            stream iso2022kr-stream-shift-out? not
            [ shift-out 1byte-array stream stream-write ] [ ] if
            !
            char unicode>cp949 h>b/b swap 2byte-array
            ! GR -> GL
            [ GR>GL at ] map
            !
            stream stream-write
        ] if
    ] ;




PRIVATE>


