! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

IN: generic
USING: arrays kernel kernel-internals lists math namespaces
parser sequences strings words ;

: define-typecheck ( class generic def -- )
    over define-generic -rot define-method ;

: define-slot-word ( class slot word quot -- )
    over [
        >r swap >fixnum r> cons define-typecheck
    ] [
        2drop 2drop
    ] if ;

: define-reader ( class slot reader -- )
    [ slot ] define-slot-word ;

: define-writer ( class slot writer -- )
    [ set-slot ] define-slot-word ;

: define-slot ( class slot reader writer -- )
    >r >r 2dup r> define-reader r> define-writer ;

: intern-slots ( spec -- spec )
    [ first3 [ dup [ first2 create ] when ] 2apply 3array ] map ;

: define-slots ( class spec -- )
    [ first3 define-slot ] each-with ;

: reader-word ( class name -- word )
    >r word-name "-" r> append3 in get 2array ;

: writer-word ( class name -- word )
    [ swap "set-" % word-name % "-" % % ] "" make in get 2array ;

: simple-slot ( class name -- reader writer )
    [ reader-word ] 2keep writer-word ;

: simple-slots ( class slots base -- spec )
    over length [ + ] map-with
    [ >r dupd simple-slot r> -rot 3array ] 2map nip
    intern-slots ;
