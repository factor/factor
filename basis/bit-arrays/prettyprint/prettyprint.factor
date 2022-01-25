USING: bit-arrays kernel prettyprint.custom ;

M: bit-array pprint-delims drop \ ?{ \ } ;
M: bit-array >pprint-sequence ;
M: bit-array pprint* pprint-object ;
