! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test boyer-moore ;
IN: boyer-moore.tests

[ 0 ] [ "qwerty" "" search ] unit-test
[ 0 ] [ "" "" search ] unit-test
[ f ] [ "qw" "qwerty" search ] unit-test
[ 3 ] [ "qwerty" "r" search ] unit-test
[ 8 ] [ "qwerasdfqwer" 2 "qwe" search-from ] unit-test
