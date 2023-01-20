! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test quoting ;

{ f } [ "" quoted? ] unit-test
{ t } [ "''" quoted? ] unit-test
{ t } [ "\"\"" quoted? ] unit-test
{ t } [ "\"Circus Maximus\"" quoted? ] unit-test
{ t } [ "'Circus Maximus'" quoted? ] unit-test
{ f } [ "Circus Maximus" quoted? ] unit-test
