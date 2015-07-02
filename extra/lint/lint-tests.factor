USING: io lint kernel math sequences tools.test ;
IN: lint.tests

! Don't write code like this
: lint1 ( obj -- ) [ "hi" print ] [ ] if ; ! when

{ { { lint1 { [ [ ] if ] } } } } [ \ lint1 lint-word ] unit-test

! : lint2 ( a b -- b a b ) dup -rot ; ! tuck

! [ { { lint2 { [ dup -rot ] } } } ] [ \ lint2 lint-word ] unit-test

: lint3 ( seq -- seq ) [ 0 swap nth 1 + ] map ;

{ { { lint3 { [ 0 swap nth ] } } } } [ \ lint3 lint-word ] unit-test
