USING: tools.test peg-lexer.test-parsers ;
IN: peg-lexer.tests

{ V{ "1234" "-end" } } [
   test1 1234-end
] unit-test

{ V{ 1234 53 } } [
   test2 12345
] unit-test

{ V{ "heavy" "duty" "testing" } } [
   test3 heavy duty testing
] unit-test