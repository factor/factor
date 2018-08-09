USING: ascii kernel math sequences strings tools.test ;

{ t } [ ch'a letter? ] unit-test
{ f } [ ch'A letter? ] unit-test
{ f } [ ch'a LETTER? ] unit-test
{ t } [ ch'A LETTER? ] unit-test
{ t } [ ch'0 digit? ] unit-test
{ f } [ ch'x digit? ] unit-test

{ 4 } [
    0 "There are Four Upper Case characters"
    [ LETTER? [ 1 + ] when ] each
] unit-test

{ t f } [ ch'\s ascii? 400 ascii? ] unit-test

{ "HELLO HOW ARE YOU?" } [ "hellO hOw arE YOU?" >upper ] unit-test
{ "i'm good thx bai" } [ "I'm Good THX bai" >lower ] unit-test

{ "Hello How Are You?" } [ "hEllo how ARE yOU?" >title ] unit-test
{ { " " "Hello" " " " " " " "World" } } [ " Hello   World" >words [ >string ] map ] unit-test
