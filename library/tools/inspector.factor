! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: generic hashtables io kernel kernel-internals listener
lists math memory namespaces prettyprint sequences strings
styles test vectors words ;

GENERIC: sheet ( obj -- sheet )

M: object sheet ( obj -- sheet )
    dup class "slots" word-prop
    [ second ] map
    tuck [ execute ] map-with
    2vector ;

M: list sheet 1vector ;

M: vector sheet 1vector ;

M: array sheet 1vector ;

M: hashtable sheet dup hash-keys swap hash-values 2vector ;

: format-column ( list -- list )
    [ unparse-short ] map
    [ max-length ] keep
    [ swap CHAR: \s pad-right ] map-with ;

: sheet-numbers ( sheet -- sheet )
    dup first length >vector 1vector swap append ;

SYMBOL: inspector-slots

: format-sheet ( sheet -- list )
    sheet-numbers
    dup peek inspector-slots set
    [ format-column ] map
    flip
    [ " | " join ] map ;

: vocab-banner ( word -- )
    dup word-vocabulary [
        dup interned? [
            "This word is located in the " write
        ] [
            "This is an orphan not part of the dictionary." print
            "It claims to belong to the " write
        ] ifte
        word-vocabulary pprint " vocabulary." print
    ] [
        drop
        "The word is a uniquely generated symbol." print
    ] ifte ;

GENERIC: extra-banner ( obj -- )

M: word extra-banner ( obj -- )
    dup vocab-banner
    metaclass [
        "This is a class whose behavior is specifed by the " write
        pprint " metaclass." print
    ] when* ;

M: object extra-banner ( obj -- ) drop ;

: inspect-banner ( obj -- )
    "You are looking at an instance of the " write dup class pprint
    " class:" print
    "  " write dup pprint-short terpri
    "It takes up " write dup size pprint " bytes of memory." print
    extra-banner ;

: describe ( obj -- )
    sheet dup format-sheet swap peek
    [ write-object terpri ] 2each ;

SYMBOL: inspector-stack

: inspecting ( -- obj ) inspector-stack get peek ;

: (inspect) ( obj -- )
    dup inspector-stack get push
    dup inspect-banner describe ;

: inspector-help ( -- )
    "Object inspector." print
    "inspecting ( -- obj ) push current object" print
    "go ( n -- ) inspect nth slot" print
    "up -- return to previous object" print
    "refs -- inspect references to current object" print
    "bye -- exit inspector" print ;

: inspector ( obj -- )
    [
        inspector-help
        terpri
        "inspector " listener-prompt set
        [ inspector-stack get "Inspector history:" ] callstack-hook set
        { } clone inspector-stack set
        (inspect)
        listener
    ] with-scope ;

: inspect ( obj -- )
    #! Start an inspector if its not already running.
    inspector-stack get [ (inspect) ] [ inspector ] ifte ;

: go ( n -- ) inspector-slots get nth (inspect) ;

: up ( -- ) inspector-stack get >pop> pop (inspect) ;

: refs ( -- ) inspecting references (inspect) ;
