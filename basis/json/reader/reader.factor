! Copyright (C) 2008 Peter Burns.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg peg.ebnf math.parser math.private strings math math.functions sequences
       arrays vectors hashtables prettyprint ;
IN: json.reader

SINGLETON: json-null

! Grammar for JSON from RFC 4627
EBNF: json>

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
     | "\\u" (hex hex hex hex) [[ hex> ]] => [[ 1 swap nth ]]
     | [^"\]
string = '"' char*:cs '"' => [[ cs >string ]]

sign = ("-" | "+")? => [[ "-" = [ "-" ] [ "" ] if ]]
digits = [0-9]+     => [[ >string ]]
decimal = "." digits  => [[ concat ]]
exp = ("e" | "E") sign digits => [[ concat ]]
number = sign digits decimal? exp? => [[ dup concat swap fourth [ string>float ] [ string>number ] if ]]

elements = value ("," value)* => [[ first2 [ second ] map swap prefix >array ]]
array = "[" elements?:arr "]" => [[ arr { } or ]]

pair = ws string:key ws ":" value:val => [[ { key val } ]]
members = pair ("," pair)* => [[ first2 [ second ] map swap prefix >hashtable ]]
object = "{" (members)?:hash "}" => [[ hash H{ } or ]]

val = true
    | false
    | null
    | string
    | number
    | array
    | object

value = ws val:v ws => [[ v ]]

;EBNF