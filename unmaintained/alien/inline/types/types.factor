! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs combinators.short-circuit
continuations effects fry kernel math memoize sequences
splitting strings peg.ebnf make words ;
IN: alien.inline.types

: cify-type ( str -- str' )
    dup word? [ name>> ] when
    H{ { CHAR: - CHAR: space } } substitute ;

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

: template-class? ( str -- ? )
    [ CHAR: < = ] any? ;

MEMO: resolved-primitives ( -- seq )
    primitive-types [ resolve-typedef ] map ;

: primitive-type? ( type -- ? )
    [
        factorize-type resolve-typedef [ resolved-primitives ] dip
        '[ _ = ] any?
    ] [ 2drop f ] recover ;

: pointer? ( type -- ? )
    factorize-type [ "*" tail? ] [ "&" tail? ] bi or ;

: type-sans-pointer ( type -- type' )
    factorize-type [ '[ _ = ] "*&" swap any? ] trim-tail ;

: pointer-to-primitive? ( type -- ? )
    factorize-type
    { [ pointer? ] [ type-sans-pointer primitive-type? ] } 1&& ;

: pointer-to-non-const-primitive? ( str -- ? )
    {
        [ pointer-to-const? not ]
        [ factorize-type pointer-to-primitive? ]
    } 1&& ;

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

TUPLE: c++-type name params ptr ;
C: <c++-type> c++-type

EBNF: (parse-c++-type)
dig  = [0-9]
alpha = [a-zA-Z]
alphanum = [1-9a-zA-Z]
name = [_a-zA-Z] [_a-zA-Z1-9:]* => [[ first2 swap prefix >string ]]
ptr = [*&] => [[ empty? not ]]

param = "," " "* type " "* => [[ third ]]

params = "<" " "* type " "* param* ">" => [[ [ 4 swap nth ] [ third ] bi prefix ]]

type = name " "* params? " "* ptr? => [[ { 0 2 4 } [ swap nth ] with map first3 <c++-type> ]]
;EBNF

: parse-c++-type ( str -- c++-type )
    factorize-type (parse-c++-type) ;

DEFER: c++-type>string

: params>string ( params -- str )
    [ "<" % [ c++-type>string ] map "," join % ">" % ] "" make ;

: c++-type>string ( c++-type -- str )
    [
        [ name>> % ]
        [ params>> [ params>string % ] when* ]
        [ ptr>> [ "*" % ] when ]
        tri
    ] "" make ;

GENERIC: c++-type ( obj -- c++-type/f )

M: object c++-type drop f ;

M: c++-type c-type ;
