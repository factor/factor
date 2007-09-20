! Copyright (C) 2006, 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces sequences math math.vectors
colors random ;
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
    } cyan
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
    } purple
  ] [
    { { { 0 0 } { 1 0 }
        { 0 1 } { 1 1 } }
    } yellow
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
    } orange
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
    } blue
  ] [
    {
      {          { 1 0 } { 2 0 }
        { 0 1 } { 1 1 }
      } {
        { 0 0 }
        { 0 1 } { 1 1 }
                { 1 2 }
      }
    } green
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
    } red
  ]
} [ call <tetromino> ] map tetrominoes set-global

: random-tetromino ( -- tetromino )
    tetrominoes get random ;

: blocks-max ( blocks quot -- max )
    map [ 1+ ] map supremum ; inline

: blocks-width ( blocks -- width )
    [ first ] blocks-max ;

: blocks-height ( blocks -- height )
    [ second ] blocks-max ;

