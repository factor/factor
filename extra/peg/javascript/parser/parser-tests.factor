! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.javascript.ast peg.javascript.tokenizer  
       peg.javascript.parser accessors ;
IN: peg.javascript.parser.tests

\ javascript must-infer

{
  T{
      ast-begin
      f
      V{
          T{ ast-number f 123 }
          T{ ast-string f "hello" }
          T{
              ast-call
              f
              T{ ast-get f "foo" }
              V{ T{ ast-get f "x" } }
          }
      }
  }
} [
  "123; 'hello'; foo(x);" tokenizer ast>> javascript ast>>
] unit-test