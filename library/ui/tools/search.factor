! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: arrays gadgets gadgets-labels gadgets-panes
gadgets-scrolling gadgets-text gadgets-theme
generic help tools kernel models sequences words
gadgets-borders gadgets-lists namespaces parser hashtables io
completion styles strings modules ;

TUPLE: live-search field list ;

: find-live-search [ [ live-search? ] is? ] find-parent ;

: find-search-list find-live-search live-search-list ;

TUPLE: search-field ;

C: search-field ( -- gadget )
    <editor> over set-gadget-delegate
    dup dup set-control-self
    [ editor-doc-end ] keep ;

search-field H{
    { T{ key-down f f "UP" } [ find-search-list select-prev ] }
    { T{ key-down f f "DOWN" } [ find-search-list select-next ] }
    { T{ key-down f f "RETURN" } [ find-search-list list-action ] }
} set-gestures

: <search-model> ( producer -- model )
    gadget get live-search-field control-model 200 <delay>
    [ "\n" join ] <filter>
    swap <filter> ;

: <search-list> ( hook seq producer presenter -- gadget )
    -rot curry <search-model> <list> ;

C: live-search ( string hook seq producer presenter -- gadget )
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

: delegate>live-search ( string hook seq producer presenter gadget -- )
    >r <live-search> r> set-gadget-delegate ;

TUPLE: word-search ;

C: word-search ( string action words -- gadget )
    >r
    [ word-completions ]
    [ word-name ]
    r>
    [ delegate>live-search ] keep ;

: help-completions ( str pairs -- seq )
    >r >lower r>
    [ second >lower ] swap completions
    [ first <link> ] map ;

TUPLE: help-search ;

C: help-search ( string action -- gadget )
    >r
    all-articles [ dup article-title 2array ] map
    [ [ second ] 2apply <=> ] sort
    [ help-completions ]
    [ article-title ]
    r>
    [ delegate>live-search ] keep ;

TUPLE: source-file-search ;

C: source-file-search ( string action -- gadget )
    >r
    source-files get hash-keys natural-sort
    [ string-completions [ <pathname> ] map ]
    [ pathname-string ]
    r>
    [ delegate>live-search ] keep ;

: module-completions ( str modules -- seq )
    [ module-name ] swap completions ;

TUPLE: module-search ;

: module-search ( string action -- gadget )
    >r
    available-modules [ module-completions ]
    [ module-name ]
    r>
    [ delegate>live-search ] keep ;

TUPLE: vocab-search ;

C: vocab-search ( string action -- gadget )
    >r
    vocabs [ string-completions [ <vocab-link> ] map ]
    [ vocab-link-name ]
    r>
    [ delegate>live-search ] keep ;

TUPLE: history-search ;

C: history-search ( string action seq -- gadget )
    >r
    [ string-completions [ <input> ] map ]
    [ input-string ]
    r>
    [ delegate>live-search ] keep ;

: search-action ( search -- obj )
    live-search-list list-value ;
