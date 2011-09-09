USING: system-info.linux strings splitting sequences
tools.test ;
IN: system-info.linux.tests

[ 6 ] [ uname length ] unit-test

[ t ] [ sysname    string? ] unit-test
[ t ] [ nodename   string? ] unit-test
[ t ] [ release    string? ] unit-test
[ t ] [ version    string? ] unit-test
[ t ] [ machine    string? ] unit-test
[ t ] [ domainname string? ] unit-test

[ t ] [
    release "." split1 drop { "2" "3" } member?
] unit-test
