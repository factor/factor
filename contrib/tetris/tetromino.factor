! Copyright (C) 2006 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays namespaces sequences math tetris-colours ;
IN: tetromino

TUPLE: tetromino states colour ;

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
  tetrominoes get dup length random-int swap nth ;

: blocks-max ( blocks quot -- max )
    ! add 1 to each block since they are 0 indexed
    ! [ 1+ ] append map 0 [ max ] reduce ;
    map [ 1+ ] map 0 [ max ] reduce ;

: blocks-width ( blocks -- width )
    [ first ] blocks-max ;

: blocks-height ( blocks -- height )
    [ second ] blocks-max ;

