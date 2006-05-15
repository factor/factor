! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: arrays generic hashtables help io kernel kernel-internals
lists math prettyprint sequences strings vectors words ;

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
    dup length 1 = [
        drop "a sequence containing 1 element"
    ] [
        "a sequence containing " swap length number>string
        " elements" append3
    ] if ;

M: list sheet 1array ;

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
    dup length reverse-slice [ zero? format-column ] 2map
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

: sequence-outliner ( seq quot -- | quot: obj -- )
    swap [
        [ unparse-short ] keep rot dupd curry
        simple-outliner terpri
    ] each-with ;

: words. ( vocab -- )
    words natural-sort [ (help) ] sequence-outliner ;

: vocabs. ( -- ) vocabs [ words. ] sequence-outliner ;

: usage. ( word -- ) usage [ usage. ] sequence-outliner ;

: uses. ( word -- ) uses [ uses. ] sequence-outliner ;

: stack. ( seq -- seq ) reverse-slice >array describe ;

: .s datastack stack. ;
: .r retainstack stack. ;
: .c callstack stack. ;
