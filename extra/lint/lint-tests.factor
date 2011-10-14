USING: io lint kernel math tools.test ;
IN: lint.tests

! Don't write code like this
: lint1 ( obj -- ) [ "hi" print ] [ ] if ; ! when

[ { { lint1 { [ [ ] if ] } } } ] [ \ lint1 lint-word ] unit-test

: lint3 ( a b -- b a b ) dup -rot ; ! tuck

[ { { lint3 { [ dup -rot ] } } } ] [ \ lint3 lint-word ] unit-test
