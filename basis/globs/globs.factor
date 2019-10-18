! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences io.pathnames kernel regexp.combinators
strings splitting system unicode.case peg.ebnf regexp arrays ;
IN: globs

: not-path-separator ( -- sep )
    os windows? R! [^/\\]! R! [^/]! ? ; foldable

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

Element = "*" => [[ not-path-separator <zero-or-more> ]]
        | "?" => [[ not-path-separator ]]
        | "[" CharClass:c "]" => [[ c ]]
        | "{" AlternationBody:b "}" => [[ b <or> ]]
        | Character

Concatenation = Element* => [[ <sequence> ]]

End = !(.)

Main = Concatenation End

;EBNF

: glob-matches? ( input glob -- ? )
    [ >case-fold ] bi@ <glob> matches? ;

: glob-pattern? ( string -- ? )
    [ "\\*?[{" member? ] any? ;

: glob-parent-directory ( glob -- parent-directory )
    path-separator split harvest dup [ glob-pattern? ] find drop head
    path-separator join ;
