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

: define-reader ( class slot decl reader -- )
    [ slot ] rot dup object eq? [
        drop
    ] [
        1array [ declare ] curry append
    ] if define-slot-word ;

: define-writer ( class slot writer -- )
    [ set-slot ] define-slot-word ;

: define-slot ( class slot decl reader writer -- )
    >r >r >r 2dup r> r> define-reader r> define-writer ;

: intern-slots ( spec -- spec )
    [ [ dup array? [ first2 create ] when ] map ] map ;

: define-slots ( class spec -- )
    [ first4 define-slot ] each-with ;

: reader-word ( class name -- word )
    >r word-name "-" r> append3 in get 2array ;

: writer-word ( class name -- word )
    [ swap "set-" % word-name % "-" % % ] "" make in get 2array ;

: simple-slot ( class name -- )
    2dup reader-word , writer-word , ;

: simple-slots ( class slots base -- spec )
    over length [ + ] map-with
    [ [ , object , dupd simple-slot ] { } make ] 2map nip intern-slots ;
