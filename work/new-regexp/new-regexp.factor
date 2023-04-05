! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel math.parser peg.ebnf regexp
regexp.ast regexp.classes regexp.parser sequences ;

IN: new-regexp

EBNF: parse-new-regexp

CharacterInBracket = !("}") Character

QuotedCharacter = !("\\E") .

Escape = "p{" CharacterInBracket*:s "}" => [[ s name>class <primitive-class> ]]
       | "P{" CharacterInBracket*:s "}" => [[ s name>class <primitive-class> <not-class> ]]
       | "Q" QuotedCharacter*:s "\\E" => [[ s <concatenation> ]]
       | "u" Character:a Character:b Character:c Character:d
            => [[ { a b c d } hex> ensure-number ]]
       | "x" Character:a Character:b
            => [[ { a b } hex> ensure-number ]]
       | "0" Character:a Character:b Character:c
            => [[ { a b c } oct> ensure-number ]]
       | . => [[ lookup-escape ]]

EscapeSequence = "∂" Escape:e => [[ e ]]

Character = EscapeSequence
          | "$" => [[ $ <tagged-epsilon> ]]
          | "^" => [[ ^ <tagged-epsilon> ]]
          | . ?[ allowed-char? ]?

AnyRangeCharacter = !("&&"|"||"|"--"|"~~") (EscapeSequence | .)

RangeCharacter = !("]") AnyRangeCharacter

Range = RangeCharacter:a "-" !("-") RangeCharacter:b => [[ a b <range-class> ]]
      | RangeCharacter

StartRange = AnyRangeCharacter:a "-" !("-") RangeCharacter:b => [[ a b <range-class> ]]
           | AnyRangeCharacter

Ranges = StartRange:s Range*:r => [[ r s prefix ]]

BasicCharClass =  "^"?:n Ranges:e => [[ e n char-class ]]

CharClass = BasicCharClass:b "&&" CharClass:c
                => [[ b c 2array <and-class> ]]
          | BasicCharClass:b "||" CharClass:c
                => [[ b c 2array <or-class> ]]
          | BasicCharClass:b "~~" CharClass:c
                => [[ b c <sym-diff-class> ]]
          | BasicCharClass:b "--" CharClass:c
                => [[ b c <minus-class> ]]
          | BasicCharClass

Options = [idmsux]*

Parenthized = "?:" Alternation:a => [[ a ]]
            | "?" Options:on "-"? Options:off ":" Alternation:a
                => [[ a on off parse-options <with-options> ]]
            | "?#" [^)]* => [[ f ]]
            | "?~" Alternation:a => [[ a <negation> ]]
            | "?=" Alternation:a => [[ a <lookahead> <tagged-epsilon> ]]
            | "?!" Alternation:a => [[ a <lookahead> <not-class> <tagged-epsilon> ]]
            | "?<=" Alternation:a => [[ a <lookbehind> <tagged-epsilon> ]]
            | "?<!" Alternation:a => [[ a <lookbehind> <not-class> <tagged-epsilon> ]]
            | Alternation

Element = "(" Parenthized:p ")" => [[ p ]]
        | "[" CharClass:r "]" => [[ r ]]
        | ".":d => [[ dot ]]
        | Character

Number = (!(","|"}").)* => [[ string>number ensure-number ]]

Times = "," Number:n "}" => [[ 0 n <from-to> ]]
      | Number:n ",}" => [[ n <at-least> ]]
      | Number:n "}" => [[ n n <from-to> ]]
      | "}" => [[ bad-number ]]
      | Number:n "," Number:m "}" => [[ n m <from-to> ]]

Repeated = Element:e "{" Times:t => [[ e t <times> ]]
         | Element:e "??" => [[ e <maybe> ]]
         | Element:e "*?" => [[ e <star> ]]
         | Element:e "+?" => [[ e <plus> ]]
         | Element:e "?" => [[ e <maybe> ]]
         | Element:e "*" => [[ e <star> ]]
         | Element:e "+" => [[ e <plus> ]]
         | Element

Concatenation = Repeated*:r => [[ r sift <concatenation> ]]

Alternation = Concatenation:c ("|" Concatenation)*:a
                => [[ a empty? [ c ] [ a values c prefix <alternation> ] if ]]

End = !(.)

Main = Alternation End
;EBNF

: <optioned-new-regexp> ( string options -- regexp )
    [ dup parse-new-regexp ] [ string>options ] bi*
    dup on>> reversed-regexp swap member?
    [ reverse-regexp new-regexp ]
    [ regexp new-regexp ] if ;

: <newregexp> ( string -- regexp ) "" <optioned-new-regexp> ;


