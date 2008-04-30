! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: lisp lisp.parser tools.test ;

IN: lisp.test

{ [ "aoeu" 2 1 T{ lisp-symbol f "foo" } ] } [
  "(foo 1 2 \"aoeu\")" lisp-string>factor
] unit-test