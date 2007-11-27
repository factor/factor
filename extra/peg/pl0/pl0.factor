! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser sequences peg ;
IN: peg.pl0

#! Grammar for PL/0 based on http://en.wikipedia.org/wiki/PL/0

: 'ident' ( -- parser )
  CHAR: a CHAR: z range 
  CHAR: A CHAR: Z range 2array choice repeat1 
  [ >string ] action ;

: 'number' ( -- parser )
  CHAR: 0 CHAR: 9 range repeat1 [ string>number ] action ;

DEFER: 'factor'

: 'term' ( -- parser )
  'factor' "*" token "/" token 2array choice sp 'factor' sp 2array seq repeat0 2array seq ;

: 'expression' ( -- parser )
  [ "+" token "-" token 2array choice sp optional 'term' sp 2dup 2array seq repeat0 3array seq ] delay ;

: 'factor' ( -- parser )
  'ident' 'number' "(" token hide 'expression' sp ")" token sp hide 3array seq 3array choice ;

: 'condition' ( -- parser )
  "odd" token 'expression' sp 2array seq
  'expression' { "=" "#" "<=" "<" ">=" ">" } [ token ] map choice sp 'expression' sp 3array seq 
  2array choice ;

: 'statement' ( -- parser )
  [
    'ident' ":=" token sp 'expression' sp 3array seq
    "call" token 'ident' sp 2array seq
    "begin" token 'statement' sp ";" token sp 'statement' sp 2array seq repeat0 "end" token sp 4array seq
     "if" token 'condition' sp "then" token sp 'statement' sp 4array seq
     4array choice
     "while" token 'condition' sp "do" token sp 'statement' sp 4array seq
     2array choice optional
  ] delay ;

: 'block' ( -- parser )
 [
  "const" token 'ident' sp "=" token sp 'number' sp 4array seq 
    "," token sp 'ident' sp "=" token sp 'number' sp 4array seq repeat0
  ";" token sp 3array seq optional
  
  "var" token 'ident' sp "," token sp 'ident' sp 2array seq repeat0 
  ";" token sp 4array seq optional

  "procedure" token 'ident' sp ";" token sp 'block' sp 4array seq ";" token sp 2array seq repeat0 'statement' sp 2array seq  

  3array seq
 ] delay ;

: 'program' ( -- parser )
  'block' "." token sp 2array seq ;
