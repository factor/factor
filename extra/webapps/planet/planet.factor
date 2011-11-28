! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sorting math math.order
calendar timers logging concurrency.combinators namespaces
db.types db.tuples db fry locals hashtables continuations
syndication urls xml.writer validators
html.forms
html.components
http.server
http.server.dispatchers
http.server.static
furnace
furnace.actions
furnace.redirection
furnace.boilerplate
furnace.auth.login
furnace.auth
furnace.syndication
syndication.pubsubhubbub ;
IN: webapps.planet

TUPLE: planet < dispatcher ;

SYMBOL: can-administer-planet?

can-administer-planet? define-capability

TUPLE: planet-admin < dispatcher ;

TUPLE: blog id name www-url feed-url ;

M: blog link-title name>> ;

M: blog link-href www-url>> ;

blog "BLOGS"
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "name" "NAME" { VARCHAR 256 } +not-null+ }
    { "www-url" "WWWURL" URL +not-null+ }
    { "feed-url" "FEEDURL" URL +not-null+ }
} define-persistent

TUPLE: posting < entry id ;

posting "POSTINGS"
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "title" "TITLE" { VARCHAR 256 } +not-null+ }
    { "url" "LINK" URL +not-null+ }
    { "description" "DESCRIPTION" TEXT +not-null+ }
    { "date" "DATE" TIMESTAMP +not-null+ }
} define-persistent

CONSTANT: hubs { { URL" http://pubsubhubbub.appspot.com/"
                   URL" http://pubsubhubbub.appspot.com/publish" } }

: <blog> ( id -- todo )
    blog new
        swap >>id ;

: blogroll ( -- seq )
    f <blog> select-tuples
    [ name>> ] sort-with ;

: sort-postings ( seq -- seq )
    [ date>> ] inv-sort-with ;

: postings ( -- seq )
    posting new select-tuples
    sort-postings ;

: <edit-blogroll-action> ( -- action )
    <page-action>
        [ blogroll "blogroll" set-value ] >>init
        { planet "admin" } >>template ;

: <planet-action> ( -- action )
    <page-action>
        [
            blogroll "blogroll" set-value
            postings "postings" set-value
        ] >>init

        { planet "planet" } >>template ;

: hubs-urls ( -- seq )
    hubs [ first ] map ;

: ping-hubs ( -- )
    { URL" http://planet.factorcode.org/feed.xml" }
    hubs [ second ] map
    [ [ ping ] [ 3drop ] recover ] with each ;

: <planet-feed-action> ( -- action )
    <feed-action>
        [ "Planet Factor" ] >>title
        [ URL" $planet" ] >>url
        [ hubs-urls ] >>hubs
        [ postings ] >>entries ;

:: <posting> ( entry name -- entry' )
    posting new
        name ": " entry title>> 3append >>title
        entry url>> >>url
        entry description>> >>description
        entry date>> >>date ;

: fetch-feed ( url -- feed )
    download-feed entries>> ;

\ fetch-feed DEBUG add-error-logging

: fetch-blogroll ( blogroll -- entries )
    [ [ feed-url>> fetch-feed ] parallel-map ] [ [ name>> ] map ] bi
    [ '[ _ <posting> ] map ] 2map concat ;

: sort-entries ( entries -- entries' )
    [ date>> ] inv-sort-with ;

: set-cached-postings ( seq -- )
    [
        posting new delete-tuples
        [ insert-tuple ] each
    ] with-transaction ;

: update-cached-postings ( -- )
    blogroll fetch-blogroll sort-entries 8 short head sort-postings
    dup postings = [ drop ] [ set-cached-postings ping-hubs ] if ;

: <update-action> ( -- action )
    <action>
        [
            update-cached-postings
            URL" $planet/admin" <redirect>
        ] >>submit ;

: <delete-blog-action> ( -- action )
    <action>
        [ validate-integer-id ] >>validate

        [
            "id" value <blog> delete-tuples
            URL" $planet/admin" <redirect>
        ] >>submit ;

: validate-blog ( -- )
    {
        { "name" [ v-one-line ] }
        { "www-url" [ v-url ] }
        { "feed-url" [ v-url ] }
    } validate-params ;

: deposit-blog-slots ( blog -- )
    { "name" "www-url" "feed-url" } to-object ;

: <new-blog-action> ( -- action )
    <page-action>

        { planet "new-blog" } >>template

        [ validate-blog ] >>validate

        [
            f <blog>
            [ deposit-blog-slots ]
            [ insert-tuple ]
            bi
            URL" $planet/admin" <redirect>
        ] >>submit ;

: <edit-blog-action> ( -- action )
    <page-action>

        [
            validate-integer-id
            "id" value <blog> select-tuple from-object
        ] >>init

        { planet "edit-blog" } >>template

        [
            validate-integer-id
            validate-blog
        ] >>validate

        [
            f <blog>
            [ deposit-blog-slots ]
            [ "id" value >>id update-tuple ] bi

            <url>
                "$planet/admin" >>path
                "id" value "id" set-query-param
            <redirect>
        ] >>submit ;

: <planet-admin> ( -- responder )
    planet-admin new-dispatcher
        <edit-blogroll-action> "" add-responder
        <update-action> "update" add-responder
        <new-blog-action> "new-blog" add-responder
        <edit-blog-action> "edit-blog" add-responder
        <delete-blog-action> "delete-blog" add-responder
    <protected>
        "administer Planet Factor" >>description
        { can-administer-planet? } >>capabilities ;

: <planet> ( -- responder )
    planet new-dispatcher
        <planet-action> "" add-responder
        <planet-feed-action> "feed.xml" add-responder
        <planet-admin> "admin" add-responder
        "vocab:webapps/planet/icons/" <static> "icons" add-responder
    <boilerplate>
        { planet "planet-common" } >>template ;

: start-update-task ( db -- )
    '[
        "webapps.planet"
        [ _ [ update-cached-postings ] with-db ] with-logging
    ] 10 minutes every drop ;
