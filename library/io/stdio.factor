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
: terpri* ( -- ) stdio get stream-terpri* ;
: format ( string style -- ) stdio get stream-format ;

: with-nesting ( style quot -- )
    swap stdio get with-nested-stream ;

: print ( string -- ) stdio get stream-print ;

: with-stream ( stream quot -- )
    #! Close the stream no matter what happens.
    [ swap stdio set [ close ] cleanup ] with-scope ; inline

: with-stream* ( stream quot -- )
    #! Close the stream if there is an error.
    [ swap stdio set [ close rethrow ] recover ] with-scope ;
    inline

SYMBOL: style-stack

: >style ( style -- )
    #! Push a style on the style stack.
    dup hashtable? [ "Style must be a hashtable" throw ] unless
    style-stack [ ?push ] change ;

: style> ( -- style )
    style-stack get pop ;

: with-style ( style quot -- )
    [ >r >style r> call style> drop ] with-scope ; inline

: current-style ( -- style )
    #! Always returns a fresh hashtable.
    style-stack get hash-concat ;

: format* ( string -- ) current-style format ;

: bl ( -- ) " " current-style t word-break pick set-hash format ;

: with-nesting* ( quot -- )
    current-style swap with-nesting ; inline

: write-object ( object quot -- )
    >r presented associate r> with-style ;

: simple-object ( string object -- )
    #! Writes a clickable presentation with the specified string.
    [ format* ] write-object ;

: write-outliner ( content caption -- )
    #! Takes a pair of quotations.
    >r outline associate r> with-nesting terpri ;

: simple-outliner ( string object content -- )
    [ simple-object ] write-outliner ;
