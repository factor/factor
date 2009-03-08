! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer macros memoize parser sequences vocabs
vocabs.loader words kernel namespaces locals.parser locals.types
locals.errors ;
IN: locals

: :>
    scan locals get [ :>-outside-lambda-error ] unless*
    [ make-local ] bind <def> parsed ; parsing

: [| parse-lambda over push-all ; parsing

: [let parse-let over push-all ; parsing

: [let* parse-let* over push-all ; parsing

: [wlet parse-wlet over push-all ; parsing

: :: (::) define ; parsing

: M:: (M::) define ; parsing

: MACRO:: (::) define-macro ; parsing

: MEMO:: (::) define-memoized ; parsing

USE: syntax

{
    "locals.macros"
    "locals.fry"
} [ require ] each

"prettyprint" vocab [
    "locals.definitions" require
    "locals.prettyprint" require
] when
