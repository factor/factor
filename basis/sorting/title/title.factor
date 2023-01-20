! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: sorting.functor regexp kernel accessors sequences
unicode ;
IN: sorting.title

<< "title" [
    >lower dup R/ ^(the|a|an|el|la|los|las|il) / first-match
    [ to>> tail-slice ] when*
] define-sorting >>
