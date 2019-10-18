USING: cont-responder io kernel namespaces sequences xml ;

SYMBOL: darcs-directory

"/var/www/factorcode.org/repos/" darcs-directory set

: darcs-changelog
    darcs-directory get cd
    "darcs changes --xml" "r" <process-stream> contents xml ;

: rss-item ( { title date author } -- )
    "item" [ ] [
        { "title" "pubDate" "author" } [ [ ] text-tag ] 2each
    ] tag ;

: ?tag-name ( tag -- name/f )
    dup tag? [ tag-name ] [ drop f ] if ;

: children-named ( tag name -- seq )
    swap tag-children [ ?tag-name = ] subset-with ;

: tag-child ( tag name -- tag )
    children-named first ;

: patch>rss-item ( tag -- { title link author date } )
    [
        dup "name" tag-child tag-children %
        tag-props [ "local_date" get , "author" get , ] bind
    ] { } make ;

SYMBOL: rss-feed-title
SYMBOL: rss-feed-link
SYMBOL: rss-feed-description

"Factor DARCS repository" rss-feed-title set
"http://factorcode.org/repos/" rss-feed-link set
"Recent patches applied to the Factor DARCS repository" rss-feed-description set

: rss-metadata ( -- )
    { rss-feed-title rss-feed-link rss-feed-description }
    { "title" "link" "description" }
    [ >r get r> [ ] text-tag ] 2each ;

: rss-feed ( items -- string )
    [
        "rss" [ "2.0" "version" set ] [
            "channel" [ ] [ rss-metadata [ rss-item ] each ] tag
        ] tag
    ] make-xml xml>string ;

: changelog>rss-feed ( xml -- string )
    "patch" children-named [ patch>rss-item ] map rss-feed ;

: darcs-rss-feed darcs-changelog changelog>rss-feed print ;

"darcs" [ darcs-rss-feed ] install-cont-responder
