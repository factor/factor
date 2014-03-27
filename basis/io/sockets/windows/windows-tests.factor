USING: accessors continuations io.sockets io.sockets.windows kernel sequences tools.test
urls windows.winsock ;
IN: io.sockets.windows.tests

: google-socket ( -- socket )
    URL" http://www.google.com" url-addr resolve-host first
    SOCK_STREAM open-socket ;

{ } [
    google-socket
    { FIONBIO FIONREAD } [
        google-socket swap execute( -- x )
        [ 1 set-ioctl-socket ] [ 0 set-ioctl-socket ] 2bi
    ] each drop
] unit-test

{ t } [
    [ google-socket 1337 -8 set-ioctl-socket ]
    [ [ winsock-exception? ] [ n>> 10045 = ] bi and ] recover
] unit-test
