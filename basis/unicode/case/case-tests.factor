! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: unicode tools.test namespaces strings unicode.case
unicode.case.private ;

! FIXME: Unicode 12.1.0 capitalizes the M in I'M too on purpose
! Look into this
! { "Hello How Are You? I’m Good" }
! [ "hEllo how ARE yOU? I’m good" >title ] unit-test

{ "Hello How Are You?" }
[ "hEllo how ARE yOU?" >title ] unit-test


{ "FUSS" } [ "Fu\u0000DF" >upper ] unit-test

{ "\u0003C3a\u0003C2 \u0003C3\u0003C2 \u0003C3a\u0003C2" }
[ "\u0003A3A\u0003A3 \u0003A3\u0003A3 \u0003A3A\u0003A3" >lower ] unit-test

{ t }
[ "hello how are you?" lower? ] unit-test

[
    { f } [ locale get i-dot? ] unit-test
    { f } [ locale get lithuanian? ] unit-test
    "tr" locale set
    { t } [ locale get i-dot? ] unit-test
    { f } [ locale get lithuanian? ] unit-test
    { "i\u000131i \u000131jj" } [ "i\u000131I\u000307 IJj" >lower ] unit-test
    { "I\u000307\u000131i Ijj" } [ "i\u000131I\u000307 IJj" >title ] unit-test
    { "I\u000307II\u000307 IJJ" } [ "i\u000131I\u000307 IJj" >upper ] unit-test
    "lt" locale set
    { f } [ locale get i-dot? ] unit-test
    { t } [ locale get lithuanian? ] unit-test
    { "i\u000307\u000300" } [ 0xCC 1string nfd >lower ] unit-test
    { "\u00012f\u000307" } [ 0x12E 1string nfd >lower nfc ] unit-test
    { "I\u000300" } [ "i\u000307\u000300" >upper ] unit-test
!    [ "I\u000300" ] [ "i\u000307\u000300" >title ] unit-test
] with-scope

{ t } [ "asdf" lower? ] unit-test
{ f } [ "asdF" lower? ] unit-test

{ t } [ "ASDF" upper? ] unit-test
{ f } [ "ASDf" upper? ] unit-test
