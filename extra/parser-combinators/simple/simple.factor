! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel strings math sequences lazy-lists words
math.parser promises ;
IN: parser-combinators 

LAZY: 'any-char' ( -- parser )
  [ drop t ] satisfy ;

: 'digit' ( -- parser )
  [ digit? ] satisfy [ digit> ] <@ ;

: 'integer' ( -- parser )
  'digit' <!+> [ 0 [ swap 10 * + ] reduce ] <@ ;

: 'string' ( -- parser )
  [ CHAR: " = ] satisfy 
  [ CHAR: " = not ] satisfy <*> &>
  [ CHAR: " = ] satisfy <& [ >string ] <@  ;
  
: 'bold' ( -- parser )
  "*" token 
  [ CHAR: * = not  ] satisfy <*> [ >string ] <@ &> 
  "*" token <& ;

: 'italic' ( -- parser )
  "_" token 
  [ CHAR: _ = not ] satisfy <*> [ >string ] <@ &> 
  "_" token <& ;

: comma-list ( element -- parser )
  "," token list-of ;