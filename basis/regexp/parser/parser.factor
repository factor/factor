! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: peg.ebnf kernel math.parser sequences assocs arrays
combinators regexp.classes strings splitting peg locals ;
IN: regexp.parser

TUPLE: range from to ;
TUPLE: char-class ranges ;
TUPLE: primitive-class class ;
TUPLE: not-char-class ranges ;
TUPLE: not-primitive-class class ;
TUPLE: from-to n m ;
TUPLE: at-least n ;
TUPLE: up-to n ;
TUPLE: exactly n ;
TUPLE: times expression times ;
TUPLE: concatenation seq ;
TUPLE: alternation seq ;
TUPLE: maybe term ;
TUPLE: star term ;
TUPLE: plus term ;
TUPLE: with-options tree options ;
TUPLE: ast ^? $? tree ;
SINGLETON: any-char

: allowed-char? ( ch -- ? )
    ".()|[*+?" member? not ;

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

        { CHAR: w [ c-identifier-class primitive-class boa ] }
        { CHAR: W [ c-identifier-class not-primitive-class boa ] }
        { CHAR: s [ java-blank-class primitive-class boa ] }
        { CHAR: S [ java-blank-class not-primitive-class boa ] }
        { CHAR: d [ digit-class primitive-class boa ] }
        { CHAR: D [ digit-class not-primitive-class boa ] }

        [ ]
    } case ;

TUPLE: options on off ;

SINGLETONS: unix-lines dotall multiline comments case-insensitive
unicode-case reversed-regexp ;

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
    [ [ ch>option ] map ] bi@ options boa ;

! TODO: make range syntax better (negation, and, etc),
!       add syntax for various parenthized things,
!       add greedy and nongreedy forms of matching
! (once it's all implemented)

EBNF: (parse-regexp)

CharacterInBracket = !("}") Character

Escape = "p{" CharacterInBracket*:s "}" => [[ s >string name>class primitive-class boa ]]
       | "P{" CharacterInBracket*:s "}" => [[ s >string name>class not-primitive-class boa ]]
       | "u" Character:a Character:b Character:c Character:d
            => [[ { a b c d } hex> ensure-number ]]
       | "x" Character:a Character:b
            => [[ { a b } hex> ensure-number ]]
       | "0" Character:a Character:b Character:c
            => [[ { a b c } oct> ensure-number ]]
       | . => [[ lookup-escape ]]

Character = "\\" Escape:e => [[ e ]]
          | . ?[ allowed-char? ]?

AnyRangeCharacter = Character | "["

RangeCharacter = !("]") AnyRangeCharacter

Range = RangeCharacter:a "-" RangeCharacter:b => [[ a b range boa ]]
      | RangeCharacter

StartRange = AnyRangeCharacter:a "-" RangeCharacter:b => [[ a b range boa ]]
           | AnyRangeCharacter

Ranges = StartRange:s Range*:r => [[ r s prefix ]]

CharClass = "^" Ranges:e => [[ e not-char-class boa ]]
          | Ranges:e => [[ e char-class boa ]]

Options = [idmsux]*

Parenthized = "?:" Alternation:a => [[ a ]]
            | "?" Options:on "-"? Options:off ":" Alternation:a
                => [[ a on off parse-options with-options boa ]]
            | "?#" [^)]* => [[ ignore ]]
            | Alternation

Element = "(" Parenthized:p ")" => [[ p ]]
        | "[" CharClass:r "]" => [[ r ]]
        | ".":d => [[ any-char ]]
        | Character

Number = (!(","|"}").)* => [[ string>number ensure-number ]]

Times = "," Number:n "}" => [[ n up-to boa ]]
      | Number:n ",}" => [[ n at-least boa ]]
      | Number:n "}" => [[ n exactly boa ]]
      | "}" => [[ bad-number ]]
      | Number:n "," Number:m "}" => [[ n m from-to boa ]]

Repeated = Element:e "{" Times:t => [[ e t times boa ]]
         | Element:e "?" => [[ e maybe boa ]]
         | Element:e "*" => [[ e star boa ]]
         | Element:e "+" => [[ e plus boa ]]
         | Element

Concatenation = Repeated*:r => [[ r concatenation boa ]]

Alternation = Concatenation:c ("|" Concatenation)*:a
                => [[ a empty? [ c ] [ a values c prefix alternation boa ] if ]]

End = !(.)

Main = Alternation End
;EBNF

: parse-regexp ( string -- regexp )
    ! Hack because I want $ allowable in regexps,
    ! but with special behavior at the end
    ! This fails if the regexp is stupid, though...
    dup first CHAR: ^ = tuck [ rest ] when
    dup peek CHAR: $ = tuck [ but-last ] when
    (parse-regexp) ast boa ;
