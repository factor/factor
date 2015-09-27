! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test kernel unicode.categories words sequences unicode.data ;
IN: unicode.categories.tests

{ { f f t t f t t f f t } } [ CHAR: A {
    blank? letter? LETTER? Letter? digit?
    printable? alpha? control? uncased? character?
} [ execute ] with map ] unit-test
{ "Nd" } [ CHAR: 3 category ] unit-test
{ "Lo" } [ 0x3400 category ] unit-test
{ "Lo" } [ 0x3450 category ] unit-test
{ "Lo" } [ 0x4DB5 category ] unit-test
{ "Cs" } [ 0xDD00 category ] unit-test
{ t } [ CHAR: \t blank? ] unit-test
{ t } [ CHAR: \s blank? ] unit-test
{ t } [ CHAR: \r blank? ] unit-test
{ t } [ CHAR: \n blank? ] unit-test
{ f } [ CHAR: a blank? ] unit-test
