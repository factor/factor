! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces sequences arrays kernel
assocs assocs.lib hashtables math.parser
html.elements http http.server http.server.sessions ;
IN: http.server.flows

TUPLE: flows < filter-responder ;

C: <flows> flows

: begin-flow* ( -- id )
    request get [ path>> ] [ query>> ] bi 2array
    flows sget set-at-unique
    session-changed ;

: end-flow* ( default id -- response )
    flows sget at [ first2 ] [ f ] ?if <permanent-redirect> ;

SYMBOL: flow-id

: flow-id-key "factorflowid" ;

: begin-flow ( -- )
    begin-flow* flow-id set ;

: end-flow ( default -- response )
    flow-id get end-flow* ;

: add-flow-id ( query -- query' )
    flow-id get [ flow-id-key associate assoc-union ] when* ;

: flow-form-field ( -- )
    flow-id get [
        <input
            "hidden" =type
            flow-id-key =name
            =value
        input/>
    ] when* ;

M: flows call-responder
    [ add-flow-id ] add-link-hook
    [ flow-form-field ] add-form-hook
    flow-id-key request-params at flow-id set
    call-next-method ;

M: flows init-session*
    H{ } clone flows sset
    call-next-method ;
