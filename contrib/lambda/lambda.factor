#! An interpreter for lambda expressions, by Matthew Willis
#! The grammar in BNF is:
#! <expr> ::= <id>
#! <expr> ::= <name>
#! <expr> ::= (<id> . <expr>)
#! <expr> ::= (<expr> <expr>)
#! <line> ::= <expr>
#! <line> ::= <name> : <expr>

REQUIRES: parser-combinators ;
USING: parser-combinators lazy-lists io strings 
hashtables sequences prettyprint namespaces kernel ;

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

TUPLE: lambda-node expr temp-label ;
TUPLE: apply-node func arg ;
TUPLE: variable-node var ;

GENERIC: variable-eq?
M: string variable-eq? ( var string -- bool ) = ;

M: lambda-node variable-eq? ( var lambda-node-pointer -- bool ) eq? ;

GENERIC: substitute
M: lambda-node substitute ( expr var lambda-node -- )
    [ lambda-node-expr substitute ] keep [ set-lambda-node-expr ] keep ;

M: apply-node substitute ( expr var apply-node -- )
    [ [ apply-node-func substitute ] keep set-apply-node-func ] 3keep 
    [ apply-node-arg substitute ] keep [ set-apply-node-arg ] keep ;
    
M: variable-node substitute ( expr var variable-node -- )
    #! ( variable-node == var ) ? expr | variable-node
    #! this could use multiple dispatch!
    [ variable-node-var variable-eq? ] keep swap ( expr variable-node cond )
    [ swap ] unless drop ;  

: beta-reduce ( expr lambda-node -- reduced-expr )
    #! "pass" expr to the lambda-node, returning a reduced expression
    dup lambda-node-expr substitute ;

GENERIC: reduce
#! TODO: eta reduction
M: lambda-node reduce ( lambda-node -- reduced-lambda-node )
    [ [ lambda-node-expr reduce ] keep set-lambda-node-expr ] keep ;

M: apply-node reduce ( apply-node -- reduced-apply-node )
    #! beta-reduction
    [ [ apply-node-func reduce ] keep set-apply-node-func ] keep
    [ [ apply-node-arg reduce  ] keep set-apply-node-arg  ] keep
    [ apply-node-func dup lambda-node? ] keep swap
    [ apply-node-arg swap beta-reduce reduce ] [ nip ] if ;

M: variable-node reduce ( -- ) ;

GENERIC: expr>string
M: lambda-node expr>string ( available-vars lambda-node -- string )
    [ uncons swap ] swap slip [ set-lambda-node-temp-label ] 2keep
    [ swap ] swap slip lambda-node-expr expr>string swap 
    [ "(" , , ". " , , ")" , ] { } make concat ;

M: apply-node expr>string ( available-vars apply-node -- string ) 
    [ apply-node-arg expr>string ] 2keep apply-node-func expr>string
    [ "(" , , " " , , ")" , ] { } make concat ;

M: variable-node expr>string ( available-vars variable-node -- string ) 
    nip variable-node-var dup string? [ lambda-node-temp-label ] unless ;

GENERIC: replace-names
M: lambda-node replace-names ( names-hash l-node -- node )
    [ lambda-node-expr replace-names ] keep [ set-lambda-node-expr ] keep ;

M: apply-node replace-names ( names-hash l-node -- node )
    [
        [ apply-node-func replace-names ] keep set-apply-node-func
    ] 2keep [ apply-node-arg replace-names ] keep [ set-apply-node-arg ] keep ;

M: variable-node replace-names ( names-hash variable-node -- node )
    [ variable-node-var swap hash ] keep over not [ nip ] [ drop ] if ;

C: lambda-node ( var expr implicit-empty-lambda-node -- lambda-node )
    #! store the expr, replacing every occurence of var with
    #! a pointer to this lambda-node
    [ <variable-node> -rot substitute ] keep [ set-lambda-node-expr ] keep ;

: <id>
    #! parses an identifier (string for now)
    #! TODO: do we need to enter it into a symbol table?
    <letter> <alphanumeric> <*> <:&> [ concat <variable-node> ] <@ ;

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

#! every expression has a canonical representation of this form
: bound-variables-list ( -- lazy-list ) 65 lfrom [ ch>string ] lmap ;

: lambda-print ( name expr -- )
    bound-variables-list swap expr>string ":" swap append append print flush ;

: update-names ( names-hash name expr -- names-hash )
    swap rot [ set-hash ] keep ;

#! Interpreter: listen-reduce-print loop
: lint ( names-hash -- new-names-hash ) 
    readln [ "." = ] keep swap [ drop ] [ 
        lambda-parse [ first ] keep second pick swap replace-names reduce
        [ lambda-print ] 2keep update-names lint 
    ] if ;

: lint-boot ( -- initial-names )
    H{ } clone ;