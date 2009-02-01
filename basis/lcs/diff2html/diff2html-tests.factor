! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: lcs.diff2html lcs kernel tools.test strings sequences xml.writer ;
IN: lcs.diff2html.tests

[ ] [ "hello" "heyo" [ 1string ] { } map-as diff htmlize-diff xml>string drop ] unit-test
