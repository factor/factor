! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: lisp lisp.parser tools.test sequences math kernel ;

IN: lisp.test

init-env

"+" [ first2 + ] lisp-define

{ [ first2 + ] } [
  "+" lisp-get
] unit-test

{ 3 } [
  "((lambda (x y) (+ x y)) 1 2)" lisp-string>factor call
] unit-test