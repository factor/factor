! Copyright (C) 2016 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii checksums checksums.common combinators
destructors io io.encodings.binary io.launcher kernel math.parser
sequences strings ;
IN: checksums.process

TUPLE: checksum-process launch-desc ;
INSTANCE: checksum-process block-checksum
C: <checksum-process> checksum-process

TUPLE: process-state < disposable process result ;

M: checksum-process initialize-checksum-state ( checksum -- checksum-state )
    launch-desc>> binary <process-stream> process-state new-disposable swap >>process ;

M: process-state dispose* ( process-state -- )
    process>> [ dispose ] when* ;

M: process-state add-checksum-bytes ( process-state bytes -- process-state' )
    over process>> stream-write ;

: trim-hash ( str -- str' )
    dup empty? [ dup [ blank? ] find drop [ head ] when* ] unless ;

M: process-state get-checksum ( checksum-state -- value )
    dup result>> [
        dup process>> [
            [
                [ out>> dispose ] keep
                stream-contents trim-hash hex-string>bytes
            ] with-disposal
        ] [ B{ } clone ] if*
        [ >>result ] keep
    ] unless* nip ;
