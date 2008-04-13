USING: accessors arrays hints kernel locals math sequences ;

IN: disjoint-set

<PRIVATE

TUPLE: disjoint-set parents ranks counts ;

: count ( a disjoint-set -- n )
    counts>> nth ; inline

: add-count ( p a disjoint-set -- )
    [ count [ + ] curry ] keep counts>> swap change-nth ; inline

: parent ( a disjoint-set -- p )
    parents>> nth ; inline

: set-parent ( p a disjoint-set -- )
    parents>> set-nth ; inline

: link-sets ( p a disjoint-set -- )
    [ set-parent ]
    [ add-count ] 3bi ; inline

: rank ( a disjoint-set -- r )
    ranks>> nth ; inline

: inc-rank ( a disjoint-set -- )
    ranks>> [ 1+ ] change-nth ; inline

: representative? ( a disjoint-set -- ? )
    dupd parent = ; inline

: representative ( a disjoint-set -- p )
    2dup representative? [ drop ] [
        [ [ parent ] keep representative dup ] 2keep set-parent
    ] if ;

: representatives ( a b disjoint-set -- r r )
    [ representative ] curry bi@ ; inline

: ranks ( a b disjoint-set -- r r )
    [ rank ] curry bi@ ; inline

:: branch ( a b neg zero pos -- )
    a b = zero [ a b < neg pos if ] if ; inline

PRIVATE>

: <disjoint-set> ( n -- disjoint-set )
    [ >array ]
    [ 0 <array> ]
    [ 1 <array> ] tri
    disjoint-set construct-boa ;

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
