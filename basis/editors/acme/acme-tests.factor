! Copyright (C) 2020 Fred Alger.
! See https://factorcode.org/license.txt for BSD license.
USING: editors.acme environment namespaces tools.test ;
IN: editors.acme.tests

{ "/plan9" } [ "/plan9" \ plan9-path [ plan9-path ] with-variable ] unit-test

{ "/plan9env" } [ f \ plan9-path [
 "/plan9env" "PLAN9" [ plan9-path ] with-os-env ] with-variable ] unit-test

{ "/usr/local/plan9" } [ f \ plan9-path [
 f "PLAN9" [ plan9-path ] with-os-env ] with-variable ] unit-test

