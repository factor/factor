! Copyright (C) 2009 Phil Dawes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.strings alien.syntax io
io.encodings.utf8 io.files kernel sequences system threads
unix.utilities ;
IN: native-thread-test

FUNCTION: void* start_standalone_factor_in_new_thread ( int argc, c-string* argv ) ;

: start-vm-in-os-thread ( args -- threadhandle )
    vm prefix
    [ length ] [ native-string-encoding strings>alien ] bi 
    start_standalone_factor_in_new_thread ;

: start-tetris-in-os-thread ( -- )
    { "-run=tetris" } start-vm-in-os-thread drop ;

: start-test-thread-in-os-thread ( -- )
    { "-run=native-thread-test" } start-vm-in-os-thread drop ;

: test-thread ( -- )
    "/tmp/hello" utf8 [ "hello!\n" write ] with-file-appender 5000000 sleep ;

MAIN: test-thread
