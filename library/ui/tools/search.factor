! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: arrays gadgets gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling gadgets-text gadgets-theme
generic help tools kernel models sequences words
gadgets-borders gadgets-lists namespaces ;

TUPLE: search-gadget input ;

: <search-pane> ( model quot -- )
    [ over empty? [ 2drop ] [ call ] if ] curry
    <pane-control> ;

: <search-bar> ( field -- gadget )
    {
        { [ "Search: " <label> ] f f @left }
        { f f f @center }
    } make-frame ;

C: search-gadget ( quot -- )
    >r f <model> dup r> {
        { [ <field> ] set-search-gadget-input [ <search-bar> ] @top }
        { [ swap <search-pane> <scroller> ] f f @center }
    } make-frame* ;

M: search-gadget focusable-child* search-gadget-input ;


! Here is the new one
TUPLE: live-search field list model producer action presenter ;

: find-live-search [ live-search? ] find-parent ;

: find-search-list find-live-search live-search-list ;

: update-live-search ( live-search -- )
    dup live-search-field editor-text
    over live-search-producer call
    swap live-search-model set-model ;

TUPLE: search-field ;

C: search-field ( string -- gadget )
    <editor> over set-gadget-delegate
    dup dup set-control-self
    [ set-editor-text ] keep ;

M: search-field model-changed
    dup find-live-search update-live-search
    delegate model-changed ;

search-field H{
    { T{ key-down f f "UP" } [ find-search-list select-prev ] }
    { T{ key-down f f "DOWN" } [ find-search-list select-next ] }
    { T{ key-down f f "RETURN" } [ find-search-list call-action ] }
} set-gestures

: <search-list>
    gadget get live-search-model
    gadget get live-search-presenter
    gadget get live-search-action
    <list> ;

C: live-search ( string action producer presenter -- gadget )
    [ set-live-search-presenter ] keep
    [ set-live-search-producer ] keep
    [ set-live-search-action ] keep
    f <model> over set-live-search-model
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
    } make-frame* ;

M: live-search focusable-child* live-search-field ;

: <word-search> ( string action -- gadget )
    \ third add*
    all-words
    [ completions ] curry
    [ [ completion. ] make-pane ]
    <live-search> ;
