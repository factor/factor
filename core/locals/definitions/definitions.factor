! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors definitions effects generic kernel locals.types
macros make memoize quotations sequences words ;
IN: locals.definitions

PREDICATE: lambda-word < word "lambda" word-prop >boolean ;

! Lambdas/locals need to expose their uninterned subwords in order
! to make a boot image.
GENERIC: lambda-subwords ( obj -- )

M: object lambda-subwords drop ;

M: lambda lambda-subwords [ vars>> % ] [ body>> [ lambda-subwords ] each ] bi ;

M: def lambda-subwords local>> , ;

M: callable lambda-subwords [ lambda-subwords ] each ;
M: sequence lambda-subwords [ lambda-subwords ] each ;

M: lambda-word subwords
    [
        "lambda" word-prop
        [ vars>> % ] [ body>> [ lambda-subwords ] each ] bi
    ] { } make ;

M: lambda-word definer drop \ \:: \ \; ;

M: lambda-word definition
    "lambda" word-prop body>> ;

M: lambda-word reset-word
    [ call-next-method ] [ f "lambda" set-word-prop ] bi ;

PREDICATE: lambda-macro < macro lambda-word? ;

M: lambda-macro definer drop \ \MACRO:: \ \; ;

M: lambda-macro definition
    "lambda" word-prop body>> ;

M: lambda-macro reset-word
    [ call-next-method ] [ f "lambda" set-word-prop ] bi ;

PREDICATE: lambda-method < method lambda-word? ;

M: lambda-method definer drop \ \M:: \ \; ;

M: lambda-method definition
    "lambda" word-prop body>> ;

M: lambda-method reset-word
    [ call-next-method ] [ f "lambda" set-word-prop ] bi ;

PREDICATE: lambda-memoized < memoized lambda-word? ;

M: lambda-memoized definer drop \ \MEMO:: \ \; ;

M: lambda-memoized definition
    "lambda" word-prop body>> ;

M: lambda-memoized reset-word
    [ call-next-method ] [ f "lambda" set-word-prop ] bi ;

: method-stack-effect ( method -- effect )
    dup "lambda" word-prop vars>>
    swap "method-generic" word-prop stack-effect
    dup [ out>> ] when
    <effect> ;
