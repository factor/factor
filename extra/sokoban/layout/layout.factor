! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces sequences math math.order
math.vectors colors random ;
IN: sokoban.layout

TUPLE: layout states color ;

C: <layout> layout

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
                                        { 4 0 } { 5 0 } { 6 0 } { 7 0 } { 8 0 }
                                        { 4 1 }                         { 8 1 }
                                        { 4 2 }                         { 8 2 }
                        { 2 3 } { 3 3 } { 4 3 }                         { 8 3 } { 9 3 } { 10 3 }
                        { 2 4 }                                                         { 10 4 }
        { 0 5 } { 1 5 } { 2 5 }         { 4 5 }         { 6 5 } { 7 5 } { 8 5 }         { 10 5 }                                              { 16 5 } { 17 5 } { 18 5 } { 19 5 } { 20 5 } { 21 5 }
        { 0 6 }                         { 4 6 }         { 6 6 } { 7 6 } { 8 6 }         { 10 6 } { 11 6 } { 12 6 } { 13 6 } { 14 6 } { 15 6 } { 16 6 }                                     { 21 6 }
        { 0 7 }                                                                                                                                                                            { 21 7 }
        { 0 8 } { 1 8 } { 2 8 } { 3 8 } { 4 8 }         { 6 8 } { 7 8 } { 8 8 }         { 10 8 }          { 12 8 } { 13 8 } { 14 8 } { 15 8 } { 16 8 }                                     { 21 8 }
                                        { 4 9 }                                         { 10 9 } { 11 9 } { 12 9 }                            { 16 9 } { 17 9 } { 18 9 } { 19 9 } { 20 9 } { 21 9 }
                                        { 4 10 } { 5 10 } { 6 10 } { 7 10 } { 8 10 } { 9 10 } { 10 10 } 

      }
    } COLOR: gray
  ]
  [ ! player position on each level
    {
      {
        { 2 2 }
      }
      {
        { 11 8 }
      }
    } COLOR: green
  ]
  [
    {
      {
        { 1 2 } { 5 3 } { 1 4 } { 4 5 } { 3 6 } { 6 6 } { 4 7 } 
      }
      {
        { 19 6 } { 20 6 }
        { 19 7 } { 20 7 }
        { 19 8 } { 20 8 }
      }
    } COLOR: pink
  ]
} [ first2 <layout> ] map component set-global

SYMBOL: boxes
{
  { ! first box on each level
    {
      { ! level 0
        { 3 2 }
      }

      { ! level 1
        { 5 2 }
      }
    } COLOR: orange
  }

  { ! second box on each level
    {
      { ! level 0
        { 4 3 }
      }

      { ! level 1
        { 7 3 }
      }
    } COLOR: orange
  }

  { ! third box on each level
    {
      { ! level 0
        { 4 4 }
      }
      { ! level 1
        { 5 4 }
      }
    } COLOR: orange
  }

  { ! fourth box on each level
    {
      { ! level 0
        { 4 6 }
      }
      { ! level 1
        { 8 4 }
      }
    } COLOR: orange
  }

  { ! fifth box on each level
    {
      { ! level 0
        { 3 6 }
      }
      { ! level 1
        { 5 7 }
      }
    } COLOR: orange
  }

  { ! sixth box on each level
    {
      { ! level 0
        { 5 6 }
      }
      { ! level 1
        { 2 7 }
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
} [ first2 <layout> ] map boxes set-global


SYMBOL: num-boxes
{
  ! number of boxes -1 of each level
  6
  5
} num-boxes set-global

: get-board ( -- layout )
    component get first ;

: get-player ( -- layout )
    component get second ;

: get-box ( n -- layout )
    boxes get nth ;
    ! TODO add an n argument and get (n + 1)th

: get-goal ( -- layout )
    component get third ;

: get-num-boxes ( n -- m )
    ! outputs how many boxes are on each level, allows for different numbers of boxes per level
    num-boxes get nth ;
