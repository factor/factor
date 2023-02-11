! Copyright (C) 2009 Philipp Brüschweiler
! See https://factorcode.org/license.txt for BSD license.
USING: infix.ast infix.tokenizer kernel multiline peg.ebnf
sequences strings vectors ;
IN: infix.parser

EBNF: parse-infix [=[
Number      = . ?[ ast-value? ]?
Identifier  = . ?[ string? ]?
Array       = Identifier:i "[" Sum:s "]" => [[ i s ast-array boa ]]
Slice1      = Identifier:i "[" Sum?:from ":" Sum?:to "]" => [[ i from to f ast-slice boa ]]
Slice2      = Identifier:i "[" Sum?:from ":" Sum?:to ":" Sum?:step "]" => [[ i from to step ast-slice boa ]]
Slice       = Slice1 | Slice2
Function    = Identifier:i "(" FunArgs?:a ")" => [[ i a [ V{ } ] unless* ast-function boa ]]

FunArgs     =   FunArgs:a "," Sum:s => [[ s a push a ]]
              | Sum:s => [[ s 1vector ]]

Terminal    =   ("-"|"+"):op Terminal:term => [[ term op "-" = [ ast-negation boa ] when ]]
              | "(" Sum:s ")" => [[ s ]]
              | Number | Array | Slice | Function
              | Identifier => [[ ast-local boa ]]

Product     =   Product:p ("**"|"*"|"/"|"%"):op Terminal:term  => [[ p term op ast-op boa ]]
              | Terminal

Sum         =   Sum:s ("+"|"-"):op Product:p  => [[ s p op ast-op boa ]]
              | Product

End         = !(.)
Expression  = Sum End
]=]

: build-infix-ast ( string -- ast )
    tokenize-infix parse-infix ;
