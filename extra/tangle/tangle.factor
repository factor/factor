! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs db db.sqlite db.postgresql http http.server http.server.actions io kernel math.parser namespaces semantic-db sequences strings ;
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

TUPLE: node-responder tangle ;
C: <node-responder> node-responder

: node-response ( responder id -- responder )
    load-node [ node-content ] [ "Unknown node" ] if* >>body ;

M: node-responder call-responder* ( path responder -- response )
    dup tangle>> [
        "text/plain" <content> nip request get request-params
        [ "node-id" swap at* [ string>number node-response ] [ drop ] if ] when* nip
    ] with-tangle ;

