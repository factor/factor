! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Bootstrapping trick; see doc/bootstrap.txt.
IN: !syntax
USING: arrays generic kernel lists namespaces parser sequences
syntax words ;

: GENERIC:
    #! GENERIC: bar == G: bar simple-combination ;
    CREATE dup reset-word define-generic ; parsing

: G:
    #! G: word combination ;
    CREATE dup reset-word [ define-generic* ] [ ] ; parsing

: UNION: ( -- class predicate definition )
    #! Followed by a class name, then a list of union members.
    CREATE
    dup intern-symbol
    dup predicate-word
    [ dupd unit "predicate" set-word-prop ] keep
    [ define-union ] [ ] ; parsing

: PREDICATE: ( -- class predicate definition )
    #! Followed by a superclass name, then a class name.
    scan-word
    CREATE dup intern-symbol
    dup rot "superclass" set-word-prop
    dup predicate-word
    [ define-predicate-class ] [ ] ; parsing

: TUPLE:
    #! Followed by a tuple name, then slot names, then ;
    scan
    string-mode on
    [ string-mode off define-tuple ]
    f ; parsing

: M: ( -- class generic [ ] )
    #! M: foo bar begins a definition of the bar generic word
    #! specialized to the foo type.
    scan-word scan-word [ -rot define-method ] [ ] ; parsing

: C:
    #! Followed by a tuple name, then constructor code, then ;
    #! Constructor code executes with the empty tuple on the
    #! stack.
    scan-word [ tuple-constructor ] keep
    [ define-constructor ] [ ] ; parsing
