! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel namespaces quotations
sequences stack-checker.errors stack-checker.recursive-state ;
IN: stack-checker.values

: <value> ( -- value ) \ <value> counter ;

SYMBOL: known-values

: known ( value -- known )
    known-values get at ;

: set-known ( known value -- )
    '[ _ known-values get set-at ] when* ;

: make-known ( known -- value )
    <value> [ set-known ] keep ;

: copy-value ( value -- value' )
    known make-known ;

: copy-values ( values -- values' )
    [ copy-value ] map ;

GENERIC: (literal-value?) ( value -- ? )

: literal-value? ( value -- ? )
    known (literal-value?) ;

GENERIC: (input-value?) ( value -- ? )

: input-value? ( value -- ? )
    known (input-value?) ;

GENERIC: (literal) ( known -- literal )

TUPLE: literal-tuple < identity-tuple value recursion ;

: literal ( value -- literal ) known (literal) ;

M: literal-tuple hashcode* nip value>> identity-hashcode ;

: <literal> ( obj -- value )
    recursive-state get literal-tuple boa ;

M: literal-tuple (input-value?) drop f ;

M: literal-tuple (literal-value?) drop t ;

M: literal-tuple (literal) ;

: curried/composed-literal ( input1 input2 quot -- literal )
    [ [ literal ] bi@ ] dip
    [ [ [ value>> ] bi@ ] dip call ] [ drop nip recursion>> ] 3bi
    literal-tuple boa ; inline

TUPLE: curried-effect obj quot ;

C: <curried-effect> curried-effect

: >curried-effect< ( curried-effect -- obj quot )
    [ obj>> ] [ quot>> ] bi ; inline

M: curried-effect (input-value?)
    >curried-effect< [ input-value? ] either? ;

M: curried-effect (literal-value?)
    >curried-effect< [ literal-value? ] both? ;

M: curried-effect (literal)
    >curried-effect< [ curry ] curried/composed-literal ;

TUPLE: composed-effect quot1 quot2 ;

C: <composed-effect> composed-effect

: >composed-effect< ( composed-effect -- quot1 quot2 )
    [ quot1>> ] [ quot2>> ] bi ; inline

M: composed-effect (input-value?)
    >composed-effect< [ input-value? ] either? ;

M: composed-effect (literal-value?)
    >composed-effect< [ literal-value? ] both? ;

M: composed-effect (literal)
    >composed-effect< [ compose ] curried/composed-literal ;

SINGLETON: input-parameter

SYMBOL: current-word

M: input-parameter (input-value?) drop t ;

M: input-parameter (literal-value?) drop f ;

M: input-parameter (literal) current-word get unknown-macro-input ;

! Argument corresponding to polymorphic declared input of inline combinator

TUPLE: declared-effect known word effect variables branches actual ;

C: (declared-effect) declared-effect

: <declared-effect> ( known word effect variables branches -- declared-effect )
    f (declared-effect) ; inline

M: declared-effect (input-value?) known>> (input-value?) ;

M: declared-effect (literal-value?) known>> (literal-value?) ;

M: declared-effect (literal) known>> (literal) ;

! Computed values
M: f (input-value?) drop f ;

M: f (literal-value?) drop f ;

M: f (literal) current-word get bad-macro-input ;

GENERIC: known>callable ( known -- quot )

: ?@ ( x -- y )
    dup callable? [ drop \ _ ] unless ;

M: object known>callable drop \ _ ;

M: literal-tuple known>callable value>> ;

M: composed-effect known>callable
    >composed-effect< [ known known>callable ?@ ] bi@ append ;

M: curried-effect known>callable
    >curried-effect< [ known known>callable ] bi@ swap prefix ;

M: declared-effect known>callable
    known>> known>callable ;
