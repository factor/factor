! (c)Joe Groff bsd license
USING: accessors arrays kernel prettyprint.backend
prettyprint.custom sequences struct-arrays ;
IN: struct-arrays.prettyprint

M: struct-array pprint-delims
    drop \ struct-array{ \ } ;

M: struct-array >pprint-sequence
    [ >array ] [ class>> ] bi prefix ;

M: struct-array pprint* pprint-object ;

