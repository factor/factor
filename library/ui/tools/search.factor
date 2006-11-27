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

: search-gesture ( gesture live-search -- command/f )
    live-search-list list-value object-operations
    [ command-gesture = ] find-with nip ;

M: live-search handle-gesture* ( gadget gesture delegate -- ? )
    drop over search-gesture dup [
        over find-workspace hide-popup
        >r live-search-list list-value r> invoke-command f
    ] [
        2drop t
    ] if ;

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
    [ find-workspace hide-popup ] -rot
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
    [ live-search-field editor-doc-end ] keep
    [ popup-theme ] keep ;

M: live-search focusable-child* live-search-field ;

: delegate>live-search ( string seq producer presenter gadget -- )
    >r <live-search> r> set-gadget-delegate ;

: <word-search> ( string words -- gadget )
    [ word-completions ]
    [ summary ]
    <live-search> ;

: help-completions ( str pairs -- seq )
    >r >lower r>
    [ second >lower ] swap completions
    [ first <link> ] map ;

: <help-search> ( string -- gadget )
    all-articles [ dup article-title 2array ] map
    [ [ second ] 2apply <=> ] sort
    [ help-completions ]
    [ article-title ]
    <live-search> ;

: <source-file-search> ( string files -- gadget )
    [ string-completions [ <pathname> ] map ]
    [ pathname-string ]
    <live-search> ;

: module-completions ( str modules -- seq )
    [ module-name ] swap completions ;

: <module-search> ( string -- gadget )
    available-modules [ module-completions ]
    [ module-string ]
    <live-search> ;

: <vocab-search> ( string -- gadget )
    vocabs [ string-completions [ <vocab-link> ] map ]
    [ vocab-link-name ]
    <live-search> ;

: <history-search> ( string seq -- gadget )
    [ string-completions [ <input> ] map ]
    [ input-string ]
    <live-search> ;

: show-titled-popup ( workspace gadget title -- )
    [ find-workspace hide-popup ] <closable-gadget>
    swap show-popup ;

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

: show-history ( workspace -- )
    "" over workspace-listener listener-history <history-search>
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
