! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: levenshtein
USING: test ;

[ 3 ] [ "sitting" "kitten" levenshtein ] unit-test
[ 3 ] [ "kitten" "sitting" levenshtein ] unit-test
[ 1 ] [ "freshpak" "freshpack" levenshtein ] unit-test
[ 1 ] [ "freshpack" "freshpak" levenshtein ] unit-test
