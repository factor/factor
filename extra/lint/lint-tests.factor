USING: io lint kernel math tools.test ;
IN: temporary

! Don't write code like this
: lint1
    [ "hi" print ] [ ] if ; ! when

[ { [ [ ] if ] } ] [ \ lint1 lint ] unit-test

: lint2
    1 + ; ! 1+
[ { [ 1 + ] } ] [ \ lint2 lint ] unit-test

: lint3
    dup -rot ; ! tuck

[ { [ dup -rot ] } ] [ \ lint3 lint ] unit-test

