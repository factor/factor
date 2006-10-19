IN: furnace:pastebin
USING: calendar kernel namespaces sequences furnace hashtables
math ;

TUPLE: paste n summary author channel contents date annotations ;

TUPLE: annotation summary author contents ;

C: paste ( summary author channel contents -- paste )
    V{ } clone over set-paste-annotations
    [ set-paste-contents ] keep
    [ set-paste-author ] keep
    [ set-paste-channel ] keep
    [ set-paste-summary ] keep ;

TUPLE: pastebin pastes ;

C: pastebin ( -- pastebin )
    V{ } clone over set-pastebin-pastes ;

: add-paste ( paste pastebin -- )
    now timestamp>http-string pick set-paste-date
    dup pastebin-pastes length pick set-paste-n
    pastebin-pastes push ;

<pastebin> pastebin set-global

: get-paste ( n -- paste )
    pastebin get pastebin-pastes nth ;

: show-paste ( n -- )
    "Paste"
    swap get-paste
    "show-paste" render-page ;

\ show-paste { { "n" v-number } } define-action

: new-paste ( -- )
    "New paste" f "new-paste" render-page ;

\ new-paste { } define-action

: submit-paste ( summary author channel contents -- )
    <paste> pastebin get-global add-paste ;

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

        "Pastebin"
        pastebin get
        "paste-list" render-page
    ] with-scope ;

\ paste-list { } define-action

\ submit-paste [ paste-list ] define-redirect

: annotate-paste ( paste# summary author contents -- )
    <annotation> swap get-paste paste-annotations push ;

\ annotate-paste {
    { "n" v-required v-number }
    { "summary" v-required }
    { "author" v-required }
    { "contents" v-required }
} define-action

\ annotate-paste [ "n" show-paste ] define-redirect

"pastebin" "paste-list" "contrib/furnace-pastebin" web-app
