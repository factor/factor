! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel strings math sequences lists.lazy words
math.parser promises parser-combinators unicode ;
IN: parser-combinators.simple

: digit-parser ( -- parser )
  [ digit? ] satisfy [ digit> ] <@ ;

: integer-parser ( -- parser )
  [ digit? ] satisfy <*> [ string>number ] <@ ;

: string-parser ( -- parser )
  [ char: \" = ] satisfy
  [ char: \" = not ] satisfy <*> &>
  [ char: \" = ] satisfy <& [ >string ] <@  ;

: bold-parser ( -- parser )
  "*" token
  [ char: * = not  ] satisfy <*> [ >string ] <@ &>
  "*" token <& ;

: italic-parser ( -- parser )
  "_" token
  [ char: _ = not ] satisfy <*> [ >string ] <@ &>
  "_" token <& ;

: comma-list ( element -- parser )
  "," token list-of ;
