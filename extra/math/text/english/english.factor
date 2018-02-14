! Copyright (c) 2007, 2008, 2018 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators combinators.short-circuit grouping kernel
math math.functions math.parser math.order math.text.utils namespaces
sequences splitting ;
IN: math.text.english

<PRIVATE

: small-numbers ( n -- str )
    {
        "zero" "one" "two" "three" "four" "five" "six"
        "seven" "eight" "nine" "ten" "eleven" "twelve"
        "thirteen" "fourteen" "fifteen" "sixteen" "seventeen"
        "eighteen" "nineteen"
    } nth ;

: tens ( n -- str )
    {
        f f "twenty" "thirty" "forty" "fifty" "sixty"
        "seventy" "eighty" "ninety"
    } nth ;

: scale-numbers ( n -- str )  ! up to 10^99
    {
        f "thousand" "million" "billion" "trillion" "quadrillion"
        "quintillion" "sextillion" "septillion" "octillion"
        "nonillion" "decillion" "undecillion" "duodecillion"
        "tredecillion" "quattuordecillion" "quindecillion"
        "sexdecillion" "septendecillion" "octodecillion" "novemdecillion"
        "vigintillion" "unvigintillion" "duovigintillion" "trevigintillion"
        "quattuorvigintillion" "quinvigintillion" "sexvigintillion"
        "septvigintillion" "octovigintillion" "novemvigintillion"
        "trigintillion" "untrigintillion" "duotrigintillion"
    } nth ;

SYMBOL: and-needed?
: set-conjunction ( seq -- )
    first { [ 100 < ] [ 0 > ] } 1&& and-needed? set ;

: negative-text ( n -- str )
    0 < "negative " "" ? ;

: hundreds-place ( n -- str )
    100 /mod over 0 = [
        2drop ""
    ] [
        [ small-numbers " hundred" append ] dip
        0 = [ " and " append ] unless
    ] if ;

: tens-place ( n -- str )
    100 mod dup 20 >= [
        10 /mod [ tens ] dip
        [ small-numbers "-" glue ] unless-zero
    ] [
        [ "" ] [ small-numbers ] if-zero
    ] if ;

: 3digits>text ( n -- str )
    [ hundreds-place ] [ tens-place ] bi append ;

: text-with-scale ( index seq -- str )
    [ nth 3digits>text ] [ drop scale-numbers ] 2bi
    [ " " glue ] unless-empty ;

: append-with-conjunction ( str1 str2 -- newstr )
    swap [
        and-needed? get " and " ", " ? glue
        and-needed? off
    ] unless-empty ;

: (recombine) ( str index seq -- newstr )
    2dup nth 0 = [
        2drop
    ] [
        text-with-scale append-with-conjunction
    ] if ;

: recombine ( seq -- str )
    dup length 1 = [
        first 3digits>text
    ] [
        [ set-conjunction "" ] [ length ] [ ] tri
        [ (recombine) ] curry each-integer
    ] if ;

: (number>text) ( n -- str )
    [ negative-text ] [ abs 3 digit-groups recombine ] bi append ;

PRIVATE>

GENERIC: number>text ( n -- str )

M: integer number>text
    [ "zero" ] [ [ (number>text) ] with-scope ] if-zero ;

M: ratio number>text
    >fraction [ number>text ] bi@ " divided by " glue ;

M: float number>text
    number>string "." split1 [
        "-" ?head
        [ string>number number>text ]
        [ [ "negative " prepend ] when ] bi*
    ] [
        [ CHAR: 0 - small-numbers ] { } map-as " " join
    ] bi* " point " glue ;

M: complex number>text
    >rect [ number>text ] [
        [ 0 < " minus " " plus " ? ]
        [ abs number>text " i" append ] bi
    ] bi* 3append ;

: ordinal-suffix ( n -- suffix )
    abs dup 100 mod 11 13 between? [ drop "th" ] [
        10 mod {
            { 1 [ "st" ] }
            { 2 [ "nd" ] }
            { 3 [ "rd" ] }
            [ drop "th" ]
        } case
    ] if ;
