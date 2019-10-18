! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays definitions errors assocs help kernel
sequences words namespaces quotations ;

TUPLE: method loc def ;

M: f method-def ;
M: f method-loc ;
M: quotation method-def ;
M: quotation method-loc drop f ;

: method ( class generic -- method/f )
    "methods" word-prop at ;

PREDICATE: pair method-spec
    first2 dup generic? [ method >boolean ] [ 2drop f ] if ;

: order ( generic -- seq )
    "methods" word-prop keys sort-classes ;

: methods ( generic -- assoc )
    dup "methods" word-prop swap order [
        dup rot at method-def 2array
    ] map-with ;

TUPLE: check-method class generic ;

: check-method ( class generic -- class generic )
    dup generic? [ <check-method> throw ] unless
    over class? [ <check-method> throw ] unless ;

: with-methods ( word quot -- )
    swap [ "methods" word-prop swap call ] keep ?make-generic ;
    inline

: define-method ( method class generic -- )
    >r bootstrap-word r> check-method
    [ set-at ] with-methods ;

! Definition protocol
M: method-spec where
    dup first2 method method-loc [ ] [ second where ] ?if ;

M: method-spec forget
    first2 [ delete-at ] with-methods ;

M: method-spec definer drop \ M: \ ; ;

M: method-spec definition first2 method method-def ;

: implementors ( class -- seq )
    all-words
    [ generic? ] subset
    [ "methods" word-prop key? ] subset-with ;

: forget-methods ( class -- )
    dup implementors [ 2array forget ] each-with ;

: forget-predicate ( class -- )
    "predicate" word-prop [ forget ] each ;

: forget-class ( class -- )
    dup forget-methods
    dup forget-predicate
    dup uncache-class
    forget-word ;

M: class forget forget-class ;
