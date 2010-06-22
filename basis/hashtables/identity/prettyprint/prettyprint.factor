! (c)2010 Joe Groff bsd license
USING: assocs continuations hashtables.identity kernel
namespaces prettyprint.backend prettyprint.config
prettyprint.custom ;
IN: hashtables.identity.prettyprint

M: identity-hashtable >pprint-sequence >alist ;
M: identity-hashtable pprint-delims drop \ IH{ \ } ;

M: identity-hashtable pprint*
    nesting-limit inc
    [ pprint-object ] [ nesting-limit dec ] [ ] cleanup ;
