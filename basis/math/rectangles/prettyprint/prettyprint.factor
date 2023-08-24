! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors math.rectangles kernel prettyprint.custom
prettyprint.backend ;

M: rect pprint*
    [
        \ RECT: [
            [ loc>> ] [ dim>> ] bi [ pprint* ] bi@
        ] pprint-prefix
    ] check-recursion ;
