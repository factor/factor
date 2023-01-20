! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math parser prettyprint.custom
sequences trees.avl ;
IN: multisets

TUPLE: multiset size avl hash ;

: <multiset> ( -- multiset )
    multiset new
        0 >>size
        <avl> >>avl
        H{ } clone >>hash ; inline

: multiset-emplace ( obj multiset -- )
    [ dup 1 + ] change-size
    [ avl>> set-at ]
    [ hash>> swapd push-at ] 3bi ; inline

: multiset-erase ( obj multiset -- )
    [
        hash>> delete-at* drop
    ] [
        nip
        [ avl>> '[ _ delete-at ] each ]
        [ [ length ] dip [ swap - ] change-size drop ] 2bi
    ] 2bi ;

: multiset-clear ( multiset -- )
    [ hash>> clear-assoc ]
    [ avl>> f >>root 0 >>count drop ]
    [ 0 >>size drop ] tri ;

: multiset-empty? ( multiset -- ? ) avl>> assoc-size 0 eq? ; inline

: multiset-in? ( multiset obj -- ? ) swap hash>> key? ; inline

: multiset-count ( multiset obj -- n )
    swap hash>> at* [ length ] [ drop 0 ] if ; inline

: multiset-members ( multiset -- seq )
    avl>> >alist values ; inline

: multiset-each ( multiset quot -- )
    [ multiset-members ] dip each ; inline

: >multiset ( seq -- multiset )
    <multiset>
    [ '[ _ multiset-emplace ] each ] keep ;

SYNTAX: multiset{
    \ } [ >multiset ] parse-literal ;

M: multiset pprint-delims drop \ multiset{ \ } ;

M: multiset >pprint-sequence avl>> >alist values ;

M: multiset pprint-narrow? drop t ;

M: multiset pprint* pprint-object ;
