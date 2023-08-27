! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test core-graphics kernel images ;
IN: core-graphics.tests

{ t } [ { 100 200 } [ drop ] make-bitmap-image image? ] unit-test

{ } [ dummy-context drop ] unit-test
