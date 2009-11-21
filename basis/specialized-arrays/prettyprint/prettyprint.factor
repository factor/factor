! Copyright (C) 2009 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel prettyprint.backend
prettyprint.sections prettyprint.custom
specialized-arrays ;
IN: specialized-arrays.prettyprint

: pprint-direct-array ( direct-array -- )
    dup direct-array-syntax
    [ [ underlying>> ] [ length>> ] bi [ pprint* ] bi@ ] pprint-prefix ;

M: specialized-array pprint*
    [ pprint-object ] [ pprint-direct-array ] pprint-c-object ;

