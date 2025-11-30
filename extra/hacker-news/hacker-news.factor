! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors assocs calendar calendar.format
calendar.holidays.us colors combinators concurrency.combinators
formatting graphs hashtables io io.styles http.json kernel make
math sequences sets ui ui.theme urls ;

IN: hacker-news
CONSTANT: christmas-red COLOR: #bc2c21
CONSTANT: christmas-green COLOR: #376627

<PRIVATE
: hacker-news-ids ( endpoint -- ids )
    "https://hacker-news.firebaseio.com/v0/%s.json?print=pretty" sprintf http-get-json nip ;

: hacker-news-id>json-url ( n -- url )
    "https://hacker-news.firebaseio.com/v0/item/%d.json?print=pretty" sprintf ;

: hacker-news-items ( n endpoint -- seq )
    hacker-news-ids swap index-or-length head
    [ hacker-news-id>json-url http-get-json ] parallel-map ;

: hacker-news-top-stories ( n -- seq )
    "topstories" hacker-news-items ;

: hacker-news-new-stories ( n -- seq )
    "newstories" hacker-news-items ;

: hacker-news-best-stories ( n -- seq )
    "beststories" hacker-news-items ;

: hacker-news-ask-stories ( n -- seq )
    "askstories" hacker-news-items ;

: hacker-news-show-stories ( n -- seq )
    "showstories" hacker-news-items ;

: hacker-news-job-stories ( n -- seq )
    "jobstories" hacker-news-items ;

: christmas-day? ( -- ? )
    now-utc dup christmas-day same-day? ;

: number-color ( n -- color )
    christmas-day? [
        odd? christmas-red christmas-green ?
    ] [
        drop COLOR: #a0a0a0
    ] if ;

: background-color ( -- color )
    christmas-day? COLOR: #bc2c21 COLOR: #ff6600 ? ;

: write-number ( n -- )
    [ "%2d. " sprintf H{ } clone ] keep
    number-color foreground pick set-at format ;

: write-title ( title url -- )
    '[
        _ presented ,,
        ui-running? text-color COLOR: white ? foreground ,,
    ] H{ } make format ;

: write-link ( title url -- )
    '[
        _ presented ,,
        COLOR: #888888 foreground ,,
    ] H{ } make format ;

: write-text ( str -- )
    text-color foreground associate format ;

: post>user-url ( post -- user-url )
    "by" of "https://news.ycombinator.com/user?id=" prepend >url ;

: post>comments-url ( post -- user-url )
    "id" of "https://news.ycombinator.com/item?id=%d" sprintf >url ;

! Api is funky, gives id=0 and /comment/2342342 for self-post ads
: post>url ( post -- url )
    dup "url" of "self" = [ post>comments-url ] [ "url" of >url ] if ;

PRIVATE>

: post. ( post index -- )
    write-number
    {
        [ [ "title" of ] [ "url" of ] bi write-title ]
        [ post>url host>> " (" ")" surround write-text nl ]
        [ "score" of "    %d points" sprintf write-text ]
        [ dup "by" of [ " by " write-text [ "by" of ] [ post>user-url ] bi write-link ] [ drop ] if ]
        [ "time" of [ " " write-text unix-time>timestamp relative-time write-text ] when* ]
        [
            dup "descendants" of [
                " | " write-text
                [ "descendants" of [ "discuss" ] [ "%d comments" sprintf ] if-zero ]
                [ post>comments-url ] bi write-link
            ] [
                drop
            ] if nl nl
        ]
    } cleave ;

: banner. ( str -- )
    "https://news.ycombinator.com" >url presented associate
    H{
        { font-size 20 }
        { font-style bold }
        { foreground COLOR: black }
    } assoc-union
    background-color background pick set-at
    format nl ;

: hacker-news-feed. ( seq -- )
    [ 1 + post. ] each-index ;

: hacker-news. ( str seq -- )
    [ banner. ]
    [ hacker-news-feed. ] bi* ;

: hacker-news-top. ( -- )
    "Hacker News - Top"
    30 hacker-news-top-stories
    hacker-news. ;

: hacker-news-new. ( -- )
    "Hacker News - New"
    50 hacker-news-new-stories
    hacker-news. ;

: hacker-news-best. ( -- )
    "Hacker News - Best"
    50 hacker-news-best-stories
    hacker-news. ;

: hacker-news-ask. ( -- )
    "Hacker News - Ask"
    50 hacker-news-ask-stories
    hacker-news. ;

: hacker-news-show. ( -- )
    "Hacker News - Show"
    50 hacker-news-show-stories
    hacker-news. ;

: hacker-news-job. ( -- )
    "Hacker News - Job"
    50 hacker-news-job-stories
    hacker-news. ;

: filter-comments ( seq -- seq' ) "type" of "comment" = ;
: reject-deleted ( seq -- seq' ) [ "deleted" of ] reject ;

: closure-with ( vertex quot1: ( key -- vertices ) quot2: ( vertex -- keys ) -- set )
    over '[ @ [ @ _ map ] closure ] call ; inline

: parallel-closure-with ( vertex quot1: ( key -- vertices ) quot2: ( vertex -- edges ) -- set )
    over '[ @ [ @ _ parallel-map ] closure ] call ; inline

 ! Yes, there is no api that grabs multiple comments in a single call. (4/17/2023)
: hacker-news-comments ( id -- seq )
    [ hacker-news-id>json-url http-get-json nip ]
    [ "kids" of ] parallel-closure-with members ;
