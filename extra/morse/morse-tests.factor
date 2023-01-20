! Copyright (C) 2007 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: arrays morse strings tools.test ;

{ "?" } [ CHAR: \\ ch>morse ] unit-test
{ "..." } [ CHAR: s ch>morse ] unit-test
{ CHAR: s } [ "..." morse>ch ] unit-test
{ CHAR: \s } [ "..--..--.." morse>ch ] unit-test
{ "-- --- .-. ... . / -.-. --- -.. ." } [ "morse code" >morse ] unit-test
{ "morse code" } [ "-- --- .-. ... . / -.-. --- -.. ." morse> ] unit-test
{ "hello, world!" } [ "Hello, World!" >morse morse> ] unit-test
{ ".- -... -.-." } [ "abc" >morse ] unit-test

{ "abc" } [ ".- -... -.-." morse> ] unit-test

{ "morse code" } [
    [MORSE
        -- --- .-. ... . /
        -.-. --- -.. .
    MORSE] >morse morse> ] unit-test

{ "morse code 123" } [
    [MORSE
        __ ___ ._. ... . /
        _._. ___ _.. . /
        .____ ..___ ...__
    MORSE] ] unit-test

{ [MORSE
      -- --- .-. ... . /
      -.-. --- -.. .
  MORSE] } [
    "morse code" >morse morse>
] unit-test

{ "factor rocks!" } [
    [MORSE
      ..-. .- -.-. - --- .-. /
      .-. --- -.-. -.- ... -.-.--
    MORSE] ] unit-test
! [ ] [ "sos" 0.075 play-as-morse* ] unit-test
! [ ] [ "Factor rocks!" play-as-morse ] unit-test
! [ ] [ "\n" play-as-morse ] unit-test
