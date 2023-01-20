! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple kernel namespaces words ;
IN: smalltalk.classes

SYMBOL: classes

classes [ H{ } clone ] initialize

: create-class ( class -- class )
    "smalltalk.classes" create-word ;

ERROR: no-class name ;

: lookup-class ( class -- class )
    classes get ?at [ no-class ] unless ;

: define-class ( class superclass ivars -- class-word )
    [ create-class ] [ lookup-class ] [ ] tri*
    [ define-tuple-class ] [ 2drop dup dup name>> classes get set-at ] 3bi ;

: define-foreign ( class name -- )
    classes get set-at ;

tuple "Object" define-foreign
