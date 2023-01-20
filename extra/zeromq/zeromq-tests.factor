! Copyright (C) 2011-2013 Eungju PARK, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: destructors sequences tools.test zeromq ;

{ t } [
    zmq-msg-size { 32 48 64 } member?
] unit-test


{ B{ 0 1 10 33 244 255 } } [
    B{ 0 1 10 33 244 255 } byte-array>zmq-message
    [ zmq-message>byte-array ] with-disposal
] unit-test
