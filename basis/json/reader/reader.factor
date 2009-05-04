! Copyright (C) 2008 Peter Burns.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg peg.ebnf math.parser math.parser.private strings math
math.functions sequences arrays vectors hashtables assocs
prettyprint json ;
IN: json.reader

<PRIVATE

: grammar-list>vector ( seq -- vec ) first2 values swap prefix ;

! Grammar for JSON from RFC 4627
EBNF: (json>)

ws = (" " | "\r" | "\t" | "\n")*

true = "true" => [[ t ]]
false = "false" => [[ f ]]
null = "null" => [[ json-null ]]

hex = [0-9a-fA-F]
char = '\\"'  [[ CHAR: "  ]]
     | "\\\\" [[ CHAR: \  ]]
     | "\\/"  [[ CHAR: /  ]]
     | "\\b"  [[ 8        ]]
     | "\\f"  [[ 12       ]]
     | "\\n"  [[ CHAR: \n ]]
     | "\\r"  [[ CHAR: \r ]]
     | "\\t"  [[ CHAR: \t ]]
     | "\\u" (hex hex hex hex) [[ hex> ]] => [[ second ]]
     | [^"\]
string = '"' char*:cs '"' => [[ cs >string ]]

sign = ("-" | "+")? => [[ "-" = "-" "" ? ]]
digits = [0-9]+     => [[ >string ]]
decimal = "." digits  => [[ concat ]]
exp = ("e" | "E") sign digits => [[ concat ]]
number = sign digits decimal? exp? => [[ dup concat swap fourth [ string>float ] [ string>number ] if ]]

elements = value ("," value)* => [[ grammar-list>vector ]]
array = "[" elements?:arr "]" => [[ arr >array ]]

pair = ws string:key ws ":" value:val => [[ { key val } ]]
members = pair ("," pair)* => [[ grammar-list>vector ]]
object = "{" members?:hash "}" => [[ hash >hashtable ]]

val = true
    | false
    | null
    | string
    | number
    | array
    | object

value = ws val:v ws => [[ v ]]

;EBNF

PRIVATE>

: json> ( string -- object ) (json>) ;