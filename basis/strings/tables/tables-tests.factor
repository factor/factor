! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test strings.tables ;

{ { } } [ { } format-table ] unit-test

{ { "A  BB" "CC D" } } [ { { "A" "BB" } { "CC" "D" } } format-table ] unit-test

{ { "A C" "B " "D E" } } [ { { "A\nB" "C" } { "D" "E" } } format-table ] unit-test

{ { "A B" "  C" "D E" } } [ { { "A" "B\nC" } { "D" "E" } } format-table ] unit-test

{ { "A B" "C D" "  E" } } [ { { "A" "B" } { "C" "D\nE" } } format-table ] unit-test

{ { "┌───┬───┐" "│ A │ B │" "├───┼───┤" "│ C │ D │" "└───┴───┘" } }
[ { { "A" "B" } { "C" "D" } } format-box ] unit-test

