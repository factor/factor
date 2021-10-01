! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces sequences math math.order
math.vectors colors colors.constants random ;
IN: sokoban.tetromino

TUPLE: tetromino states colour ;

C: <tetromino> tetromino

SYMBOL: players

{
  [
    { 
      {
        { -2 2 }
      }
    } COLOR: green
  ]
} [ first2 <tetromino> ] map players set-global

SYMBOL: boards

{
  [
    { 
      {
        { 0 0 } { 1 0 } { 2 0 } { 3 0 } { 4 0 } { 5 0 } { 6 0 } { 7 0 } { 8 0 }
        { 0 1 } { 1 1 } { 2 1 }                         { 6 1 }         { 8 1 }
        { 0 2 }                                         { 6 2 }         { 8 2 }
        { 0 3 } { 1 3 } { 2 3 }                         { 6 3 }         { 8 3 }
        { 0 4 }         { 2 4 } { 3 4 }                 { 6 4 }         { 8 4 }
        { 0 5 }         { 2 5 }                         { 6 5 } { 7 5 } { 8 5 }
        { 0 6 }                                                 { 7 6 } { 8 6 }
        { 0 7 }                                                 { 7 7 } { 8 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 } { 5 8 } { 6 8 } { 7 8 } { 8 8 }
      }
    } COLOR: gray
  ]
} [ first2 <tetromino> ] map boards set-global

: random-tetromino ( -- tetromino )
    boards get random ;

: get-board ( -- tetromino )
    boards get first ;

: get-player ( -- tetromino )
    players get first ;

: blocks-max ( blocks quot -- max )
    map supremum 1 + ; inline

: blocks-width ( blocks -- width )
    [ first ] blocks-max ;

: blocks-height ( blocks -- height )
    [ second ] blocks-max ;
