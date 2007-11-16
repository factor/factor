USING: calendar furnace furnace.validator io.files kernel namespaces
sequences store ;
IN: webapps.pastebin

TUPLE: pastebin pastes ;

: <pastebin> ( -- pastebin )
    V{ } clone pastebin construct-boa ;

TUPLE: paste n summary article author channel contents date annotations ;

: <paste> ( summary author channel contents -- paste )
    V{ } clone
    {
        set-paste-summary
        set-paste-author
        set-paste-channel
        set-paste-contents
        set-paste-annotations
    } paste construct ;

TUPLE: annotation summary author contents ;

C: <annotation> annotation


SYMBOL: store

"pastebin.store" resource-path load-store store set-global

<pastebin> \ pastebin store get store-variable

: get-paste ( n -- paste )
    pastebin get pastebin-pastes nth ;

: show-paste ( n -- )
    get-paste "show-paste" "Paste" render-page ;

\ show-paste { { "n" v-number } } define-action

: new-paste ( -- )
    f "new-paste" "New paste" render-page ;

\ new-paste { } define-action

: paste-list ( -- )
    [
        [ show-paste ] "show-paste-quot" set
        [ new-paste ] "new-paste-quot" set
        pastebin get "paste-list" "Pastebin" render-page
    ] with-scope ;

\ paste-list { } define-action



: save-pastebin-store ( -- )
    store get-global save-store ;

: add-paste ( paste pastebin -- )
    >r now timestamp>http-string over set-paste-date r>
    pastebin-pastes
    [ length over set-paste-n ] keep push ;

: submit-paste ( summary author channel contents -- )
    <paste>
    \ pastebin get-global add-paste
    save-pastebin-store ;

\ submit-paste {
    { "summary" v-required }
    { "author" v-required }
    { "channel" "#concatenative" v-default }
    { "contents" v-required }
} define-action

\ submit-paste [ paste-list ] define-redirect

: annotate-paste ( n summary author contents -- )
    <annotation> swap get-paste
    paste-annotations push
    save-pastebin-store ;

\ annotate-paste {
    { "n" v-required v-number }
    { "summary" v-required }
    { "author" v-required }
    { "contents" v-required }
} define-action

\ annotate-paste [ "n" show-paste ] define-redirect

"pastebin" "paste-list" "extra/webapps/pastebin" web-app
