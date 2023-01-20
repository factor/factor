! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: models.arrow models.product stack-checker accessors fry
generalizations sequences.generalizations combinators.smart
macros kernel ;
IN: models.arrow.smart

MACRO: <smart-arrow> ( quot -- quot' )
    [ inputs dup ] keep
    '[ _ narray <product> [ _ firstn @ ] <arrow> ] ;

MACRO: <?smart-arrow> ( quot -- quot' )
    [ inputs dup ] keep
    '[ _ narray <product> [ _ firstn @ ] <?arrow> ] ;
