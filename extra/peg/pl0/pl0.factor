! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser sequences
peg peg.ebnf peg.parsers memoize namespaces ;
IN: peg.pl0

#! Grammar for PL/0 based on http://en.wikipedia.org/wiki/PL/0
MEMO: ident ( -- parser )
  [
    CHAR: a CHAR: z range ,
    CHAR: A CHAR: Z range ,
  ] choice* repeat1 [ >string ] action ;

MEMO: number ( -- parser )
  CHAR: 0 CHAR: 9 range repeat1 [ string>number ] action ;

<EBNF
program = block "." 
block = ( "CONST" ident "=" number ( "," ident "=" number )* ";" )?
        ( "VAR" ident ( "," ident )* ";" )?
        ( "PROCEDURE" ident ";" ( block ";" )? )* statement 
statement = ( ident ":=" expression | "CALL" ident |
              "BEGIN" statement (";" statement )* "END" |
              "IF" condition "THEN" statement |
              "WHILE" condition "DO" statement )?
condition = "ODD" expression |
            expression ("=" | "#" | "<=" | "<" | ">=" | ">") expression 
expression = ("+" | "-")? term (("+" | "-") term )* 
term = factor (("*" | "/") factor )* 
factor = ident | number | "(" expression ")"
EBNF>
