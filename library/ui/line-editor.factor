! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: line-editor
USING: kernel math namespaces sequences strings vectors ;

SYMBOL: history
SYMBOL: history-index

SYMBOL: line-text
SYMBOL: caret

! Completion
SYMBOL: possibilities

: history-length ( -- n )
    #! Call this in the line editor scope.
    history get length ;

: reset-history ( -- )
    #! Call this in the line editor scope. After user input,
    #! resets the history index.
    history-length history-index set ;

! A point is a mutable object holding an index in the line
! editor. Changing text in the points registered with the
! line editor will move the point if it is after the changed
! text.
TUPLE: point index ;

: (point-update) ( len from to index -- index )
    pick over > [
        >r 3drop r>
    ] [
        3dup -rot between? [ 2drop ] [ >r - + r> ] if +
    ] if ;

: point-update ( len from to point -- )
    #! Call this in the line editor scope.
    [ point-index (point-update) ] keep set-point-index ;

: line-replace ( str from to -- )
    #! Call this in the line editor scope.
    reset-history
    pick length pick pick caret get point-update
    line-text [ replace-slice ] change ;

: line-remove ( from to -- )
    #! Call this in the line editor scope.
    "" -rot line-replace ;

: line-length line-text get length ;

: set-line-text ( text -- )
    #! Call this in the line editor scope.
    0 line-length line-replace ;

: line-clear ( -- )
    #! Call this in the line editor scope.
    "" set-line-text ;

! An element is a unit of text; character, word, etc.
GENERIC: next-elt* ( i str element -- i )
GENERIC: prev-elt* ( i str element -- i )

TUPLE: char-elt ;

M: char-elt next-elt* 2drop 1+ ;
M: char-elt prev-elt* 2drop 1- ;

TUPLE: word-elt ;

M: word-elt next-elt* ( i str element -- i )
    drop dup length >r [ blank? ] find* drop dup -1 =
    [ drop r> ] [ r> drop 1+ ] if ;

M: word-elt prev-elt* ( i str element -- i )
    drop >r 1- r> [ blank? ] find-last* drop 1+ ;

TUPLE: document-elt ;

M: document-elt next-elt* rot 2drop length ;
M: document-elt prev-elt* 3drop 0 ;

: caret-pos caret get point-index ;

: set-caret-pos caret get set-point-index ;

: next-elt@ ( element -- from to )
    >r caret-pos dup line-text get r> next-elt* line-length min ;

: next-elt ( element -- )
    next-elt@ set-caret-pos drop ;

: prev-elt@ ( element -- from to )
    >r caret-pos dup line-text get r> prev-elt* 0 max swap ;

: prev-elt ( element -- )
    prev-elt@ drop set-caret-pos ;

: delete-next-elt ( element -- )
    next-elt@ line-remove ;

: delete-prev-elt ( element -- )
    prev-elt@ line-remove ;

: insert-char ( ch -- )
    #! Call this in the line editor scope.
    ch>string caret-pos dup line-replace ;

: commit-history ( -- )
    #! Call this in the line editor scope. Adds the currently
    #! entered text to the history.
    line-text get dup empty?
    [ drop ] [ history get push reset-history ] if ;

: <line-editor> ( -- editor )
    [
        "" line-text set
        0 <point> caret set
        V{ } clone history set
        0 history-index set
        possibilities off
    ] make-hash ;

: goto-history ( n -- )
    #! Call this in the line editor scope.
    dup history get nth set-line-text history-index set ;

: history-prev ( -- )
    #! Call this in the line editor scope.
    history-index get dup zero? [
        drop
    ] [
        dup history-length = [ commit-history ] when
        1- goto-history
    ] if ;

: history-next ( -- )
    #! Call this in the line editor scope.
    history-index get dup 1+ history-length >=
    [ drop ] [ 1+ goto-history ] if ;

: completions ( -- seq )
    T{ word-elt } prev-elt@ 2dup = [
        2drop f
    ] [
        line-text get subseq possibilities get
        [ [ swap head? ] completion? ] subset-with
    ] if ;

: complete ( completion -- )
    T{ word-elt } prev-elt@ line-replace ;
