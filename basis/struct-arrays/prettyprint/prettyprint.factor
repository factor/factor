! (c)Joe Groff bsd license
USING: accessors arrays kernel prettyprint.backend
prettyprint.custom sequences struct-arrays ;
IN: struct-arrays.prettyprint

M: struct-array pprint-delims
    drop \ struct-array{ \ } ;

M: struct-array >pprint-sequence
    [ >array ] [ class>> ] bi prefix ;

: pprint-struct-array-pointer ( struct-array -- )
    \ struct-array@ pprint-word 
    [ class>> ] [ underlying>> ] [ length>> ] tri [ pprint* ] tri@ ;

M: struct-array pprint*
    [ pprint-object ]
    [ pprint-struct-array-pointer ] pprint-c-object ;

