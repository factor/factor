! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: lisp.parser tools.test peg peg.ebnf ;

IN: lisp.parser.tests

{ 1234  }  [
  "1234" "atom" \ lisp-expr rule parse parse-result-ast
] unit-test

{ 123.98 } [
  "123.98" "atom" \ lisp-expr rule parse parse-result-ast
] unit-test

{ "" } [
  "\"\"" "atom" \ lisp-expr rule parse parse-result-ast
] unit-test

{ "aoeu" } [
  "\"aoeu\"" "atom" \ lisp-expr rule parse parse-result-ast
] unit-test

{ "aoeu\"de" } [
  "\"aoeu\\\"de\"" "atom" \ lisp-expr rule parse parse-result-ast
] unit-test

{ T{ lisp-symbol f "foobar" } } [
  "foobar" "atom" \ lisp-expr rule parse parse-result-ast
] unit-test

{ T{ lisp-symbol f "+" } } [
  "+" "atom" \ lisp-expr rule parse parse-result-ast
] unit-test

{ T{ s-exp f
     V{ T{ lisp-symbol f "foo" } 1 2 "aoeu" } } } [
  "(foo 1 2 \"aoeu\")" lisp-expr parse-result-ast
] unit-test