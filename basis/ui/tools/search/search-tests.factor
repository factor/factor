USING: assocs ui.tools.search help.topics io.pathnames io.styles
kernel namespaces sequences source-files threads
tools.test ui.gadgets ui.gestures vocabs accessors
vocabs.loader words tools.test.ui debugger calendar ;
IN: ui.tools.search.tests

[ f ] [
    "no such word with this name exists, certainly"
    f f <definition-search>
    T{ key-down f { C+ } "x" } swap search-gesture
] unit-test

: assert-non-empty ( obj -- ) empty? f assert= ;

: update-live-search ( search -- seq )
    dup [
        300 milliseconds sleep
        list>> control-value
    ] with-grafted-gadget ;

: test-live-search ( gadget quot -- ? )
    [ update-live-search dup assert-non-empty ] dip all? ;

[ t ] [
    "swp" all-words f <definition-search>
    [ word? ] test-live-search
] unit-test

[ t ] [
    "" all-words t <definition-search>
    dup [
        { "set-word-prop" } over field>> set-control-value
        300 milliseconds sleep
        search-value \ set-word-prop eq?
    ] with-grafted-gadget
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
