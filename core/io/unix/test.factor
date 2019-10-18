USING: io-internals test unix-internals ;
IN: temporary

[ "127.0.0.1" ] [ HEX: 07f000001 htonl inet-ntoa ] unit-test
