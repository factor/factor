USING: peg.ebnf help.syntax help.markup strings ;
IN: peg-lexer
ABOUT: "peg-lexer"

HELP: ON-BNF:
{ $syntax "ON-BNF: word ... ;ON-BNF" }
{ $description "Creates a parsing word using a parser for lexer control, adding the resulting ast to the stack.  Parser syntax is as in " { $link POSTPONE: EBNF: } } ;

HELP: create-bnf
{ $values { "word" string } { "parser" parser } }
{ $description "Runtime equivalent of ON-BNF- also useful with manually constructed parsers." } ;