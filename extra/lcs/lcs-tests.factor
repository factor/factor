! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test lcs ;

[ 3 ] [ "sitting" "kitten" levenshtein ] unit-test
[ 3 ] [ "kitten" "sitting" levenshtein ] unit-test
[ 1 ] [ "freshpak" "freshpack" levenshtein ] unit-test
[ 1 ] [ "freshpack" "freshpak" levenshtein ] unit-test

! [ "hell" ] [ "hello" "hell" lcs ] unit-test
! [ "hell" ] [ "hell" "hello" lcs ] unit-test
[ "ell" ] [ "ell" "hell" lcs ] unit-test
[ "ell" ] [ "hell" "ell" lcs ] unit-test
! [ "abd" ] [ "faxbcd" "abdef" lcs ] unit-test
