! Copyright (C) 2011-2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs calendar classes.tuple colors.constants
colors.hex combinators formatting http.client io io.styles json
json.reader kernel make math math.statistics sequences urls
namespaces fry ;

IN: reddit

<PRIVATE

TUPLE: comment approved_by author author_flair_css_class
author_flair_text banned_by body body_html created created_utc
downs id levenshtein likes link_id link_title name num_reports
parent_id replies edited subreddit subreddit_id ups ;

TUPLE: user comment_karma created created_utc has_mail
has_mod_mail id is_gold is_mod link_karma name ;

TUPLE: story author author_flair_css_class author_flair_text
approved_by banned_by clicked created created_utc domain downs
hidden id is_self levenshtein likes link_flair_css_class
link_flair_text media media_embed name edited num_comments
num_reports over_18 permalink saved score selftext selftext_html
subreddit subreddit_id thumbnail title ups url ;

TUPLE: subreddit accounts_active created created_utc description
display_name id header_img header_size header_title name over18
public_description subscribers title url ;

: parse-data ( assoc -- obj )
    [ "data" of ] [ "kind" of ] bi {
        { "t1" [ comment ] }
        { "t2" [ user ] }
        { "t3" [ story ] }
        { "t5" [ subreddit ] }
        [ throw ]
    } case from-slots ;

TUPLE: page url data before after ;

: json-page ( url -- page )
    >url dup http-get nip json> "data" of {
        [ "children" of [ parse-data ] map ]
        [ "before" of [ f ] when-json-null ]
        [ "after" of [ f ] when-json-null ]
    } cleave \ page boa ;

: get-user ( username -- page )
    "http://api.reddit.com/user/%s" sprintf json-page ;

: get-user-info ( username -- user )
    "http://api.reddit.com/user/%s/about" sprintf
    http-get nip json> parse-data ;

: get-url-info ( url -- page )
    "http://api.reddit.com/api/info?url=%s" sprintf json-page ;

: search-reddit ( query -- page )
    "http://api.reddit.com/search?q=%s" sprintf json-page ;

: search-subreddits ( query -- page )
    "http://api.reddit.com/reddits/search?q=%s" sprintf json-page ;

: get-domains ( query -- page )
    "http://api.reddit.com/domain/%s" sprintf json-page ;

: get-subreddit ( subreddit -- page )
    "http://api.reddit.com/r/%s" sprintf json-page ;

: next-page ( page -- page' )
    [ url>> ] [ after>> "after" set-query-param ] bi json-page ;

: all-pages ( page -- data )
    [
        [ [ data>> , ] [ dup after>> ] bi ]
        [ next-page ] while drop
    ] { } make concat ;

PRIVATE>

: user-links ( username -- stories )
    get-user data>> [ story? ] filter [ url>> ] map ;

: user-comments ( username -- comments )
    get-user data>> [ comment? ] filter [ body>> ] map ;

: user-karma ( username -- karma )
    get-user-info link_karma>> ;

: url-score ( url -- score )
    get-url-info data>> [ score>> ] map-sum ;

: subreddit-links ( subreddit -- links )
    get-subreddit data>> [ url>> ] map ;

: story>comments-url ( story -- url )
    permalink>> "http://reddit.com" prepend >url ;

: story>author-url ( story -- url )
    author>> "http://reddit.com/user/" prepend >url ;

<PRIVATE

: write-title ( title url -- )
    '[
        _ presented ,,
        COLOR: blue foreground ,,
    ] H{ } make format ;

: write-link ( title url -- )
    '[
        _ presented ,,
        HEXCOLOR: 888888 foreground ,,
    ] H{ } make format ;

: write-text ( str -- )
    H{ { foreground HEXCOLOR: 888888 } } format ;

PRIVATE>

: subreddit. ( subreddit -- )
    get-subreddit data>> [
        1 + "%2d. " sprintf write-text {
            [ [ title>> ] [ url>> ] bi write-title ]
            [ domain>> " (%s)\n" sprintf write-text ]
            [ score>> "    %d points, " sprintf write-text ]
            [ [ num_comments>> "%d comments" sprintf ] [ story>comments-url ] bi write-link ]
            [
                created_utc>> unix-time>timestamp now swap time-
                duration>hours ", posted %d hours ago" sprintf write-text
            ]
            [ " by " write-text [ author>> ] [ story>author-url ] bi write-link nl nl ]
        } cleave
    ] each-index ;

: domain-stats ( domain -- stats )
    get-domains all-pages [
        created>> 1000 * millis>timestamp year>>
    ] collect-by [ [ score>> ] map-sum ] assoc-map ;
