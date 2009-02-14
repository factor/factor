! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs byte-arrays combinators io io.encodings
io.encodings.ascii io.encodings.iana io.files kernel locals math
math.order math.parser memoize multiline sequences splitting
values hashtables ;
IN: io.encodings.korean


SINGLETON: cp949

ALIAS: ms949 cp949
ALIAS: euc-kr cp949
ALIAS: euckr cp949

cp949 "EUC-KR" register-encoding



<PRIVATE

! parse cp949.txt -> table

: (cp949.txt-lines) ( -- seq )
    ! "cp949.txt" from ...
    ! <http://unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP949.TXT>
    "resource:basis/io/encodings/korean/data/cp949.txt"
    ascii file-lines ;

: (PCL-drop-comments) ( seq -- newseq )
    [ "#" split1 drop ] map harvest ;

: (PCL-split-column) ( line -- columns )
    "\t" split 2 head ;

: (PCL-parse-hex) ( s -- n )
    2 short tail hex> ;

: (PCL-parse-line) ( line -- code-unicode )
    (PCL-split-column)
    [ (PCL-parse-hex) ] map ;

: (process-codetable-lines) ( lines -- assoc )
    (PCL-drop-comments)
    [ (PCL-parse-line) ] map ;


! convert cp949 <-> unicode

: (cp949.txt>alist) ( -- alist )
    (cp949.txt-lines) (process-codetable-lines) ;

: (make-cp949->unicode-table) ( alist -- h )
    >hashtable ;

: (make-unicode->cp949-table) ( alist -- h )
    [ reverse ] map >hashtable ;

VALUE: cp949->unicode-table
VALUE: unicode->cp949-table

(cp949.txt>alist) dup
(make-cp949->unicode-table) to: cp949->unicode-table
(make-unicode->cp949-table) to: unicode->cp949-table


MEMO: (cp949->unicode) ( b -- u )
    cp949->unicode-table at ;

MEMO: (unicode->cp949) ( u -- b )
    unicode->cp949-table at ;

:: (2b->1mb) ( c1 c2 -- mb )
    c1 8 shift c2 + ;

:: (1mb->1st) ( mb -- c1 )
    mb HEX: ff00 bitand -8 shift ;

:: (1mb->2nd) ( mb -- c2 )
    mb HEX: ff bitand ;

:: (1mb->2b) ( mb -- c1 c2 )
    mb (1mb->1st)
    mb (1mb->2nd) ;

: (cp949-1st?) ( n -- ? )
    dup f = not
    [ HEX: 81 HEX: fe between? ] when ;

: (1byte-unicode?) ( n -- ? )
    0 HEX: ff between? ;



M:: cp949 encode-char ( char stream encoding -- )
    char (unicode->cp949) (1byte-unicode?)
        [ char 1byte-array
        stream stream-write ]
    [ char (unicode->cp949)
        (1mb->2b) 2byte-array
        stream stream-write ]
        if ;

    
: (eof?) ( n -- ? ) 0 = ;

: (decode-char-step2) ( c stream -- char/f )
    stream-read1 (2b->1mb) (cp949->unicode) ;

M:: cp949 decode-char ( stream encoding -- char/f )
    stream stream-read1
    {
        { [ dup f = ] [ drop f ] }
        { [ dup (eof?) ] [ drop replacement-char ] }
        { [ dup (cp949-1st?) ] [ stream (decode-char-step2) ] }
        [ ]
    } cond ;


! TODO: <encoder>

! TODO: <decoder>




! EOF
