! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test quoting ;
IN: quoting.tests

[ f ] [ "" quoted? ] unit-test
[ t ] [ "''" quoted? ] unit-test
[ t ] [ "\"\"" quoted? ] unit-test
[ t ] [ "\"Circus Maximus\"" quoted? ] unit-test
[ t ] [ "'Circus Maximus'" quoted? ] unit-test
[ f ] [ "Circus Maximus" quoted? ] unit-test
