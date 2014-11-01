! Copyright (C) 2011-2013 Eungju PARK, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: destructors kernel tools.test ;

IN: zeromq

{ B{ 0 1 10 33 244 255 } } [
    B{ 0 1 10 33 244 255 } byte-array>zmq-message
    [ zmq-message>byte-array ] with-disposal
] unit-test
