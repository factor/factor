USING: assocs calendar init kernel math.parser
namespaces random boxes alarms ;
IN: furnace.sessions

SYMBOL: sessions

: timeout ( -- dt ) 20 minutes ;

[
    H{ } clone sessions set-global
] "furnace.sessions" add-init-hook

: new-session-id ( -- str )
    4 big-random >hex
    dup sessions get-global key?
    [ drop new-session-id ] when ;

TUPLE: session id namespace alarm user-agent ;

: cancel-timeout ( session -- )
    session-alarm ?box [ cancel-alarm ] [ drop ] if ;

: delete-session ( session -- )
    sessions get-global delete-at*
    [ cancel-timeout ] [ drop ] if ;

: touch-session ( session -- )
    dup cancel-timeout
    dup [ session-id delete-session ] curry timeout later
    swap session-alarm >box ;

: <session> ( id -- session )
    H{ } clone <box> f session construct-boa ;

: new-session ( -- session id )
    new-session-id [
        dup <session> [
            [ sessions get-global set-at ] keep
            touch-session
        ] keep
    ] keep ;

: get-session ( id -- session/f )
    sessions get-global at*
    [ dup touch-session ] when ;

: session> ( str -- obj )
    session get session-namespace at ;

: >session ( value key -- )
    session get session-namespace set-at ;
