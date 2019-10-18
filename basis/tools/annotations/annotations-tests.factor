USING: destructors eval io io.streams.string kernel math memory
namespaces parser sequences strings tools.annotations
tools.test tools.time ;
IN: tools.annotations.tests

: foo ( -- ) ;
\ foo watch

{ } [ foo ] unit-test

! erg's bug
GENERIC: some-generic ( a -- b )

M: integer some-generic 1 + ;

{ 4 } [ 3 some-generic ] unit-test

{ } [ \ some-generic watch ] unit-test

{ 4 } [ 3 some-generic ] unit-test

{ } [ "IN: tools.annotations.tests USE: math M: integer some-generic 1 - ;" eval( -- ) ] unit-test

{ 2 } [ 3 some-generic ] unit-test

{ } [ \ some-generic reset ] unit-test

{ 2 } [ 3 some-generic ] unit-test

! slava's bug
GENERIC: another-generic ( a -- b )

M: object another-generic ;

\ another-generic watch

{ } [ "IN: tools.annotations.tests GENERIC: another-generic ( a -- b )" eval( -- ) ] unit-test

{ } [ \ another-generic reset ] unit-test

{ "" } [ [ 3 another-generic drop ] with-string-writer ] unit-test

! reset should do the right thing for generic words
{ } [ \ another-generic watch ] unit-test

GENERIC: blah-generic ( a -- b )

M: string blah-generic ;

{ } [ M\ string blah-generic watch ] unit-test

{ "hi" } [ "hi" blah-generic ] unit-test

! See how well watch interacts with optimizations.
GENERIC: my-generic ( a -- b )
M: object my-generic ;

\ my-generic watch

: some-code ( -- )
    f my-generic drop ;

{ } [ some-code ] unit-test

! Make sure annotations work on primitives
\ gc reset
\ gc watch

{ f } [ [ [ gc ] with-error>output ] with-string-writer empty? ] unit-test

\ gc reset
