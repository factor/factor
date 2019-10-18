! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Some code for defining slot accessors and mutators. Used to
! implement tuples, as well as builtin types.
IN: generic
USING: kernel kernel-internals lists math namespaces parser
sequences strings words ;

: simple-generic ( class generic def -- )
    #! Just like:
    #! GENERIC: generic
    #! M: class generic def ;
    over define-generic define-method ;

: define-slot-word ( class slot word quot -- )
    over [
        >r swap >fixnum r> cons simple-generic
    ] [
        2drop 2drop
    ] ifte ;

: define-reader ( class slot reader -- )
    [ slot ] define-slot-word ;

: define-writer ( class slot writer -- )
    [ set-slot ] define-slot-word ;

: define-slot ( class slot reader writer -- )
    >r >r 2dup r> define-reader r> define-writer ;

: ?create-in dup string? [ create-in ] when ;

: intern-slots ( spec -- spec )
    #! For convenience, we permit reader/writers to be specified
    #! as strings.
    [ 3unlist swap ?create-in swap ?create-in 3list ] map ;

: define-slots ( class spec -- )
    #! Define a collection of slot readers and writers for the
    #! given class. The spec is a list of lists of length 3 of
    #! the form [ slot reader writer ]. slot is an integer,
    #! reader and writer are either words, strings or f.
    intern-slots
    2dup "slots" set-word-prop
    [ 3unlist define-slot ] each-with ;

: reader-word ( class name -- word )
    >r word-name "-" r> append3 create-in ;

: writer-word ( class name -- word )
    [ swap "set-" , word-name , "-" , , ] make-string create-in ;

: simple-slot ( class name -- [ reader writer ] )
    [ reader-word ] 2keep writer-word 2list ;

: simple-slot-spec ( class slots -- spec )
    [ simple-slot ] map-with ;

: simple-slots ( base class slots -- )
    #! Takes a list of slot names, and for each slot name
    #! defines a pair of words <class>-<slot> and 
    #! set-<class>-<slot>. Slot numbering is consecutive and
    #! begins at base.
    >r tuck r>
    simple-slot-spec [ length [ + ] project-with ] keep zip
    define-slots ;
