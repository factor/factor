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
        { 0 1 }
      }
    } COLOR: green
  ]
} [ first2 <tetromino> ] map players set-global

SYMBOL: boards

{
  [
    { 
      {
        { 0 0 } { 1 0 } { 2 0 } { 3 0 } { 4 0 }
        { 0 1 }                         { 4 1 }
        { 0 2 }                         { 4 2 }
        { 0 3 }                         { 4 3 }
        { 0 4 } { 1 4 } { 2 4 } { 3 4 } { 4 4 }
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
