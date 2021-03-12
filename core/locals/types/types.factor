! Copyright (C) 2007, 2010 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel sequences words
quotations ;
IN: locals.types

TUPLE: lambda vars body ;

C: <lambda> lambda

TUPLE: let body ;

C: <let> let

TUPLE: quote local ;

C: <quote> quote

: unquote ( quote -- local ) dup quote? [ local>> ] when ; inline

TUPLE: def local ;

C: <def> def

TUPLE: multi-def locals ;

C: <multi-def> multi-def

PREDICATE: local < word "local?" word-prop ;

: <local> ( name -- word )
    ! Create a local variable identifier
    f <word>
    dup t "local?" set-word-prop ;

M: local literalize ;

PREDICATE: local-reader < word "local-reader?" word-prop ;

: <local-reader> ( name -- word )
    f <word>
    dup t "local-reader?" set-word-prop ;

M: local-reader literalize ;

PREDICATE: local-writer < word "local-writer?" word-prop ;

: <local-writer> ( reader -- word )
    dup name>> "!" append f <word> {
        [ nip t "local-writer?" set-word-prop ]
        [ swap "local-reader" set-word-prop ]
        [ "local-writer" set-word-prop ]
        [ nip ]
    } 2cleave ;

UNION: lexical local local-reader local-writer ;
UNION: special lexical quote def ;
