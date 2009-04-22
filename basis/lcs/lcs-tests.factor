! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test lcs ;

[ 3 ] [ "sitting" "kitten" levenshtein ] unit-test
[ 3 ] [ "kitten" "sitting" levenshtein ] unit-test
[ 1 ] [ "freshpak" "freshpack" levenshtein ] unit-test
[ 1 ] [ "freshpack" "freshpak" levenshtein ] unit-test

[ "hell" ] [ "hello" "hell" lcs ] unit-test
[ "hell" ] [ "hell" "hello" lcs ] unit-test
[ "ell" ] [ "ell" "hell" lcs ] unit-test
[ "ell" ] [ "hell" "ell" lcs ] unit-test
[ "abd" ] [ "faxbcd" "abdef" lcs ] unit-test

[ {
        T{ delete f CHAR: f }
        T{ retain f CHAR: a }
        T{ delete f CHAR: x }
        T{ retain f CHAR: b }
        T{ delete f CHAR: c }
        T{ retain f CHAR: d }
        T{ insert f CHAR: e }
        T{ insert f CHAR: f }
} ] [ "faxbcd" "abdef" diff ] unit-test
