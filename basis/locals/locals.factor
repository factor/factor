! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer macros memoize parser sequences vocabs
vocabs.loader words kernel namespaces locals.parser locals.types
locals.errors ;
IN: locals

SYNTAX: :>
    scan locals get [ :>-outside-lambda-error ] unless*
    parse-def suffix! ;

SYNTAX: [| parse-lambda append! ;

SYNTAX: [let parse-let append! ;

SYNTAX: :: (::) define-declared ;

SYNTAX: M:: (M::) define ;

SYNTAX: MACRO:: (::) define-macro ;

SYNTAX: MEMO:: (::) define-memoized ;

{
    "locals.macros"
    "locals.fry"
} [ require ] each

"prettyprint" "locals.definitions" require-when
"prettyprint" "locals.prettyprint" require-when
