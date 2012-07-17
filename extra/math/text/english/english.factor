! Copyright (c) 2007, 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit grouping kernel math math.parser
math.text.utils namespaces sequences ;
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
    over length 0 = [
        nip
    ] [
        swap and-needed? get " and " ", " ?
        glue and-needed? off
    ] if ;

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

: number>text ( n -- str )
    dup zero? [ small-numbers ] [ [ (number>text) ] with-scope ] if ;

