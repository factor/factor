#! A parser for lambda expressions, by Matthew Willis
#! The grammar in BNF is:
#! <expr> ::= <id>
#! <expr> ::= <name>
#! <expr> ::= (<id> . <expr>)
#! <expr> ::= (<expr> <expr>)
#! <line> ::= <expr>
#! <line> ::= <name> : <expr>

REQUIRES: parser-combinators ;
USING: parser-combinators strings sequences kernel ;

IN: lambda

: <letter> 
    #! parses an uppercase or lowercase letter
	[ letter? ] satisfy [ ch>string ] <@ ;

: <LETTER> 
    #! parses an uppercase or lowercase letter
    [ LETTER? ] satisfy [ ch>string ] <@ ;

: <number>
    #! parses a number
    [ digit? ] satisfy [ ch>string ] <@ ;

: <alphanumeric>
    #! parses an alphanumeral
    <letter> <number> <|> ;

: <ALPHANUMERIC>
    #! parses an alphanumeral
    <LETTER> <number> <|> ;

: <id>
    #! parses an identifier (string for now)
    #! TODO: do we need to enter it into a symbol table?
    <letter> <alphanumeric> <*> <&:> [ concat <variable-node> ] <@ ;

: <name>
    #! parses a name, which is used in replacement
    <ALPHANUMERIC> <+> [ concat ] <@ ;

DEFER: <expr>
: <lambda>
    #! parses (<id>.<expr>), the "lambda" expression
    #! all occurences of <id> are replaced with a pointer to this
    #! lambda expression.
    "(" token <id> sp &> "." token sp <& 
    <expr> sp <&> ")" token sp <&
    [ [ first variable-node-var ] keep second <lambda-node> ] <@ ;

: <apply>
    #! parses (<expr> <expr>), the function application
    "(" token <expr> sp &> <expr> sp <&> ")" token sp <& 
    [ [ first ] keep second <apply-node> ] <@ ;

: <expr>
    [ <id> call ] [ <lambda> call ] [ <apply> call ] <|> <|>
    <name> [ <variable-node> ] <@ <|> ;

: <line>
    ":" token <name> &> <expr> sp <&> "OK" succeed <expr> <&> 
    <|> ;

: lambda-parse
    #! debug word to parse this <expr> and print the result
    <line> some call ;