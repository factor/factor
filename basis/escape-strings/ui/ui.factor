! Copyright (C) 2019 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors documents escape-strings io kernel sequences ui
ui.gadgets ui.gadgets.editors ui.gadgets.tracks ui.gestures ;
IN: escape-strings.ui

TUPLE: escape-string-editor < source-editor ;

: <escape-string-editor> ( -- editor )
    escape-string-editor new-editor ; inline

M: escape-string-editor handle-gesture
    [ call-next-method ] 2keep
    nip parent>> children>> first3
    [ model>> doc-string ] 2dip
    [ drop [ number-escape-string ] dip model>> set-doc-string ]
    [ nip [ escape-string ] dip model>> set-doc-string ] 3bi ;
: run-escape-string-editor ( -- )
    [
        vertical <track>
            ! { 450 500 } >>pref-dim
            { 450 500 } >>dim

        <escape-string-editor>
            ! { 450 500 } >>pref-dim
            { 450 500 } >>dim
            1/3 track-add

        <escape-string-editor>
            { 900 1000 } >>pref-dim
            1/3 track-add

        <escape-string-editor>
            { 900 1000 } >>pref-dim
            1/3 track-add

        "escape-string editor" open-window
    ] with-ui ;

MAIN: run-escape-string-editor
