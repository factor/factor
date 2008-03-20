! Copyright (C) 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel calendar alarms io.streams.duplex io.encodings ;
IN: io.timeouts

! Won't need this with new slot accessors
GENERIC: timeout ( obj -- dt/f )
GENERIC: set-timeout ( dt/f obj -- )

M: duplex-stream set-timeout
    2dup
    duplex-stream-in set-timeout
    duplex-stream-out set-timeout ;

M: decoder set-timeout decoder-stream set-timeout ;

M: encoder set-timeout encoder-stream set-timeout ;

GENERIC: timed-out ( obj -- )

M: object timed-out drop ;

: queue-timeout ( obj timeout -- alarm )
    >r [ timed-out ] curry r> later ;

: with-timeout ( obj quot -- )
    over dup timeout dup [
        queue-timeout slip cancel-alarm
    ] [
        2drop call
    ] if ; inline
