! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors classes.algebra fry generic kernel math
namespaces sequences words ;
FROM: classes.tuple.private => tuple-layout ;
IN: stack-checker.dependencies

! Words that the current quotation depends on
SYMBOL: dependencies

SYMBOLS: inlined-dependency conditional-dependency flushed-dependency called-dependency ;

: index>= ( obj1 obj2 seq -- ? )
    [ index ] curry bi@ >= ;

: dependency>= ( how1 how2 -- ? )
    { called-dependency conditional-dependency flushed-dependency inlined-dependency }
    index>= ;

: strongest-dependency ( how1 how2 -- how )
    [ called-dependency or ] bi@ [ dependency>= ] most ;

: depends-on ( word how -- )
    over primitive? [ 2drop ] [
        dependencies get dup [
            swap '[ _ strongest-dependency ] change-at
        ] [ 3drop ] if
    ] if ;

: depends-on-effect ( word -- )
    called-dependency depends-on ;

: depends-on-definition ( word -- )
    inlined-dependency depends-on ;

: depends-on-conditionally ( word -- )
    conditional-dependency depends-on ;

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
    dup [ push ] [ 2drop ] if ; inline

TUPLE: depends-on-class<= class1 class2 ;

: depends-on-class<= ( class1 class2 -- )
    \ depends-on-class<= add-conditional-dependency ;

M: depends-on-class<= satisfied?
    [ class1>> ] [ class2>> ] bi class<= ;

TUPLE: depends-on-classes-disjoint class1 class2 ;

: depends-on-classes-disjoint ( class1 class2 -- )
    \ depends-on-classes-disjoint add-conditional-dependency ;

M: depends-on-classes-disjoint satisfied?
    [ class1>> ] [ class2>> ] bi classes-intersect? not ;

TUPLE: depends-on-method class generic method ;

: depends-on-method ( class generic method -- )
    \ depends-on-method add-conditional-dependency ;

M: depends-on-method satisfied?
    [ [ class>> ] [ generic>> ] bi method-for-class ] [ method>> ] bi eq? ;

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
    V{ } clone conditional-dependencies set ;

: without-dependencies ( quot -- )
    [
        dependencies off
        generic-dependencies off
        call
    ] with-scope ; inline
