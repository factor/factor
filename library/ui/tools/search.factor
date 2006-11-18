! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: arrays gadgets gadgets-labels gadgets-panes
gadgets-scrolling gadgets-text gadgets-theme
generic help tools kernel models sequences words
gadgets-borders gadgets-lists gadgets-workspace gadgets-listener
namespaces parser hashtables io completion styles strings
modules prettyprint ;

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

: <search-list> ( seq producer presenter -- gadget )
    -rot curry <search-model>
    [ [ workspace? ] find-parent hide-popup ] -rot
    <list> ;

C: live-search ( string seq producer presenter -- gadget )
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
    [ live-search-field set-editor-text ] keep
    dup popup-theme ;

M: live-search focusable-child* live-search-field ;

: delegate>live-search ( string seq producer presenter gadget -- )
    >r <live-search> r> set-gadget-delegate ;

TUPLE: word-search ;

C: word-search ( string words -- gadget )
    >r
    [ word-completions ]
    [ summary ]
    r>
    [ delegate>live-search ] keep ;

: help-completions ( str pairs -- seq )
    >r >lower r>
    [ second >lower ] swap completions
    [ first <link> ] map ;

TUPLE: help-search ;

C: help-search ( string -- gadget )
    >r
    all-articles [ dup article-title 2array ] map
    [ [ second ] 2apply <=> ] sort
    [ help-completions ]
    [ article-title ]
    r>
    [ delegate>live-search ] keep ;

TUPLE: source-file-search ;

C: source-file-search ( string files -- gadget )
    >r
    [ string-completions [ <pathname> ] map ]
    [ pathname-string ]
    r>
    [ delegate>live-search ] keep ;

: module-completions ( str modules -- seq )
    [ module-name ] swap completions ;

TUPLE: module-search ;

C: module-search ( string -- gadget )
    >r
    available-modules [ module-completions ]
    [ module-string ]
    r>
    [ delegate>live-search ] keep ;

TUPLE: vocab-search ;

C: vocab-search ( string -- gadget )
    >r
    vocabs [ string-completions [ <vocab-link> ] map ]
    [ vocab-link-name ]
    r>
    [ delegate>live-search ] keep ;

TUPLE: history-search ;

C: history-search ( string seq -- gadget )
    >r
    [ string-completions [ <input> ] map ]
    [ input-string ]
    r>
    [ delegate>live-search ] keep ;

: search-action ( search -- obj )
    dup [ workspace? ] find-parent hide-popup
    live-search-list list-value ;

: show-titled-popup ( workspace gadget title -- )
    <labelled-gadget> swap show-popup ;

: workspace-listener ( workspace -- listener )
    listener-gadget swap find-tool tool-gadget nip ;

: current-word ( workspace -- string )
    workspace-listener listener-gadget-input selected-word ;

: show-word-search ( workspace words -- )
    >r dup current-word r> <word-search>
    "Word search" show-titled-popup ;

: show-vocab-words ( workspace vocab -- )
    "" over words <word-search>
    "Words in " rot append show-titled-popup ;

: show-help-search ( workspace -- )
    "" <help-search> "Help search" show-titled-popup ;

: all-source-files ( -- seq )
    source-files get hash-keys natural-sort ;

: show-source-file-search ( workspace -- )
    "" all-source-files <source-file-search>
    "Source file search" show-titled-popup ;

: show-module-files ( workspace module -- )
    "" over module-files* <source-file-search>
    "Source files in " rot module-name append show-titled-popup ;

: show-vocab-search ( workspace -- )
    dup current-word <vocab-search>
    "Vocabulary search" show-titled-popup ;

: show-module-search ( workspace -- )
    "" <module-search> "Module search" show-titled-popup ;

: listener-history ( listener -- seq )
    listener-gadget-input interactor-history <reversed> ;

: history-action ( string -- )
    find-listener listener-gadget-input set-editor-text ;

: show-history ( workspace -- )
    dup workspace-listener
    [ listener-gadget-input editor-text ] keep listener-history
    <history-search>
    "History search" show-titled-popup ;

workspace "toolbar" {
    {
        "History"
        T{ key-down f { C+ } "p" }
        [ show-history ]
    }
    {
        "Words"
        T{ key-down f f "TAB" }
        [ all-words show-word-search ]
    }
    {
        "Vocabularies"
        T{ key-down f { C+ } "u" }
        [ show-vocab-search ]
    }
    {
        "Modules"
        T{ key-down f { C+ } "m" }
        [ show-module-search ]
    }
    {
        "Sources"
        T{ key-down f { C+ } "e" }
        [ show-source-file-search ]
    }
    {
        "Search help"
        T{ key-down f { C+ } "h" }
        [ show-help-search ]
    }
} define-commands
