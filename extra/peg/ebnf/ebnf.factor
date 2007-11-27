! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser sequences namespaces peg ;
IN: peg.ebnf

TUPLE: ebnf-non-terminal symbol ;
TUPLE: ebnf-terminal symbol ;
TUPLE: ebnf-choice options ;

C: <ebnf-non-terminal> ebnf-non-terminal
C: <ebnf-terminal> ebnf-terminal
C: <ebnf-choice> ebnf-choice

GENERIC: ebnf-compile ( ast -- quot )

M: ebnf-terminal ebnf-compile ( ast -- quot )
  [
    ebnf-terminal-symbol , \ token ,
  ] [ ] make ;

M: ebnf-choice ebnf-compile ( ast -- quot )
  [
    [
      ebnf-choice-options [
        ebnf-compile ,
      ] each
    ] { } make ,
    [ call ] , \ map ,
  ] [ ] make ;

DEFER: 'rhs'

: 'non-terminal' ( -- parser )
  CHAR: a CHAR: z range repeat1 [ >string <ebnf-non-terminal> ] action ;

: 'terminal' ( -- parser )
  "\"" token hide [ CHAR: " = not ] satisfy repeat1 "\"" token hide 3array seq [ first >string <ebnf-terminal> ] action ;

: 'element' ( -- parser )
  'non-terminal' 'terminal' 2array choice ;

: 'sequence' ( -- parser )
  'element' sp repeat1 ;
  
: 'choice' ( -- parser )
  'element' sp "|" token sp list-of [ <ebnf-choice> ] action ;

: 'repeat0' ( -- parser )
  "{" token sp hide
  [ 'rhs' sp ] delay
  "}" token sp hide 
  3array seq ;

: 'rhs' ( -- parser )
  'repeat0'
  'choice'
  'sequence'
  'element' 
  4array choice ;
  
: 'rule' ( -- parser )
  'non-terminal' 
  "=" token sp 
  'rhs' 
  3array seq ;
