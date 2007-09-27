! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel furnace furnace.validator http.server.responders
       help help.topics html splitting sequences words strings 
       quotations macros vocabs tools.browser combinators
       arrays io.files ;
IN: webapps.help 

: show-help ( topic -- )
    serving-html
    dup article-title [
        [ help ] with-html-stream
    ] simple-html-document ;

: string>topic ( string -- topic )
    " " split dup length 1 = [ first ] when ;

\ show-help {
    { "topic" "handbook" v-default string>topic }
} define-action

M: link browser-link-href
    link-name 
    dup word? [
        browser-link-href
    ] [
        dup array? [ " " join ] when
        [ show-help ] curry quot-link
    ] if ;

: show-word ( word vocab -- )
    lookup show-help ;

\ show-word {
    { "vocab" "kernel" v-default }
    { "word" "call" v-default }
} define-action

M: word browser-link-href
    dup word-name swap word-vocabulary
    [ show-word ] 2curry quot-link ;

: show-vocab ( vocab -- )
    f >vocab-link show-help ;

\ show-vocab {
    { "vocab" "kernel" v-default }
} define-action

M: vocab-spec browser-link-href
    vocab-name [ show-vocab ] curry quot-link ;

: show-vocabs-tagged ( tag -- )
    <vocab-tag> show-help ;

\ show-vocabs-tagged {
    { "tag" }
} define-action

M: vocab-tag browser-link-href
    vocab-tag-name [ show-vocabs-tagged ] curry quot-link ;

: show-vocabs-by ( author -- )
    <vocab-author> show-help ;

\ show-vocabs-by {
    { "author" }
} define-action

M: vocab-author browser-link-href
    vocab-author-name [ show-vocabs-by ] curry quot-link ;

"help" "show-help" "extra/webapps/help" web-app

! Hard-coding for factorcode.org
PREDICATE: pathname resource-pathname
    pathname-string "resource:" head? ;

M: resource-pathname browser-link-href
    pathname-string
    "resource:" ?head drop
    "/responder/resources/" swap append ;
