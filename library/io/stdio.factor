! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: errors generic hashtables kernel namespaces sequences
strings styles ;

! Default stream
SYMBOL: stdio

: close ( -- ) stdio get stream-close ;

: readln ( -- string/f ) stdio get stream-readln ;
: read1 ( -- char/f ) stdio get stream-read1 ;
: read ( count -- string ) stdio get stream-read ;

: write1 ( char -- ) stdio get stream-write1 ;
: write ( string -- ) stdio get stream-write ;
: flush ( -- ) stdio get stream-flush ;

: terpri ( -- ) stdio get stream-terpri ;
: format ( string style -- ) stdio get stream-format ;

: with-nesting ( style quot -- )
    swap stdio get with-nested-stream ;

: tabular-output ( grid style quot -- )
    -rot stdio get with-stream-table ;

: print ( string -- ) stdio get stream-print ;

: with-stream* ( stream quot -- )
    [ swap stdio set call ] with-scope ; inline

: with-stream ( stream quot -- )
    swap [ [ close ] cleanup ] with-stream* ; inline

SYMBOL: style-stack

V{ } clone style-stack set-global

: >style ( style -- )
    dup hashtable? [ "Style must be a hashtable" throw ] unless
    style-stack get push ;

: drop-style ( -- ) style-stack get pop* ;

: with-style ( style quot -- )
    swap >style call drop-style ; inline

: with-style-stack ( quot -- )
    [ V{ } clone style-stack set call ] with-scope ;

: current-style ( -- style )
    style-stack get hash-concat ;

: format* ( string -- ) current-style format ;

: bl ( -- ) " " format* ;

: with-nesting* ( style quot -- )
    swap [ current-style swap with-nesting ] with-style ; inline

: write-object ( object quot -- )
    >r presented associate r> with-style ;

: simple-object ( string object -- )
    [ format* ] write-object ;

: write-outliner ( content caption -- )
    >r outline associate r> with-nesting* ;

: simple-outliner ( string object content -- )
    [ simple-object ] write-outliner ;
