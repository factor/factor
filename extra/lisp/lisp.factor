! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg.ebnf peg.expr math.parser sequences arrays strings combinators.lib
namespaces combinators math ;
IN: lisp

TUPLE: lisp-symbol name ;

C: <symbol> lisp-symbol

EBNF: lisp-expr
_          = (" " | "\t" | "\n")*
LPAREN     = "("
RPAREN     = ")"
digit      = [0-9]
integer    = (digit)+                   => [[ string>number ]]
float      = (digit)+ "." (digit)*      => [[ first3 >string [ >string ] 2 ndip 3append string>number ]]
number     = float
             | integer
identifier = [a-zA-Z] ([^(){} ])*       => [[ [ 1 head ] [ second ] bi append >string <symbol> ]]
atom       = number
             | identifier
list-item  = _ (atom|list) _            => [[ second ]]
list       = LPAREN (list-item)* RPAREN => [[ second ]]
;EBNF
  
DEFER: convert-form

: convert-body ( lisp-form -- quot )
  [ convert-form ] map [ ] [ compose ] reduce ; inline
  
: convert-if ( lisp-form -- quot )
  1 tail [ convert-form ] map reverse first3  [ % , , \ if , ] [ ] make ;
  
: convert-general-form ( lisp-form -- quot )  
  unclip swap convert-body [ % , ] [ ] make ;

: convert-list-form ( lisp-form -- quot )  
dup first
  { { [ dup "if" <symbol> equal? ] [ convert-if ] }
   [ drop convert-general-form ]
  } cond ;
  
: convert-form ( lisp-form -- quot )
  { { [ dup [ sequence? ] [ number? not ] bi and ] [ convert-list-form ] }
   [ [ , ] [ ] make ]
  } cond ;