! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel assocs sequences
stack-checker.recursive-state ;
IN: stack-checker.values

! Values
: <value> ( -- value ) \ <value> counter ;

SYMBOL: known-values

: init-known-values ( -- )
    H{ } clone known-values set ;

: known ( value -- known ) known-values get at ;

: set-known ( known value -- )
    over [ known-values get set-at ] [ 2drop ] if ;

: make-known ( known -- value )
    <value> [ set-known ] keep ;

: copy-value ( value -- value' )
    known make-known ;

: copy-values ( values -- values' )
    [ copy-value ] map ;

! Literal value
TUPLE: literal < identity-tuple value recursion hashcode ;

M: literal hashcode* nip hashcode>> ;

: <literal> ( obj -- value )
    recursive-state get over hashcode \ literal boa ;

GENERIC: (literal) ( value -- literal )

M: literal (literal) ;

: literal ( value -- literal )
    known (literal) ;

! Result of curry
TUPLE: curried obj quot ;

C: <curried> curried

! Result of compose
TUPLE: composed quot1 quot2 ;

C: <composed> composed
