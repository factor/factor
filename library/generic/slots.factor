! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Some code for defining slot accessors and mutators. Used to
! implement tuples, as well as builtin types.
IN: generic
USING: kernel kernel-internals lists math namespaces parser
strings words ;

! So far, only tuples can have delegates, which also must be
! tuples (the UI uses numbers as delegates in a couple of places
! but this is Unsupported(tm)).
GENERIC: delegate
M: object delegate drop f ;

: simple-generic ( class generic def -- )
    #! Just like:
    #! GENERIC: generic
    #! M: class generic def ;
    over >r [ single-combination ] \ GENERIC: r>
    define-generic define-method ;

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
    [ swap word-name , "-" , , ] make-string create-in ;

: writer-word ( class name -- word )
    [ swap "set-" , word-name , "-" , , ] make-string create-in ;

: simple-slot ( class name -- [ reader writer ] )
    [ reader-word ] 2keep writer-word 2list ;

: simple-slot-spec ( class slots -- spec )
    [ simple-slot ] map-with ;

: set-delegate-prop ( base class slots -- )
    #! This sets the delegate-slot property of the class for
    #! the benefit of tuples. Built-in types do not have
    #! delegate slots.
    swap >r [ "delegate" = dup [ >r 1 + r> ] unless ] some? [
        r> swap
        2dup "delegate-slot" set-word-prop
        "delegate" [ "generic" ] search define-reader
    ] [
        r> 2drop
    ] ifte ;

: simple-slots ( base class slots -- )
    #! Takes a list of slot names, and for each slot name
    #! defines a pair of words <class>-<slot> and 
    #! set-<class>-<slot>. Slot numbering is consecutive and
    #! begins at base.
    >r tuck r>
    3dup set-delegate-prop
    simple-slot-spec [ length [ + ] project-with ] keep zip
    define-slots ;
