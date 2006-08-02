! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: words hashtables sequences arrays errors kernel ;

PREDICATE: array method-spec
    dup length 2 = [
        first2 generic? >r class? r> and
    ] [
        drop f
    ] if ;

TUPLE: method def loc ;

M: f method-def ;
M: f method-loc ;
M: quotation method-def ;
M: quotation method-loc drop f ;

: method ( class generic -- quot )
    "methods" word-prop hash method-def ;

: methods ( generic -- alist )
    "methods" word-prop hash>alist
    [ [ first ] 2apply class-compare ] sort
    [ first2 method-def 2array ] map ;

: order ( generic -- list )
    "methods" word-prop hash-keys [ class-compare ] sort ;

TUPLE: check-method class generic ;

: check-method ( class generic -- class generic )
    dup generic? [ <check-method> throw ] unless
    over class? [ <check-method> throw ] unless ;

: with-methods ( word quot -- | quot: methods -- )
    swap [ "methods" word-prop swap call ] keep ?make-generic ;
    inline

: define-method ( method class generic -- )
    >r bootstrap-word r> check-method
    [ set-hash ] with-methods ;

: forget-method ( class generic -- )
    [ remove-hash ] with-methods ;

: implementors ( class -- list )
    [ "methods" word-prop ?hash* nip ] word-subset-with ;
