! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors definitions effects generic kernel locals
macros memoize prettyprint prettyprint.backend see words ;
IN: locals.definitions

PREDICATE: lambda-word < word "lambda" word-prop >boolean ;

M: lambda-word definer drop \ :: \ ; ;

M: lambda-word definition
    "lambda" word-prop body>> ;

M: lambda-word reset-word
    [ call-next-method ] [ "lambda" remove-word-prop ] bi ;

PREDICATE: lambda-macro < macro lambda-word? ;

M: lambda-macro definer drop \ MACRO:: \ ; ;

M: lambda-macro definition
    "lambda" word-prop body>> ;

M: lambda-macro reset-word
    [ call-next-method ] [ "lambda" remove-word-prop ] bi ;

PREDICATE: lambda-method < method lambda-word? ;

M: lambda-method definer drop \ M:: \ ; ;

M: lambda-method definition
    "lambda" word-prop body>> ;

M: lambda-method reset-word
    [ call-next-method ] [ "lambda" remove-word-prop ] bi ;

PREDICATE: lambda-memoized < memoized lambda-word? ;

M: lambda-memoized definer drop \ MEMO:: \ ; ;

M: lambda-memoized definition
    "lambda" word-prop body>> ;

M: lambda-memoized reset-word
    [ call-next-method ] [ "lambda" remove-word-prop ] bi ;

: method-stack-effect ( method -- effect )
    dup "lambda" word-prop vars>>
    swap "method-generic" word-prop stack-effect
    dup [ out>> ] when
    <effect> ;

M: lambda-method synopsis*
    dup dup dup definer.
    "method-class" word-prop pprint-word
    "method-generic" word-prop pprint-word
    method-stack-effect effect>string comment. ;
