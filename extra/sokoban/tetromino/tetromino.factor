! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces sequences math math.order
math.vectors colors colors.constants random ;
IN: sokoban.tetromino

TUPLE: tetromino states color ;

C: <tetromino> tetromino

SYMBOL: component

{
  [ ! walls
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
      { ! new level (access it by rotating the level piece)
        { 0 0 } { 1 0 } { 2 0 } { 3 0 } { 4 0 } { 5 0 } { 6 0 } { 7 0 } { 8 0 }
        { 0 1 } { 1 1 } { 2 1 }                         { 6 1 } { 7 1 } { 8 1 }
        { 0 2 }                                         { 6 2 } { 7 2 } { 8 2 }
        { 0 3 } { 1 3 } { 2 3 }                         { 6 3 } { 7 3 } { 8 3 }
        { 0 4 }         { 2 4 } { 3 4 }                 { 6 4 } { 7 4 } { 8 4 } 
        { 0 5 }         { 2 5 }                         { 6 5 } { 7 5 } { 8 5 }
        { 0 6 }                                                 { 7 6 } { 8 6 }
        { 0 7 }                                                 { 7 7 } { 8 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 } { 5 8 } { 6 8 } { 7 8 } { 8 8 }
      }
    } COLOR: gray
  ]
  [ ! player
    {
      {
        { 0 0 }
      }
    } COLOR: green
  ]
  [ ! boxes
    {
      {
        { 0 0 }
      }
    } COLOR: orange
  ]
  [ ! goals
    {
      {
        { 0 0 }
      }
    } COLOR: pink
  ]
} [ first2 <tetromino> ] map component set-global

SYMBOL: boxes
{
  [ ! first box on each level
    {
      { ! level 0
        { 3 2 }
      }

      { ! level 1
        { 4 3 }
      }
    } COLOR: orange
  ]

  [ ! second box on each level
    {
      { ! level 0
        { 4 2 }
      }

      { ! level 1
        { 4 3 }
      }
    } COLOR: orange
  ]

  ! etc
} [ first2 <tetromino> ] map boxes set-global

SYMBOL: startinglocs
{
  { ! player
    { 2 2 }
  }
  { ! box
    { 5 3 }
  }
  { ! goal
    { 5 3 }
  }
} startinglocs set-global

: get-board ( -- tetromino )
    component get first ;

: get-player ( -- tetromino )
    component get second ;

: get-box ( -- tetromino )
    boxes get first ;
    ! TODO add an n argument and get (n + 1)th

: get-goal ( -- tetromino )
    component get fourth ;

: blocks-max ( blocks quot -- max )
    map supremum 1 + ; inline

: blocks-width ( blocks -- width )
    [ first ] blocks-max ;

: blocks-height ( blocks -- height )
    [ second ] blocks-max ;
