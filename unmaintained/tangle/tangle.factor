! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs db db.sqlite db.postgresql
http http.server http.server.dispatchers http.server.responses
http.server.static furnace.actions furnace.json
io io.files json.writer kernel math.parser namespaces
semantic-db sequences strings tangle.path ;
IN: tangle

GENERIC: render* ( content templater -- output )
GENERIC: render ( content templater -- )

TUPLE: echo-template ;
C: <echo-template> echo-template

M: echo-template render* drop ;
! METHOD: render* { string echo-template } drop ;
M: object render render* write ;

TUPLE: tangle db seq templater ;
C: <tangle> tangle

: with-tangle ( tangle quot -- )
    [ [ db>> ] [ seq>> ] bi ] dip with-db ;

: node-response ( id -- response )
    load-node [ node-content <text-content> ] [ <404> ] if* ;

: display-node ( params -- response )
    [
        "node_id" swap at* [
            string>number node-response
        ] [
            drop <400>
        ] if
    ] [
        <400>
    ] if* ;

: submit-node ( params -- response )
    [
        "node_content" swap at* [
            create-node id>> number>string <text-content>
        ] [
            drop <400>
        ] if
    ] [
        <400>
    ] if* ;

: <node-responder> ( -- responder )
    <action> [ params get display-node ] >>display
    [ params get submit-node ] >>submit ;

TUPLE: path-responder ;
C: <path-responder> path-responder

M: path-responder call-responder* ( path responder -- response )
    drop path>file [ node-content <text-content> ] [ <404> ] if* ;

TUPLE: tangle-dispatcher < dispatcher tangle ;

: <tangle-dispatcher> ( tangle -- dispatcher )
    tangle-dispatcher new-dispatcher swap >>tangle
    <path-responder> >>default
    "resource:extra/tangle/resources" <static> "resources" add-responder
    <node-responder> "node" add-responder
    <action> [ all-node-ids <json-content> ] >>display "all" add-responder ;

M: tangle-dispatcher call-responder* ( path dispatcher -- response )
    dup tangle>> [
        find-responder call-responder
    ] with-tangle ;
