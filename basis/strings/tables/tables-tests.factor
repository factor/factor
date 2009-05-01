! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test strings.tables ;
IN: strings.tables.tests

[ { "A  BB" "CC D" } ] [ { { "A" "BB" } { "CC" "D" } } format-table ] unit-test

[ { "A C" "B " "D E" } ] [ { { "A\nB" "C" } { "D" "E" } } format-table ] unit-test