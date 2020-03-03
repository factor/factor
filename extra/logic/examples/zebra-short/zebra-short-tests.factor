! Copyright (C) 2019 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test logic logic.examples.zebra-short ;
IN: logic.examples.zebra-short.tests

{
    { H{ { X japanese } } H{ { X japanese } } }
}
[ { zebrao X } query ] unit-test

