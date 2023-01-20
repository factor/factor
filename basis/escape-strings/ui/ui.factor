! Copyright (C) 2019 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors checksums checksums.sha documents
escape-strings kernel math.parser models sequences ui ui.gadgets
ui.gadgets.editors ui.gadgets.labeled ui.gadgets.scrollers
ui.gadgets.tracks ;
IN: escape-strings.ui

TUPLE: escape-string-editor < source-editor source-model quot ;

: <escape-string-editor> ( source-model quot: ( str -- str' ) -- editor )
    escape-string-editor new-editor
        swap >>quot
        swap >>source-model ;

M: escape-string-editor graft*
    [ dup source-model>> add-connection ] [ call-next-method ] bi ;

M: escape-string-editor ungraft*
    [ dup source-model>> remove-connection ] [ call-next-method ] bi ;

M: escape-string-editor model-changed
    2dup source-model>> eq? [
        [ doc-string ] dip
        [ quot>> call( str -- str' ) ] [ set-editor-string ] bi
    ] [ call-next-method ] if ;

: containerize ( string tag open-delim close-delim -- string' )
    overd [ 1surround ] 2bi@ surround ;

: checksum-escape-string ( string checksum -- string' )
    [ drop ]
    [ checksum-bytes bytes>hex-string ] 2bi
    "[" "]" containerize ;

:: <escape-string-ui> ( -- gadget )
    vertical <track>
        1 >>fill
        { 10 10 } >>gap

    <source-editor> dup model>> :> source-model
    <scroller> "Plain Text" <labeled-gadget>
        1/4 track-add

    source-model [ number-escape-string ] <escape-string-editor>
    <scroller> "Number Escape" <labeled-gadget>
        1/4 track-add

    source-model [ escape-string ] <escape-string-editor>
    <scroller> "Escape" <labeled-gadget>
        1/4 track-add

    source-model [ sha-256 checksum-escape-string ] <escape-string-editor>
    <scroller> "SHA256 Escape" <labeled-gadget>
        1/4 track-add ;

MAIN-WINDOW: escape-string-ui
    {
        { title "Escape String Editor" }
        { pref-dim { 600 700 } }
    } <escape-string-ui> >>gadgets ;
