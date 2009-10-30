! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry fry.private generalizations kernel
locals.types make sequences ;
IN: locals.fry

! Support for mixing locals with fry

M: let count-inputs body>> count-inputs ;

M: lambda count-inputs body>> count-inputs ;

M: lambda deep-fry
    clone [ shallow-fry swap ] change-body
    [ [ vars>> length ] keep '[ _ _ mnswap @ ] , ] [ drop [ncurry] % ] 2bi ;

M: let deep-fry
    clone [ fry '[ @ call ] ] change-body , ;
