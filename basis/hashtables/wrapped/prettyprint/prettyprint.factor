! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: assocs hashtables.wrapped prettyprint.backend
prettyprint.custom ;

M: wrapped-hashtable >pprint-sequence >alist ;

M: wrapped-hashtable pprint*
    [ pprint-object ] with-extra-nesting-level ;
