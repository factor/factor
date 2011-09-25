! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs continuations hashtables.sequences kernel
namespaces prettyprint.backend prettyprint.config
prettyprint.custom ;

IN: hashtables.identity.prettyprint

M: sequence-hashtable >pprint-sequence >alist ;
M: sequence-hashtable pprint-delims drop \ SH{ \ } ;

M: sequence-hashtable pprint*
    nesting-limit inc
    [ pprint-object ] [ nesting-limit dec ] [ ] cleanup ;

