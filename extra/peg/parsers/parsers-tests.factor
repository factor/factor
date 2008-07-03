USING: kernel peg peg.parsers tools.test accessors ;
IN: peg.parsers.tests

{ V{ "a" } }
[ "a" "a" token "," token list-of parse ast>> ] unit-test

{ V{ "a" "a" "a" "a" } }
[ "a,a,a,a" "a" token "," token list-of parse ast>> ] unit-test

[ "a" "a" token "," token list-of-many parse ] must-fail

{ V{ "a" "a" "a" "a" } }
[ "a,a,a,a" "a" token "," token list-of-many parse ast>> ] unit-test

[ "aaa" "a" token 4 exactly-n parse ] must-fail

{ V{ "a" "a" "a" "a" } }
[ "aaaa" "a" token 4 exactly-n parse ast>> ] unit-test

[ "aaa" "a" token 4 at-least-n parse ] must-fail

{ V{ "a" "a" "a" "a" } }
[ "aaaa" "a" token 4 at-least-n parse ast>> ] unit-test

{ V{ "a" "a" "a" "a" "a" } }
[ "aaaaa" "a" token 4 at-least-n parse ast>> ] unit-test

{ V{ "a" "a" "a" "a" } }
[ "aaaa" "a" token 4 at-most-n parse ast>> ] unit-test

{ V{ "a" "a" "a" "a" } }
[ "aaaaa" "a" token 4 at-most-n parse ast>> ] unit-test

{ V{ "a" "a" "a" } }
[ "aaa" "a" token 3 4 from-m-to-n parse ast>> ] unit-test

{ V{ "a" "a" "a" "a" } }
[ "aaaa" "a" token 3 4 from-m-to-n parse ast>> ] unit-test

{ V{ "a" "a" "a" "a" } }
[ "aaaaa" "a" token 3 4 from-m-to-n parse ast>> ] unit-test

{ 97 }
[ "a" any-char parse ast>> ] unit-test

{ V{ } }
[ "" epsilon parse ast>> ] unit-test

{ "a" } [
  "a" "a" token just parse ast>>
] unit-test