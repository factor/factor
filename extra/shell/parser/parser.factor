
USING: kernel arrays strings sequences sequences.deep accessors peg peg.ebnf
       newfx ;

IN: shell.parser

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: basic-expr         command  stdin stdout background ;
TUPLE: pipeline-expr      commands stdin stdout background ;
TUPLE: single-quoted-expr expr ;
TUPLE: double-quoted-expr expr ;
TUPLE: back-quoted-expr   expr ;
TUPLE: glob-expr          expr ;
TUPLE: variable-expr      expr ;
TUPLE: factor-expr        expr ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ast>basic-expr ( ast -- obj ) first4 basic-expr boa ;

: ast>pipeline-expr ( ast -- obj )
  pipeline-expr new
    over [ 1st ] [ 4th [ 1st ] map ] [ 5th ] tri suffix prefix-on >>commands
    over 2nd >>stdin
    over 6th   >>stdout
    swap 7th   >>background ;

: ast>single-quoted-expr ( ast -- obj )
  2nd >string single-quoted-expr boa ;

: ast>double-quoted-expr ( ast -- obj )
  2nd >string double-quoted-expr boa ;

: ast>back-quoted-expr ( ast -- obj )
  2nd >string back-quoted-expr boa ;

: ast>glob-expr ( ast -- obj ) flatten concat glob-expr boa ;

: ast>variable-expr ( ast -- obj ) 2nd variable-expr boa ;

: ast>factor-expr ( ast -- obj ) 2nd >string factor-expr boa ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EBNF: expr

space = " "

tab   = "\t"

white = (space | tab)

_ = (white)* => [[ drop ignore ]]

sq = "'"
dq = '"'
bq = "`"

single-quoted = sq (!(sq) .)* sq => [[ ast>single-quoted-expr ]]
double-quoted = dq (!(dq) .)* dq => [[ ast>double-quoted-expr ]]
back-quoted   = bq (!(bq) .)* bq => [[ ast>back-quoted-expr   ]]

factor = "$(" (!(")") .)* ")" => [[ ast>factor-expr ]]

variable = "$" other => [[ ast>variable-expr ]]

glob-char = ("*" | "?")

non-glob-char = !(glob-char | white) .

glob-beginning-string = (non-glob-char)* => [[ >string ]]

glob-rest-string = (non-glob-char)+ => [[ >string ]]

glob = glob-beginning-string glob-char (glob-rest-string | glob-char)* => [[ ast>glob-expr ]]

other = (!(white | "&" | ">" | ">>" | "<" | "|") .)+ => [[ >string ]]

element = (single-quoted | double-quoted | back-quoted | factor | variable | glob | other)

command = (element _)+

to-file = ">"  _ other => [[ second ]]
in-file = "<"  _ other => [[ second ]]
ap-file = ">>" _ other => [[ second ]]

basic = _ command _ (in-file)? _ (to-file | ap-file)? _ ("&")? => [[ ast>basic-expr ]]

pipeline = _ command _ (in-file)? _ "|" _ (command _ "|" _)* command _ (to-file | ap-file)? _ ("&")? => [[ ast>pipeline-expr ]]

submission = (pipeline | basic)

;EBNF