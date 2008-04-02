! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser sequences
peg peg.ebnf peg.parsers memoize namespaces math ;
IN: peg.pl0

#! Grammar for PL/0 based on http://en.wikipedia.org/wiki/PL/0

EBNF: pl0 
_ = (" " | "\t" | "\n")* => [[ drop ignore ]]

BEGIN       = "BEGIN" _
CALL        = "CALL" _
CONST       = "CONST" _
DO          = "DO" _
END         = "END" _
IF          = "IF" _
THEN        = "THEN" _
ODD         = "ODD" _
PROCEDURE   = "PROCEDURE" _
VAR         = "VAR" _
WHILE       = "WHILE" _
EQ          = "=" _
LTEQ        = "<=" _
LT          = "<" _
GT          = ">" _
GTEQ        = ">=" _
NEQ         = "#" _
COMMA       = "," _
SEMICOLON   = ";" _
ASSIGN      = ":=" _

ADD         = "+" _
SUBTRACT    = "-" _
MULTIPLY    = "*" _
DIVIDE      = "/" _

LPAREN      = "(" _
RPAREN      = ")" _

block       =  ( CONST ident EQ number ( COMMA ident EQ number )* SEMICOLON )? 
               ( VAR ident ( COMMA ident )* SEMICOLON )? 
               ( PROCEDURE ident SEMICOLON ( block SEMICOLON )? )* statement 
statement   =  (  ident ASSIGN expression 
                | CALL ident 
                | BEGIN statement ( SEMICOLON statement )* END 
                | IF condition THEN statement 
                | WHILE condition DO statement )?  
condition   =  ODD expression 
             | expression (EQ | NEQ | LTEQ | LT | GTEQ | GT) expression
expression  = (ADD | SUBTRACT)? term ( (ADD | SUBTRACT) term )* _
term        = factor ( (MULTIPLY | DIVIDE) factor )* 
factor      = ident | number | LPAREN expression RPAREN
ident       = (([a-zA-Z])+) _ => [[ >string ]]
digit       = ([0-9])         => [[ digit> ]]
number      = ((digit)+) _    => [[ 10 digits>integer ]]
program     = _ block "."
;EBNF
