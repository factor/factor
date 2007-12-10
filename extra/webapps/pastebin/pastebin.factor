USING: calendar furnace furnace.validator io.files kernel
namespaces sequences store http.server.responders html
math.parser rss xml.writer ;
IN: webapps.pastebin

TUPLE: pastebin pastes ;

: <pastebin> ( -- pastebin )
    V{ } clone pastebin construct-boa ;

TUPLE: paste
summary author channel mode contents date
annotations n ;

: <paste> ( summary author channel mode contents -- paste )
    f V{ } clone f paste construct-boa ;

TUPLE: annotation summary author mode contents ;

C: <annotation> annotation

SYMBOL: store

"pastebin.store" resource-path load-store store set-global

<pastebin> \ pastebin store get store-variable

: get-paste ( n -- paste )
    pastebin get pastebin-pastes nth ;

: show-paste ( n -- )
    serving-html
    get-paste
    [ "show-paste" render-component ] with-html-stream ;

\ show-paste { { "n" v-number } } define-action

: new-paste ( -- )
    serving-html
    [ "new-paste" render-template ] with-html-stream ;

\ new-paste { } define-action

: paste-list ( -- )
    serving-html
    [
        [ show-paste ] "show-paste-quot" set
        [ new-paste ] "new-paste-quot" set
        pastebin get "paste-list" render-component
    ] with-html-stream ;

\ paste-list { } define-action

: paste-link ( paste -- link )
    paste-n number>string [ show-paste ] curry quot-link ;

: paste-feed ( -- entries )
    pastebin get pastebin-pastes [
        {
            paste-summary
            paste-link
            paste-date
        } get-slots timestamp>rfc3339 f swap <entry>
    ] map ;

: feed.xml ( -- )
    "text/xml" serving-content
    "pastebin"
    "http://pastebin.factorcode.org"
    paste-feed <feed> feed>xml write-xml ;

\ feed.xml { } define-action

: save-pastebin-store ( -- )
    store get-global save-store ;

: add-paste ( paste pastebin -- )
    >r now over set-paste-date r>
    pastebin-pastes 2dup length swap set-paste-n push ;

: submit-paste ( summary author channel mode contents -- )
    <paste> [
        \ pastebin get-global add-paste
        save-pastebin-store
    ] keep paste-link permanent-redirect ;

\ submit-paste {
    { "summary" "- no summary -" v-default }
    { "author" "- no author -" v-default }
    { "channel" "#concatenative" v-default }
    { "mode" "factor" v-default }
    { "contents" v-required }
} define-action

: annotate-paste ( n summary author mode contents -- )
    <annotation> swap get-paste
    paste-annotations push
    save-pastebin-store ;

\ annotate-paste {
    { "n" v-required v-number }
    { "summary" "- no summary -" v-default }
    { "author" v-required }
    { "mode" "factor" v-default }
    { "contents" v-required }
} define-action

\ annotate-paste [ "n" show-paste ] define-redirect

: style.css ( -- )
    "text/css" serving-content
    "style.css" send-resource ;

\ style.css { } define-action

"pastebin" "paste-list" "extra/webapps/pastebin" web-app
