! Copyright (C) 2010 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators hashtables kernel literals math math.functions
math.vectors memoize path-finding sequences sorting splitting strings tools.test ;
IN: path-finding.tests

! Use a 10x9 maze (see below) to try to go from s to e, f or g.
! X means that a position is unreachable.
! The costs model is:
!   - going up costs 5 points
!   - going down costs 1 point
!   - going left or right costs 2 points

<<

TUPLE: maze < astar ;

: reachable? ( pos -- ? )
    first2 [ 2 * 5 + ] [ 2 + ] bi* $[
"    0 1 2 3 4 5 6 7 8 9

  0  X X X X X X X X X X
  1  X s           f X X
  2  X X X X   X X X X X
  3  X X X X   X X X X X
  4  X X X X   X       X
  5  X X       X   X   X
  6  X X X X   X   X e X
  7  X g   X           X
  8  X X X X X X X X X X"
        split-lines ] nth nth CHAR: X = not ;

M: maze neighbors
    drop
    first2
    { [ 1 + 2array ] [ 1 - 2array ] [ [ 1 + ] dip 2array ] [ [ 1 - ] dip 2array ] } 2cleave
    4array
    [ reachable? ] filter ;

M: maze heuristic
    drop v- [ abs ] [ + ] map-reduce ;

M: maze cost
    drop 2dup [ first ] same? [ [ second ] bi@ > 1 5 ? ] [ 2drop 2 ] if ;

: test1 ( to -- path considered )
    { 1 1 } swap maze new [ find-path ] [ considered ] bi ;
>>

! Existing path from s to f
{
    {
        { 1 1 }
        { 2 1 }
        { 3 1 }
        { 4 1 }
        { 4 2 }
        { 4 3 }
        { 4 4 }
        { 4 5 }
        { 4 6 }
        { 4 7 }
        { 5 7 }
        { 6 7 }
        { 7 7 }
        { 8 7 }
        { 8 6 }
    }
} [
    { 8 6 } test1 drop
] unit-test

! Check that only the right positions have been considered in the s to f path
{ 7 } [ { 7 1 } test1 nip length ] unit-test

! Non-existing path from s to g -- all positions must have been considered
{ f 26 } [ { 1 7 } test1 length ] unit-test

! Look for a path between A and C. The best path is A --> D --> C. C will be placed
! in the open set early because B will be examined first. This checks that the evaluation
! of C is correctly replaced in the open set.
!
! We use no heuristic here and always return 0.
!
!       (5)
!     B ---> C <--------
!                        \ (2)
!     ^      ^            |
!     |      |            |
! (1) |      | (2)        |
!     |      |            |
!
!     A ---> D ---------> E ---> F
!       (2)       (1)       (1)

<<

! In this version, we will use the quotations-aware version through <astar>.

MEMO: routes ( -- hash ) $[ { "ABD" "BC" "C" "DCE" "ECF" } [ unclip swap 2array ] map >hashtable ] ;

: n ( pos -- neighbors )
    routes at ;

: c ( from to -- cost )
    "" 2sequence H{ { "AB" 1 } { "AD" 2 } { "BC" 5 } { "DC" 2 } { "DE" 1 } { "EC" 2 } { "EF" 1 } } at ;

: test2 ( fromto -- path considered )
    first2 [ n ] [ c ] [ 2drop 0 ] <astar> [ find-path ] [ considered sort >string ] bi ;
>>

! Check path from A to C -- all nodes but F must have been examined
{ "ADC" "ABCDE" } [ "AC" test2 [ >string ] dip ] unit-test

! No path from D to B -- all nodes reachable from D must have been examined
{ f "CDEF" } [ "DB" test2 ] unit-test

! Find a path using BFS. There are no path from F to A, and the path from D to
! C does not include any other node.

{ f } [ "FA" first2 routes <bfs> find-path ] unit-test
{ "DC" } [ "DC" first2 routes <bfs> find-path >string ] unit-test

<<

! Build the costs as expected by the dijkstra word.

MEMO: costs ( -- costs )
    routes keys [ dup dup n [ dup [ c ] dip swap 2array ] with { } map-as >hashtable 2array ] map >hashtable ;

: test3 ( fromto -- path considered )
    first2 costs <dijkstra> [ find-path ] [ considered sort >string ] bi ;

>>

! Check path from A to C -- all nodes but F must have been examined
{ "ADC" "ABCDE" } [ "AC" test3 [ >string ] dip ] unit-test

! No path from D to B -- all nodes reachable from D must have been examined
{ f "CDEF" } [ "DB" test3 ] unit-test

{ { 1 3 } } [
    1 3 H{
        { 1 H{ { 2 0 } { 3 0 } } }
        { 2 H{ { 3 0 } { 1 0 } { 4 0 } } }
        { 3 H{ { 4 0 } } }
        { 4 H{ } }
    } <dijkstra> find-path
] unit-test
