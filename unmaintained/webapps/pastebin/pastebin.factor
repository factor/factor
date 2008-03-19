USING: calendar furnace furnace.validator io.files kernel
namespaces sequences http.server.responders html math.parser rss
xml.writer xmode.code2html math calendar.format ;
IN: webapps.pastebin

TUPLE: pastebin pastes ;

: <pastebin> ( -- pastebin )
    V{ } clone pastebin construct-boa ;

<pastebin> pastebin set-global

TUPLE: paste
summary author channel mode contents date
annotations n ;

: <paste> ( summary author channel mode contents -- paste )
    f V{ } clone f paste construct-boa ;

TUPLE: annotation summary author mode contents ;

C: <annotation> annotation

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

: safe-head ( seq n -- seq' )
    over length min head ;

: paste-feed ( -- entries )
    pastebin get pastebin-pastes <reversed> 20 safe-head [
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

: add-paste ( paste pastebin -- )
    >r now over set-paste-date r>
    pastebin-pastes 2dup length swap set-paste-n push ;

: submit-paste ( summary author channel mode contents -- )
    <paste> [ pastebin get add-paste ] keep
    paste-link permanent-redirect ;

\ new-paste
\ submit-paste {
    { "summary" v-required }
    { "author" v-required }
    { "channel" }
    { "mode" v-required }
    { "contents" v-required }
} define-form

\ new-paste {
    { "channel" "#concatenative" }
    { "mode" "factor" }
} default-values

: annotate-paste ( n summary author mode contents -- )
    <annotation> swap get-paste
    [ paste-annotations push ] keep
    paste-link permanent-redirect ;

[ "n" show-paste ]
\ annotate-paste {
    { "n" v-required v-number }
    { "summary" v-required }
    { "author" v-required }
    { "mode" v-required }
    { "contents" v-required }
} define-form

\ show-paste {
    { "mode" "factor" }
} default-values

: style.css ( -- )
    "text/css" serving-content
    "style.css" send-resource ;

\ style.css { } define-action

"pastebin" "paste-list" "extra/webapps/pastebin" web-app
