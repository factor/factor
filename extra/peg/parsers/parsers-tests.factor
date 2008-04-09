USING: kernel peg peg.parsers tools.test ;
IN: peg.parsers.tests

[ V{ "a" } ]
[ "a" "a" token "," token list-of parse parse-result-ast ] unit-test

[ V{ "a" "a" "a" "a" } ]
[ "a,a,a,a" "a" token "," token list-of parse parse-result-ast ] unit-test

[ f ]
[ "a" "a" token "," token list-of-many parse ] unit-test

[ V{ "a" "a" "a" "a" } ]
[ "a,a,a,a" "a" token "," token list-of-many parse parse-result-ast ] unit-test

[ f ]
[ "aaa" "a" token 4 exactly-n parse ] unit-test

[ V{ "a" "a" "a" "a" } ]
[ "aaaa" "a" token 4 exactly-n parse parse-result-ast ] unit-test

[ f ]
[ "aaa" "a" token 4 at-least-n parse ] unit-test

[ V{ "a" "a" "a" "a" } ]
[ "aaaa" "a" token 4 at-least-n parse parse-result-ast ] unit-test

[ V{ "a" "a" "a" "a" "a" } ]
[ "aaaaa" "a" token 4 at-least-n parse parse-result-ast ] unit-test

[ V{ "a" "a" "a" "a" } ]
[ "aaaa" "a" token 4 at-most-n parse parse-result-ast ] unit-test

[ V{ "a" "a" "a" "a" } ]
[ "aaaaa" "a" token 4 at-most-n parse parse-result-ast ] unit-test

[ V{ "a" "a" "a" } ]
[ "aaa" "a" token 3 4 from-m-to-n parse parse-result-ast ] unit-test

[ V{ "a" "a" "a" "a" } ]
[ "aaaa" "a" token 3 4 from-m-to-n parse parse-result-ast ] unit-test

[ V{ "a" "a" "a" "a" } ]
[ "aaaaa" "a" token 3 4 from-m-to-n parse parse-result-ast ] unit-test

[ 97 ]
[ "a" any-char parse parse-result-ast ] unit-test

[ V{ } ]
[ "" epsilon parse parse-result-ast ] unit-test

{ "a" } [
  "a" "a" token just parse parse-result-ast
] unit-test