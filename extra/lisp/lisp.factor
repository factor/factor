! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg.ebnf peg.expr ;
IN: lisp

EBNF: expr
list  = "(" ( atom | list )* ")"   =>  [[ second 1array ]]
;EBNF