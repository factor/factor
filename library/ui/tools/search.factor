! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: arrays gadgets gadgets-labels gadgets-panes
gadgets-scrolling gadgets-text gadgets-theme
generic help tools kernel models sequences words
gadgets-borders gadgets-lists namespaces parser hashtables io
completion styles strings modules ;

TUPLE: live-search field list ;

: find-live-search [ live-search? ] find-parent ;

: find-search-list find-live-search live-search-list ;

TUPLE: search-field ;

C: search-field ( -- gadget )
    <editor> over set-gadget-delegate
    dup dup set-control-self
    [ editor-doc-end ] keep ;

search-field H{
    { T{ key-down f f "UP" } [ find-search-list select-prev ] }
    { T{ key-down f f "DOWN" } [ find-search-list select-next ] }
    { T{ key-down f f "RETURN" } [ find-search-list call-action ] }
} set-gestures

: <search-model> ( producer -- model )
    gadget get live-search-field control-model 200 <delay>
    [ "\n" join ] <filter>
    swap <filter> ;

: <search-list> ( action seq producer presenter -- gadget )
    -rot curry <search-model> <list> ;

C: live-search ( string action seq producer presenter -- gadget )
    {
        {
            [ <search-field> ]
            set-live-search-field
            f
            @top
        }
        {
            [ <search-list> ]
            set-live-search-list
            [ <scroller> ]
            @center
        }
    } make-frame*
    [ live-search-field set-editor-text ] keep ;

M: live-search focusable-child* live-search-field ;

: <word-search> ( string action -- gadget )
    all-words
    [ word-completions ]
    [ word-name ]
    <live-search> ;

: help-completions ( str pairs -- seq )
    >r >lower r>
    [ second >lower ] swap completions
    [ first <link> ] map ;

: <help-search> ( string action -- gadget )
    all-articles [ dup article-title 2array ] map
    [ help-completions ]
    [ article-title ]
    <live-search> ;

: <source-files-search> ( string action -- gadget )
    source-files get hash-keys natural-sort
    [ string-completions [ <pathname> ] map ]
    [ pathname-string ]
    <live-search> ;

: module-completions ( str modules -- seq )
    [ module-name ] swap completions ;

: <modules-search> ( string action -- gadget )
    available-modules [ module-completions ]
    [ module-name ]
    <live-search> ;

: <vocabs-search> ( string action -- gadget )
    vocabs [ string-completions [ <vocab-link> ] map ]
    [ vocab-link-name ]
    <live-search> ;

: <history-search> ( string action seq -- gadget )
    [ string-completions [ <input> ] map ]
    [ input-string ]
    <live-search> ;
