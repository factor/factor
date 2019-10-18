#! A parser for lambda expressions, by Matthew Willis
#! The grammar in BNF is:
#! <expr> ::= <id>
#! <expr> ::= <name>
#! <expr> ::= (<id> . <expr>)
#! <expr> ::= (<expr> <expr>)
#! <line> ::= <expr>
#! <line> ::= <name> : <expr>
USING: lazy-lists parser-combinators strings sequences kernel ;

IN: lambda

LAZY: <letter> 
    #! parses an uppercase or lowercase letter
	[ letter? ] satisfy [ ch>string ] <@ ;

LAZY: <LETTER> 
    #! parses an uppercase or lowercase letter
    [ LETTER? ] satisfy [ ch>string ] <@ ;

LAZY: <number>
    #! parses a number
    [ digit? ] satisfy [ ch>string ] <@ ;

LAZY: <alphanumeric>
    #! parses an alphanumeral
    <letter> <number> <|> ;

LAZY: <ALPHANUMERIC>
    #! parses an alphanumeral
    <LETTER> <number> <|> ;

LAZY: <id>
    #! parses an identifier (string for now)
    #! TODO: do we need to enter it into a symbol table?
    <letter> <alphanumeric> <*> <&:> [ concat <var-node> ] <@ ;

LAZY: <name>
    #! parses a name, which is used in replacement
    <ALPHANUMERIC> <+> [ concat ] <@ ;

DEFER: <expr>
LAZY: <lambda> ( -- parser )
    #! parses (<id>.<expr>), the "lambda" expression
    #! all occurences of <id> are replaced with a pointer to this
    #! lambda expression.
    "(" token <id> sp &> "." token sp <& 
    <expr> sp <&> ")" token sp <&
    [ [ first var-node-name ] keep second <lambda-node> ] <@ ;

LAZY: <apply> ( -- parser )
    #! parses (<expr> <expr>), the function application
    "(" token <expr> sp &> <expr> sp <&> ")" token sp <& 
    [ [ first ] keep second <apply-node> ] <@ ;

LAZY: <alien> ( -- parser )
    #! parses [<FACTOR-WORD>], the alien invocation
    #! an alien factor word must be all capital letters and numerals
    "[" token <name> sp &> "]" token sp <& [ <alien-node> ] <@ ;

LAZY: <expr>
    <id> <lambda> <apply> <|> <|>
    <name> [ <var-node> ] <@ <|> <alien> <|> ;

LAZY: <line>
    ":" token <name> &> <expr> sp <&> f succeed <expr> <&> 
    <|> "." token <name> &> f succeed <&> <|> ;

: lambda-parse
    <line> some parse force ;