! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test logic logic.examples.factorial ;

{ { H{ { F 1 } } } } [ { factorial 0 F } query ] unit-test

{ { H{ { F 1 } } } } [ { factorial 1 F } query ] unit-test

{ { H{ { F 2 } } } } [ { factorial 2 F } query ] unit-test

{ { H{ { F 3628800 } } } } [ { factorial 10 F } query ] unit-test
