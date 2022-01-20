USING: bit-vectors kernel prettyprint.custom ;
IN: bit-vectors.prettyprint

M: bit-vector >pprint-sequence ;
M: bit-vector pprint-delims drop \ ?V{ \ } ;
M: bit-vector pprint* pprint-object ;

