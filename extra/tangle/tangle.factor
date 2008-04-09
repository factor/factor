! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs db db.sqlite db.postgresql http.server io kernel namespaces semantic-db sequences strings ;
IN: tangle

GENERIC: render* ( content templater -- output )
GENERIC: render ( content templater -- )

TUPLE: echo-template ;
C: <echo-template> echo-template

M: echo-template render* drop ;
! METHOD: render* { string echo-template } drop ;
M: object render render* write ;

TUPLE: tangle db templater ;
C: <tangle> tangle

TUPLE: sqlite-tangle ;
TUPLE: postgres-tangle ;

: make-tangle ( db templater type -- tangle )
    construct-empty [ <tangle> ] dip tuck set-delegate ;

: <sqlite-tangle> ( db templater -- tangle ) sqlite-tangle make-tangle ;
: <postgres-tangle> ( db templater -- tangle ) postgres-tangle make-tangle ;

: with-tangle ( tangle quot -- )
    [ db>> ] dip with-db ;

: init-db ( tangle -- tangle )
    dup [ init-semantic-db ] with-tangle ;

GENERIC# new-db 1 ( tangle obj -- tangle )
M: sqlite-tangle new-db ( tangle filename -- tangle )
    sqlite-db >>db init-db ;
M: postgres-tangle new-db ( tangle args -- tangle )
    postgresql-db >>db init-db ;

TUPLE: node-responder tangle ;
C: <node-responder> node-responder

M: node-responder call-responder ( path responder -- response )
    "text/plain" <content> nip request-params
    [ "node-id" swap at* [ >>body ] [ drop ] if ] when* nip ;

: test-tangle ( -- )
    f f <sqlite-tangle> <node-responder> main-responder set ;

