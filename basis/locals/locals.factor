! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer macros memoize parser sequences vocabs
vocabs.loader words kernel namespaces locals.parser locals.types
locals.errors ;
IN: locals

SYNTAX: :>
    in-lambda? get [ :>-outside-lambda-error ] unless
    scan-token parse-def suffix! ;

SYNTAX: [| parse-lambda append! ;

SYNTAX: [let parse-let append! ;

SYNTAX: :: (::) define-declared ;

SYNTAX: M:: (M::) define ;

SYNTAX: MACRO:: (::) define-macro ;

SYNTAX: MEMO:: (::) define-memoized ;

SYNTAX: IDENTITY-MEMO:: (::) define-identity-memoized ;

{
    "locals.macros"
    "locals.fry"
} [ require ] each

{ "locals" "prettyprint" } "locals.definitions" require-when
{ "locals" "prettyprint" } "locals.prettyprint" require-when
