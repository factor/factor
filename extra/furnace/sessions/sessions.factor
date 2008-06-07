! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math.intervals math.parser namespaces
random accessors quotations hashtables sequences continuations
fry calendar combinators destructors alarms
db db.tuples db.types
http http.server http.server.dispatchers http.server.filters
html.elements furnace ;
IN: furnace.sessions

TUPLE: session id expires uid namespace changed? ;

: <session> ( id -- session )
    session new
        swap >>id ;

session "SESSIONS"
{
    { "id" "ID" +random-id+ system-random-generator }
    { "expires" "EXPIRES" TIMESTAMP +not-null+ }
    { "uid" "UID" { VARCHAR 255 } }
    { "namespace" "NAMESPACE" FACTOR-BLOB }
} define-persistent

: get-session ( id -- session )
    dup [ <session> select-tuple ] when ;

: init-sessions-table session ensure-table ;

: start-expiring-sessions ( db seq -- )
    '[
        , , [
            session new
                -1.0/0.0 now [a,b] >>expires
            delete-tuples
        ] with-db
    ] 5 minutes every drop ;

GENERIC: init-session* ( responder -- )

M: object init-session* drop ;

M: dispatcher init-session* default>> init-session* ;

M: filter-responder init-session* responder>> init-session* ;

TUPLE: sessions < filter-responder timeout domain ;

: <sessions> ( responder -- responder' )
    sessions new
        swap >>responder
        20 minutes >>timeout ;

: (session-changed) ( session -- )
    t >>changed? drop ;

: session-changed ( -- )
    session get (session-changed) ;

: sget ( key -- value )
    session get namespace>> at ;

: sset ( value key -- )
    session get
    [ namespace>> set-at ] [ (session-changed) ] bi ;

: schange ( key quot -- )
    session get
    [ namespace>> swap change-at ] keep
    (session-changed) ; inline

: uid ( -- uid )
    session get uid>> ;

: set-uid ( uid -- )
    session get [ (>>uid) ] [ (session-changed) ] bi ;

: init-session ( session -- )
    session [ sessions get init-session* ] with-variable ;

: cutoff-time ( -- time )
    sessions get timeout>> from-now ;

: touch-session ( session -- )
    cutoff-time >>expires drop ;

: empty-session ( -- session )
    f <session>
        H{ } clone >>namespace
        dup touch-session ;

: begin-session ( -- session )
    empty-session [ init-session ] [ insert-tuple ] [ ] tri ;

! Destructor
TUPLE: session-saver session ;

C: <session-saver> session-saver

M: session-saver dispose
    session>> dup changed?>> [
        [ touch-session ] [ update-tuple ] bi
    ] [ drop ] if ;

: save-session-after ( session -- )
    <session-saver> &dispose drop ;

: existing-session ( path session -- response )
    [ session set ] [ save-session-after ] bi
    sessions get responder>> call-responder ;

: session-id-key "__s" ;

: cookie-session-id ( request -- id/f )
    session-id-key get-cookie
    dup [ value>> string>number ] when ;

: post-session-id ( request -- id/f )
    session-id-key swap request-params at string>number ;

: request-session-id ( -- id/f )
    request get dup method>> {
        { "GET" [ cookie-session-id ] }
        { "HEAD" [ cookie-session-id ] }
        { "POST" [ post-session-id ] }
    } case ;

: request-session ( -- session/f )
    request-session-id get-session ;

: <session-cookie> ( id -- cookie )
    session-id-key <cookie>
        "$sessions" resolve-base-path >>path
        sessions get timeout>> from-now >>expires
        sessions get domain>> >>domain ;

: put-session-cookie ( response -- response' )
    session get id>> number>string <session-cookie> put-cookie ;

M: sessions modify-form ( responder -- )
    drop session get id>> session-id-key hidden-form-field ;

M: sessions call-responder* ( path responder -- response )
    sessions set
    request-session [ begin-session ] unless*
    existing-session put-session-cookie ;

: logout-all-sessions ( uid -- )
    session new swap >>uid delete-tuples ;
