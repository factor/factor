! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: arrays generic hashtables io kernel kernel-internals
lists math prettyprint sequences strings vectors words ;

GENERIC: summary ( object -- string )

: sign-string ( n -- string )
    0 > "a positive " "a negative " ? ;

M: integer summary
    dup sign-string over 2 mod 0 = "even " "odd " ?
    rot class word-name append3 ;

M: real summary
    dup sign-string swap class word-name append ;

M: complex summary
    "a complex number in the "
    swap quadrant { "first" "second" "fourth" "third" } nth
    " quadrant" append3 ;

GENERIC: sheet ( obj -- sheet )

M: object summary
    "an instance of the " swap class word-name " class" append3 ;

M: object sheet ( obj -- sheet )
    dup class "slots" word-prop
    dup [ second ] map -rot
    [ first slot ] map-with
    2array ;

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

M: hashtable sheet dup hash-keys swap hash-values 2array ;

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
    dup length reverse-slice [ 0 = format-column ] 2map
    flip [ " " join ] map ;

DEFER: describe

: sheet. ( sheet -- )
    dup format-sheet swap peek
    [ dup [ describe ] curry write-outliner ] 2each ;

: describe ( object -- ) dup summary print sheet sheet. ;

: word. ( word -- )
    dup word-name swap dup [ see ] curry write-outliner ;

: simple-outliner ( seq quot -- | quot: obj -- )
    swap [
        [ unparse-short ] keep rot dupd curry write-outliner
    ] each-with ;

: words. ( vocab -- )
    words word-sort [ see ] simple-outliner ;

: vocabs. ( -- )
    #! Outlining word browser.
    vocabs [ f over [ words. ] curry write-outliner ] each ;

: usage. ( word -- )
    #! Outlining usages browser.
    usage [ usage. ] simple-outliner ;

: uses. ( word -- )
    #! Outlining call hierarchy browser.
    uses [ uses. ] simple-outliner ;

: stack. ( seq -- seq )
    reverse-slice >array describe ;

: .s datastack stack. ;
: .r callstack stack. ;
