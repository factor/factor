! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs assocs.lib kernel sequences urls
http http.server http.server.filters http.server.redirection
furnace furnace.sessions ;
IN: furnace.flash

: flash-id-key "__f" ;

TUPLE: flash-scopes < filter-responder ;

C: <flash-scopes> flash-scopes

SYMBOL: flash-scope

: fget ( key -- value ) flash-scope get at ;

M: flash-scopes call-responder*
    flash-id-key
    request get request-params at
    flash-scopes sget at flash-scope set
    call-next-method ;

M: flash-scopes init-session*
    H{ } clone flash-scopes sset
    call-next-method ;

: make-flash-scope ( seq -- id )
    [ dup get ] H{ } map>assoc flash-scopes sget set-at-unique
    session-changed ;

: <flash-redirect> ( url seq -- response )
    make-flash-scope
    [ clone ] dip flash-id-key set-query-param
    <redirect> ;

: restore-flash ( seq -- )
    [ flash-scope get key? ] filter [ [ fget ] keep set ] each ;
