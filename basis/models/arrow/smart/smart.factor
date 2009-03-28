! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: models.arrow models.product stack-checker accessors fry
generalizations macros kernel ;
IN: models.arrow.smart

MACRO: <smart-arrow> ( quot -- quot' )
    [ infer in>> dup ] keep
    '[ _ narray <product> [ _ firstn @ ] <arrow> ] ;