! Copyright (C) 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel calendar alarms io io.encodings accessors
namespaces ;
IN: io.timeouts

GENERIC: timeout ( obj -- dt/f )
GENERIC: set-timeout ( dt/f obj -- )

M: decoder set-timeout stream>> set-timeout ;

M: encoder set-timeout stream>> set-timeout ;

GENERIC: cancel-operation ( obj -- )

: queue-timeout ( obj timeout -- alarm )
    >r [ cancel-operation ] curry r> later ;

: with-timeout* ( obj timeout quot -- )
    3dup drop queue-timeout >r nip call r> cancel-alarm ;
    inline

: with-timeout ( obj quot -- )
    over timeout [ >r dup timeout r> with-timeout* ] [ call ] if ;
    inline

: timeouts ( dt -- )
    [ input-stream get set-timeout ]
    [ output-stream get set-timeout ] bi ;
