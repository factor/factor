! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data kernel prettyprint.backend
prettyprint.sections prettyprint.custom
specialized-arrays ;
IN: specialized-arrays.prettyprint

: pprint-direct-array ( direct-array -- )
    \ c-array@ [
        [ underlying-type ] [ underlying>> ] [ length>> ] tri
        [ pprint* ] tri@
    ] pprint-prefix ;

M: specialized-array pprint*
    [ pprint-object ] [ pprint-direct-array ] pprint-c-object ;
