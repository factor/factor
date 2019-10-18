! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel lists strings ;

G: tree-each ( obj quot -- | quot: elt -- )
    [ over ] standard-combination ; inline

: tree-each-with ( obj vector quot -- )
    swap [ with ] tree-each 2drop ; inline

M: object tree-each call ;

M: sequence tree-each swap [ swap tree-each ] each-with ;

M: string tree-each call ;

M: cons tree-each ( cons quot -- )
    >r uncons r> tuck >r >r tree-each r> r> tree-each ;
