! (c)Joe Groff bsd license
USING: accessors arrays kernel prettyprint.backend
prettyprint.custom prettyprint.sections sequences struct-arrays ;
IN: struct-arrays.prettyprint

M: struct-array pprint-delims
    drop \ struct-array{ \ } ;

M: struct-array >pprint-sequence
    [ >array ] [ class>> ] bi prefix ;

: pprint-struct-array-pointer ( struct-array -- )
    \ struct-array@ 
    [ [ class>> pprint-word ] [ underlying>> pprint* ] [ length>> pprint* ] tri ]
    pprint-prefix ;

M: struct-array pprint*
    [ pprint-object ]
    [ pprint-struct-array-pointer ] pprint-c-object ;

