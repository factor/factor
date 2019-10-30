! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math.order regexp sequences
sorting.functor unicode ;
IN: sorting.title

SORTING: title "[
    >lower dup re[[^(the|a|an|el|la|los|las|il) ]] first-match
    [ to>> tail-slice ] when*
]"
