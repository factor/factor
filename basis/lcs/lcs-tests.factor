! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test lcs ;

{ 3 } [ "sitting" "kitten" levenshtein ] unit-test
{ 3 } [ "kitten" "sitting" levenshtein ] unit-test
{ 1 } [ "freshpak" "freshpack" levenshtein ] unit-test
{ 1 } [ "freshpack" "freshpak" levenshtein ] unit-test

{ "hell" } [ "hello" "hell" lcs ] unit-test
{ "hell" } [ "hell" "hello" lcs ] unit-test
{ "ell" } [ "ell" "hell" lcs ] unit-test
{ "ell" } [ "hell" "ell" lcs ] unit-test
{ "abd" } [ "faxbcd" "abdef" lcs ] unit-test

{ {
        T{ delete f char: f }
        T{ retain f char: a }
        T{ delete f char: x }
        T{ retain f char: b }
        T{ delete f char: c }
        T{ retain f char: d }
        T{ insert f char: e }
        T{ insert f char: f }
} } [ "faxbcd" "abdef" lcs-diff ] unit-test
