! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel strings math sequences lists.lazy words
math.parser promises parser-combinators unicode.categories ;
IN: parser-combinators.simple

: 'digit' ( -- parser )
  [ digit? ] satisfy [ digit> ] <@ ;

: 'integer' ( -- parser )
  'digit' <!+> [ 10 digits>integer ] <@ ;

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