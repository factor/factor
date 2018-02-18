! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel tools.test peg peg.javascript.ast
peg.javascript.tokenizer accessors ;

{
  V{
    T{ ast-number f 123 }
    ";"
    T{ ast-string f "hello" }
    ";"
    T{ ast-name f "foo" }
    "("
    T{ ast-name f "x" }
    ")"
    ";"
  }
} [
  "123; 'hello'; foo(x);" tokenize-javascript
] unit-test

{ V{ T{ ast-regexp f "<(w+)[^>]*?)/>" "g" } } } [
  "/<(\\w+)[^>]*?)\\/>/g" tokenize-javascript
] unit-test

{
    V{ T{ ast-string { value "abc\"def\"" } } }
} [ "\"abc\\\"def\\\"\"" tokenize-javascript ] unit-test

{
    V{ T{ ast-string { value "\b\f\n\r\t\v'\"\\" } } }
} [ "\"\\b\\f\\n\\r\\t\\v\\'\\\"\\\\\"" tokenize-javascript ] unit-test

{
    V{ T{ ast-string { value "abc" } } }
} [ "\"\\x61\\u0062\\u{63}\"" tokenize-javascript ] unit-test
