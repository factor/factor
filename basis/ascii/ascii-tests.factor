USING: ascii kernel math sequences strings tools.test ;

{ t } [ char: a letter? ] unit-test
{ f } [ char: A letter? ] unit-test
{ f } [ char: a LETTER? ] unit-test
{ t } [ char: A LETTER? ] unit-test
{ t } [ char: 0 digit? ] unit-test
{ f } [ char: x digit? ] unit-test

{ 4 } [
    0 "There are Four Upper Case characters"
    [ LETTER? [ 1 + ] when ] each
] unit-test

{ t f } [ char: \s ascii? 400 ascii? ] unit-test

{ "HELLO HOW ARE YOU?" } [ "hellO hOw arE YOU?" >upper ] unit-test
{ "i'm good thx bai" } [ "I'm Good THX bai" >lower ] unit-test

{ "Hello How Are You?" } [ "hEllo how ARE yOU?" >title ] unit-test
{ { " " "Hello" " " " " " " "World" } } [ " Hello   World" >words [ >string ] map ] unit-test
