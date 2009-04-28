! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors definitions generic generic.single kernel
namespaces words math math.order combinators sequences ;
IN: generic.standard

TUPLE: standard-combination < single-combination # ;

: <standard-combination> ( n -- standard-combination )
    dup 0 2 between? [ "Bad dispatch position" throw ] unless
    standard-combination boa ;

PREDICATE: standard-generic < generic
    "combination" word-prop standard-combination? ;

PREDICATE: simple-generic < standard-generic
    "combination" word-prop #>> 0 = ;

CONSTANT: simple-combination T{ standard-combination f 0 }

: define-simple-generic ( word effect -- )
    [ simple-combination ] dip define-generic ;

: (picker) ( n -- quot )
    {
        { 0 [ [ dup ] ] }
        { 1 [ [ over ] ] }
        { 2 [ [ pick ] ] }
    } case ;

M: standard-combination picker
    combination get #>> (picker) ;

M: standard-combination dispatch# #>> ;

M: standard-generic effective-method
    [ datastack ] dip [ "combination" word-prop #>> swap <reversed> nth ] keep
    (effective-method) ;

M: standard-generic definer drop \ GENERIC# f ;

M: simple-generic definer drop \ GENERIC: f ;
