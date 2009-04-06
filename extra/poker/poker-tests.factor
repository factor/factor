USING: accessors poker poker.private tools.test ;
IN: poker.tests

[ 134236965 ] [ "KD" >ckf ] unit-test
[ 529159 ] [ "5s" >ckf ] unit-test
[ 33589533 ] [ "jc" >ckf ] unit-test


[ 7462 ] [ "7C 5D 4H 3S 2C" <hand> value>> ] unit-test
[ 1601 ] [ "KD QS JC TH 9S" <hand> value>> ] unit-test
[ 11 ] [ "AC AD AH AS KC" <hand> value>> ] unit-test
[ 9 ] [ "6C 5C 4C 3C 2C" <hand> value>> ] unit-test
[ 1 ] [ "AC KC QC JC TC" <hand> value>> ] unit-test

[ "High Card" ] [ "7C 5D 4H 3S 2C" <hand> >value ] unit-test
[ "Straight" ] [ "KD QS JC TH 9S" <hand> >value ] unit-test
[ "Four of a Kind" ] [ "AC AD AH AS KC" <hand> >value ] unit-test
[ "Straight Flush" ] [ "6C 5C 4C 3C 2C" <hand> >value ] unit-test
