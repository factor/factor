! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.javascript.ast peg.javascript.tokenizer accessors ;
IN: peg.javascript.tokenizer.tests

\ tokenize-javascript must-infer

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
  "123; 'hello'; foo(x);" tokenize-javascript ast>>
] unit-test

{ V{ T{ ast-regexp f "<(w+)[^>]*?)/>" "g" } } } [
  "/<(\\w+)[^>]*?)\\/>/g" tokenize-javascript ast>>
] unit-test