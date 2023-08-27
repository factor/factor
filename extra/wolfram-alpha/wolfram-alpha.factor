! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors formatting http http.client images.gif
images.http io io.styles kernel namespaces sequences splitting
ui urls.encoding xml xml.data xml.traversal ;

IN: wolfram-alpha

SYMBOL: wolfram-api-id

! "XXXXXX-XXXXXXXXXX" wolfram-api-id set-global

<PRIVATE

: query ( query -- xml )
    url-encode wolfram-api-id get-global
    "https://api.wolframalpha.com/v2/query?input=%s&appid=%s"
    sprintf http-get nip string>xml
    dup "error" tag-named [
        "msg" tag-named children>string throw
    ] when* ;

PRIVATE>

: wolfram-image. ( query -- )
    query "pod" tags-named [
        [
            "title" attr "%s:\n" sprintf H{
                { foreground COLOR: slate-gray }
                { font-name "sans-serif" }
                { font-style bold }
            } format
        ] [
            "img" deep-tags-named [
                "src" attr "  " write http-image.
            ] each
        ] bi
    ] each ;

: wolfram-text. ( query -- )
    query "pod" tags-named [
        [ "title" attr "%s:\n" printf ]
        [
            "plaintext" deep-tags-named [
                children>string split-lines
                [ "  %s\n" printf ] each
            ] each
        ] bi
    ] each ;

: wolfram. ( query -- )
    ui-running? [ wolfram-image. ] [ wolfram-text. ] if ;
