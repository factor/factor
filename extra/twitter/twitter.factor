! Copyright (C) 2009 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators hashtables http
http.client json.reader kernel macros namespaces sequences
urls.secure fry ;
IN: twitter

! Configuration
SYMBOLS: twitter-username twitter-password twitter-source ;

twitter-source [ "factor" ] initialize

: set-twitter-credentials ( username password -- )
    [ twitter-username set ] [ twitter-password set ] bi* ;

<PRIVATE

! Utilities
MACRO: keys-boa ( keys class -- )
    [ [ '[ _ swap at ] ] map ] dip '[ _ cleave _ boa ] ;

! Twitter requests

: twitter-url ( string -- url )
    "https://twitter.com/statuses/" ".json" surround ;

: set-request-twitter-auth ( request -- request )
    twitter-username get twitter-password get set-basic-auth ;

: twitter-request ( string quot -- data )
    [ twitter-url ] dip call
    set-request-twitter-auth
    http-request nip ; inline

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
        "status" set
        twitter-source get "source" set
    ] make-assoc ;

: (tweet) ( string -- json )
    update-post-data "update" [ <post-request> ] twitter-request ;

PRIVATE>

: tweet* ( string -- tweet )
    (tweet) json>twitter-status ;

: tweet ( string -- ) (tweet) drop ;

! Timelines
<PRIVATE

: timeline ( url -- tweets )
    [ <get-request> ] twitter-request json>twitter-statuses ;

PRIVATE>

: public-timeline ( -- tweets )
    "public_timeline" timeline ;

: friends-timeline ( -- tweets )
    "friends_timeline" timeline ;

: user-timeline ( username -- tweets )
    "user_timeline/" prepend timeline ;
