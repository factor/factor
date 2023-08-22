! Copyright (C) 2009 Philipp Brüschweiler
! See https://factorcode.org/license.txt for BSD license.
USING: infix.ast kernel peg peg.ebnf math.parser sequences
strings multiline ;
IN: infix.tokenizer

EBNF: tokenize-infix [=[
Letter            = [a-zA-Z]
Digit             = [0-9]
Digits            = Digit+
Number            =   Digits '.' Digits => [[ "" concat-as string>number ast-value boa ]]
                    | Digits => [[ >string string>number ast-value boa ]]
String            = '"' [^"]* '"' => [[ second >string ast-value boa ]]
Space             = [ \t\n\r]
Spaces            = Space* => [[ ignore ]]
NameFirst         = Letter | "_" => [[ CHAR: _ ]]
NameRest          = NameFirst | Digit
Name              = NameFirst NameRest* => [[ first2 swap prefix >string ]]
Special           =   [+*/%(),] | "-" => [[ CHAR: - ]]
                    | "[" => [[ CHAR: [ ]] | "]" => [[ CHAR: ] ]]
                    | ":" => [[ CHAR: : ]]
Tok               = Spaces (Name | Number | String | Special )
End               = !(.)
Toks              = Tok* Spaces End
]=]
