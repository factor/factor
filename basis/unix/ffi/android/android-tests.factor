USING: alien.c-types classes.struct tools.test unix.ffi ;
IN: unix.ffi.android.tests

{ 48 8 } [ addrinfo heap-size addrinfo c-type-align ] unit-test
{ 24 32 40 } [
    "canonname" addrinfo offset-of
    "addr" addrinfo offset-of
    "next" addrinfo offset-of
] unit-test

{ 11 0x0008 0x0800 0x0100 0x0400 } [
    EAI_SYSTEM AI_NUMERICSERV AI_V4MAPPED AI_ALL AI_ADDRCONFIG
] unit-test
