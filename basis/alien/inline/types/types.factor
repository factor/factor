! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs combinators.short-circuit
continuations effects fry kernel math memoize sequences
splitting ;
IN: alien.inline.types

: cify-type ( str -- str' )
    { { CHAR: - CHAR: space } } substitute ;

: factorize-type ( str -- str' )
    cify-type
    "const " ?head drop
    "unsigned " ?head [ "u" prepend ] when
    "long " ?head [ "long" prepend ] when
    " const" ?tail drop ;

: const-pointer? ( str -- ? )
    cify-type { [ " const" tail? ] [ "&" tail? ] } 1|| ;

: pointer-to-const? ( str -- ? )
    cify-type "const " head? ;

MEMO: resolved-primitives ( -- seq )
    primitive-types [ resolve-typedef ] map ;

: primitive-type? ( type -- ? )
    [
        factorize-type resolve-typedef [ resolved-primitives ] dip
        '[ _ = ] any?
    ] [ 2drop f ] recover ;

: pointer? ( type -- ? )
    [ "*" tail? ] [ "&" tail? ] bi or ;

: type-sans-pointer ( type -- type' )
    [ '[ _ = ] "*&" swap any? ] trim-tail ;

: pointer-to-primitive? ( type -- ? )
    { [ pointer? ] [ type-sans-pointer primitive-type? ] } 1&& ;

: types-effect>params-return ( types effect -- params return )
    [ in>> zip ]
    [ nip out>> dup length 0 > [ first ] [ drop "void" ] if ]
    2bi ;

: annotate-effect ( types effect -- types effect' )
    [ in>> ] [ out>> ] bi [
        zip
        [ over pointer-to-primitive? [ ">" prepend ] when ]
        assoc-map unzip
    ] dip <effect> ;
