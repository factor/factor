! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces sequences arrays kernel
assocs assocs.lib hashtables math.parser urls combinators
furnace http http.server http.server.filters furnace.sessions
html.elements html.templates.chloe.syntax ;
IN: furnace.asides

TUPLE: asides < filter-responder ;

C: <asides> asides

: begin-aside* ( -- id )
    request get
    [ url>> ] [ post-data>> ] [ method>> ] tri 3array
    asides sget set-at-unique
    session-changed ;

: end-aside-post ( url post-data -- response )
    request [
        clone
            swap >>post-data
            swap >>url
    ] change
    request get url>> path>> split-path
    asides get responder>> call-responder ;

ERROR: end-aside-in-get-error ;

: end-aside* ( url id -- response )
    request get method>> "POST" = [ end-aside-in-get-error ] unless
    asides sget at [
        first3 {
            { "GET" [ drop <redirect> ] }
            { "HEAD" [ drop <redirect> ] }
            { "POST" [ end-aside-post ] }
        } case
    ] [ <redirect> ] ?if ;

SYMBOL: aside-id

: aside-id-key "__a" ;

: begin-aside ( -- )
    begin-aside* aside-id set ;

: end-aside ( default -- response )
    aside-id [ f ] change end-aside* ;

M: asides call-responder*
    dup asides set
    aside-id-key request get request-params at aside-id set
    call-next-method ;

M: asides init-session*
    H{ } clone asides sset
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
