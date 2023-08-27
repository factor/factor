! Copyright (C) 2016 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors alien.c-types alien.data alien.destructors
alien.syntax classes.struct destructors libc sequences sets
sorting ;
IN: ifaddrs

STRUCT: sockaddr
    { sa_len uint8_t }
    { sa_family uint8_t }
    { sa_data char[14] } ;

STRUCT: ifaddrs
    { ifa_next ifaddrs* }
    { ifa_name c-string }
    { ifa_flags uint }
    { ifa_addr sockaddr* }
    { ifa_netmask sockaddr* }
    { ifa_dstaddr sockaddr* }
    { ifa_data void* } ;

FUNCTION: int getifaddrs ( ifaddrs** ifap )

FUNCTION: void freeifaddrs ( ifaddrs* ifp )

DESTRUCTOR: freeifaddrs

: interface-names ( -- ifaddrs )
    [
        { void* } [ getifaddrs io-error ] with-out-parameters
        &freeifaddrs ifaddrs deref
        [ ifa_next>> ] follow
        [ ifa_name>> ] map members sort
    ] with-destructors ;
