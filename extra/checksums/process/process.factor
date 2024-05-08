! Copyright (C) 2016 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii checksums checksums.common destructors
hex-strings io io.encodings.binary io.launcher kernel sequences ;
IN: checksums.process

TUPLE: checksum-process launch-desc ;
INSTANCE: checksum-process block-checksum
C: <checksum-process> checksum-process

TUPLE: process-state < disposable process result ;

M: checksum-process initialize-checksum-state
    launch-desc>> binary <process-stream>
    process-state new-disposable swap >>process ;

M: process-state dispose*
    process>> [ dispose ] when* ;

M: process-state add-checksum-bytes
    over process>> stream-write ;

: trim-hash ( str -- str' )
    dup [ blank? ] find drop [ head ] when* ;

M: process-state get-checksum
    dup result>> [
        dup process>> [
            [
                [ out>> dispose ] keep
                stream-contents trim-hash hex-string>bytes
            ] with-disposal
        ] [ B{ } ] if*
        [ >>result ] keep
    ] unless* nip ;
