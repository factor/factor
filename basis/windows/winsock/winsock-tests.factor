USING: kernel tools.test windows.winsock ;
IN: windows.winsock.tests

: normal-socket ( -- socket )
    AF_INET SOCK_STREAM IPPROTO_TCP socket ;

{ t f } [
    98 97 96 socket normal-socket [ INVALID_SOCKET = ] bi@
] unit-test

{ 0 } [ normal-socket closesocket ] unit-test

! Generate lots of socket errors
{ t t t } [
    normal-socket 99 98 "bad bad!" 3 setsockopt
    f closesocket
    normal-socket "hello" 5 0 send
    [ SOCKET_ERROR = ] tri@
] unit-test
