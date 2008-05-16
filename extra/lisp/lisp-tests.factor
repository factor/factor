! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: lisp lisp.parser tools.test sequences math kernel parser ;

IN: lisp.test

init-env

"+" "math" "+" define-primitve

{ 5 } [
  [ 2 3 ] "+" <lisp-symbol> funcall
] unit-test

{ 3 } [
  "((lambda (x y) (+ x y)) 1 2)" lisp-string>factor call
] unit-test