! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors classes.algebra fry generic kernel math
namespaces sequences words sets combinators.short-circuit ;
FROM: classes.tuple.private => tuple-layout ;
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

: depends-on-effect ( word -- )
    effect-dependency depends-on ;

: depends-on-conditionally ( word -- )
    conditional-dependency depends-on ;

: depends-on-definition ( word -- )
    definition-dependency depends-on ;

! Generic words that the current quotation depends on
SYMBOL: generic-dependencies

: ?class-or ( class class/f -- class' )
    [ class-or ] when* ;

: depends-on-generic ( class generic -- )
    generic-dependencies get dup
    [ [ ?class-or ] change-at ] [ 3drop ] if ;

! Conditional dependencies are re-evaluated when classes change;
! if any fail, the word is recompiled
SYMBOL: conditional-dependencies

GENERIC: satisfied? ( dependency -- ? )

: add-conditional-dependency ( ... class -- )
    boa conditional-dependencies get
    dup [ conjoin ] [ 2drop ] if ; inline

TUPLE: depends-on-class<= class1 class2 ;

: depends-on-class<= ( class1 class2 -- )
    \ depends-on-class<= add-conditional-dependency ;

M: depends-on-class<= satisfied?
    {
        [ class1>> classoid? ]
        [ class2>> classoid? ]
        [ [ class1>> ] [ class2>> ] bi class<= ]
    } 1&& ;

TUPLE: depends-on-classes-disjoint class1 class2 ;

: depends-on-classes-disjoint ( class1 class2 -- )
    \ depends-on-classes-disjoint add-conditional-dependency ;

M: depends-on-classes-disjoint satisfied?
    {
        [ class1>> classoid? ]
        [ class2>> classoid? ]
        [ [ class1>> ] [ class2>> ] bi classes-intersect? not ]
    } 1&& ;

TUPLE: depends-on-next-method class generic next-method ;

: depends-on-next-method ( class generic next-method -- )
    over depends-on-conditionally
    \ depends-on-next-method add-conditional-dependency ;

M: depends-on-next-method satisfied?
    {
        [ class>> classoid? ]
        [ [ [ class>> ] [ generic>> ] bi next-method ] [ next-method>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-method class generic method ;

: depends-on-method ( class generic method -- )
    over depends-on-conditionally
    \ depends-on-method add-conditional-dependency ;

M: depends-on-method satisfied?
    {
        [ class>> classoid? ]
        [ [ [ class>> ] [ generic>> ] bi method-for-class ] [ method>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-tuple-layout class layout ;

: depends-on-tuple-layout ( class layout -- )
    [ drop depends-on-conditionally ]
    [ \ depends-on-tuple-layout add-conditional-dependency ] 2bi ;

M: depends-on-tuple-layout satisfied?
    [ class>> tuple-layout ] [ layout>> ] bi eq? ;

TUPLE: depends-on-flushable word ;

: depends-on-flushable ( word -- )
    [ depends-on-conditionally ]
    [ \ depends-on-flushable add-conditional-dependency ] bi ;

M: depends-on-flushable satisfied?
    word>> flushable? ;

: init-dependencies ( -- )
    H{ } clone dependencies set
    H{ } clone generic-dependencies set
    H{ } clone conditional-dependencies set ;

: without-dependencies ( quot -- )
    [
        dependencies off
        generic-dependencies off
        conditional-dependencies off
        call
    ] with-scope ; inline
