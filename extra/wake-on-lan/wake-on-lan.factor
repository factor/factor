! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays destructors io.sockets kernel math.parser
sequences splitting ;

IN: wake-on-lan

<PRIVATE

: mac-address-bytes ( mac-address -- byte-array )
    ":-" split [ hex> ] B{ } map-as ;

: wake-on-lan-packet ( mac-address -- byte-array )
    [ 16 ] [ mac-address-bytes ] bi* <array> concat
    B{ 0xff 0xff 0xff 0xff 0xff 0xff } prepend ;

PRIVATE>

: wake-on-lan ( mac-address broadcast-ip -- )
    [ wake-on-lan-packet ] [ 9 <inet4> ] bi*
    broadcast-once ;
