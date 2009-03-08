! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: peg.ebnf kernel math.parser sequences assocs arrays fry math
combinators regexp.classes strings splitting peg locals accessors
regexp.ast ;
IN: regexp.parser

: allowed-char? ( ch -- ? )
    ".()|[*+?$^" member? not ;

ERROR: bad-number ;

: ensure-number ( n -- n )
    [ bad-number ] unless* ;

:: at-error ( key assoc quot: ( key -- replacement ) -- value )
    key assoc at* [ drop key quot call ] unless ; inline

ERROR: bad-class name ;

: name>class ( name -- class )
    {
        { "Lower" letter-class }
        { "Upper" LETTER-class }
        { "Alpha" Letter-class }
        { "ASCII" ascii-class }
        { "Digit" digit-class }
        { "Alnum" alpha-class }
        { "Punct" punctuation-class }
        { "Graph" java-printable-class }
        { "Print" java-printable-class }
        { "Blank" non-newline-blank-class }
        { "Cntrl" control-character-class }
        { "XDigit" hex-digit-class }
        { "Space" java-blank-class }
        ! TODO: unicode-character-class
    } [ bad-class ] at-error ;

: lookup-escape ( char -- ast )
    {
        { CHAR: t [ CHAR: \t ] }
        { CHAR: n [ CHAR: \n ] }
        { CHAR: r [ CHAR: \r ] }
        { CHAR: f [ HEX: c ] }
        { CHAR: a [ HEX: 7 ] }
        { CHAR: e [ HEX: 1b ] }
        { CHAR: \\ [ CHAR: \\ ] }

        { CHAR: w [ c-identifier-class <primitive-class> ] }
        { CHAR: W [ c-identifier-class <primitive-class> <not-class> ] }
        { CHAR: s [ java-blank-class <primitive-class> ] }
        { CHAR: S [ java-blank-class <primitive-class> <not-class> ] }
        { CHAR: d [ digit-class <primitive-class> ] }
        { CHAR: D [ digit-class <primitive-class> <not-class> ] }

        { CHAR: z [ end-of-input <tagged-epsilon> ] }
        { CHAR: Z [ end-of-file <tagged-epsilon> ] }
        { CHAR: A [ beginning-of-input <tagged-epsilon> ] }
        [ ]
    } case ;

: options-assoc ( -- assoc )
    H{
        { CHAR: i case-insensitive }
        { CHAR: d unix-lines }
        { CHAR: m multiline }
        { CHAR: n multiline }
        { CHAR: r reversed-regexp }
        { CHAR: s dotall }
        { CHAR: u unicode-case }
        { CHAR: x comments }
    } ;

: ch>option ( ch -- singleton )
    options-assoc at ;

: option>ch ( option -- string )
    options-assoc value-at ;

: parse-options ( on off -- options )
    [ [ ch>option ] { } map-as ] bi@ <options> ;

: string>options ( string -- options )
    "-" split1 parse-options ;
 
: options>string ( options -- string )
    [ on>> ] [ off>> ] bi
    [ [ option>ch ] map ] bi@
    [ "-" glue ] unless-empty
    "" like ;

! TODO: add syntax for various parenthized things,
!       add greedy and nongreedy forms of matching
! (once it's all implemented)

EBNF: parse-regexp

CharacterInBracket = !("}") Character

QuotedCharacter = !("\\E") .

Escape = "p{" CharacterInBracket*:s "}" => [[ s >string name>class <primitive-class> ]]
       | "P{" CharacterInBracket*:s "}" => [[ s >string name>class <primitive-class> <negation> ]]
       | "Q" QuotedCharacter*:s "\\E" => [[ s <concatenation> ]]
       | "u" Character:a Character:b Character:c Character:d
            => [[ { a b c d } hex> ensure-number ]]
       | "x" Character:a Character:b
            => [[ { a b } hex> ensure-number ]]
       | "0" Character:a Character:b Character:c
            => [[ { a b c } oct> ensure-number ]]
       | . => [[ lookup-escape ]]

EscapeSequence = "\\" Escape:e => [[ e ]]

Character = EscapeSequence
          | "$" => [[ $ <tagged-epsilon> ]]
          | "^" => [[ ^ <tagged-epsilon> ]]
          | . ?[ allowed-char? ]?

AnyRangeCharacter = EscapeSequence | .

RangeCharacter = !("]") AnyRangeCharacter

Range = RangeCharacter:a "-" RangeCharacter:b => [[ a b <range> ]]
      | RangeCharacter

StartRange = AnyRangeCharacter:a "-" RangeCharacter:b => [[ a b <range> ]]
           | AnyRangeCharacter

Ranges = StartRange:s Range*:r => [[ r s prefix ]]

CharClass = "^"?:n Ranges:e => [[ e n char-class ]]

Options = [idmsux]*

Parenthized = "?:" Alternation:a => [[ a ]]
            | "?" Options:on "-"? Options:off ":" Alternation:a
                => [[ a on off parse-options <with-options> ]]
            | "?#" [^)]* => [[ f ]]
            | "?~" Alternation:a => [[ a <negation> ]]
            | "?=" Alternation:a => [[ a t <lookahead> <tagged-epsilon> ]]
            | "?!" Alternation:a => [[ a f <lookahead> <tagged-epsilon> ]]
            | "?<=" Alternation:a => [[ a t <lookbehind> <tagged-epsilon> ]]
            | "?<!" Alternation:a => [[ a f <lookbehind> <tagged-epsilon> ]]
            | Alternation

Element = "(" Parenthized:p ")" => [[ p ]]
        | "[" CharClass:r "]" => [[ r ]]
        | ".":d => [[ any-char <primitive-class> ]]
        | Character

Number = (!(","|"}").)* => [[ string>number ensure-number ]]

Times = "," Number:n "}" => [[ 0 n <from-to> ]]
      | Number:n ",}" => [[ n <at-least> ]]
      | Number:n "}" => [[ n n <from-to> ]]
      | "}" => [[ bad-number ]]
      | Number:n "," Number:m "}" => [[ n m <from-to> ]]

Repeated = Element:e "{" Times:t => [[ e t <times> ]]
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
