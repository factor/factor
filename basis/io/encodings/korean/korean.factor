! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs byte-arrays combinators io io.encodings
io.encodings.ascii io.encodings.iana io.files kernel locals math
math.order math.parser values multiline sequences splitting
values hashtables io.binary io.encodings.asian ;
IN: io.encodings.korean


SINGLETON: cp949

cp949 "EUC-KR" register-encoding

SINGLETON: johab

! johab "JOHAB" register-encoding


<PRIVATE

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

M:: cp949 encode-char ( char stream encoding -- )
    char unicode>cp949 byte?
    [ char 1byte-array stream stream-write ] [
        char unicode>cp949
        h>b/b swap 2byte-array
        stream stream-write
    ] if ;

: cp949-decode-char-step2 ( c stream -- char )
    stream-read1
    [ 2byte-array be> cp949>unicode ]
    [ drop replacement-char ] if* ;

M:: cp949 decode-char ( stream encoding -- char/f )
    stream stream-read1
    {
        { [ dup not ] [ drop f ] }
        { [ dup cp949-1st? ] [ stream cp949-decode-char-step2 ] }
        [ ]
    } cond ;



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

M:: johab encode-char ( char stream encoding -- )
    char unicode>johab byte?
    [ char 1byte-array stream stream-write ] [
        char unicode>johab
        h>b/b swap 2byte-array
        stream stream-write
    ] if ;

: johab-decode-char-step2 ( c stream -- char )
    stream-read1
    [ 2byte-array be> johab>unicode ]
    [ drop replacement-char ] if* ;

M:: johab decode-char ( stream encoding -- char/f )
    stream stream-read1
    {
        { [ dup not ] [ drop f ] }
        { [ dup johab-1st? ] [ stream johab-decode-char-step2 ] }
        [ ]
    } cond ;

PRIVATE>


