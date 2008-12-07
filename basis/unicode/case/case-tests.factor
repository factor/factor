USING: unicode.case tools.test namespaces ;

\ >upper must-infer
\ >lower must-infer
\ >title must-infer

[ "Hello How Are You? I'M Good" ] [ "hEllo how ARE yOU? I'm good" >title ] unit-test
[ "FUSS" ] [ "Fu\u0000DF" >upper ] unit-test
[ "\u0003C3\u0003C2" ] [ "\u0003A3\u0003A3" >lower ] unit-test
[ t ] [ "hello how are you?" lower? ] unit-test
[
    "tr" locale set
    [ "i\u000131i \u000131jj" ] [ "i\u000131I\u000307 IJj" >lower ] unit-test
!    [ "I\u00307\u000131i Ijj" ] [ "i\u000131I\u000307 IJj" >title ] unit-test
    [ "I\u000307II\u000307 IJJ" ] [ "i\u000131I\u000307 IJj" >upper ] unit-test
    "lt" locale set
    ! Lithuanian casing tests
] with-scope

[ t ] [ "asdf" lower? ] unit-test
[ f ] [ "asdF" lower? ] unit-test

[ t ] [ "ASDF" upper? ] unit-test
[ f ] [ "ASDf" upper? ] unit-test
