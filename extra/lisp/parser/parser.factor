! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg peg.ebnf peg.expr math.parser sequences arrays strings
combinators.lib math fry accessors lists ;

IN: lisp.parser

TUPLE: lisp-symbol name ;
C: <lisp-symbol> lisp-symbol

EBNF: lisp-expr
_            = (" " | "\t" | "\n")*
LPAREN       = "("
RPAREN       = ")"
dquote       = '"'
squote       = "'"
digit        = [0-9]
integer      = ("-")? (digit)+                           => [[ first2 append string>number ]]
float        = integer "." (digit)*                      => [[ first3 >string [ number>string ] 2dip 3append string>number ]]
rational     = integer "/" (digit)+                      => [[ first3 nip string>number / ]]
number       = float
              | rational
              | integer
id-specials  = "!" | "$" | "%" | "&" | "*" | "/" | ":"
              | "<" | "#" | " =" | ">" | "?" | "^" | "_"
              | "~" | "+" | "-" | "." | "@"
letters      = [a-zA-Z]                                  => [[ 1array >string ]]
initials     = letters | id-specials
numbers      = [0-9]                                     => [[ 1array >string ]]
subsequents  = initials | numbers
identifier   = initials (subsequents)*                   => [[ first2 concat append <lisp-symbol> ]]
escaped      = "\" .                                     => [[ second ]]
string       = dquote ( escaped | !(dquote) . )*  dquote => [[ second >string ]]
atom         = number
              | identifier
              | string
s-expression = LPAREN (list-item)* RPAREN                => [[ second seq>cons ]]
list-item    = _ ( atom | s-expression ) _               => [[ second ]]
;EBNF