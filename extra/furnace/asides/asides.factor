! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces sequences arrays kernel
assocs assocs.lib hashtables math.parser urls combinators
html.elements html.templates.chloe.syntax db.types db.tuples
http http.server http.server.filters 
furnace furnace.cache furnace.sessions furnace.redirection ;
IN: furnace.asides

TUPLE: aside < server-state session method url post-data ;

: <aside> ( id -- aside )
    aside new-server-state ;

aside "ASIDES"
{
    { "session" "SESSION" BIG-INTEGER +not-null+ }
    { "method" "METHOD" { VARCHAR 10 } +not-null+ }
    { "url" "URL" URL +not-null+ }
    { "post-data" "POST_DATA" FACTOR-BLOB }
} define-persistent

TUPLE: asides < server-state-manager ;

: <asides> ( responder -- responder' )
    asides new-server-state-manager ;

: begin-aside* ( -- id )
    f <aside>
        session get id>> >>session
        request get
        [ method>> >>method ]
        [ url>> >>url ]
        [ post-data>> >>post-data ]
        tri
    [ asides get touch-state ] [ insert-tuple ] [ id>> ] tri ;

: end-aside-post ( aside -- response )
    request [
        clone
            over post-data>> >>post-data
            over url>> >>url
    ] change
    url>> path>> split-path
    asides get responder>> call-responder ;

ERROR: end-aside-in-get-error ;

: get-aside ( id -- aside )
    dup [ aside get-state ] when
    dup [ dup session>> session get id>> = [ drop f ] unless ] when ;

: end-aside* ( url id -- response )
    post-request? [ end-aside-in-get-error ] unless
    aside get-state [
        dup method>> {
            { "GET" [ url>> <redirect> ] }
            { "HEAD" [ url>> <redirect> ] }
            { "POST" [ end-aside-post ] }
        } case
    ] [ <redirect> ] ?if ;

SYMBOL: aside-id

: aside-id-key "__a" ;

: begin-aside ( -- )
    begin-aside* aside-id set ;

: end-aside ( default -- response )
    aside-id [ f ] change end-aside* ;

: request-aside-id ( request -- aside-id )
    aside-id-key swap request-params at string>number ;

M: asides call-responder*
    dup asides set
    request get request-aside-id aside-id set
    call-next-method ;

M: asides link-attr ( tag -- )
    drop
    "aside" optional-attr {
        { "none" [ aside-id off ] }
        { "begin" [ begin-aside ] }
        { "current" [ ] }
        { f [ ] }
    } case ;

M: asides modify-query ( query responder -- query' )
    drop
    aside-id get [ aside-id-key associate assoc-union ] when* ;

M: asides modify-form ( responder -- )
    drop aside-id get aside-id-key hidden-form-field ;
