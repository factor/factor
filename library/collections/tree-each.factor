! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel lists strings sequences-internals ;

G: tree-each* ( obj quot -- | quot: elt -- )
    1 standard-combination ; inline

: tree-each ( obj quot -- | quot: elt -- )
    [ call ] 2keep tree-each* ; inline

: tree-each-with ( obj obj quot -- )
    swap [ with ] tree-each 2drop ; inline

M: object tree-each* 2drop ;

M: sequence tree-each* swap [ swap tree-each ] each-with ;

M: string tree-each* 2drop ;

M: cons tree-each* ( cons quot -- )
    >r uncons r> tuck >r >r tree-each r> r> tree-each ;

M: wrapper tree-each* ( wrapper quot -- )
    >r wrapped r> tree-each ;

: tree-subset ( obj quot -- seq )
    [ tree-each ] select ; inline

: tree-subset-with ( obj seq quot -- seq | quot: obj elt -- ? )
    swap [ with rot ] tree-subset 2nip ; inline
