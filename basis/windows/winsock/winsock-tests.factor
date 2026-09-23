USING: kernel sequences system tools.test windows.winsock ;
IN: windows.winsock.tests

{ t } [ <wsadata> length cpu x86.32? 400 408 ? = ] unit-test

! WSASend takes flags by value; an invalid socket exercises argument marshalling.
{ -1 } [ INVALID_SOCKET f 0 f 0 f f WSASend ] unit-test

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
