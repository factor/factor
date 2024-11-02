! Copyright (c) 2007, 2008, 2018 Aaron Schaefer, 2022 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators combinators.short-circuit kernel math
math.order math.parser math.text.utils namespaces sequences
splitting ;
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

: scale-numbers ( n -- str )  ! up to 10^630
    {
        { [ dup 41 < ] [
            {
                f "thousand" "million" "billion" "trillion" "quadrillion"
                "quintillion" "sextillion" "septillion" "octillion"
                "nonillion" "decillion" "undecillion" "duodecillion"
                "tredecillion" "quattuordecillion" "quindecillion"
                "sexdecillion" "septendecillion" "octodecillion"
                "novemdecillion" "vigintillion" "unvigintillion"
                "duovigintillion" "tresvigintillion" "quattuorvigintillion"
                "quinvigintillion" "sesvigintillion" "septemvigintillion"
                "octovigintillion" "novemvigintillion" "trigintillion"
                "untrigintillion" "duotrigintillion" "trestrigintillion"
                "quattuortrigintillion" "quintrigintillion" "sestrigintillion"
                "septentrigintillion" "octotrigintillion" "noventrigintillion"
            } nth
        ] }
        { [ dup 311 < ] [
            41 - 10 /mod [
                {
                    "quadragintillion" "quinquagintillion" "sexagintillion"
                    "septuagintillion" "octogintillion" "nonagintillion"
                    "centillion" "decicentillion" "viginticentillion"
                    "trigintacentillion" "quadragintacentillion"
                    "quinquagintacentillion" "sexagintacentillion"
                    "septuagintacentillion" "octogintacentillion"
                    "nonagintacentillion" "ducentillion"
                } nth
                ! Next 10^300 increments after ducentillion, which is 10^603:
                ! "trecentillion" "quadringentillion"
                ! "quingentillion" "sescentillion"
                ! "septingentillion" "octingentillion"
                ! "nongentillion" "millinillion" = 10^3003
            ] [
                {
                    f "un" "duo" "tre" "quattuor"
                    "quinqua" "se" "septe" "octo" "nove"
                } nth
            ] bi* swap "" append-as
        ] }
    } cond ;

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
    {
        { 1/0. [ "infinity" ] }
        { -1/0. [ "negative infinity" ] }
        [
            dup fp-nan? [ drop "not a number" ] [
                number>string "-" ?head swap
                "e-" split1 [
                    [ CHAR: . swap remove ] dip
                    string>number 1 - CHAR: 0 <repetition>
                    prepend "0" swap
                ] [
                    "e+" split1 [
                        [ "." split1 [ append ] [ length ] bi ] dip
                        string>number swap - CHAR: 0 <repetition> append
                        "0"
                    ] [
                        "." split1
                    ] if*
                ] if*

                [ string>number number>text ] dip
                [ CHAR: 0 - small-numbers ] { } map-as
                join-words " point " glue swap
                [ "negative " prepend ] when
            ] if
        ]
    } case ;

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

: number-ap-style ( n -- str )
    dup { [ integer? ] [ 0 9 between? ] } 1&&
    [ number>text ] [ number>string ] if ;

: ordinal-ap-style ( n -- str )
    dup {
        f "first" "second" "third" "fourth" "fifth" "sixth"
        "seventh" "eighth" "ninth"
    } ?nth [ nip ] [
        [ number>string ] [ ordinal-suffix ] bi append
    ] if* ;
