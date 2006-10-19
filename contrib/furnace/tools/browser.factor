! Copyright (C) 2004 Chris Double
! Copyright (C) 2004, 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: furnace:browser
USING: definitions hashtables help html httpd io kernel memory
namespaces prettyprint sequences words xml furnace arrays ;

TUPLE: list current options name ;

: list ( current options name -- )
    <list> "list" render-template ;

: vocab-list ( vocab -- ) vocabs "vocab" list ;

: word-list ( word vocab -- )
    [ lookup [ word-name ] [ f ] if* ] keep
    vocab hash-keys natural-sort "word" list ;

: browser-title ( word vocab -- str )
    2dup lookup dup
    [ 2nip summary ] [ drop nip "IN: " swap append ] if ;

TUPLE: browser word vocab ;

: browse ( word vocab -- )
    2dup browser-title
    -rot <browser>
    "browser" render-page ;

\ browse {
    { "word" }
    { "vocab" "kernel" v-default }
} define-action

"browser" "browse" "contrib/furnace/tools" web-app

M: word browser-link-href
    dup word-name swap word-vocabulary \ browse
    3array >quotation quot-link ;
