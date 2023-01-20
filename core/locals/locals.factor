! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: sequences vocabs vocabs.loader ;
IN: locals

{
    "locals.parser"
    "locals.types"
    "locals.errors"
    "locals.macros"
    "locals.fry"
} [ require ] each

{ "locals" "prettyprint" } "locals.definitions" require-when
{ "locals" "prettyprint" } "locals.prettyprint" require-when
