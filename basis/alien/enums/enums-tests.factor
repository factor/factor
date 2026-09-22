! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.enums alien.enums.private
alien.syntax kernel sequences tools.test words ;
IN: alien.enums.tests

ENUM: color_t red { green 3 } blue ;
ENUM: instrument_t < ushort trombone trumpet ;

{ { red green blue 5 } }
[ { 0 3 4 5 } [ <color_t> ] map ] unit-test

{ { 0 3 4 5 } }
[ { red green blue 5 } [ enum>number ] map ] unit-test

{ { -1 trombone trumpet } }
[ { -1 0 1 } [ <instrument_t> ] map ] unit-test

{ { -1 0 1 } }
[ { -1 trombone trumpet } [ enum>number ] map ] unit-test

{ t }
[ color_t "c-type" word-prop enum-c-type? ] unit-test

{ f }
[ ushort "c-type" word-prop enum-c-type? ] unit-test

{ int }
[ color_t "c-type" word-prop base-type>> ] unit-test

{ ushort }
[ instrument_t "c-type" word-prop base-type>> ] unit-test

{ V{ { red 0 } { green 3 } { blue 4 } } }
[ color_t "c-type" word-prop members>> ] unit-test

ENUM: colores { rojo red } { verde green } { azul blue } { colorado rojo } ;

{ { 0 3 4 0 } } [ { rojo verde azul colorado } [ enum>number ] map ] unit-test

SYMBOLS: couleurs rouge vert bleu jaune azure ;

<< \ couleurs int {
    { rouge red }
    { vert green }
    { bleu blue }
    { jaune 14 }
    { azure bleu }
} define-enum >>

{ { 0 3 4 14 4 } } [ { rouge vert bleu jaune azure } [ enum>number ] map ] unit-test

ENUM: large-enum
    e00 e01 e02 e03 e04 e05 e06 e07 e08 e09
    e10 e11 e12 e13 e14 e15 e16 e17 e18 e19
    e20 e21 e22 e23 e24 e25 e26 e27 e28 e29
    e30 e31 e32 { e00-alias e00 } { e01-alias e01 } ;

{ e00 e01 e32 -1 33 } [
    0 <large-enum> 1 <large-enum> 32 <large-enum>
    -1 <large-enum> 33 <large-enum>
] unit-test

{ t } [
    33 <iota> dup [ <large-enum> enum>number ] map sequence=
] unit-test
