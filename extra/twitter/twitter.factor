USING: accessors assocs combinators hashtables http
http.client json.reader kernel macros namespaces sequences
urls.secure urls.encoding ;
IN: twitter

SYMBOLS: twitter-username twitter-password twitter-source ;

twitter-source [ "factor" ] initialize

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

MACRO: keys-boa ( keys class -- )
    [ [ \ swap \ at [ ] 3sequence ] map \ cleave ] dip \ boa [ ] 4sequence ;

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

: set-twitter-credentials ( username password -- )
    [ twitter-username set ] [ twitter-password set ] bi* ; 

: set-request-twitter-auth ( request -- request )
    twitter-username twitter-password [ get ] bi@ set-basic-auth ;

: update-post-data ( update -- assoc )
    "status" associate
    [ twitter-source get "source" ] dip [ set-at ] keep ;

: (tweet) ( string -- json )
    update-post-data "https://twitter.com/statuses/update.json" <post-request>
        set-request-twitter-auth 
    http-request nip ;

: tweet* ( string -- tweet )
    (tweet) json>twitter-status ;

: tweet ( string -- ) (tweet) drop ;

: public-timeline ( -- tweets )
    "https://twitter.com/statuses/public_timeline.json" <get-request>
        set-request-twitter-auth
    http-request nip json>twitter-statuses ;

: friends-timeline ( -- tweets )
    "https://twitter.com/statuses/friends_timeline.json" <get-request>
        set-request-twitter-auth
    http-request nip json>twitter-statuses ;

: user-timeline ( username -- tweets )
    "https://twitter.com/statuses/user_timeline/" ".json" surround <get-request>
        set-request-twitter-auth
    http-request nip json>twitter-statuses ;
