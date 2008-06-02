! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces sequences arrays kernel
assocs assocs.lib hashtables math.parser urls combinators
furnace http http.server http.server.filters furnace.sessions
html.elements html.templates.chloe.syntax ;
IN: furnace.flows

TUPLE: flows < filter-responder ;

C: <flows> flows

: begin-flow* ( -- id )
    request get
    [ url>> ] [ post-data>> ] [ method>> ] tri 3array
    flows sget set-at-unique
    session-changed ;

: end-flow-post ( url post-data -- response )
    request [
        clone
            "POST" >>method
            swap >>post-data
            swap >>url
    ] change
    request get url>> path>> split-path
    flows get responder>> call-responder ;

: end-flow* ( url id -- response )
    flows sget at [
        first3 {
            { "GET" [ drop <redirect> ] }
            { "HEAD" [ drop <redirect> ] }
            { "POST" [ end-flow-post ] }
        } case
    ] [ <redirect> ] ?if ;

SYMBOL: flow-id

: flow-id-key "factorflowid" ;

: begin-flow ( -- )
    begin-flow* flow-id set ;

: end-flow ( default -- response )
    flow-id get end-flow* ;

M: flows call-responder*
    dup flows set
    flow-id-key request get request-params at flow-id set
    call-next-method ;

M: flows init-session*
    H{ } clone flows sset
    call-next-method ;

M: flows link-attr ( tag -- )
    drop
    "flow" optional-attr {
        { "none" [ flow-id off ] }
        { "begin" [ begin-flow ] }
        { "current" [ ] }
        { f [ ] }
    } case ;

M: flows modify-query ( query responder -- query' )
    drop
    flow-id get [ flow-id-key associate assoc-union ] when* ;

M: flows hidden-form-field ( responder -- )
    drop
    flow-id get [
        <input
            "hidden" =type
            flow-id-key =name
            =value
        input/>
    ] when* ;
