USING: sequences rss arrays concurrency kernel sorting
html.elements io assocs namespaces math threads vocabs html
furnace http.server.templating calendar math.parser splitting
continuations debugger system http.server.responders
xml.writer ;
IN: webapps.planet

: print-posting-summary ( posting -- )
    <p "news" =class p>
        <b> dup entry-title write </b> <br/>
        <a entry-link =href "more" =class a>
            "Read More..." write
        </a>
    </p> ;

: print-posting-summaries ( postings -- )
    [ print-posting-summary ] each ;

: print-blogroll ( blogroll -- )
    <ul "description" =class ul>
        [
            <li> <a dup third =href a> first write </a> </li>
        ] each
    </ul> ;

: format-date ( date -- string )
    10 head "-" split [ string>number ] map
    first3 0 0 0 0 <timestamp>
    [
        dup timestamp-day #
        " " %
        dup timestamp-month month-abbreviations nth %
        ", " %
        timestamp-year #
    ] "" make ;

: print-posting ( posting -- )
    <h2 "posting-title" =class h2>
        <a dup entry-link =href a>
            dup entry-title write-html
        </a>
    </h2>
    <p "posting-body" =class p>
        dup entry-description write-html
    </p>
    <p "posting-date" =class p>
        entry-pub-date format-date write
    </p> ;

: print-postings ( postings -- )
    [ print-posting ] each ;

SYMBOL: default-blogroll
SYMBOL: cached-postings

: mini-planet-factor ( -- )
    cached-postings get 4 head print-posting-summaries ;

: planet-factor ( -- )
    serving-html [ "planet" render-template ] with-html-stream ;

\ planet-factor { } define-action

: planet-feed ( -- feed )
    "[ planet-factor ]"
    "http://planet.factorcode.org"
    cached-postings get 30 head <feed> ;

: feed.xml ( -- )
    "text/xml" serving-content
    planet-feed feed>xml write-xml ;

\ feed.xml { } define-action

: style.css ( -- )
    "text/css" serving-content
    "style.css" send-resource ;

\ style.css { } define-action

SYMBOL: last-update

: diagnostic write print flush ;

: fetch-feed ( triple -- feed )
    second
    dup "Fetching " diagnostic
    dup download-feed feed-entries
    swap "Done fetching " diagnostic ;

: <posting> ( author entry -- entry' )
    clone
    [ ": " swap entry-title 3append ] keep
    [ set-entry-title ] keep ;

: ?fetch-feed ( triple -- feed/f )
    [ fetch-feed ] [ error. drop f ] recover ;

: fetch-blogroll ( blogroll -- entries )
    dup 0 <column>
    swap [ ?fetch-feed ] parallel-map
    [ [ <posting> ] curry* map ] 2map concat ;

: sort-entries ( entries -- entries' )
    [ [ entry-pub-date ] compare ] sort <reversed> ;

: update-cached-postings ( -- )
    default-blogroll get
    fetch-blogroll sort-entries
    cached-postings set-global ;

: update-thread ( -- )
    millis last-update set-global
    [ update-cached-postings ] in-thread
    10 60 * 1000 * sleep
    update-thread ;

: start-update-thread ( -- )
    [ update-thread ] in-thread ;

"planet" "planet-factor" "extra/webapps/planet" web-app

{
    { "Berlin Brown" "http://factorlang-fornovices.blogspot.com/feeds/posts/default" "http://factorlang-fornovices.blogspot.com" }
    { "Chris Double" "http://www.blogger.com/feeds/18561009/posts/full/-/factor" "http://www.bluishcoder.co.nz/" }
    { "Elie Chaftari" "http://fun-factor.blogspot.com/feeds/posts/default" "http://fun-factor.blogspot.com/" }
    { "Doug Coleman" "http://code-factor.blogspot.com/feeds/posts/default" "http://code-factor.blogspot.com/" }
    { "Daniel Ehrenberg" "http://useless-factor.blogspot.com/feeds/posts/default" "http://useless-factor.blogspot.com/" }
    { "Gavin Harrison" "http://gmh33.blogspot.com/feeds/posts/default" "http://gmh33.blogspot.com/" }
    { "Kio M. Smallwood"
    "http://sekenre.wordpress.com/feed/atom/"
    "http://sekenre.wordpress.com/" }
    ! { "Phil Dawes" "http://www.phildawes.net/blog/category/factor/feed/atom" "http://www.phildawes.net/blog/" }
    { "Samuel Tardieu" "http://www.rfc1149.net/blog/tag/factor/feed/atom/" "http://www.rfc1149.net/blog/tag/factor/" }
    { "Slava Pestov" "http://factor-language.blogspot.com/atom.xml" "http://factor-language.blogspot.com/" }
} default-blogroll set-global
