! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser sequences
peg peg.ebnf peg.parsers memoize namespaces math ;
IN: peg.pl0

#! Grammar for PL/0 based on http://en.wikipedia.org/wiki/PL/0

EBNF: pl0 
- = (" " | "\t" | "\n")+ => [[ drop ignore ]]
_ = (" " | "\t" | "\n")* => [[ drop ignore ]]
block = ( _ "CONST" - ident _ "=" _ number ( _ "," _ ident _ "=" _ number )* _ ";" )?
        ( _ "VAR" - ident ( _ "," _ ident )* _ ";" )?
        ( _ "PROCEDURE" - ident _ ";" ( _ block _ ";" )? )* _ statement
statement = ( ident _ ":=" _ expression | "CALL" - ident |
              "BEGIN" - statement ( _ ";" _ statement )* _ "END" |
              "IF" - condition _ "THEN" - statement |
              "WHILE" - condition _ "DO" - statement )?
condition = "ODD" - expression |
            expression _ ("=" | "#" | "<=" | "<" | ">=" | ">") _ expression
expression = ("+" | "-")? term ( _ ("+" | "-") _ term )* 
term = factor ( _ ("*" | "/") _ factor )* 
factor = ident | number | "(" _ expression _ ")"
ident = (([a-zA-Z])+) [[ >string ]]
digit = ([0-9]) [[ digit> ]]
number = ((digit)+) [[ unclip [ swap 10 * + ] reduce ]]
program = block "."
;EBNF
