! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators db.tuples db.types
furnace.cache furnace.redirection furnace.sessions
furnace.utilities hashtables html.templates.chloe.syntax http
http.server kernel logging math.parser namespaces urls ;
IN: furnace.asides

TUPLE: aside < server-state
session method url post-data ;

: <aside> ( id -- aside )
    aside new-server-state ;

aside "ASIDES" {
    { "session" "SESSION" BIG-INTEGER +not-null+ }
    { "method" "METHOD" { VARCHAR 10 } }
    { "url" "URL" URL }
    { "post-data" "POST_DATA" FACTOR-BLOB }
} define-persistent

CONSTANT: aside-id-key "__a"

TUPLE: asides < server-state-manager ;

: <asides> ( responder -- responder' )
    asides new-server-state-manager ;

SYMBOL: aside-id

: get-aside ( id -- aside )
    dup [ aside get-state ] when check-session ;

: request-aside-id ( request -- id )
    aside-id-key swap request-params at string>number ;

: request-aside ( request -- aside )
    request-aside-id get-aside ;

: set-aside ( aside -- )
    [ id>> aside-id set ] when* ;

: init-asides ( asides -- )
    asides set
    request get request-aside
    set-aside ;

M: asides call-responder*
    [ init-asides ] [ call-next-method ] bi ;

: touch-aside ( aside -- )
    asides get touch-state ;

: begin-aside ( url -- )
    f <aside>
        swap >>url
        session get id>> >>session
        request get method>> >>method
        request get post-data>> >>post-data
    [ touch-aside ] [ insert-tuple ] [ set-aside ] tri ;

: end-aside-post ( aside -- response )
    request [
        clone
            over post-data>> >>post-data
            over url>> >>url
    ] change
    [ [ post-data>> params>> params set ] [ url>> url set ] bi ]
    [ url>> path>> split-path asides get responder>> call-responder ] bi ;

\ end-aside-post DEBUG add-input-logging

ERROR: end-aside-in-get-error ;

: move-on ( id -- response )
    post-request? [ end-aside-in-get-error ] unless
    dup method>> {
        { "GET" [ url>> <redirect> ] }
        { "HEAD" [ url>> <redirect> ] }
        { "POST" [ end-aside-post ] }
    } case ;

: end-aside ( default -- response )
    [ drop aside-id get aside-id off get-aside ]
    [ move-on ] [ <redirect> ] ?if ;

M: asides link-attr
    drop
    "aside" optional-attr {
        { "none" [ aside-id off ] }
        { "begin" [ url get begin-aside ] }
        { "current" [ ] }
        { f [ ] }
    } case ;

M: asides modify-query
    drop
    aside-id get [
        aside-id-key associate assoc-union
    ] when* ;

M: asides modify-form
    drop
    aside-id get
    aside-id-key
    hidden-form-field ;
