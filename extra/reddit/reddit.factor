! Copyright (C) 2011-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs calendar calendar.format colors
combinators formatting http.client http.json io io.styles json
kernel make math sequences urls ;

IN: reddit

<PRIVATE

TUPLE: page url data before after ;

: json-page ( url -- page )
    >url dup http-get-json nip "data" of {
        [ "children" of ]
        [ "before" of [ f ] when-json-null ]
        [ "after" of [ f ] when-json-null ]
    } cleave \ page boa ;

: get-user ( username -- page )
    "https://api.reddit.com/user/%s" sprintf json-page ;

: get-user-info ( username -- user )
    "https://api.reddit.com/user/%s/about" sprintf http-get-json nip ;

: get-url-info ( url -- page )
    "https://api.reddit.com/api/info?url=%s" sprintf json-page ;

: search-reddit ( query -- page )
    "https://api.reddit.com/search?q=%s" sprintf json-page ;

: search-subreddits ( query -- page )
    "https://api.reddit.com/reddits/search?q=%s" sprintf json-page ;

: get-domains ( query -- page )
    "https://api.reddit.com/domain/%s" sprintf json-page ;

: get-subreddit ( subreddit -- page )
    "https://api.reddit.com/r/%s" sprintf json-page ;

: next-page ( page -- page' )
    [ url>> ] [ after>> "after" set-query-param ] bi json-page ;

: all-pages ( page -- data )
    [
        [ [ data>> , ] [ dup after>> ] bi ]
        [ next-page ] while drop
    ] { } make concat ;

PRIVATE>

: user-links ( username -- stories )
    get-user data>> [ "kind" of "t3" = ] filter
    [ "data" of "url" of ] map ;

: user-comments ( username -- comments )
    get-user data>> [ "kind" of "t1" = ] filter
    [ "data" of "body" of ] map ;

: user-karma ( username -- karma )
    get-user-info "data" of "link_karma" of ;

: url-score ( url -- score )
    get-url-info data>> [ "score" of ] map-sum ;

: subreddit-links ( subreddit -- links )
    get-subreddit data>> [ "url" of ] map ;

: story>comments-url ( story -- url )
    "permalink" of "https://reddit.com" prepend >url ;

: story>author-url ( story -- url )
    "author" of "https://reddit.com/user/" prepend >url ;

<PRIVATE

: write-title ( title url -- )
    '[
        _ presented ,,
        COLOR: blue foreground ,,
    ] H{ } make format ;

: write-link ( title url -- )
    '[
        _ presented ,,
        COLOR: #888888 foreground ,,
    ] H{ } make format ;

: write-text ( str -- )
    H{ { foreground COLOR: #888888 } } format ;

PRIVATE>

: subreddit. ( subreddit -- )
    get-subreddit data>> [
        1 + "%2d. " sprintf write-text "data" of {
            [ [ "title" of ] [ "url" of ] bi write-title ]
            [ "domain" of " (%s)\n" sprintf write-text ]
            [ "score" of "    %d points, " sprintf write-text ]
            [
                [ "num_comments" of "%d comments" sprintf ]
                [ story>comments-url ] bi write-link
            ]
            [
                "created_utc" of unix-time>timestamp
                relative-time ", posted " write-text write-text
            ]
            [ " by " write-text [ "author" of ] [ story>author-url ] bi write-link nl nl ]
        } cleave
    ] each-index ;

: domain-stats ( domain -- stats )
    get-domains all-pages [ "data" of ] map [
        "created" of 1000 * millis>timestamp year>>
    ] collect-by [ [ "score" of ] map-sum ] assoc-map ;
