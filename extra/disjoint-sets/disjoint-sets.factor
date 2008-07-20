! Copyright (C) 2008 Eric Mertens.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hints kernel locals math hashtables
assocs ;

IN: disjoint-sets

TUPLE: disjoint-set
{ parents hashtable read-only }
{ ranks hashtable read-only }
{ counts hashtable read-only } ;

<PRIVATE

: count ( a disjoint-set -- n )
    counts>> at ; inline

: add-count ( p a disjoint-set -- )
    [ count [ + ] curry ] keep counts>> swap change-at ; inline

: parent ( a disjoint-set -- p )
    parents>> at ; inline

: set-parent ( p a disjoint-set -- )
    parents>> set-at ; inline

: link-sets ( p a disjoint-set -- )
    [ set-parent ] [ add-count ] 3bi ; inline

: rank ( a disjoint-set -- r )
    ranks>> at ; inline

: inc-rank ( a disjoint-set -- )
    ranks>> [ 1+ ] change-at ; inline

: representative? ( a disjoint-set -- ? )
    dupd parent = ; inline

PRIVATE>

: representative ( a disjoint-set -- p )
    2dup representative? [ drop ] [
        [ [ parent ] keep representative dup ] 2keep set-parent
    ] if ;

<PRIVATE

: representatives ( a b disjoint-set -- r r )
    [ representative ] curry bi@ ; inline

: ranks ( a b disjoint-set -- r r )
    [ rank ] curry bi@ ; inline

:: branch ( a b neg zero pos -- )
    a b = zero [ a b < neg pos if ] if ; inline

PRIVATE>

: <disjoint-set> ( -- disjoint-set )
    H{ } clone H{ } clone H{ } clone disjoint-set boa ;

: add-atom ( a disjoint-set -- )
    [ dupd parents>> set-at ]
    [ 0 -rot ranks>> set-at ]
    [ 1 -rot counts>> set-at ]
    2tri ;

: equiv-set-size ( a disjoint-set -- n )
    [ representative ] keep count ;

: equiv? ( a b disjoint-set -- ? )
    representatives = ; inline

:: equate ( a b disjoint-set -- )
    a b disjoint-set representatives
    2dup = [ 2drop ] [
        2dup disjoint-set ranks
        [ swap ] [ over disjoint-set inc-rank ] [ ] branch
        disjoint-set link-sets
    ] if ;

HINTS: equate disjoint-set ;
HINTS: representative disjoint-set ;
HINTS: equiv-set-size disjoint-set ;
