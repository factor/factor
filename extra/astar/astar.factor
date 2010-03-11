! Copyright (C) 2010 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs heaps kernel math sequences sets shuffle ;
IN: astar

! This implements the A* algorithm. See http://en.wikipedia.org/wiki/A*

TUPLE: astar g in-closed-set ;
GENERIC: cost ( from to astar -- n )
GENERIC: heuristic ( from to astar -- n )
GENERIC: neighbours ( node astar -- seq )

<PRIVATE

TUPLE: (astar) astar goal origin in-open-set open-set ;

: (add-to-open-set) ( h node astar -- )
    2dup in-open-set>> at* [ over open-set>> heap-delete ] [ drop ] if
    [ swapd open-set>> heap-push* ] [ in-open-set>> set-at ] 2bi ;

: add-to-open-set ( node astar -- )
    [ astar>> g>> at ] 2keep
    [ [ goal>> ] [ astar>> heuristic ] bi + ] 2keep
    (add-to-open-set) ;

: ?add-to-open-set ( node astar -- )
    2dup astar>> in-closed-set>> key? [ 2drop ] [ add-to-open-set ] if ;

: move-to-closed-set ( node astar -- )
    [ astar>> in-closed-set>> conjoin ] [ in-open-set>> delete-at ] 2bi ;

: get-first ( astar -- node )
    [ open-set>> heap-pop drop dup ] [ move-to-closed-set ] bi ;

: set-g ( origin g node astar -- )
    [ [ origin>> set-at ] [ astar>> g>> set-at ] bi-curry bi-curry bi* ] [ ?add-to-open-set ] 2bi ;

: cost-through ( origin node astar -- cost )
    [ astar>> cost ] [ nip astar>> g>> at ] 3bi + ;

: ?set-g ( origin node astar -- )
    [ cost-through ] 3keep [ swap ] 2dip
    3dup astar>> g>> at [ 1/0. ] unless* > [ 4drop ] [ set-g ] if ;

: build-path ( target astar -- path )
    [ over ] [ over [ [ origin>> at ] keep ] dip ] produce 2nip reverse ;

: handle ( node astar -- )
    dupd [ astar>> neighbours ] keep [ ?set-g ] curry with each ;

: (find-path) ( astar -- path/f )
    dup open-set>> heap-empty? [
        drop f
    ] [
        [ get-first ] keep 2dup goal>> = [ build-path ] [ [ handle ] [ (find-path) ] bi ] if
    ] if ;

: (init) ( from to astar -- )
    swap >>goal
    H{ } clone over astar>> (>>g)
    H{ } clone over astar>> (>>in-closed-set)
    H{ } clone >>origin
    H{ } clone >>in-open-set
    <min-heap> >>open-set
    [ 0 ] 2dip [ (add-to-open-set) ] [ astar>> g>> set-at ] 3bi ;

TUPLE: astar-simple < astar cost heuristic neighbours ;
M: astar-simple cost cost>> call( n1 n2 -- c ) ;
M: astar-simple heuristic heuristic>> call( n1 n2 -- c ) ;
M: astar-simple neighbours neighbours>> call( n -- neighbours ) ;

PRIVATE>

: find-path ( start target astar -- path/f )
    (astar) new [ (>>astar) ] keep [ (init) ] [ (find-path) ] bi ;

: <astar> ( neighbours cost heuristic -- astar )
    astar-simple new swap >>heuristic swap >>cost swap >>neighbours ;

: considered ( astar -- considered )
    in-closed-set>> keys ;
