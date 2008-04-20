! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg.ebnf peg.expr math.parser sequences arrays ;
IN: lisp

EBNF: lisp-expr
digit      = [0-9]                     => [[ digit> ]]
integer    = (digit)+                  => [[ 10 digits>integer ]]
float      = (digit)+ "." (digit)*     => [[ 3 head 3append string>number ]]
number     = integer
             | float
identifier = [a-zA-Z] ([a-zA-Z0-9])*
atom       = number
             | identifier          
list       = "(" (atom|list)* ")"      =>  [[ second 1array ]]
;EBNF