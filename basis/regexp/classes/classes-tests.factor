! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: regexp.classes tools.test arrays kernel ;
IN: regexp.classes.tests

[ f ] [ { 1 2 } <and-class> ] unit-test
[ T{ or-class f { 2 1 } } ] [ { 1 2 } <or-class> ] unit-test
[ 3 ] [ { 1 2 } <and-class> 3 2array <or-class> ] unit-test
[ CHAR: A ] [ CHAR: A LETTER-class <primitive-class> 2array <and-class> ] unit-test
[ CHAR: A ] [ LETTER-class <primitive-class> CHAR: A 2array <and-class> ] unit-test
[ T{ primitive-class { class LETTER-class } } ] [ CHAR: A LETTER-class <primitive-class> 2array <or-class> ] unit-test
[ T{ primitive-class { class LETTER-class } } ] [ LETTER-class <primitive-class> CHAR: A 2array <or-class> ] unit-test
[ t ] [ { t 1 } <or-class> ] unit-test
[ t ] [ { 1 t } <or-class> ] unit-test
[ f ] [ { f 1 } <and-class> ] unit-test
[ f ] [ { 1 f } <and-class> ] unit-test
[ 1 ] [ { f 1 } <or-class> ] unit-test
[ 1 ] [ { 1 f } <or-class> ] unit-test
[ 1 ] [ { t 1 } <and-class> ] unit-test
[ 1 ] [ { 1 t } <and-class> ] unit-test
[ 1 ] [ 1 <not-class> <not-class> ] unit-test
[ 1 ] [ { 1 1 } <and-class> ] unit-test
[ 1 ] [ { 1 1 } <or-class> ] unit-test
[ T{ primitive-class { class letter-class } } ] [ letter-class <primitive-class> dup 2array <and-class> ] unit-test
[ T{ primitive-class { class letter-class } } ] [ letter-class <primitive-class> dup 2array <or-class> ] unit-test
[ T{ or-class { seq { 2 3 1 } } } ] [ { 1 2 } <or-class> { 2 3 } <or-class> 2array <or-class> ] unit-test
