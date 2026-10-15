USING: kernel sequences tools.test unix.ffi ;
IN: unix.ffi.haiku.network.tests

{ 0x1234 } [ 0x1234 htons ntohs ] unit-test
{ 0x12345678 } [ 0x12345678 htonl ntohl ] unit-test
{ { 0 1 0x1234 0xffff 0 0xffff } } [
    { 0 1 0x1234 0xffff 0x10000 -1 } [ htons ntohs ] map
] unit-test
{ { 0 1 0x12345678 0xffffffff 0 0xffffffff } } [
    { 0 1 0x12345678 0xffffffff 0x100000000 -1 } [ htonl ntohl ] map
] unit-test
