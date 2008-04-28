! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg.ebnf peg.expr math.parser sequences arrays strings
combinators.lib ;

IN: lisp.parser

TUPLE: lisp-symbol name ;
C: <lisp-symbol> lisp-symbol

TUPLE: s-exp body ;
C: <s-exp> s-exp

EBNF: lisp-expr
_            = (" " | "\t" | "\n")*
LPAREN       = "("
RPAREN       = ")"
dquote       = '"'
squote       = "'"
digit        = [0-9]
integer      = (digit)+                               => [[ string>number ]]
float        = (digit)+ "." (digit)*                  => [[ first3 >string [ >string ] dipd 3append string>number ]]
number       = float
              | integer
id-specials  = "!" | "$" | "%" | "&" | "*" | "/" | ":" | "<"
              | " =" | ">" | "?" | "^" | "_" | "~" | "+" | "-" | "." | "@"
letters      = [a-zA-Z]                               => [[ 1array >string ]]
initials     = letters | id-specials
numbers      = [0-9]                                  => [[ 1array >string ]]
subsequents  = initials | numbers
identifier   = initials (subsequents)*                => [[ first2 concat append <lisp-symbol> ]]
string       = dquote ("\" . | !(dquote) . )*  dquote => [[ second >string ]]
atom         = number
              | identifier
              | string
list-item    = _ (atom|s-expression) _                        => [[ second ]]
s-expression = LPAREN (list-item)* RPAREN             => [[ second <s-exp> ]]
;EBNF