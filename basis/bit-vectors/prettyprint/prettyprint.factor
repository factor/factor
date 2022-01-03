USING: bit-vectors kernel prettyprint.custom ;

M: bit-vector >pprint-sequence ;
M: bit-vector pprint-delims drop \ ?V{ \ } ;
M: bit-vector pprint* pprint-object ;

