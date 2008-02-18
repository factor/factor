USING: tools.test tools.annotations math parser ;
IN: temporary

: foo ;
\ foo watch

[ ] [ foo ] unit-test

! erg's bug
GENERIC: some-generic ( a -- b )

M: integer some-generic 1+ ;

[ 4 ] [ 3 some-generic ] unit-test

[ ] [ \ some-generic watch ] unit-test

[ 4 ] [ 3 some-generic ] unit-test

[ ] [ "IN: temporary USE: math M: integer some-generic 1- ;" eval ] unit-test

[ 2 ] [ 3 some-generic ] unit-test

[ ] [ \ some-generic reset ] unit-test

[ 2 ] [ 3 some-generic ] unit-test
