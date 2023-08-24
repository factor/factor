! Copyright (C) 2008 Slava Pestov, Doug Coleman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry io io.encodings io.streams.null kernel
namespaces timers ;
IN: io.timeouts

GENERIC: timeout ( obj -- dt/f )
GENERIC: set-timeout ( dt/f obj -- )

M: decoder set-timeout stream>> set-timeout ;

M: encoder set-timeout stream>> set-timeout ;

GENERIC: cancel-operation ( obj -- )

: queue-timeout ( obj timeout -- timer )
    [ '[ _ cancel-operation ] ] dip later ;

: with-timeout* ( obj timeout quot -- )
    2over queue-timeout
    [ nip call ] dip stop-timer ; inline

: with-timeout ( obj quot -- )
    over timeout
    [ [ dup timeout ] dip with-timeout* ] [ call ] if ; inline

: timeouts ( dt -- )
    [ input-stream get set-timeout ]
    [ output-stream get set-timeout ] bi ;

M: null-stream set-timeout 2drop ;
