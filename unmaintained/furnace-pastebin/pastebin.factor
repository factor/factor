IN: furnace:pastebin
USING: calendar concurrency irc kernel namespaces sequences
furnace hashtables math store ;

TUPLE: paste n summary author channel contents date annotations ;

TUPLE: annotation summary author contents ;

C: paste ( summary author channel contents -- paste )
    V{ } clone over set-paste-annotations
    [ set-paste-contents ] keep
    [ set-paste-channel ] keep
    [ set-paste-author ] keep
    [ set-paste-summary ] keep ;

TUPLE: pastebin pastes ;

C: pastebin ( -- pastebin )
    V{ } clone over set-pastebin-pastes ;

SYMBOL: store
"pastebin.store" load-store store set-global
<pastebin> pastebin store get store-variable

: add-paste ( paste pastebin -- )
    now timestamp>http-string pick set-paste-date
    dup pastebin-pastes length pick set-paste-n
    pastebin-pastes push ;

: get-paste ( n -- paste )
    pastebin get pastebin-pastes nth ;

: show-paste ( n -- )
    get-paste "show-paste" "Paste" render-page ;

\ show-paste { { "n" v-number } } define-action

: new-paste ( -- )
    f "new-paste" "New paste" render-page ;

\ new-paste { } define-action

: make-remote-process
    "trifocus.net" 4030 <node> "public-irc" <remote-process> ;

: alert-new-paste ( paste -- )
    >r make-remote-process r>
    f over paste-channel rot [
        dup paste-author %
        " pasted " %
        CHAR: " ,
        dup paste-summary %
        CHAR: " ,
        " at " %
        "http://wee-url.com/responder/pastebin/show-paste?n=" %
        paste-n #
    ] "" make <chat-command> swap send ;

: alert-annotation ( annotation paste -- )
    make-remote-process -rot
    f over paste-channel 2swap [
        over annotation-author %
        " annotated paste " %
        " with \"" %
        over annotation-summary %
        "\" at " %
        "http://wee-url.com/responder/pastebin/show-paste?n=" %
        dup paste-n #
        2drop
    ] "" make <chat-command> swap send ;
    

: submit-paste ( summary author channel contents -- )
    <paste> dup pastebin get-global add-paste
    alert-new-paste store get save-store ;

\ submit-paste {
    { "summary" v-required }
    { "author" v-required }
    { "channel" "#concatenative" v-default }
    { "contents" v-required }
} define-action

: paste-list ( -- )
    [
        [ show-paste ] "show-paste-quot" set
        [ new-paste ] "new-paste-quot" set

        pastebin get "paste-list" "Pastebin" render-page
    ] with-scope ;

\ paste-list { } define-action

\ submit-paste [ paste-list ] define-redirect

: annotate-paste ( paste# summary author contents -- )
    <annotation> swap get-paste
    [ paste-annotations push ] 2keep
    alert-annotation store get save-store ;

\ annotate-paste {
    { "n" v-required v-number }
    { "summary" v-required }
    { "author" v-required }
    { "contents" v-required }
} define-action

\ annotate-paste [ "n" show-paste ] define-redirect

"pastebin" "paste-list" "apps/furnace-pastebin" web-app
