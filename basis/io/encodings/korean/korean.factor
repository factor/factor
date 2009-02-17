! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs byte-arrays combinators io io.encodings
io.encodings.ascii io.encodings.iana io.files kernel locals math
math.order math.parser memoize multiline sequences splitting
values hashtables io.binary ;
IN: io.encodings.korean

! TODO: euckr, cp949 seperate (euckr: backslash = Won, cp949: bs <> Won)
! TODO: no byte manip. only code-tables.
! TODO: migrate to common code-table parser (by Dan).

SINGLETON: cp949

cp949 "EUC-KR" register-encoding

<PRIVATE

! parse cp949.txt > table

: cp949.txt-lines ( -- seq )
    ! "cp949.txt" from ...
    ! <http://unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP949.TXT>
    "vocab:io/encodings/korean/data/cp949.txt"
    ascii file-lines ;

: drop-comments ( seq -- newseq )
    [ "#" split1 drop ] map harvest ;

: split-column ( line -- columns )
    "\t" split 2 head ;

: parse-hex ( s -- n )
    2 short tail hex> ;

: parse-line ( line -- code-unicode )
    split-column [ parse-hex ] map ;

: process-codetable-lines ( lines -- assoc )
    drop-comments [ parse-line ] map ; 

! convert cp949 <> unicode

MEMO: cp949>unicode-table ( -- hashtable )
    cp949.txt-lines process-codetable-lines >hashtable ;

MEMO: unicode>cp949-table ( -- hashtable )
    cp949>unicode-table [ swap ] assoc-map ;

unicode>cp949-table drop

: cp949>unicode ( b -- u )
    cp949>unicode-table at ;

: unicode>cp949 ( u -- b )
    unicode>cp949-table at ;

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

: decode-char-step2 ( c stream -- char )
    stream-read1
    [ 2byte-array be> cp949>unicode ]
    [ drop replacement-char ] if* ;

M:: cp949 decode-char ( stream encoding -- char/f )
    stream stream-read1
    {
        { [ dup not ] [ drop f ] }
        { [ dup cp949-1st? ] [ stream decode-char-step2 ] }
        [ ]
    } cond ;
