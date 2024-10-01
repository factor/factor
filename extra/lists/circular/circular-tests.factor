! Copyright (C) 2022 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: circular lists lists.circular lists.lazy sequences tools.test ;

{ { f f "Fizz" f f "Fizz" f f "Fizz" } } [
    { f f "Fizz" } <circular> 9 ltake list>array
] unit-test

{ { f f f f "Buzz" f f f f "Buzz" f f f f "Buzz" } } [
    { f f f f "Buzz" } <circular> 15 ltake list>array
] unit-test

{ {
    "" "" "Fizz" "" "Buzz"
    "Fizz" "" "" "Fizz" "Buzz"
    "" "Fizz" "" "" "FizzBuzz"
} } [
    { "" "" "Fizz" } <circular>
    { "" "" "" "" "Buzz" } <circular>
    lzip [ first2 append ] lmap-lazy
    15 ltake list>array
] unit-test
