! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg.javascript peg.javascript.ast accessors ;
IN: peg.javascript.tests

\ parse-javascript must-infer

{ T{ ast-begin f V{ T{ ast-number f 123 } } } } [
  "123;" parse-javascript
] unit-test