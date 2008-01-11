USING: unicode.case tools.test namespaces ;

[ "Hello How Are You? I'M Good" ] [ "hEllo how ARE yOU? I'm good" >title ] unit-test
[ "FUSS" ] [ "Fu\u00DF" >upper ] unit-test
[ "\u03C3\u03C2" ] [ "\u03A3\u03A3" >lower ] unit-test
[ t ] [ "hello how are you?" lower? ] unit-test
[
    "tr" locale set
    [ "i\u0131i \u0131jj" ] [ "i\u0131I\u0307 IJj" >lower ] unit-test
!    [ "I\u307\u0131i Ijj" ] [ "i\u0131I\u0307 IJj" >title ] unit-test
    [ "I\u0307II\u0307 IJJ" ] [ "i\u0131I\u0307 IJj" >upper ] unit-test
    "lt" locale set
    ! Lithuanian casing tests
] with-scope
