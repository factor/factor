! Copyright (C) 2009 Philipp Brüschweiler
! See http://factorcode.org/license.txt for BSD license.
USING: infix.ast kernel peg peg.ebnf math.parser sequences
strings ;
IN: infix.tokenizer

EBNF: tokenize-infix
Letter            = [a-zA-Z]
Digit             = [0-9]
Digits            = Digit+
Number            =   Digits '.' Digits => [[ "" concat-as string>number ast-number boa ]]
                    | Digits => [[ >string string>number ast-number boa ]]
Space             = " " | "\n" | "\r" | "\t"
Spaces            = Space* => [[ ignore ]]
NameFirst         = Letter | "_" => [[ CHAR: _ ]]
NameRest          = NameFirst | Digit
Name              = NameFirst NameRest* => [[ first2 swap prefix >string ]]
Special           =   [+*/%(),] | "-" => [[ CHAR: - ]]
                    | "[" => [[ CHAR: [ ]] | "]" => [[ CHAR: ] ]]
                    | ":" => [[ CHAR: : ]]
Tok               = Spaces (Name | Number | Special )
End               = !(.)
Toks              = Tok* Spaces End
;EBNF
