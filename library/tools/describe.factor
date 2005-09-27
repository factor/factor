! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: arrays generic hashtables io kernel kernel-internals
lists math prettyprint sequences strings vectors words ;

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

: format-sheet ( sheet -- list )
    [ format-column ] map flip [ " " join ] map ;

DEFER: describe

: sheet. ( sheet -- )
    dup format-sheet swap peek
    [ dup [ describe ] curry write-outliner ] 2each ;

: describe ( object -- ) sheet sheet. ;

: word. ( word -- )
    dup word-name swap dup [ see ] curry write-outliner ;

: object-outline ( seq quot -- )
    swap [
        [ unparse-short ] keep rot dupd curry write-outliner
    ] each-with ;

: words. ( vocab -- )
    words [ see ] object-outline ;

: vocabs. ( -- )
    #! Outlining word browser.
    vocabs [ f over [ words. ] curry write-outliner ] each ;

: usage. ( word -- )
    #! Outlining usages browser.
    usage [ usage. ] object-outline ;

: uses. ( word -- )
    #! Outlining call hierarchy browser.
    uses [ uses. ] object-outline ;

: stack. ( seq -- seq )
    reverse-slice >array describe ;

: .s datastack stack. ;
: .r callstack stack. ;
