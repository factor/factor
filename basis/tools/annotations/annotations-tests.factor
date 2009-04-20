USING: tools.test tools.annotations tools.time math parser eval
io.streams.string kernel strings ;
IN: tools.annotations.tests

: foo ( -- ) ;
\ foo watch

[ ] [ foo ] unit-test

! erg's bug
GENERIC: some-generic ( a -- b )

M: integer some-generic 1+ ;

[ 4 ] [ 3 some-generic ] unit-test

[ ] [ \ some-generic watch ] unit-test

[ 4 ] [ 3 some-generic ] unit-test

[ ] [ "IN: tools.annotations.tests USE: math M: integer some-generic 1- ;" eval( -- ) ] unit-test

[ 2 ] [ 3 some-generic ] unit-test

[ ] [ \ some-generic reset ] unit-test

[ 2 ] [ 3 some-generic ] unit-test

! slava's bug
GENERIC: another-generic ( a -- b )

M: object another-generic ;

\ another-generic watch

[ ] [ "IN: tools.annotations.tests GENERIC: another-generic ( a -- b )" eval( -- ) ] unit-test

[ ] [ \ another-generic reset ] unit-test

[ "" ] [ [ 3 another-generic drop ] with-string-writer ] unit-test

GENERIC: blah-generic ( a -- b )

M: string blah-generic ;

[ ] [ M\ string blah-generic watch ] unit-test

[ "hi" ] [ "hi" blah-generic ] unit-test
