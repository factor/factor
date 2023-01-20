! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry fry.private generalizations kernel
locals.types sequences ;
IN: locals.fry

! Support for mixing locals with fry

M: let count-inputs body>> count-inputs ;
M: lambda count-inputs body>> count-inputs ;

M: lambda fry
    clone [ [ count-inputs ] [ fry ] bi ] change-body
    [ [ vars>> length ] keep '[ _ _ mnswap _ call ] ]
    [ drop [ncurry] curry [ call ] compose ] 2bi ;

M: let fry
    clone [ fry ] change-body ;

INSTANCE: lambda fried
INSTANCE: let    fried
