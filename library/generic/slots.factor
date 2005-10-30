! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Some code for defining slot accessors and mutators. Used to
! implement tuples, as well as builtin types.
IN: generic
USING: arrays kernel kernel-internals lists math namespaces
parser sequences strings words ;

: define-typecheck ( class generic def -- )
    #! Just like:
    #! GENERIC: generic
    #! M: class generic def ;
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

: ?create ( { name vocab } -- word )
    dup [ first2 create ] when ;

: intern-slots ( spec -- spec )
    [ first3 [ ?create ] 2apply 3array ] map ;

: define-slots ( class spec -- )
    #! Define a collection of slot readers and writers for the
    #! given class. The spec is a list of lists of length 3 of
    #! the form [ slot reader writer ]. slot is an integer,
    #! reader and writer are either words, strings or f.
    [ first3 define-slot ] each-with ;

: reader-word ( class name -- word )
    >r word-name "-" r> append3 "in" get 2array ;

: writer-word ( class name -- word )
    [ swap "set-" % word-name % "-" % % ] "" make
    "in" get 2array ;

: simple-slot ( class name -- reader writer )
    [ reader-word ] 2keep writer-word ;

: simple-slots ( class slots base -- spec )
    #! Takes a list of slot names, and for each slot name
    #! defines a pair of words <class>-<slot> and 
    #! set-<class>-<slot>. Slot numbering is consecutive and
    #! begins at base.
    over length [ + ] map-with
    [ >r dupd simple-slot r> -rot 3array ] 2map nip
    intern-slots ;
