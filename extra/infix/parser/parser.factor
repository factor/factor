! Copyright (C) 2009 Philipp Brüschweiler
! See http://factorcode.org/license.txt for BSD license.
USING: infix.ast infix.tokenizer kernel math peg.ebnf sequences
strings vectors ;
IN: infix.parser

EBNF: parse-infix
Number      = . ?[ ast-number? ]?
Identifier  = . ?[ string? ]?
Array       = Identifier:i "[" Sum:s "]" => [[ i s ast-array boa ]]
Function    = Identifier:i "(" FunArgs?:a ")" => [[ i a [ V{ } ] unless* ast-function boa ]]

FunArgs     =   FunArgs:a "," Sum:s => [[ s a push a ]]
              | Sum:s => [[ s 1vector ]]

Terminal    =   ("-"|"+"):op Terminal:term => [[ term op "-" = [ ast-negation boa ] when ]]
              | "(" Sum:s ")" => [[ s ]]
              | Number | Array | Function
              | Identifier => [[ ast-local boa ]]

Product     =   Product:p ("*"|"/"|"%"):op Terminal:term  => [[ p term op ast-op boa ]]
              | Terminal

Sum         =   Sum:s ("+"|"-"):op Product:p  => [[ s p op ast-op boa ]]
              | Product

End         = !(.)
Expression  = Sum End
;EBNF

: build-infix-ast ( string -- ast )
    tokenize-infix parse-infix ;
