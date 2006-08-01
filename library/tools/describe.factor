! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inspector
USING: arrays generic hashtables io kernel kernel-internals
math namespaces prettyprint sequences strings styles vectors
words ;

GENERIC: sheet ( obj -- sheet )

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

: sheet. ( sheet -- )
    flip dup empty? [
        drop
    ] [
        dup first length 1 =
        { 0 0 } { 10 0 } ? table-gap associate
        [ dup unparse-short swap write-object ]
        tabular-output
    ] if ;

: describe ( object -- ) dup summary print sheet sheet. ;

: stack. ( seq -- seq ) <reversed> >array sheet sheet. ;

: .s datastack stack. ;
: .r retainstack stack. ;

: callframe. ( seq pos -- )
    [
        hilite-index set dup hilite-quotation set
        1 nesting-limit set
        pprint
        terpri
    ] with-scope ;

: callstack. ( seq -- seq )
    3 group <reversed> [ first2 1- callframe. ] each ;

: .c callstack callstack. ;
