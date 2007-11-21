USING: sequences rss arrays concurrency kernel sorting
html.elements io assocs namespaces math threads vocabs html
furnace http.server.templating calendar math.parser splitting
continuations debugger system ;
IN: webapps.planet

TUPLE: posting author title date link body ;

: diagnostic write print flush ;

: fetch-feed ( pair -- feed )
    second
    dup "Fetching " diagnostic
    dup news-get feed-entries
    swap "Done fetching " diagnostic ;

: fetch-blogroll ( blogroll -- entries )
    #! entries is an array of { author entries } pairs.
    dup [
        [ fetch-feed ] [ error. drop f ] recover
    ] parallel-map [ ] subset
    [ [ >r first r> 2array ] curry* map ] 2map concat ;

: sort-entries ( entries -- entries' )
    [ [ second entry-pub-date ] compare ] sort <reversed> ;

: <posting> ( pair -- posting )
    #! pair has shape { author entry }
    first2
    { entry-title entry-pub-date entry-link entry-description }
    get-slots posting construct-boa ;

: print-posting-summary ( posting -- )
    <p "news" =class p>
        <b> dup posting-title write </b> <br/>
        "- " write
        dup posting-author write bl
        <a posting-link =href "more" =class a>
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
        <a dup posting-link =href a>
            dup posting-title write-html
            " - " write
            dup posting-author write
        </a>
    </h2>
    <p "posting-body" =class p> dup posting-body write-html </p>
    <p "posting-date" =class p> posting-date format-date write </p> ;

: print-postings ( postings -- )
    [ print-posting ] each ;

: browse-webapp-source ( vocab -- )
    <a f >vocab-link browser-link-href =href a>
        "Browse source" write
    </a> ;

SYMBOL: default-blogroll
SYMBOL: cached-postings

: update-cached-postings ( -- )
    default-blogroll get fetch-blogroll sort-entries
    [ <posting> ] map
    cached-postings set-global ;

: mini-planet-factor ( -- )
    cached-postings get 4 head print-posting-summaries ;

: planet-factor ( -- )
    [
        "resource:extra/webapps/planet/planet.fhtml"
        run-template-file
    ] with-html-stream ;

\ planet-factor { } define-action

{
    { "Chris Double" "http://www.bluishcoder.co.nz/atom.xml" "http://www.bluishcoder.co.nz/" }
    { "Elie Chaftari" "http://fun-factor.blogspot.com/feeds/posts/default" "http://fun-factor.blogspot.com/" }
    { "Doug Coleman" "http://code-factor.blogspot.com/feeds/posts/default" "http://code-factor.blogspot.com/" }
    { "Daniel Ehrenberg" "http://useless-factor.blogspot.com/feeds/posts/default" "http://useless-factor.blogspot.com/" }
    { "Kio M. Smallwood"
    "http://sekenre.wordpress.com/feed/atom/"
    "http://sekenre.wordpress.com/" }
    { "Samuel Tardieu" "http://www.rfc1149.net/blog/tag/factor/feed/atom/" "http://www.rfc1149.net/blog/tag/factor/" }
    { "Slava Pestov" "http://factor-language.blogspot.com/atom.xml" "http://factor-language.blogspot.com/" }
} default-blogroll set-global

SYMBOL: last-update

: update-thread ( -- )
    millis last-update set-global
    [ update-cached-postings ] in-thread
    10 60 * 1000 * sleep
    update-thread ;

: start-update-thread ( -- )
    [ update-thread ] in-thread ;

"planet" "planet-factor" "extra/webapps/planet" web-app

: merge-feeds ( feeds -- feed )
    [ feed-entries ] map concat sort-entries ;

: planet-feed ( -- feed )
    default-blogroll get [ second news-get ] map merge-feeds 
    >r "[ planet-factor ]" "http://planet.factorcode.org" r> <entry>
    generate-atom ;

: feed.xml planet-feed ;

\ feed.xml { } define-action
