! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: regexp.classes tools.test arrays kernel ;
IN: regexp.classes.tests

! Class algebra

{ f } [ { 1 2 } <and-class> ] unit-test
{ T{ or-class f { 1 2 } } } [ { 1 2 } <or-class> ] unit-test
{ 3 } [ { 1 2 } <and-class> 3 2array <or-class> ] unit-test
{ CHAR: A } [ CHAR: A LETTER-class <primitive-class> 2array <and-class> ] unit-test
{ CHAR: A } [ LETTER-class <primitive-class> CHAR: A 2array <and-class> ] unit-test
{ T{ primitive-class { class LETTER-class } } } [ CHAR: A LETTER-class <primitive-class> 2array <or-class> ] unit-test
{ T{ primitive-class { class LETTER-class } } } [ LETTER-class <primitive-class> CHAR: A 2array <or-class> ] unit-test
{ t } [ { t 1 } <or-class> ] unit-test
{ t } [ { 1 t } <or-class> ] unit-test
{ f } [ { f 1 } <and-class> ] unit-test
{ f } [ { 1 f } <and-class> ] unit-test
{ 1 } [ { f 1 } <or-class> ] unit-test
{ 1 } [ { 1 f } <or-class> ] unit-test
{ 1 } [ { t 1 } <and-class> ] unit-test
{ 1 } [ { 1 t } <and-class> ] unit-test
{ 1 } [ 1 <not-class> <not-class> ] unit-test
{ 1 } [ { 1 1 } <and-class> ] unit-test
{ 1 } [ { 1 1 } <or-class> ] unit-test
{ t } [ { t t } <or-class> ] unit-test
{ T{ primitive-class { class letter-class } } } [ letter-class <primitive-class> dup 2array <and-class> ] unit-test
{ T{ primitive-class { class letter-class } } } [ letter-class <primitive-class> dup 2array <or-class> ] unit-test
{ T{ or-class { seq { 1 2 3 } } } } [ { 1 2 } <or-class> { 2 3 } <or-class> 2array <or-class> ] unit-test
{ T{ or-class { seq { 2 3 } } } } [ { 2 3 } <or-class> 1 <not-class> 2array <and-class> ] unit-test
{ f } [ t <not-class> ] unit-test
{ t } [ f <not-class> ] unit-test
{ f } [ 1 <not-class> 1 t answer ] unit-test
{ t } [ { 1 2 } <or-class> <not-class> 1 2 3array <or-class> ] unit-test
{ f } [ { 1 2 } <and-class> <not-class> 1 2 3array <and-class> ] unit-test

! Making classes into nested conditionals

{ { 1 2 3 4 } } [ T{ and-class f { 1 T{ not-class f 2 } T{ or-class f { 3 4 } } 2 } } class>questions ] unit-test
{ { 3 } } [ { { 3 t } } table>condition ] unit-test
{ { T{ primitive-class } } } [ { { 1 t } { 2 T{ primitive-class } } } table>questions ] unit-test
{ { { 1 t } { 2 t } } } [ { { 1 t } { 2 T{ primitive-class } } } T{ primitive-class } t assoc-answer ] unit-test
{ { { 1 t } } } [ { { 1 t } { 2 T{ primitive-class } } } T{ primitive-class } f assoc-answer ] unit-test
{ T{ condition f T{ primitive-class } { 1 2 } { 1 } } } [ { { 1 t } { 2 T{ primitive-class } } } table>condition ] unit-test

SYMBOL: foo
SYMBOL: bar

{ T{ condition f T{ primitive-class f bar } T{ condition f T{ primitive-class f foo } { 1 3 2 } { 1 3 } } T{ condition f T{ primitive-class f foo } { 1 2 } { 1 } } } } [ { { 1 t } { 3 T{ primitive-class f bar } } { 2 T{ primitive-class f foo } } } table>condition ] unit-test

{ t } [ foo <primitive-class> dup t answer ] unit-test
{ f } [ foo <primitive-class> dup f answer ] unit-test
{ T{ primitive-class f foo } } [ foo <primitive-class> bar <primitive-class> t answer ] unit-test
{ T{ primitive-class f foo } } [ foo <primitive-class> bar <primitive-class> f answer ] unit-test
{ T{ primitive-class f foo } } [ foo <primitive-class> bar <primitive-class> 2array <and-class> bar <primitive-class> t answer ] unit-test
{ T{ primitive-class f bar } } [ foo <primitive-class> bar <primitive-class> 2array <and-class> foo <primitive-class> t answer ] unit-test
{ f } [ foo <primitive-class> bar <primitive-class> 2array <and-class> foo <primitive-class> f answer ] unit-test
{ f } [ foo <primitive-class> bar <primitive-class> 2array <and-class> bar <primitive-class> f answer ] unit-test
{ t } [ foo <primitive-class> bar <primitive-class> 2array <or-class> bar <primitive-class> t answer ] unit-test
{ T{ primitive-class f foo } } [ foo <primitive-class> bar <primitive-class> 2array <or-class> bar <primitive-class> f answer ] unit-test
