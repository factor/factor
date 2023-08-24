! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors formatting html.entities html.parser
html.parser.analyzer html.parser.printer http.client images.http
images.viewer images.viewer.prettyprint io kernel parser
prettyprint.custom prettyprint.sections regexp sequences strings
ui wrap.strings ;

IN: xkcd

<PRIVATE

: comic-image ( url -- image )
    http-get nip
    R/ \/\/imgs\.xkcd\.com\/comics\/[^\.]+\.(png|jpg)/
    first-match >string "https:" prepend load-http-image ;

: comic-image. ( url -- )
    comic-image image. ;

: comic-text ( url -- string )
    scrape-html nip "transcript" find-by-id-between
    html-text html-unescape ;

: comic-text. ( url -- )
    comic-text 80 wrap-string print ;

: comic. ( url -- )
    ui-running? [ comic-image. ] [ comic-text. ] if ;

PRIVATE>

: xkcd-url ( n -- url )
    "https://xkcd.com/%s/" sprintf ;

: xkcd-image ( n -- image )
    xkcd-url comic-image ;

: xkcd. ( n -- )
    xkcd-url comic. ;

: random-xkcd. ( -- )
    "https://c.xkcd.com/random/comic/" comic. ;

: latest-xkcd. ( -- )
    "https://xkcd.com" comic. ;

TUPLE: xkcd number image ;

C: <xkcd> xkcd

SYNTAX: XKCD: scan-number dup xkcd-image <xkcd> suffix! ;

M: xkcd pprint* image>> <image-section> add-section ;
