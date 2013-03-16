! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs accessors classes classes.algebra fry
generic kernel math namespaces sequences words sets
combinators.short-circuit classes.tuple alien.c-types ;
FROM: classes.tuple.private => tuple-layout ;
FROM: assocs => change-at ;
FROM: namespaces => set ;
IN: stack-checker.dependencies

! Words that the current quotation depends on
SYMBOL: dependencies

SYMBOLS: effect-dependency conditional-dependency definition-dependency ;

: index>= ( obj1 obj2 seq -- ? )
    [ index ] curry bi@ >= ;

: dependency>= ( how1 how2 -- ? )
    { effect-dependency conditional-dependency definition-dependency }
    index>= ;

: strongest-dependency ( how1 how2 -- how )
    [ effect-dependency or ] bi@ [ dependency>= ] most ;

: depends-on ( word how -- )
    over primitive? [ 2drop ] [
        dependencies get dup [
            swap '[ _ strongest-dependency ] change-at
        ] [ 3drop ] if
    ] if ;

: add-depends-on-effect ( word -- )
    effect-dependency depends-on ;

: add-depends-on-conditionally ( word -- )
    conditional-dependency depends-on ;

: add-depends-on-definition ( word -- )
    definition-dependency depends-on ;

GENERIC: add-depends-on-c-type ( c-type -- )

M: void add-depends-on-c-type drop ;

M: c-type-word add-depends-on-c-type add-depends-on-definition ;

M: array add-depends-on-c-type
    [ word? ] filter [ add-depends-on-definition ] each ;

M: pointer add-depends-on-c-type
    to>> add-depends-on-c-type ;

! Generic words that the current quotation depends on
SYMBOL: generic-dependencies

: ?class-or ( class class/f -- class' )
    [ class-or ] when* ;

: add-depends-on-generic ( class generic -- )
    generic-dependencies get dup
    [ [ ?class-or ] change-at ] [ 3drop ] if ;

! Conditional dependencies are re-evaluated when classes change;
! if any fail, the word is recompiled
SYMBOL: conditional-dependencies

GENERIC: satisfied? ( dependency -- ? )

: add-conditional-dependency ( ... class -- )
    boa conditional-dependencies get
    dup [ adjoin ] [ 2drop ] if ; inline

TUPLE: depends-on-class-predicate class1 class2 result ;

: add-depends-on-class-predicate ( class1 class2 result -- )
    \ depends-on-class-predicate add-conditional-dependency ;

M: depends-on-class-predicate satisfied?
    {
        [ [ class1>> valid-classoid? ] [ class2>> valid-classoid? ] bi and ]
        [ [ [ class1>> ] [ class2>> ] bi evaluate-class-predicate ] [ result>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-instance-predicate object class result ;

: add-depends-on-instance-predicate ( object class result -- )
    \ depends-on-instance-predicate add-conditional-dependency ;

M: depends-on-instance-predicate satisfied?
    {
        [ class>> valid-classoid? ]
        [ [ [ object>> ] [ class>> ] bi instance? ] [ result>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-next-method class generic next-method ;

: add-depends-on-next-method ( class generic next-method -- )
    over add-depends-on-conditionally
    \ depends-on-next-method add-conditional-dependency ;

M: depends-on-next-method satisfied?
    {
        [ class>> valid-classoid? ]
        [ [ [ class>> ] [ generic>> ] bi next-method ] [ next-method>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-method class generic method ;

: add-depends-on-method ( class generic method -- )
    over add-depends-on-conditionally
    \ depends-on-method add-conditional-dependency ;

M: depends-on-method satisfied?
    {
        [ class>> classoid? ]
        [ [ [ class>> ] [ generic>> ] bi method-for-class ] [ method>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-tuple-layout class layout ;

: add-depends-on-tuple-layout ( class layout -- )
    [ drop add-depends-on-conditionally ]
    [ \ depends-on-tuple-layout add-conditional-dependency ] 2bi ;

M: depends-on-tuple-layout satisfied?
    [ class>> tuple-layout ] [ layout>> ] bi eq? ;

TUPLE: depends-on-flushable word ;

: add-depends-on-flushable ( word -- )
    [ add-depends-on-conditionally ]
    [ \ depends-on-flushable add-conditional-dependency ] bi ;

M: depends-on-flushable satisfied?
    word>> flushable? ;

TUPLE: depends-on-final class ;

: add-depends-on-final ( word -- )
    [ add-depends-on-conditionally ]
    [ \ depends-on-final add-conditional-dependency ] bi ;

M: depends-on-final satisfied?
    class>> { [ class? ] [ final-class? ] } 1&& ;

: init-dependencies ( -- )
    H{ } clone dependencies set
    H{ } clone generic-dependencies set
    HS{ } clone conditional-dependencies set ;

: without-dependencies ( quot -- )
    [
        dependencies off
        generic-dependencies off
        conditional-dependencies off
        call
    ] with-scope ; inline
