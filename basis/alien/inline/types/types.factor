! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types assocs combinators.short-circuit
continuations fry kernel memoize sequences splitting ;
IN: alien.inline.types

: factorize-type ( str -- str' )
    "const-" ?head drop
    "unsigned-" ?head [ "u" prepend ] when
    "long-" ?head [ "long" prepend ] when ;

: cify-type ( str -- str' )
    { { CHAR: - CHAR: space } } substitute ;

: const-type? ( str -- ? )
    "const-" head? ;

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
