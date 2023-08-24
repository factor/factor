USING: assocs kernel prettyprint.custom vlists ;

M: vlist pprint-delims drop \ VL{ \ } ;
M: vlist >pprint-sequence ;
M: vlist pprint* pprint-object ;

M: valist pprint-delims drop \ VA{ \ } ;
M: valist >pprint-sequence >alist ;
M: valist pprint* pprint-object ;
