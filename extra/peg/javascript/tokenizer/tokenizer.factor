! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences strings arrays math.parser peg peg.ebnf
peg.javascript.ast multiline ;
IN: peg.javascript.tokenizer

! Grammar for JavaScript. Based on OMeta-JS example from:
! http://jarrett.cs.ucla.edu/ometa-js/#JavaScript_Compiler

USE: prettyprint

EBNF: tokenize-javascript [=[
Letter            = [a-zA-Z]
Digit             = [0-9]
Digits            = Digit+
SingleLineComment = "//" (!("\n") .)* "\n" => [[ ignore ]]
MultiLineComment  = "/*" (!("*/") .)* "*/" => [[ ignore ]]
Space             = [ \t\r\n] | SingleLineComment | MultiLineComment
Spaces            = Space* => [[ ignore ]]
NameFirst         = Letter | "$" => [[ CHAR: $ ]] | "_" => [[ CHAR: _ ]]
NameRest          = NameFirst | Digit
iName             = NameFirst NameRest* => [[ first2 swap prefix >string ]]
Keyword           =  ("break"
                    | "case"
                    | "catch"
                    | "continue"
                    | "default"
                    | "delete"
                    | "do"
                    | "else"
                    | "finally"
                    | "for"
                    | "function"
                    | "if"
                    | "in"
                    | "instanceof"
                    | "new"
                    | "return"
                    | "switch"
                    | "this"
                    | "throw"
                    | "try"
                    | "typeof"
                    | "var"
                    | "void"
                    | "while"
                    | "with") !(NameRest)
Name              = !(Keyword) iName  => [[ ast-name boa ]]
Number            =   Digits:ws '.' Digits:fs => [[ ws "." fs 3array "" concat-as string>number ast-number boa ]]
                    | Digits => [[ >string string>number ast-number boa ]]

SingleEscape      =   "b"  => [[ CHAR: \b ]]
                    | "f"  => [[ CHAR: \f ]]
                    | "n"  => [[ CHAR: \n ]]
                    | "r"  => [[ CHAR: \r ]]
                    | "t"  => [[ CHAR: \t ]]
                    | "v"  => [[ CHAR: \v ]]
                    | "'"  => [[ CHAR: '  ]]
                    | "\"" => [[ CHAR: \"  ]]
                    | "\\" => [[ CHAR: \\ ]]
HexDigit          = [0-9a-fA-F]
HexEscape         = "x" (HexDigit HexDigit):d => [[ d hex> ]]
UnicodeEscape     = "u" (HexDigit HexDigit HexDigit HexDigit):d => [[ d hex> ]]
                    | "u{" HexDigit+:d "}" => [[ d hex> ]]
EscapeChar         = "\\" (SingleEscape | HexEscape | UnicodeEscape):c => [[ c ]]
StringChars1       = (EscapeChar | !('"""') .)* => [[ >string ]]
StringChars2       = (EscapeChar | !('"') .)* => [[ >string ]]
StringChars3       = (EscapeChar | !("'") .)* => [[ >string ]]
Str                =   '"""' StringChars1:cs '"""' => [[ cs ast-string boa ]]
                     | '"' StringChars2:cs '"' => [[ cs ast-string boa ]]
                     | "'" StringChars3:cs "'" => [[ cs ast-string boa ]]
RegExpFlags        = NameRest* => [[ >string ]]
NonTerminator      = !([\n\r]) .
BackslashSequence  = "\\" NonTerminator => [[ second ]]
RegExpFirstChar    =   !([*\\/]) NonTerminator
                     | BackslashSequence
RegExpChar         =   !([\\/]) NonTerminator
                     | BackslashSequence
RegExpChars        = RegExpChar*
RegExpBody         = RegExpFirstChar RegExpChars => [[ first2 swap prefix >string ]]
RegExp             = "/" RegExpBody:b "/" RegExpFlags:fl => [[ b fl ast-regexp boa ]]
Special            =   "("    | ")"   | "{"   | "}"   | "["   | "]"   | ","   | ";"
                     | "?"    | ":"   | "!==" | "!="  | "===" | "=="  | "="   | ">="
                     | ">>>=" | ">>>" | ">>=" | ">>"  | ">"   | "<="  | "<<=" | "<<"
                     | "<"    | "++"  | "+="  | "+"   | "--"  | "-="  | "-"   | "*="
                     | "*"    | "/="  | "/"   | "%="  | "%"   | "&&=" | "&&"  | "||="
                     | "||"   | "."   | "!"   | "&="  | "&"   | "|="  | "|"   | "^="
                     | "^"
Tok                = Spaces (Name | Keyword | Number | Str | RegExp | Special )
Toks               = Tok* Spaces
]=]
