! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sorting math math.order
calendar alarms logging concurrency.combinators namespaces
sequences.lib db.types db.tuples db fry locals hashtables
html.components
syndication urls xml.writer
validators
http.server
http.server.dispatchers
furnace
furnace.actions
furnace.boilerplate
furnace.auth.login
furnace.auth
furnace.syndication ;
IN: webapps.planet

TUPLE: planet-factor < dispatcher ;

TUPLE: planet-factor-admin < dispatcher ;

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

TUPLE: posting < entry id ;

posting "POSTINGS"
{
    { "id" "ID" INTEGER +db-assigned-id+ }
    { "title" "TITLE" { VARCHAR 256 } +not-null+ }
    { "url" "LINK" { VARCHAR 256 } +not-null+ }
    { "description" "DESCRIPTION" TEXT +not-null+ }
    { "date" "DATE" TIMESTAMP +not-null+ }
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
    [ [ date>> ] compare invert-comparison ] sort ;

: <edit-blogroll-action> ( -- action )
    <page-action>
        [ blogroll "blogroll" set-value ] >>init
        { planet-factor "admin" } >>template ;

: <planet-action> ( -- action )
    <page-action>
        [
            blogroll "blogroll" set-value
            postings "postings" set-value
        ] >>init

        { planet-factor "planet" } >>template ;

: <planet-feed-action> ( -- action )
    <feed-action>
        [ "Planet Factor" ] >>title
        [ URL" $planet-factor" ] >>url
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
    [ '[ , <posting> ] map ] 2map concat ;

: sort-entries ( entries -- entries' )
    [ [ date>> ] compare invert-comparison ] sort ;

: update-cached-postings ( -- )
    blogroll fetch-blogroll sort-entries 8 short head [
        posting new delete-tuples
        [ insert-tuple ] each
    ] with-transaction ;

: <update-action> ( -- action )
    <action>
        [
            update-cached-postings
            URL" $planet-factor/admin" <redirect>
        ] >>submit ;

: <delete-blog-action> ( -- action )
    <action>
        [ validate-integer-id ] >>validate

        [
            "id" value <blog> delete-tuples
            URL" $planet-factor/admin" <redirect>
        ] >>submit ;

: validate-blog ( -- )
    {
        { "name" [ v-one-line ] }
        { "www-url" [ v-url ] }
        { "feed-url" [ v-url ] }
    } validate-params ;

: deposit-blog-slots ( blog -- )
    { "name" "www-url" "feed-url" } deposit-slots ;

: <new-blog-action> ( -- action )
    <page-action>
        { planet-factor "new-blog" } >>template

        [ validate-blog ] >>validate

        [
            f <blog>
            [ deposit-blog-slots ]
            [ insert-tuple ]
            [
                <url>
                    "$planet-factor/admin/edit-blog" >>path
                    swap id>> "id" set-query-param
                <redirect>
            ]
            tri
        ] >>submit ;
    
: <edit-blog-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value <blog> select-tuple from-object
        ] >>init

        { planet-factor "edit-blog" } >>template

        [
            validate-integer-id
            validate-blog
        ] >>validate

        [
            f <blog>
            [ deposit-blog-slots ]
            [ update-tuple ]
            [
                <url>
                    "$planet-factor/admin" >>path
                    swap id>> "id" set-query-param
                <redirect>
            ]
            tri
        ] >>submit ;

: <planet-factor-admin> ( -- responder )
    planet-factor-admin new-dispatcher
        <edit-blogroll-action> "blogroll" add-main-responder
        <update-action> "update" add-responder
        <new-blog-action> "new-blog" add-responder
        <edit-blog-action> "edit-blog" add-responder
        <delete-blog-action> "delete-blog" add-responder ;

SYMBOL: can-administer-planet-factor?

can-administer-planet-factor? define-capability

: <planet-factor> ( -- responder )
    planet-factor new-dispatcher
        <planet-action> "list" add-main-responder
        <planet-feed-action> "feed.xml" add-responder
        <planet-factor-admin> <protected>
            "administer Planet Factor" >>description
            { can-administer-planet-factor? } >>capabilities
        "admin" add-responder
    <boilerplate>
        { planet-factor "planet-common" } >>template ;

: start-update-task ( db params -- )
    '[ , , [ update-cached-postings ] with-db ] 10 minutes every drop ;
