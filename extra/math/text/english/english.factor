! Copyright (c) 2007, 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit grouping kernel math math.parser namespaces
    sequences ;
IN: math.text.english

<PRIVATE

: small-numbers ( n -- str )
    { "Zero" "One" "Two" "Three" "Four" "Five" "Six" "Seven" "Eight" "Nine"
    "Ten" "Eleven" "Twelve" "Thirteen" "Fourteen" "Fifteen" "Sixteen"
    "Seventeen" "Eighteen" "Nineteen" } nth ;

: tens ( n -- str )
    { f f "Twenty" "Thirty" "Forty" "Fifty" "Sixty" "Seventy" "Eighty" "Ninety" } nth ;

: scale-numbers ( n -- str )  ! up to 10^99
    { f "Thousand" "Million" "Billion" "Trillion" "Quadrillion" "Quintillion"
    "Sextillion" "Septillion" "Octillion" "Nonillion" "Decillion" "Undecillion"
    "Duodecillion" "Tredecillion" "Quattuordecillion" "Quindecillion"
    "Sexdecillion" "Septendecillion" "Octodecillion" "Novemdecillion"
    "Vigintillion" "Unvigintillion" "Duovigintillion" "Trevigintillion"
    "Quattuorvigintillion" "Quinvigintillion" "Sexvigintillion"
    "Septvigintillion" "Octovigintillion" "Novemvigintillion" "Trigintillion"
    "Untrigintillion" "Duotrigintillion" } nth ;

SYMBOL: and-needed?
: set-conjunction ( seq -- )
    first { [ 100 < ] [ 0 > ] } 1&& and-needed? set ;

: negative-text ( n -- str )
    0 < "Negative " "" ? ;

: 3digit-groups ( n -- seq )
    number>string <reversed> 3 <groups>
    [ reverse string>number ] map ;

: hundreds-place ( n -- str )
    100 /mod swap dup zero? [
        2drop ""
    ] [
        small-numbers " Hundred" append
        swap zero? [ " and " append ] unless
    ] if ;

: tens-place ( n -- str )
    100 mod dup 20 >= [
        10 /mod [ tens ] dip
        dup zero? [ drop ] [ "-" swap small-numbers 3append ] if
    ] [
        dup zero? [ drop "" ] [ small-numbers ] if
    ] if ;

: 3digits>text ( n -- str )
    [ hundreds-place ] [ tens-place ] bi append ;

: text-with-scale ( index seq -- str )
    [ nth 3digits>text ] [ drop scale-numbers ] 2bi
    [ " " glue ] unless-empty ;

: append-with-conjunction ( str1 str2 -- newstr )
    over length zero? [
        nip
    ] [
        and-needed? get " and " ", " ? rot 3append
        and-needed? off
    ] if ;

: (recombine) ( str index seq -- newstr )
    2dup nth zero? [
        2drop
    ] [
        text-with-scale append-with-conjunction
    ] if ;

: recombine ( seq -- str )
    dup length 1 = [
        first 3digits>text
    ] [
        [ set-conjunction "" ] [ length ] [ ] tri
        [ (recombine) ] curry each
    ] if ;

: (number>text) ( n -- str )
    [ negative-text ] [ abs 3digit-groups recombine ] bi append ;

PRIVATE>

: number>text ( n -- str )
    dup zero? [ small-numbers ] [ [ (number>text) ] with-scope ] if ;

