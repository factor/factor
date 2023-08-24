! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: math.parser multiline peg.ebnf strings ;
IN: peg.pl0

! Grammar for PL/0 based on https://en.wikipedia.org/wiki/PL/0

EBNF: pl0 [=[

block       =  { "CONST" ident "=" number { "," ident "=" number }* ";" }?
               { "VAR" ident { "," ident }* ";" }?
               { "PROCEDURE" ident ";" { block ";" }? }* statement
statement   =  {  ident ":=" expression
                | "CALL" ident
                | "BEGIN" statement { ";" statement }* "END"
                | "IF" condition "THEN" statement
                | "WHILE" condition "DO" statement }?
condition   =  { "ODD" expression }
             | { expression ("=" | "#" | "<=" | "<" | ">=" | ">") expression }
expression  = {"+" | "-"}? term { {"+" | "-"} term }*
term        = factor { {"*" | "/"} factor }*
factor      = ident | number | "(" expression ")"
ident       = (([a-zA-Z])+)   => [[ >string ]]
number      = ([0-9])+        => [[ string>number ]]
program     = { block "." }
]=]
