! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs assocs.lib kernel sequences accessors
urls db.types db.tuples math.parser fry
http http.server http.server.filters http.server.redirection
furnace furnace.cache furnace.sessions ;
IN: furnace.flash

TUPLE: flash-scope < server-state session namespace ;

: <flash-scope> ( id -- aside )
    flash-scope new-server-state ;

flash-scope "FLASH_SCOPES" {
    { "session" "SESSION" BIG-INTEGER +not-null+ }
    { "namespace" "NAMESPACE" FACTOR-BLOB +not-null+ }
} define-persistent

: flash-id-key "__f" ;

TUPLE: flash-scopes < server-state-manager ;

: <flash-scopes> ( responder -- responder' )
    flash-scopes new-server-state-manager ;

SYMBOL: flash-scope

: fget ( key -- value ) flash-scope get at ;

: get-flash-scope ( id -- flash-scope )
    dup [ flash-scope get-state ] when
    dup [ dup session>> session get id>> = [ drop f ] unless ] when ;

: request-flash-scope ( request -- flash-scope )
    flash-id-key swap request-params at string>number get-flash-scope ;

M: flash-scopes call-responder*
    dup flash-scopes set
    request get request-flash-scope flash-scope set
    call-next-method ;

: make-flash-scope ( seq -- id )
    f <flash-scope>
        session get id>> >>session
        swap [ dup get ] H{ } map>assoc >>namespace
    [ flash-scopes get touch-state ] [ insert-tuple ] [ id>> ] tri ;

: <flash-redirect> ( url seq -- response )
    [ clone ] dip
    make-flash-scope flash-id-key set-query-param
    <redirect> ;

: restore-flash ( seq -- )
    flash-scope get dup [
        namespace>>
        [ '[ , key? ] filter ]
        [ '[ [ , at ] keep set ] each ]
        bi
    ] [ 2drop ] if ;
