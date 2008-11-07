! Copyright (C) 2008 Peter Burns.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg peg.ebnf math.parser strings math math.functions sequences
       arrays vectors hashtables ;
IN: json.reader

! Grammar for JSON from RFC 4627

SINGLETON: json-null

EBNF: json>

ws = (" " | "\r" | "\t" | "\n")*

hex = [0-9a-fA-F]

char = '\\"'  [[ drop CHAR: "  ]]
     | "\\\\" [[ drop CHAR: \  ]]
     | "\\/"  [[ drop CHAR: /  ]]
     | "\\b"  [[ drop 8        ]]
     | "\\f"  [[ drop 12       ]]
     | "\\n"  [[ drop CHAR: \n ]]
     | "\\r"  [[ drop CHAR: \r ]]
     | "\\t"  [[ drop CHAR: \t ]]
     | "\\u" (hex hex hex hex) [[ hex> ]] => [[ 1 swap nth ]]
     | [^"\]

string = '"' char*:cs '"' => [[ cs >string ]]

number = base:base exp?:exp            => [[ base exp [ exp * ] when ]]
base   = sign?:s float:f               => [[ f s "-" = [ neg ] when ]]
float  = digits:int ("." digits)?:frac => [[ int frac [ frac concat append ] when string>number ]]
digits = [0-9]+                        => [[ >string ]]

exp  = ("e" | "E") (sign)?:s digits:ex => [[ ex string>number s "-" = [ neg ] when 10 swap ^ ]]
sign = "-" | "+"


array = "[" elements*:vec "]" => [[ 0 vec nth <reversed> >array ]]
elements = value:head ("," elements)?:tail => [[ head tail [ 1 tail nth ?push ] [ f ?push ] if ]]

object = "{" (members)*:assoc "}" => [[ 0 assoc nth >hashtable ]]
members = pair:head ("," members)?:tail => [[ head tail [ 1 tail nth ?push ] [ f ?push ] if ]]
pair = ws string:key ws ":" value:val => [[ { key val } ]]

val = string
    | number
    | object
    | array
    | "true"      [[ drop t ]]
    | "false"     [[ drop f ]]
    | "null"      [[ drop json-null ]]

value = ws val:v ws => [[ v ]]

;EBNF