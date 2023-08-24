! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test logic logic.examples.zebra-short ;

{
    { H{ { X japanese } } H{ { X japanese } } }
}
[ { zebrao X } query ] unit-test
