! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types arrays assocs classes
classes.algebra classes.algebra.private classes.maybe
classes.tuple combinators.short-circuit fry generic kernel math
namespaces sequences sets words ;

FROM: classes.tuple.private => tuple-layout ;
IN: stack-checker.dependencies

SYMBOL: dependencies

SYMBOLS: +effect+ +conditional+ +definition+ ;

: index>= ( obj1 obj2 seq -- ? )
    [ index ] curry bi@ >= ;

: dependency>= ( how1 how2 -- ? )
    { +effect+ +conditional+ +definition+ } index>= ;

: strongest-dependency ( how1 how2 -- how )
    [ +effect+ or ] bi@ [ dependency>= ] most ;

: depends-on ( word how -- )
    over primitive? [ 2drop ] [
        dependencies get [
            swap '[ _ strongest-dependency ] change-at
        ] [ 2drop ] if*
    ] if ;

GENERIC: add-depends-on-class ( classoid -- )

M: class add-depends-on-class
    +conditional+ depends-on ;

M: maybe add-depends-on-class
    class>> add-depends-on-class ;

M: anonymous-union add-depends-on-class
    members>> [ add-depends-on-class ] each ;

M: anonymous-intersection add-depends-on-class
    participants>> [ add-depends-on-class ] each ;

M: anonymous-complement add-depends-on-class
    class>> add-depends-on-class ;

GENERIC: add-depends-on-c-type ( c-type -- )

M: void add-depends-on-c-type drop ;

M: c-type-word add-depends-on-c-type +definition+ depends-on ;

M: array add-depends-on-c-type
    [ word? ] filter [ +definition+ depends-on ] each ;

M: pointer add-depends-on-c-type
    to>> add-depends-on-c-type ;

SYMBOL: generic-dependencies

: ?class-or ( class class/f -- class' )
    [ class-or ] when* ;

: add-depends-on-generic ( class generic -- )
    generic-dependencies get
    [ [ ?class-or ] change-at ] [ 2drop ] if* ;

SYMBOL: conditional-dependencies

GENERIC: satisfied? ( dependency -- ? )

: add-conditional-dependency ( ... class -- )
    boa conditional-dependencies get
    [ adjoin ] [ drop ] if* ; inline

TUPLE: depends-on-class-predicate class1 class2 result ;

: add-depends-on-class-predicate ( class1 class2 result -- )
    depends-on-class-predicate add-conditional-dependency ;

M: depends-on-class-predicate satisfied?
    {
        [ class1>> classoid? ]
        [ class2>> classoid? ]
        [ [ [ class1>> ] [ class2>> ] bi evaluate-class-predicate ] [ result>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-instance-predicate object class result ;

: add-depends-on-instance-predicate ( object class result -- )
    depends-on-instance-predicate add-conditional-dependency ;

M: depends-on-instance-predicate satisfied?
    {
        [ class>> classoid? ]
        [ [ [ object>> ] [ class>> ] bi instance? ] [ result>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-next-method class generic next-method ;

: add-depends-on-next-method ( class generic next-method -- )
    over +conditional+ depends-on
    depends-on-next-method add-conditional-dependency ;

M: depends-on-next-method satisfied?
    {
        [ class>> classoid? ]
        [ [ [ class>> ] [ generic>> ] bi next-method ] [ next-method>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-method class generic method ;

: add-depends-on-method ( class generic method -- )
    over +conditional+ depends-on
    depends-on-method add-conditional-dependency ;

M: depends-on-method satisfied?
    {
        [ class>> classoid? ]
        [ [ [ class>> ] [ generic>> ] bi method-for-class ] [ method>> ] bi eq? ]
    } 1&& ;

TUPLE: depends-on-tuple-layout class layout ;

: add-depends-on-tuple-layout ( class layout -- )
    [ drop +conditional+ depends-on ]
    [ depends-on-tuple-layout add-conditional-dependency ] 2bi ;

M: depends-on-tuple-layout satisfied?
    [ class>> tuple-layout ] [ layout>> ] bi eq? ;

TUPLE: depends-on-struct-slots class slots ;

: add-depends-on-struct-slots ( class slots -- )
    [ drop +conditional+ depends-on ]
    [ depends-on-struct-slots add-conditional-dependency ] 2bi ;

SLOT: fields

M: depends-on-struct-slots satisfied?
    [ class>> "c-type" word-prop fields>> ] [ slots>> ] bi eq? ;

TUPLE: depends-on-flushable word ;

: add-depends-on-flushable ( word -- )
    [ +conditional+ depends-on ]
    [ depends-on-flushable add-conditional-dependency ] bi ;

M: depends-on-flushable satisfied?
    word>> flushable? ;

TUPLE: depends-on-final class ;

: add-depends-on-final ( word -- )
    [ +conditional+ depends-on ]
    [ depends-on-final add-conditional-dependency ] bi ;

M: depends-on-final satisfied?
    class>> { [ class? ] [ final-class? ] } 1&& ;

: without-dependencies ( quot -- )
    [
        dependencies off
        generic-dependencies off
        conditional-dependencies off
        call
    ] with-scope ; inline
