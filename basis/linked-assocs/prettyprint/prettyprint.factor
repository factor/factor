USING: accessors assocs hashtables kernel linked-assocs
prettyprint.backend prettyprint.custom ;
IN: linked-assocs.prettyprint

PREDICATE: linked-hash < linked-assoc assoc>> hashtable? ;

M: linked-hash pprint-delims drop \ LH{ \ } ;

M: linked-hash >pprint-sequence >alist ;

M: linked-hash pprint-narrow? drop t ;

M: linked-hash pprint*
    [ pprint-object ] with-extra-nesting-level ;
