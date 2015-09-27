USING: tools.test wordtimer math kernel tools.annotations prettyprint ;
IN: wordtimer.tests

: testfn ( a b c d -- a+b c+d )
  + [ + ] dip ;

{ 3 7 }
[ reset-word-timer
  \ testfn [ reset ] [ add-timer ] bi
  1 2 3 4 testfn ] unit-test
