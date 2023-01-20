! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii combinators combinators.smart io kernel math
math.parser ranges sequences splitting ;
IN: 99-bottles

: bottles ( n -- number string )
    [ dup 0 > [ number>string ] [ drop "No more" ] if ]
    [ 1 = not "bottles" "bottle" ? ] bi ;

: verse ( n -- )
    [
        {
            [ bottles "of beer on the wall," ]
            [ bottles "of beer.\nTake one down, pass it around," ]
            [ 1 - bottles [ >lower ] dip "of beer on the wall." ]
        } cleave
    ] output>array join-words print nl ;

: last-verse ( -- )
    "No more bottles of beer on the wall, no more bottles of beer." print
    "Go to the store and buy some more, 99 bottles of beer on the wall." print ;

: 99-bottles ( -- )
    99 1 [a..b] [ verse ] each last-verse ;

MAIN: 99-bottles
