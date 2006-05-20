! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inspector
USING: arrays generic hashtables help io kernel kernel-internals
math namespaces prettyprint sequences strings vectors words ;

GENERIC: summary ( object -- string )

: sign-string ( n -- string )
    0 > "a positive " "a negative " ? ;

M: integer summary
    dup zero? [
        "a " "zero "
    ] [
        dup sign-string over 2 mod zero? "even " "odd " ?
    ] if rot class word-name append3 ;

M: real summary
    dup sign-string swap class word-name append ;

M: complex summary
    "a complex number in the "
    swap quadrant { "first" "second" "fourth" "third" } nth
    " quadrant" append3 ;

GENERIC: sheet ( obj -- sheet )

M: object summary
    "an instance of the " swap class word-name " class" append3 ;

: slot-sheet ( obj -- sheet )
    dup class "slots" word-prop
    dup [ third ] map -rot
    [ first slot ] map-with
    2array ;

M: object sheet ( obj -- sheet ) slot-sheet ;

M: sequence summary
    [ dup length # " element " % class word-name % ] "" make ;

M: quotation sheet 1array ;

M: vector sheet 1array ;

M: array sheet 1array ;

M: hashtable summary
    "a hashtable storing " swap hash-size number>string
    " keys" append3 ;

M: hashtable sheet hash>alist flip ;

M: word summary ( word -- )
    dup word-vocabulary [
        dup interned?
        "a word in the " "a word orphaned from the " ?
        swap word-vocabulary " vocabulary" append3
    ] [
        drop "a uniquely generated symbol"
    ] if ;

: format-column ( list ? -- list )
    >r [ unparse-short ] map r> [
        [ 0 [ length max ] reduce ] keep
        [ swap CHAR: \s pad-right ] map-with
    ] unless ;

: format-sheet ( sheet -- list )
    #! We use an idiom to notify format-column if it is
    #! formatting the last column.
    dup length <reversed> [ zero? format-column ] 2map
    flip [ " " join ] map ;

DEFER: describe

: sheet. ( sheet -- )
    dup empty? [
        drop
    ] [
        dup format-sheet swap peek
        [ dup [ describe ] curry simple-outliner terpri ] 2each
    ] if ;

: describe ( object -- ) dup summary print sheet sheet. ;

: stack. ( seq -- seq ) <reversed> >array describe ;

: .s datastack stack. ;
: .r retainstack stack. ;

: callframe. ( seq pos -- )
    [
        hilite-index set dup hilite-quotation set .
    ] with-scope ;

: callstack. ( seq -- seq )
    3 swap group <reversed> [ first2 1- callframe. ] each ;

: .c callstack callstack. ;

: word-outliner ( seq quot -- )
    swap natural-sort [
        [ synopsis ] keep rot dupd curry
        simple-outliner terpri
    ] each-with ;

: usage. ( word -- ) usage [ usage. ] word-outliner ;

: uses. ( word -- ) uses [ uses. ] word-outliner ;

: apropos ( substring -- )
    all-words completions natural-sort
    [ (help) ] word-outliner ;
