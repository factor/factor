! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.enums alien.enums.private
alien.syntax sequences tools.test words ;
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
