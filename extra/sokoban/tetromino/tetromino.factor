! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces sequences math math.order
math.vectors colors colors.constants random ;
IN: sokoban.tetromino

TUPLE: tetromino states color ;

C: <tetromino> tetromino

SYMBOL: component

{
  [ ! walls on each level
    {
      {
                        { 2 0 } { 3 0 } { 4 0 } { 5 0 } { 6 0 }
        { 0 1 } { 1 1 } { 2 1 }                         { 6 1 }
        { 0 2 }                                         { 6 2 }
        { 0 3 } { 1 3 } { 2 3 }                         { 6 3 }
        { 0 4 }         { 2 4 } { 3 4 }                 { 6 4 }
        { 0 5 }         { 2 5 }                         { 6 5 } { 7 5 }
        { 0 6 }                                                 { 7 6 }
        { 0 7 }                                                 { 7 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 } { 5 8 } { 6 8 } { 7 8 }
      }
      { ! new level (access it by rotating the level piece)
        { 0 0 } { 1 0 } { 2 0 } { 3 0 } { 4 0 } { 5 0 } { 6 0 } { 7 0 } { 8 0 }
        { 0 1 } { 1 1 } { 2 1 }                         { 6 1 } { 7 1 } { 8 1 }
        { 0 2 }                                         { 6 2 } { 7 2 }
        { 0 3 } { 1 3 } { 2 3 }                         { 6 3 } { 7 3 }
        { 0 4 }         { 2 4 } { 3 4 }                 { 6 4 } { 7 4 }
        { 0 5 }         { 2 5 }                         { 6 5 } { 7 5 }
        { 0 6 }                                                 { 7 6 }
        { 0 7 }                                                 { 7 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 } { 5 8 } { 6 8 } { 7 8 }
        { 1 9 }
      }
    } COLOR: gray
  ]
  [ ! player position on each level
    {
      {
        { 2 2 }
      }
      {
        { 1 2 }
      }
    } COLOR: green
  ]
  [ ! goals on each level (doesn't work yet)
    {
      {
        { 1 2 } { 5 3 } { 1 4 } { 4 5 } { 3 6 } { 6 6 } { 4 7 } 
      }
      {
        { 4 4 } { 6 4 }
      }
    } COLOR: pink
  ]
} [ first2 <tetromino> ] map component set-global

SYMBOL: boxes
{
  { ! first box on each level
    {
      { ! level 0
        { 3 2 }
      }

      { ! level 1
        { 4 3 }
      }
    } COLOR: orange
  }

  { ! second box on each level
    {
      { ! level 0
        { 4 3 }
      }

      { ! level 1
        { 4 5 }
      }
    } COLOR: orange
  }

  { ! third box on each level
    {
      { ! level 0
        { 4 4 }
      }
    } COLOR: orange
  }

  { ! fourth box on each level
    {
      { ! level 0
        { 4 6 }
      }
    } COLOR: orange
  }

  { ! fifth box on each level
    {
      { ! level 0
        { 3 6 }
      }
    } COLOR: orange
  }

  { ! sixth box on each level
    {
      { ! level 0
        { 5 6 }
      }
    } COLOR: orange
  }

    { ! seventh box on each level
    {
      { ! level 0
        { 1 6 }
      }
    } COLOR: orange
  }

  ! etc
} [ first2 <tetromino> ] map boxes set-global


SYMBOL: num-boxes
{
  ! number of boxes -1 of each level
  6
  1
} num-boxes set-global

: get-board ( -- tetromino )
    component get first ;

: get-player ( -- tetromino )
    component get second ;

: get-box ( n -- tetromino )
    boxes get nth ;
    ! TODO add an n argument and get (n + 1)th

: get-goal ( -- tetromino )
    component get third ;

: get-num-boxes ( n -- m )
    ! outputs how many boxes are on each level, allows for different numbers of boxes per level
    num-boxes get nth ;

: blocks-max ( blocks quot -- max )
    map supremum 1 + ; inline

: blocks-width ( blocks -- width )
    [ first ] blocks-max ;

: blocks-height ( blocks -- height )
    [ second ] blocks-max ;
