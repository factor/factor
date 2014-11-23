! Copyright (C) 2009, 2010 Joe Groff, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators hashtables http
http.client json.reader kernel macros make namespaces sequences
io.sockets.secure fry oauth urls ;
FROM: assocs => change-at ;
IN: twitter

! Configuration
SYMBOLS: twitter-source twitter-consumer-token twitter-access-token ;

twitter-source [ "factor" ] initialize

<PRIVATE

: with-twitter-oauth ( quot -- )
    [
        twitter-consumer-token get consumer-token set
        twitter-access-token get access-token set
        call
    ] with-scope ; inline

: twitter-url ( string -- string' )
    ssl-supported?
    "https://api.twitter.com/" "http://api.twitter.com/" ? prepend ;

PRIVATE>

: obtain-twitter-request-token ( -- request-token )
    [
        "oauth/request_token" twitter-url
        <request-token-params>
        obtain-request-token
    ] with-twitter-oauth ;

: twitter-authorize-url ( token -- url )
    "oauth/authorize" twitter-url >url
        swap key>> "oauth_token" set-query-param ;

: obtain-twitter-access-token ( request-token verifier -- access-token )
    [
        [ "oauth/access_token" twitter-url ] 2dip
        <access-token-params>
            swap >>verifier
            swap >>request-token
        obtain-access-token
    ] with-twitter-oauth ;

<PRIVATE

! Utilities
MACRO: keys-boa ( keys class -- )
    [ [ '[ _ of ] ] map ] dip '[ _ cleave _ boa ] ;

! Twitter requests
: status-url ( string -- url )
    "1.1/statuses/" ".json" surround twitter-url ;

: set-request-twitter-auth ( request -- request )
    [ <oauth-request-params> set-oauth ] with-twitter-oauth ;

: twitter-request ( request -- data )
    set-request-twitter-auth http-request* ; inline

PRIVATE>

! Data types

TUPLE: twitter-status
    created-at
    id
    text
    source
    truncated?
    in-reply-to-status-id
    in-reply-to-user-id
    favorited?
    user ;

TUPLE: twitter-user
    id
    name
    screen-name
    description
    location
    profile-image-url 
    url
    protected?
    followers-count ;

<PRIVATE

: <twitter-user> ( assoc -- user )
    {
        "id"
        "name"
        "screen_name"
        "description"
        "location"
        "profile_image_url"
        "url"
        "protected"
        "followers_count"
    } twitter-user keys-boa ;

: <twitter-status> ( assoc -- tweet )
    clone "user" over [ <twitter-user> ] change-at 
    {
        "created_at"
        "id"
        "text"
        "source"
        "truncated"
        "in_reply_to_status_id"
        "in_reply_to_user_id"
        "favorited"
        "user"
    } twitter-status keys-boa ;

: json>twitter-statuses ( json-array -- tweets )
    json> [ <twitter-status> ] map ;

: json>twitter-status ( json-object -- tweet )
    json> <twitter-status> ;

PRIVATE>

! Updates
<PRIVATE

: update-post-data ( update -- assoc )
    [
        "status" ,,
        twitter-source get "source" ,,
    ] H{ } make ;

: (tweet) ( string -- json )
    update-post-data "update" status-url
    <post-request> twitter-request ;

PRIVATE>

: tweet* ( string -- tweet )
    (tweet) json>twitter-status ;

: tweet ( string -- ) (tweet) drop ;

: verify-credentials ( -- foo )
    "1.1/account/verify_credentials.json" twitter-url
    <get-request> twitter-request json> ;

! Timelines
<PRIVATE

: timeline ( url -- tweets )
    status-url <get-request>
    twitter-request json>twitter-statuses ;

PRIVATE>

: public-timeline ( -- tweets )
    "public_timeline" timeline ;

: friends-timeline ( -- tweets )
    "friends_timeline" timeline ;

: user-timeline ( username -- tweets )
    "user_timeline/" prepend timeline ;
