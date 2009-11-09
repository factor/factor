! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel assocs sequences
stack-checker.recursive-state stack-checker.errors ;
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

GENERIC: (literal-value?) ( value -- ? )

: literal-value? ( value -- ? ) known (literal-value?) ;

GENERIC: (input-value?) ( value -- ? )

: input-value? ( value -- ? ) known (input-value?) ;

GENERIC: (literal) ( known -- literal )

! Literal value
TUPLE: literal < identity-tuple value recursion hashcode ;

: literal ( value -- literal ) known (literal) ;

M: literal hashcode* nip hashcode>> ;

: <literal> ( obj -- value )
    recursive-state get over hashcode \ literal boa ;

M: literal (input-value?) drop f ;

M: literal (literal-value?) drop t ;

M: literal (literal) ;

: curried/composed-literal ( input1 input2 quot -- literal )
    [ [ literal ] bi@ ] dip
    [ [ [ value>> ] bi@ ] dip call ] [ drop nip recursion>> ] 3bi
    over hashcode \ literal boa ; inline

! Result of curry
TUPLE: curried obj quot ;

C: <curried> curried

: >curried< ( curried -- obj quot )
    [ obj>> ] [ quot>> ] bi ; inline

M: curried (input-value?) >curried< [ input-value? ] either? ;

M: curried (literal-value?) >curried< [ literal-value? ] both? ;

M: curried (literal) >curried< [ curry ] curried/composed-literal ;

! Result of compose
TUPLE: composed quot1 quot2 ;

C: <composed> composed

: >composed< ( composed -- quot1 quot2 )
    [ quot1>> ] [ quot2>> ] bi ; inline

M: composed (input-value?)
    [ quot1>> input-value? ] [ quot2>> input-value? ] bi or ;

M: composed (literal-value?) >composed< [ literal-value? ] both? ;

M: composed (literal) >composed< [ compose ] curried/composed-literal ;

! Input parameters
SINGLETON: input-parameter

SYMBOL: current-word

M: input-parameter (input-value?) drop t ;

M: input-parameter (literal-value?) drop f ;

M: input-parameter (literal) current-word get unknown-macro-input ;

! Computed values
M: f (input-value?) drop f ;

M: f (literal-value?) drop f ;

M: f (literal) current-word get bad-macro-input ;