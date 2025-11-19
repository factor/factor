USING: kernel linked-sets prettyprint.custom sets ;
IN: linked-sets.prettyprint

M: linked-set pprint-delims drop \ LS{ \ } ;

M: linked-set >pprint-sequence members ;

M: linked-set pprint-narrow? drop t ;

M: linked-set pprint* pprint-object ;
