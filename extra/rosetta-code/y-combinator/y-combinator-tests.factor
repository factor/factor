USING: kernel tools.test ;
IN: rosetta-code.y-combinator

{ 120 } [ 5 [ almost-fac ] Y call ] unit-test
{ 8 }   [ 6 [ almost-fib ] Y call ] unit-test
{ 61 }  [ 3 3 [ almost-ack ] Y call ] unit-test
