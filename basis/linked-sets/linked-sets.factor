! Copyright (C) 2016 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques dlists hashtables kernel parser
sets vocabs.loader ;
IN: linked-sets

TUPLE: linked-set
    { assoc hashtable read-only }
    { dlist dlist read-only } ;

: <linked-set> ( capacity -- linked-set )
    <hashtable> <dlist> linked-set boa ;

M: linked-set in? assoc>> key? ;

M: linked-set clear-set
    [ assoc>> clear-assoc ] [ dlist>> clear-deque ] bi ;

<PRIVATE

: (delete-at) ( key assoc dlist -- )
    '[ at [ _ delete-node ] when* ] [ delete-at ] 2bi ; inline

PRIVATE>

M: linked-set delete
    [ assoc>> ] [ dlist>> ] bi (delete-at) ;

M: linked-set cardinality assoc>> assoc-size ;

M: linked-set adjoin
    [ assoc>> ] [ dlist>> ] bi
    '[ _ 2over key? [ 3dup (delete-at) ] when nip push-back* ]
    [ set-at ] 2bi ;

M: linked-set members
    dlist>> dlist>sequence ;

M: linked-set clone
    [ assoc>> clone ] [ dlist>> clone ] bi linked-set boa ;

M: linked-set equal?
    over linked-set? [ [ dlist>> ] bi@ = ] [ 2drop f ] if ;

: >linked-set ( set -- linked-set )
    [ 0 <linked-set> ] dip union! ;

INSTANCE: linked-set set

M: linked-set set-like
    drop dup linked-set? [ >linked-set ] unless ;

SYNTAX: LS{ \ } [ >linked-set ] parse-literal ;

{ "linked-sets" "prettyprint" } "linked-sets.prettyprint" require-when
