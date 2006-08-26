! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: new-browser
USING: arrays sequences kernel gadgets-panes definitions
prettyprint gadgets-tiles gadgets-theme gadgets-borders gadgets
generic gadgets-scrolling math io words models styles
namespaces gadgets-tracks gadgets-presentations ;

TUPLE: definitions showing ;

: find-definitions ( gadget -- definitions )
    [ definitions? ] find-parent ;

: definition-index ( definition definitions -- n )
    definitions-showing index ;

: close-definition ( gadget definition -- )
    over find-definitions definitions-showing delete
    unparent ;

: <definition-gadget> ( definition -- gadget )
    dup [ see ] make-pane <default-border>
    over unparse rot [ close-definition ] curry <tile>
    dup faint-boundary ;

C: definitions ( -- gadget )
    <pile> over set-delegate
    { 5 5 } over set-pack-gap
    V{ } clone over set-definitions-showing ;

: show-definition ( definition definitions -- )
    2dup definition-index dup 0 >= [
        over nth-gadget swap scroll>rect drop
    ] [
        drop 2dup definitions-showing push
        swap <definition-gadget> over add-gadget
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

TUPLE: browser navigator definitions ;

C: browser ( -- gadget )
    {
        { [ <navigator> ] set-browser-navigator f 1/4 }
        { [ <definitions> ] set-browser-definitions [ <scroller> ] 3/4 }
    } { 0 1 } make-track* ;

: show-vocab ( vocab browser -- )
    browser-navigator navigator-vocab set-model ;

M: browser gadget-title drop "Browser" <model> ;

: browser-window ( -- ) <browser> open-window ;

: show-word ( word browser -- )
    over word-vocabulary over show-vocab
    browser-definitions show-definition ;

: browse ( obj browser -- )
    over vocab-link? [
        >r vocab-link-name r> show-vocab
    ] [
        show-word
    ] if ;

: browser-tool [ browser? ] [ <browser> ] [ browse ] ;

M: word show browser-tool call-tool ;

M: vocab-link show browser-tool call-tool ;
