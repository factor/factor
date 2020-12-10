! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs calendar calendar.format
colors.constants colors.hex combinators concurrency.combinators
formatting fry hashtables http.client io io.styles json.reader
kernel make math math.parser sequences ui urls vocabs ;

IN: hacker-news

<PRIVATE
: hacker-news-ids ( endpoint -- ids )
    "https://hacker-news.firebaseio.com/v0/%s.json?print=pretty" sprintf
    http-get nip json> ;

: hacker-news-id>json-url ( n -- url )
    "https://hacker-news.firebaseio.com/v0/item/%d.json?print=pretty" sprintf ;

: hacker-news-items ( n endpoint -- seq' )
    hacker-news-ids swap short head
    [ hacker-news-id>json-url http-get nip json> ] parallel-map ;

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

: write-title ( title url -- )
    '[
        _ presented ,,
        ui-running? COLOR: black COLOR: white ? foreground ,,
    ] H{ } make format ;

: write-link ( title url -- )
    '[
        _ presented ,,
        HEXCOLOR: 888888 foreground ,,
    ] H{ } make format ;

: write-text ( str -- )
    H{ { foreground HEXCOLOR: 888888 } } format ;

: post>user-url ( post -- user-url )
    "by" of "http://news.ycombinator.com/user?id=" prepend >url ;

: post>comments-url ( post -- user-url )
    "id" of "http://news.ycombinator.com/item?id=%d" sprintf >url ;

! Api is funky, gives id=0 and /comment/2342342 for self-post ads
: post>url ( post -- url )
    dup "url" of "self" = [ post>comments-url ] [ "url" of >url ] if ;

PRIVATE>

: post. ( post index -- )
    "%2d. " sprintf write-text {
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
    "http://news.ycombinator.com" >url presented associate
    H{
        { font-size 20 }
        { font-style bold }
        { background HEXCOLOR: ff6600 }
        { foreground COLOR: black }
    } assoc-union format nl ;

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
