! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.javascript.ast peg.javascript.tokenizer accessors ;
IN: peg.javascript.tokenizer.tests

\ tokenizer must-infer

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
  "123; 'hello'; foo(x);" tokenizer ast>>
] unit-test
