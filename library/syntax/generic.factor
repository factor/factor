! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

! Bootstrapping trick; see doc/bootstrap.txt.
IN: !syntax
USING: syntax generic kernel lists namespaces parser words ;

: GENERIC:
    #! GENERIC: bar creates a generic word bar. Add methods to
    #! the generic word using M:.
    [ single-combination ]
    \ GENERIC: CREATE define-generic ; parsing

: 2GENERIC:
    #! 2GENERIC: bar creates a generic word bar. Add methods to
    #! the generic word using M:. 2GENERIC words dispatch on
    #! arithmetic types and should not be used for non-numerical
    #! types.
    [ arithmetic-combination ]
    \ 2GENERIC: CREATE define-generic ; parsing

: BUILTIN:
    #! Syntax: BUILTIN: <class> <type#> <slots> ;
    CREATE scan-word [ builtin-class ] [ ] ; parsing

: COMPLEMENT: ( -- class predicate definition )
    #! Followed by a class name, then a complemented class.
    CREATE
    dup intern-symbol
    dup predicate-word
    [ dupd unit "predicate" set-word-property ] keep
    scan-word define-complement ; parsing

: UNION: ( -- class predicate definition )
    #! Followed by a class name, then a list of union members.
    CREATE
    dup intern-symbol
    dup predicate-word
    [ dupd unit "predicate" set-word-property ] keep
    [ define-union ] [ ] ; parsing

: PREDICATE: ( -- class predicate definition )
    #! Followed by a superclass name, then a class name.
    scan-word
    CREATE dup intern-symbol
    dup rot "superclass" set-word-property
    dup predicate-word
    [ dupd unit "predicate" set-word-property ] keep
    [ define-predicate ] [ ] ; parsing

: TUPLE:
    #! Followed by a tuple name, then slot names, then ;
    scan
    string-mode on
    [ string-mode off define-tuple ]
    f ; parsing

: M: ( -- class generic [ ] )
    #! M: foo bar begins a definition of the bar generic word
    #! specialized to the foo type.
    scan-word scan-word [ define-method ] [ ] ; parsing

: C:
    #! Followed by a tuple name, then constructor code, then ;
    #! Constructor code executes with the empty tuple on the
    #! stack.
    scan-word [ define-constructor ] f ; parsing
