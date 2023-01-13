USING: tools.test xml.tokenize xml.state io.streams.string kernel io strings ascii ;
IN: xml.test.state

: string-parse ( str quot -- )
    [ <string-reader> ] dip with-state ; inline

: take-rest ( -- string )
    [ drop f ] take-until ;

: take-char ( char -- string )
    1string take-to ;

{ "hello" } [ "hello" [ take-rest ] string-parse ] unit-test
{ 2 3 } [ "12\n123" [ take-rest drop get-line get-column ] string-parse ] unit-test
{ "hi" " how are you?" } [ "hi how are you?" [ [ blank? ] take-until take-rest ] string-parse ] unit-test
{ "foo" ";bar" } [ "foo;bar" [ CHAR: ; take-char take-rest ] string-parse ] unit-test
{ "foo " " bar" } [ "foo and bar" [ "and" take-string take-rest ] string-parse ] unit-test
{ "baz" } [ " \n\t baz" [ pass-blank take-rest ] string-parse ] unit-test
