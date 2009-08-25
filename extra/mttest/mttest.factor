USING: alien.syntax io io.encodings.utf16n io.encodings.utf8 io.files
kernel namespaces sequences system threads unix.utilities ;
IN: mttest

FUNCTION: void* start_standalone_factor_in_new_thread ( int argc, char** argv ) ;

HOOK: native-string-encoding os ( -- encoding )
M: windows native-string-encoding utf16n ;
M: unix native-string-encoding utf8 ;

: start-vm-in-os-thread ( args -- threadhandle )
    \ vm get-global prefix 
    [ length ] [ native-string-encoding strings>alien ] bi 
     start_standalone_factor_in_new_thread ;

: start-tetris-in-os-thread ( -- )
     { "-run=tetris" } start-vm-in-os-thread drop ;

: start-testthread-in-os-thread ( -- )
     { "-run=mttest" } start-vm-in-os-thread drop ;
 
: testthread ( -- )
     "/tmp/hello" utf8 [ "hello!\n" write ] with-file-appender 5000000 sleep ;

MAIN: testthread