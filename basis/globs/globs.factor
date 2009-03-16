! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel regexp.combinators strings unicode.case
peg.ebnf regexp arrays ;
IN: globs

EBNF: <glob>

Character = "\\" .:c => [[ c 1string <literal> ]]
          | !(","|"}") . => [[ 1string <literal> ]]

RangeCharacter = !("]") .

Range = RangeCharacter:a "-" RangeCharacter:b => [[ a b <char-range> ]]
      | RangeCharacter => [[ 1string <literal> ]]

StartRange = .:a "-" RangeCharacter:b => [[ a b <char-range> ]]
           | . => [[ 1string <literal> ]]

Ranges = StartRange:s Range*:r => [[ r s prefix ]]

CharClass = "^"?:n Ranges:e => [[ e <or> n [ <not> ] when ]]

AlternationBody = Concatenation:c "," AlternationBody:a => [[ a c prefix ]]
                | Concatenation => [[ 1array ]]

Element = "*" => [[ R/ .*/ ]]
        | "?" => [[ R/ ./ ]]
        | "[" CharClass:c "]" => [[ c ]]
        | "{" AlternationBody:b "}" => [[ b <or> ]]
        | Character

Concatenation = Element* => [[ <sequence> ]]

End = !(.)

Main = Concatenation End

;EBNF

: glob-matches? ( input glob -- ? )
    [ >case-fold ] bi@ <glob> matches? ;
