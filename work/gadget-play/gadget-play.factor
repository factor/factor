! File: gadget-play
! Version: 0.1
! DRI: Dave Carlton
! Description: Gadget playground
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes.tuple io kernel math.parser pmlog
sequences ui.gadgets.world ;
IN: gadget-play

: (tuples) ( seq -- seq )
    [ tuple? ] collect-by  t swap at
    dup [
        { } swap [ tuple-slots (tuples) append ] each
    ] when
    ;

: (arrays) ( seq -- seq )
    [ array? ] collect-by
    t swap at
    ;

: tuples ( world -- seq seq )
    tuple-slots [ (tuples) ] keep
    ;

: test1 ( -- ) LOGWARNING ; 
: test2 ( -- ) LOGWARNING" this is just a warning" ;
: test3 ( n -- ) number>string "The number was: " prepend >LOGWARNING ;

