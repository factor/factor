! Copyright (C) 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel calendar alarms io io.encodings accessors
namespaces ;
IN: io.timeouts

GENERIC: timeout ( obj -- dt/f )
GENERIC: set-timeout ( dt/f obj -- )

M: decoder set-timeout stream>> set-timeout ;

M: encoder set-timeout stream>> set-timeout ;

GENERIC: timed-out ( obj -- )

: queue-timeout ( obj timeout -- alarm )
    >r [ timed-out ] curry r> later ;

: with-timeout ( obj quot -- )
    over dup timeout dup [
        queue-timeout slip cancel-alarm
    ] [
        2drop call
    ] if ; inline

: timeouts ( dt -- )
    [ input-stream get set-timeout ]
    [ output-stream get set-timeout ] bi ;
