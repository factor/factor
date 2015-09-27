! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: continuations hash-sets.wrapped namespaces
prettyprint.config prettyprint.custom sets ;

IN: hash-sets.wrapped.prettyprint

M: wrapped-hash-set >pprint-sequence members ;

M: wrapped-hash-set pprint*
    nesting-limit inc
    [ pprint-object ] [ nesting-limit dec ] [ ] cleanup ;
