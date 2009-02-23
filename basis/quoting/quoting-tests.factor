! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test quoting ;
IN: quoting.tests


[ "abc" ] [ "'abc'" unquote ] unit-test
[ "abc" ] [ "\"abc\"" unquote ] unit-test
[ "'abc" ] [ "'abc" unquote ] unit-test
[ "abc'" ] [ "abc'" unquote ] unit-test
