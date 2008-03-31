! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs assocs.lib accessors http.server.sessions.storage
alarms kernel fry http.server ;
IN: http.server.sessions.storage.assoc

TUPLE: sessions-in-memory sessions alarms ;

: <sessions-in-memory> ( -- storage )
    H{ } clone H{ } clone sessions-in-memory construct-boa ;

: cancel-session-timeout ( id storage -- )
    alarms>> at [ cancel-alarm ] when* ;

: touch-session ( id storage -- )
    [ cancel-session-timeout ]
    [ '[ , , delete-session ] timeout later ]
    [ alarms>> set-at ]
    2tri ;

M: sessions-in-memory get-session ( id storage -- namespace )
    [ sessions>> at ] [ touch-session ] 2bi ;

M: sessions-in-memory update-session ( namespace id storage -- )
    [ sessions>> set-at ]
    [ touch-session ]
    2bi ;

M: sessions-in-memory delete-session ( id storage -- )
    [ sessions>> delete-at ]
    [ cancel-session-timeout ]
    2bi ;

M: sessions-in-memory new-session ( namespace storage -- id )
    [ sessions>> set-at-unique ]
    [ [ touch-session ] [ drop ] 2bi ]
    bi ;
