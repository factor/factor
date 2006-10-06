! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: arrays gadgets gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling gadgets-text gadgets-theme
generic help tools kernel models sequences words
gadgets-borders gadgets-lists namespaces parser hashtables io
completion styles ;

TUPLE: live-search field list model producer action presenter ;

: find-live-search [ live-search? ] find-parent ;

: find-search-list find-live-search live-search-list ;

TUPLE: search-field ;

C: search-field ( string -- gadget )
    <editor> over set-gadget-delegate
    dup dup set-control-self
    [ set-editor-text ] keep
    [ select-all ] keep ;

search-field H{
    { T{ key-down f f "UP" } [ find-search-list select-prev ] }
    { T{ key-down f f "DOWN" } [ find-search-list select-next ] }
    { T{ key-down f f "RETURN" } [ find-search-list call-action ] }
} set-gestures

: <search-model> ( -- model )
    gadget get dup live-search-field control-model
    swap live-search-producer [ "\n" join ] swap append
    <filter> ;

: <search-list>
    <search-model>
    gadget get live-search-presenter [ make-pane ] curry
    gadget get live-search-action \ first add*
    <list> ;

C: live-search ( string action producer presenter -- gadget )
    [ set-live-search-presenter ] keep
    [ set-live-search-producer ] keep
    [ set-live-search-action ] keep
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
    all-words
    [ word-completions ] curry
    [ word-completion. ]
    <live-search> ;

: <help-search> ( string action -- gadget )
    [ search-help ]
    [ first ($link) ]
    <live-search> ;

: string-completion. ( pair quot -- )
    >r first2 over completion>string swap r> write-object ;
    inline

: <source-files-search> ( string action -- gadget )
    source-files get hash-keys natural-sort
    [ string-completions ] curry
    [ [ <pathname> ] string-completion. ]
    <live-search> ;

: <vocabs-search> ( string action -- gadget )
    vocabs
    [ string-completions ] curry
    [ [ <vocab-link> ] string-completion. ]
    <live-search> ;
