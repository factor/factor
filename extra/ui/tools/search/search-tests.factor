USING: assocs ui.tools.search help.topics io.files io.styles
kernel namespaces sequences source-files threads timers
tools.test ui.gadgets ui.gadgets.controls ui.gestures vocabs
vocabs.loader words ;
IN: temporary

timers get [ init-timers ] unless

[ f ] [
    "no such word with this name exists, certainly"
    f f <definition-search>
    T{ key-down f { C+ } "x" } swap search-gesture
] unit-test

: test-live-search ( gadget quot -- ? )
    >r dup graft 300 sleep do-timers
    dup live-search-list control-value
    dup empty? [ "Empty" throw ] when
    r> all?
    >r ungraft r> ;

[ t ] [
    "swp" all-words f <definition-search>
    [ word? ] test-live-search
] unit-test

[ t ] [
    "" all-words t <definition-search>
    dup graft
    { "set-word-prop" } over live-search-field set-control-value
    300 sleep
    do-timers
    search-value \ set-word-prop eq?
] unit-test

[ t ] [
    "quot" <help-search>
    [ link? ] test-live-search
] unit-test

[ t ] [
    "factor" source-files get keys <source-file-search>
    [ pathname? ] test-live-search
] unit-test

[ t ] [
    "kern" <vocab-search>
    [ vocab-spec? ] test-live-search
] unit-test

[ t ] [
    "a" { "a" "b" "aa" } <history-search>
    [ input? ] test-live-search
] unit-test
