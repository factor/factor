! Copyright (C) 2022 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: circular lists lists.circular lists.lazy sequences tools.test ;

{ { f f "Fizz" f f "Fizz" f f "Fizz" } } [
    9 { f f "Fizz" } <circular> ltake list>array
] unit-test

{ { f f f f "Buzz" f f f f "Buzz" f f f f "Buzz" } } [
    15 { f f f f "Buzz" } <circular> ltake list>array
] unit-test

{ {
    "" "" "Fizz" "" "Buzz"
    "Fizz" "" "" "Fizz" "Buzz"
    "" "Fizz" "" "" "FizzBuzz"
} } [
    15
        { "" "" "Fizz" } <circular>
        { "" "" "" "" "Buzz" } <circular>
        lzip [ first2 append ] lmap-lazy
    ltake list>array
] unit-test
