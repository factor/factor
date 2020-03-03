! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factlog factlog.examples.factorial ;
IN: factlog.examples.factorial.tests

{ { H{ { F 1 } } } } [ { factorial 0 F } query ] unit-test

{ { H{ { F 1 } } } } [ { factorial 1 F } query ] unit-test

{ { H{ { F 2 } } } } [ { factorial 2 F } query ] unit-test

{ { H{ { F 3628800 } } } } [ { factorial 10 F } query ] unit-test
