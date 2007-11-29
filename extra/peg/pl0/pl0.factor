! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser sequences peg peg.ebnf ;
IN: peg.pl0

#! Grammar for PL/0 based on http://en.wikipedia.org/wiki/PL/0
: ident ( -- parser )
  CHAR: a CHAR: z range 
  CHAR: A CHAR: Z range 2array choice repeat1 
  [ >string ] action ;

: number ( -- parser )
  CHAR: 0 CHAR: 9 range repeat1 [ string>number ] action ;

<EBNF
program = block '.' .
block = [ 'const' ident '=' number { ',' ident '=' number } ';' ]
        [ 'var' ident { ',' ident } ';' ]
        { 'procedure' ident ';' [ block ';' ] } statement .
statement = [ ident ':=' expression | 'call' ident |
              'begin' statement {';' statement } 'end' |
              'if' condition 'then' statement |
              'while' condition 'do' statement ] .
condition = 'odd' expression |
            expression ('=' | '#' | '<=' | '<' | '>=' | '>') expression .
expression = ['+' | '-'] term {('+' | '-') term } .
term = factor {('*' | '/') factor } .
factor = ident | number | '(' expression ')'
EBNF>
