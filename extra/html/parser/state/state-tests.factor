USING: tools.test html.parser.state ascii kernel ;
IN: html.parser.state.tests

: take-rest ( -- string )
    [ f ] take-until ;

: take-char ( -- string )
    [ get-char = ] curry take-until ;

[ "hello" ] [ "hello" [ take-rest ] string-parse ] unit-test
[ "hi" " how are you?" ] [ "hi how are you?" [ [ get-char blank? ] take-until take-rest ] string-parse ] unit-test
[ "foo" ";bar" ] [ "foo;bar" [ CHAR: ; take-char take-rest ] string-parse ] unit-test
! [ "foo " " bar" ] [ "foo and bar" [ "and" take-string take-rest ] string-parse ] unit-test
