! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib kernel math math.functions math.parser namespaces
    sequences splitting grouping sequences.lib ;
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
    first { [ dup 100 < ] [ dup 0 > ] } 0&& and-needed? set drop ;

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
    dup hundreds-place swap tens-place append ;

: text-with-scale ( index seq -- str )
    dupd nth 3digits>text swap
    scale-numbers dup empty? [
        drop
    ] [
        " " swap 3append
    ] if ;

: append-with-conjunction ( str1 str2 -- newstr )
    over length zero? [
        nip
    ] [
        and-needed? get " and " ", " ? rot 3append
        and-needed? off
    ] if ;

: (recombine) ( str index seq -- newstr seq )
    2dup nth zero? [
        nip
    ] [
        [ text-with-scale ] keep
        -rot append-with-conjunction swap
    ] if ;

: recombine ( seq -- str )
    dup length 1 = [
        first 3digits>text
    ] [
        dup set-conjunction "" swap
        dup length [ swap (recombine) ] each drop
    ] if ;

: (number>text) ( n -- str )
    dup negative-text swap abs 3digit-groups recombine append ;

PRIVATE>

: number>text ( n -- str )
    dup zero? [
        small-numbers
    ] [
        [ (number>text) ] with-scope
    ] if ;

