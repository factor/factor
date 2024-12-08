! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs assocs.extras calendar combinators.short-circuit
crypto.jwt formatting http http.client http.json kernel
linked-assocs math.order namespaces namespaces.extras
prettyprint sequences urls urls.encoding ;
IN: bluesky

SYMBOL: bluesky-identifier
SYMBOL: bluesky-password

SYMBOL: bluesky-session

DEFER: bluesky-get-session
: set-bluesky-auth ( request -- request )
    bluesky-get-session "accessJwt" of set-bearer-auth ;

: set-bluesky-refresh-auth ( request -- request )
    bluesky-get-session "refreshJwt" of set-bearer-auth ;

: bluesky-create-session ( -- session )
    bluesky-identifier bluesky-password 2required
    'H{ { "identifier" _ } { "password" _ } }
    "https://bsky.social/xrpc/com.atproto.server.createSession" http-post-json nip ;

: bluesky-get-json ( url -- json )
    <get-request> set-bluesky-auth http-request-json nip ;

: bluesky-post-json ( json url -- json )
    <post-request> set-bluesky-auth http-request-json nip ;

: bluesky-refresh-get-json ( url -- json )
    <get-request> set-bluesky-refresh-auth http-request-json nip ;

: bluesky-refresh-post-json ( json url -- json )
    <post-request> set-bluesky-refresh-auth http-request-json nip ;

: bluesky-refresh-session ( -- session )
    H{ } clone "https://bsky.social/xrpc/com.atproto.server.refreshSession" bluesky-refresh-post-json ;

: jwt-needs-refresh? ( jwt -- ? )
    jwt> drop nip
    "exp" of unix-time>timestamp
    1 minutes hence
    before? ;

: refresh-jwt-valid? ( session -- ? ) "refreshJwt" of jwt-needs-refresh? ;
: access-jwt-valid? ( session -- ? ) "accessJwt" of jwt-needs-refresh? ;
: session-valid? ( session -- ? ) refresh-jwt-valid? ;

: session-needs-refresh? ( session -- ? )
    { [ refresh-jwt-valid? not ] [ access-jwt-valid? ] } 1&& ;

: session-needs-recreate? ( session -- ? )
    { [ refresh-jwt-valid? not ] [ access-jwt-valid? not ] } 1&& ;

: bluesky-get-session ( -- session )
    bluesky-session get-global [
        session-needs-recreate?
        [ bluesky-create-session ]
        [ bluesky-refresh-session ] if
    ] [
        bluesky-create-session
    ] if* dup bluesky-session set-global ;

! "did:plc:ragtjsm2j2vknwkz3zp4oxrd" bluesky-get-profile
: bluesky-get-profile ( did -- profile )
    "https://bsky.social/xrpc/app.bsky.actor.getProfile?actor=%s" sprintf bluesky-get-json ;

: bluesky-get-feed-default-assoc ( -- linked-assoc )
    <linked-hash>
        "filter" "posts_with_replies" set-of
        "includePins" "true" set-of
        "limit" 100 set-of ;

! actor: required
! filter: posts_with_replies, posts_no_replies, posts_with_media, posts_and_author_threads
! default: posts_with_replies
! includePins: true, false
: bluesky-get-feed ( linked-assoc -- feed )
    "https://bsky.social/xrpc/app.bsky.feed.getAuthorFeed" >url
        swap set-query-params bluesky-get-json ;

: bluesky-get-feed-default ( actor -- feed )
    [ bluesky-get-feed-default-assoc ] dip
    "actor" pick set-at bluesky-get-feed ;

: bluesky-get-feed-all ( linked-assoc -- feed )
    "" "cursor" pick ?set-once-at 2drop
    [ dup "cursor" of ] [
        [
            bluesky-get-feed
            [ "feed" of ] [ "cursor" of dup . ] bi
        ] keep [ "cursor" ] dip [ set-at ] keep swap
    ] produce concat nip ;

! "pfrazee.com" bluesky-search-actors
: bluesky-search-actors ( query -- profile )
    "https://bsky.social/xrpc/app.bsky.actor.searchActors?q=%s" sprintf bluesky-get-json ;
