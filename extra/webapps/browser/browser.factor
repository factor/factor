! Copyright (C) 2004 Chris Double
! Copyright (C) 2004, 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel vocabs words assocs sorting inspector sequences 
       arrays quotations html furnace furnace.validator ;
IN: webapps.browser

TUPLE: list current options name ;

C: <list> list

: list ( current options name -- )
    <list> "list" render-template ;

: vocab-list ( vocab -- ) vocabs "vocab" list ;

: word-list ( word vocab -- )
    [ lookup [ word-name ] [ f ] if* ] keep
    vocab vocab-words keys natural-sort "word" list ;

: browser-title ( word vocab -- str )
    2dup lookup dup
    [ 2nip summary ] [ drop nip "IN: " swap append ] if ;

TUPLE: browser word vocab apropos ;

C: <browser> browser

: browse ( word vocab apropos -- )
    pick pick browser-title >r <browser> "browser" r> render-page ;

\ browse {
    { "word" }
    { "vocab" "kernel" v-default }
    { "apropos" }
} define-action

M: word browser-link-href
    dup word-name swap word-vocabulary f \ browse
    4array >quotation quot-link ;

"browser" "browse" "extra/webapps/browser" web-app
