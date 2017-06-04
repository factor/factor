! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces sequences math math.order
math.vectors colors colors.constants random ;
IN: tetris.tetromino

TUPLE: tetromino states colour ;

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
    } color: cyan
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
    } color: purple
  ] [
    { { { 0 0 } { 1 0 }
        { 0 1 } { 1 1 } }
    } color: yellow
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
    } color: orange
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
    } color: blue
  ] [
    {
      {          { 1 0 } { 2 0 }
        { 0 1 } { 1 1 }
      } {
        { 0 0 }
        { 0 1 } { 1 1 }
                { 1 2 }
      }
    } color: green
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
    } color: red
  ]
} [ first2 <tetromino> ] map tetrominoes set-global

: random-tetromino ( -- tetromino )
    tetrominoes get random ;

: blocks-max ( blocks quot -- max )
    map supremum 1 + ; inline

: blocks-width ( blocks -- width )
    [ first ] blocks-max ;

: blocks-height ( blocks -- height )
    [ second ] blocks-max ;
