! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences kernel gadgets-panes definitions
prettyprint gadgets-theme gadgets-borders gadgets
generic gadgets-scrolling math io words models styles
namespaces gadgets-tracks gadgets-presentations
gadgets-workspace help gadgets-buttons tools ;
IN: gadgets-browser

TUPLE: browser definitions ;

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

: <tile-content> ( definition -- gadget )
    [ [ see ] make-pane <default-border> ] keep
    unparse [ find-tile close-tile ] <closable-gadget>
    dup faint-boundary ;

C: tile ( definition -- gadget )
    over <tile-content> over set-gadget-delegate
    [ set-tile-definition ] keep ;

: show-definition ( definition definitions -- )
    2dup definition-index dup 0 >= [
        over nth-gadget swap scroll>rect drop
    ] [
        drop 2dup definitions-showing push
        swap <tile> over add-gadget
        scroll>bottom
    ] if ;

C: browser ( -- gadget )
    {
        {
            [ <definitions> ]
            set-browser-definitions
            [ <scroller> ]
            @center
        }
    } make-frame* ;

: clear-browser ( browser -- )
    browser-definitions close-definitions ;

browser "toolbar" {
    { "Clear" T{ key-down f f "CLEAR" } [ clear-browser ] }
} define-commands

M: browser call-tool*
    browser-definitions show-definition ;

M: browser tool-scroller browser-definitions find-scroller ;

M: browser tool-help drop "ui-browser" ;
