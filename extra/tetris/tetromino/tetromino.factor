! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.

USING: colors math namespaces random sequences ;

IN: tetris.tetromino

TUPLE: tetromino states color ;

C: <tetromino> tetromino

SYMBOL: tetrominoes

{
  [
    { {
        { 0 0 } { 1 0 } { 2 0 } { 3 0 }
      }
      { { 0 0 }
        { 0 1 }
        { 0 2 }
        { 0 3 }
      }
    } COLOR: cyan
  ] [
    {
      {         { 1 0 }
        { 0 1 } { 1 1 } { 2 1 }
      } {
        { 0 0 }
        { 0 1 } { 1 1 }
        { 0 2 }
      } {
        { 0 0 } { 1 0 } { 2 0 }
                { 1 1 }
      } {
                { 1 0 }
        { 0 1 } { 1 1 }
                { 1 2 }
      }
    } COLOR: purple
  ] [
    { { { 0 0 } { 1 0 }
        { 0 1 } { 1 1 } }
    } COLOR: yellow
  ] [
    {
      { { 0 0 } { 1 0 } { 2 0 }
        { 0 1 }
      } {
        { 0 0 } { 1 0 }
                { 1 1 }
                { 1 2 }
      } {
                        { 2 0 }
        { 0 1 } { 1 1 } { 2 1 }
      } {
        { 0 0 }
        { 0 1 }
        { 0 2 } { 1 2 }
      }
    } COLOR: orange
  ] [
    {
      { { 0 0 } { 1 0 } { 2 0 }
                        { 2 1 }
      } {
                { 1 0 }
                { 1 1 }
        { 0 2 } { 1 2 }
      } {
        { 0 0 }
        { 0 1 } { 1 1 } { 2 1 }
      } {
        { 0 0 } { 1 0 }
        { 0 1 }
        { 0 2 }
      }
    } COLOR: blue
  ] [
    {
      {          { 1 0 } { 2 0 }
        { 0 1 } { 1 1 }
      } {
        { 0 0 }
        { 0 1 } { 1 1 }
                { 1 2 }
      }
    } COLOR: green
  ] [
    {
      {
        { 0 0 } { 1 0 }
                { 1 1 } { 2 1 }
      } {
                { 1 0 }
        { 0 1 } { 1 1 }
        { 0 2 }
      }
    } COLOR: red
  ]
} [ first2 <tetromino> ] map tetrominoes set-global

: random-tetromino ( -- tetromino )
    tetrominoes get random ;

: blocks-max ( blocks quot -- max )
    map maximum 1 + ; inline

: blocks-width ( blocks -- width )
    [ first ] blocks-max ;

: blocks-height ( blocks -- height )
    [ second ] blocks-max ;
