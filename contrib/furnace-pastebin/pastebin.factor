IN: furnace:pastebin
USING: calendar kernel namespaces sequences furnace hashtables
math ;

TUPLE: paste n summary author contents date ;

C: paste ( summary author contents -- paste )
    [ set-paste-contents ] keep
    [ set-paste-author ] keep
    [ set-paste-summary ] keep ;

TUPLE: pastebin pastes ;

C: pastebin ( -- pastebin )
    V{ } clone over set-pastebin-pastes ;

: add-paste ( paste pastebin -- )
    now timestamp>http-string pick set-paste-date
    dup pastebin-pastes length pick set-paste-n
    pastebin-pastes push ;

<pastebin> "pastebin" set-global

: get-paste ( n -- paste )
    "pastebin" get pastebin-pastes nth ;

: show-paste ( n -- )
    "Paste"
    swap string>number get-paste
    "show-paste" render-page ;

\ show-paste { { "n" "0" } } define-action

: new-paste ( -- )
    "New paste" f "new-paste" render-page ;

\ new-paste { } define-action

: submit-paste ( summary author contents -- )
    <paste> "pastebin" get-global add-paste ;

\ submit-paste {
    { "summary" "" }
    { "author" "" }
    { "contents" "" }
} define-action

: paste-list ( -- )
    [
        [ show-paste ] "show-paste-quot" set
        [ new-paste ] "new-paste-quot" set

        "Pastebin"
        "pastebin" get
        "paste-list" render-page
    ] with-scope ;

\ paste-list { } define-action

\ submit-paste [ paste-list ] define-redirect

"pastebin" "paste-list" "contrib/pastebin" web-app
