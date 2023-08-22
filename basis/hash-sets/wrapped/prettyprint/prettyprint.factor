! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: continuations hash-sets.wrapped namespaces
prettyprint.config prettyprint.custom sets ;

M: wrapped-hash-set >pprint-sequence members ;

M: wrapped-hash-set pprint*
    nesting-limit inc
    [ pprint-object ] [ nesting-limit dec ] finally ;
