USING: accessors assocs classes hashtables kernel linked-assocs
prettyprint.backend prettyprint.custom ;
IN: linked-assocs.prettyprint

PREDICATE: linked-hash < linked-assoc
    [ class-of linked-assoc = ] [ assoc>> hashtable? ] bi and ;

M: linked-hash pprint-delims drop \ LH{ \ } ;

M: linked-hash >pprint-sequence >alist ;

M: linked-hash pprint-narrow? drop t ;

M: linked-hash pprint*
    [ pprint-object ] with-extra-nesting-level ;
