
USING: kernel arrays strings sequences sequences.deep peg peg.ebnf ;

IN: shell.parser

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: incantation command stdin stdout background ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: single-quoted-expr expr ;
TUPLE: double-quoted-expr expr ;
TUPLE: back-quoted-expr   expr ;
TUPLE: glob-expr          expr ;

TUPLE: variable-expr expr ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <single-quoted-expr> single-quoted-expr boa ;
: <double-quoted-expr> double-quoted-expr boa ;
: <back-quoted-expr>   back-quoted-expr boa ;
: <glob-expr>          glob-expr boa ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EBNF: expr

space = " "

tab   = "\t"

white = (space | tab)

whitespace = (white)* => [[ drop ignore ]]

squote        = "'"

single-quoted = squote (!(squote) .)* squote => [[ second >string <single-quoted-expr> ]]

dquote        = '"'

double-quoted = dquote (!(dquote) .)* dquote => [[ second >string <double-quoted-expr> ]]

bquote = "`"

back-quoted = bquote (!(bquote) .)* bquote => [[ second >string <back-quoted-expr> ]]

variable = "$" other => [[ second variable-expr boa ]]

glob-char = ("*" | "?")

non-glob-char = !(glob-char | white) .

glob-beginning-string = (non-glob-char)* [[ >string ]]

glob-rest-string = (non-glob-char)+ [[ >string ]]

glob = glob-beginning-string glob-char (glob-rest-string | glob-char)* => [[ flatten concat <glob-expr> ]]

other = (!(white | "&" | ">" | ">>" | "<") .)+ => [[ >string ]]

element = (single-quoted | double-quoted | back-quoted | variable | glob | other)

to-file = ">" whitespace other => [[ second ]]

in-file = "<" whitespace other => [[ second ]]

ap-file = ">>" whitespace other  => [[ second ]]

redirection = (in-file)? whitespace (to-file | ap-file)?

line = (element whitespace)+ (in-file)? whitespace (to-file | ap-file)? whitespace ("&")? => [[ first4 incantation boa ]]

;EBNF

