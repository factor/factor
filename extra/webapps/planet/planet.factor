! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sorting math math.order
calendar alarms logging concurrency.combinators namespaces
sequences.lib db.types db.tuples db fry locals hashtables
html.components html.templates.chloe
rss xml.writer
validators
http.server
http.server.actions
http.server.boilerplate
http.server.auth.login
http.server.auth ;
IN: webapps.planet

: planet-template ( name -- template )
    "resource:extra/webapps/planet/" swap ".xml" 3append <chloe> ;

TUPLE: blog id name www-url feed-url ;

M: blog link-title name>> ;

M: blog link-href www-url>> ;

blog "BLOGS"
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "name" "NAME" { VARCHAR 256 } +not-null+ }
    { "www-url" "WWWURL" { VARCHAR 256 } +not-null+ }
    { "feed-url" "FEEDURL" { VARCHAR 256 } +not-null+ }
} define-persistent

! TUPLE: posting < entry id ;
TUPLE: posting id title link description pub-date ;

posting "POSTINGS"
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "title" "TITLE" { VARCHAR 256 } +not-null+ }
    { "link" "LINK" { VARCHAR 256 } +not-null+ }
    { "description" "DESCRIPTION" TEXT +not-null+ }
    { "pub-date" "DATE" TIMESTAMP +not-null+ }
} define-persistent

: init-blog-table blog ensure-table ;

: init-postings-table posting ensure-table ;

: <blog> ( id -- todo )
    blog new
        swap >>id ;

: blogroll ( -- seq )
    f <blog> select-tuples
    [ [ name>> ] compare ] sort ;

: postings ( -- seq )
    posting new select-tuples
    [ [ pub-date>> ] compare invert-comparison ] sort ;

: <edit-blogroll-action> ( -- action )
    <page-action>
        [ blogroll "blogroll" set-value ] >>init
        "admin" planet-template >>template ;

: <planet-action> ( -- action )
    <page-action>
        [
            blogroll "blogroll" set-value
            postings "postings" set-value
        ] >>init

        "planet" planet-template >>template ;

: planet-feed ( -- feed )
    feed new
        "Planet Factor" >>title
        "http://planet.factorcode.org" >>link
        postings >>entries ;

: <planet-feed-action> ( -- action )
    <feed-action> [ planet-feed ] >>feed ;

:: <posting> ( entry name -- entry' )
    posting new
        name ": " entry title>> 3append >>title
        entry link>> >>link
        entry description>> >>description
        entry pub-date>> >>pub-date ;

: fetch-feed ( url -- feed )
    download-feed entries>> ;

\ fetch-feed DEBUG add-error-logging

: fetch-blogroll ( blogroll -- entries )
    [ [ feed-url>> fetch-feed ] parallel-map ] [ [ name>> ] map ] bi
    [ '[ , <posting> ] map ] 2map concat ;

: sort-entries ( entries -- entries' )
    [ [ pub-date>> ] compare invert-comparison ] sort ;

: update-cached-postings ( -- )
    blogroll fetch-blogroll sort-entries 8 short head [
        posting new delete-tuples
        [ insert-tuple ] each
    ] with-transaction ;

: <update-action> ( -- action )
    <action>
        [
            update-cached-postings
            "" f <permanent-redirect>
        ] >>submit ;

: <delete-blog-action> ( -- action )
    <action>
        [ validate-integer-id ] >>validate

        [
            "id" value <blog> delete-tuples
            "$planet-factor/admin" f <standard-redirect>
        ] >>submit ;

: validate-blog ( -- )
    {
        { "name" [ v-one-line ] }
        { "www-url" [ v-url ] }
        { "feed-url" [ v-url ] }
    } validate-params ;

: <id-redirect> ( id next -- response )
    swap "id" associate <standard-redirect> ;

: deposit-blog-slots ( blog -- )
    { "name" "www-url" "feed-url" } deposit-slots ;

: <new-blog-action> ( -- action )
    <page-action>
        "new-blog" planet-template >>template

        [ validate-blog ] >>validate

        [
            f <blog>
            [ deposit-blog-slots ]
            [ insert-tuple ]
            [ id>> "$planet-factor/admin/edit-blog" <id-redirect> ]
            tri
        ] >>submit ;
    
: <edit-blog-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value <blog> select-tuple from-tuple
        ] >>init

        "edit-blog" planet-template >>template

        [
            validate-integer-id
            validate-blog
        ] >>validate

        [
            f <blog>
            [ deposit-blog-slots ]
            [ update-tuple ]
            [ id>> "$planet-factor/admin" <id-redirect> ]
            tri
        ] >>submit ;

TUPLE: planet-factor-admin < dispatcher ;

: <planet-factor-admin> ( -- responder )
    planet-factor-admin new-dispatcher
        <edit-blogroll-action> "blogroll" add-main-responder
        <update-action> "update" add-responder
        <new-blog-action> "new-blog" add-responder
        <edit-blog-action> "edit-blog" add-responder
        <delete-blog-action> "delete-blog" add-responder ;

SYMBOL: can-administer-planet-factor?

can-administer-planet-factor? define-capability

TUPLE: planet-factor < dispatcher ;

: <planet-factor> ( -- responder )
    planet-factor new-dispatcher
        <planet-action> "list" add-main-responder
        <feed-action> "feed.xml" add-responder
        <planet-factor-admin> { can-administer-planet-factor? } <protected> "admin" add-responder
    <boilerplate>
        "planet-common" planet-template >>template ;

: start-update-task ( db params -- )
    '[ , , [ update-cached-postings ] with-db ] 10 minutes every drop ;
