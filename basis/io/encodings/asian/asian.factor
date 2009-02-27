! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.parser sequences io.files io.encodings.ascii
splitting assocs hashtables accessors ;
IN: io.encodings.asian




<PRIVATE

: drop-comments ( seq -- newseq )
    [ "#" split1 drop ] map harvest ;

: split-column ( line -- columns )
    "\t" split 2 head ;

: parse-hex ( s -- n )
    2 short tail hex> ;

: parse-line ( line -- code-unicode )
    split-column [ parse-hex ] map ;

: lines>(n>u) ( lines -- n>u )
    drop-comments [ parse-line ] map >hashtable ; 

: file>(n>u) ( filename -- n>u )
    ascii file-lines lines>(n>u) ;

: (n>u)>(u>n) ( n>u -- u>n )
    [ swap ] assoc-map ;

PRIVATE>

TUPLE: code-table n>u u>n ;

C: <code-table> code-table

: <code-table>* ( filename -- code-table )
    file>(n>u) dup (n>u)>(u>n) <code-table> ;

GENERIC: n>u ( n code-table -- u )

M: code-table n>u ( n code-table -- u ) n>u>> at ;

GENERIC: u>n ( u code-table -- n )

M: code-table u>n ( u code-table -- n ) u>n>> at ;


