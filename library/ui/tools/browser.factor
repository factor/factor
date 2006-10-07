! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences kernel gadgets-panes definitions
prettyprint gadgets-theme gadgets-borders gadgets
generic gadgets-scrolling math io words models styles
namespaces gadgets-tracks gadgets-presentations gadgets-grids
gadgets-workspace gadgets-frames help gadgets-buttons
gadgets-search tools ;
IN: gadgets-browser

TUPLE: browser navigator definitions search ;

TUPLE: definitions showing ;

: find-definitions ( gadget -- definitions )
    [ definitions? ] find-parent ;

: definition-index ( definition definitions -- n )
    definitions-showing index ;

: close-definition ( gadget definition -- )
    over find-definitions definitions-showing delete
    unparent ;

: close-definitions ( definitions -- )
    dup clear-gadget definitions-showing delete-all ;

C: definitions ( -- gadget )
    <pile> over set-delegate
    { 2 2 } over set-pack-gap
    V{ } clone over set-definitions-showing ;

TUPLE: tile definition gadget ;

: find-tile [ tile? ] find-parent ;

: close-tile ( tile -- )
    dup tile-definition over find-definitions
    definitions-showing delete
    unparent ;

: <tile-content> ( definition toolbar -- gadget )
    >r [ see ] make-pane r> 2array
    make-pile { 5 5 } over set-pack-gap
    <default-border> dup faint-boundary ;

C: tile ( definition -- gadget )
    2dup { tile } <toolbar>
    <tile-content> over set-gadget-delegate
    [ set-tile-definition ] keep ;

: show-definition ( definition definitions -- )
    2dup definition-index dup 0 >= [
        over nth-gadget swap scroll>rect drop
    ] [
        drop 2dup definitions-showing push
        swap <tile> over add-gadget
        scroll>bottom
    ] if ;

: <list-control> ( model quot -- gadget )
    [ map [ first2 write-object terpri ] each ] curry
    <pane-control> ;

TUPLE: navigator vocab ;

: <vocab-list> ( -- gadget )
    vocabs <model> [ dup <vocab-link> 2array ]
    <list-control> ;

: <word-list> ( model -- gadget )
    gadget get navigator-vocab
    [ words natural-sort ] <filter>
    [ dup word-name swap 2array ]
    <list-control> ;

C: navigator ( -- gadget )
    f <model> over set-navigator-vocab
    {
        { [ <vocab-list> ] f [ <scroller> ] 1/2 }
        { [ <word-list> ] f [ <scroller> ] 1/2 }
    } { 1 0 } make-track* ;

C: browser ( -- gadget )
    {
        {
            [ <navigator> ]
            set-browser-navigator
            f
            1/5
        }
        {
            [ <definitions> ]
            set-browser-definitions
            [ <scroller> ]
            3/5
        }
        {
            [ "" [ browser call-tool ] <word-search> ]
            set-browser-search
            f
            1/5
        }
    } { 0 1 } make-track* ;

M: browser focusable-child* browser-search ;

: show-vocab ( vocab browser -- )
    browser-navigator navigator-vocab set-model* ;

: show-word ( word browser -- )
    over word-vocabulary over show-vocab
    browser-definitions show-definition ;

: clear-browser ( browser -- )
    browser-definitions close-definitions ;

browser "Toolbar" {
    { "Clear" T{ key-down f f "CLEAR" } [ clear-browser ] }
} define-commands

M: browser call-tool*
    over vocab-link? [
        >r vocab-link-name r> show-vocab
    ] [
        show-word
    ] if ;

M: browser tool-scroller browser-definitions find-scroller ;

M: browser tool-help drop "ui-browser" ;
