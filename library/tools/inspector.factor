! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: arrays generic hashtables io kernel kernel-internals
listener lists math memory namespaces prettyprint sequences
strings styles test vectors words ;

GENERIC: sheet ( obj -- sheet )

M: object sheet ( obj -- sheet )
    dup class "slots" word-prop
    dup [ second ] map -rot
    [ first slot ] map-with
    2array ;

M: list sheet 1array ;

M: vector sheet 1array ;

M: array sheet 1array ;

M: hashtable sheet dup hash-keys swap hash-values 2array ;

: format-column ( list -- list )
    [ unparse-short ] map
    [ 0 [ length max ] reduce ] keep
    [ swap CHAR: \s pad-right ] map-with ;

: sheet-numbers ( sheet -- sheet )
    dup first length >array 1array swap append ;

SYMBOL: inspector-slots

: format-sheet ( sheet -- list )
    sheet-numbers
    dup peek inspector-slots set
    [ format-column ] map
    flip
    [ " | " join ] map ;

GENERIC: extra-banner ( obj -- )

M: word extra-banner ( word -- )
    dup word-vocabulary [
        dup interned? [
            "This word is located in the " write
        ] [
            "This is an orphan not part of the dictionary." print
            "It claims to belong to the " write
        ] if
        word-vocabulary pprint " vocabulary." print
    ] [
        drop
        "The word is a uniquely generated symbol." print
    ] if ;

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
    inspector-stack get [ (inspect) ] [ inspector ] if ;

: go ( n -- ) inspector-slots get nth (inspect) ;

: up ( -- ) inspector-stack get dup pop* pop (inspect) ;
