! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: furnace:help
USING: furnace help html kernel sequences words strings ;

: string>topic ( string -- topic )
    " " split dup length 1 = [ first ] when ;

: show-help ( topic -- )
    dup article-title [
        [ help ] with-html-stream
    ] html-document ;

\ show-help {
    { "topic" "handbook" v-default string>topic }
} define-action

"help" "show-help" "contrib/furnace/tools" web-app

M: link browser-link-href
    link-name [ \ f ] unless* dup word? [
        browser-link-href
    ] [
        dup [ string? ] all? [ " " join ] when
        [ show-help ] curry quot-link
    ] if ;
