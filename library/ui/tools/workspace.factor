! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: help arrays compiler gadgets gadgets-books
gadgets-browser gadgets-buttons gadgets-dataflow gadgets-help
gadgets-listener gadgets-presentations gadgets-walker
gadgets-workspace generic kernel math modules scratchpad
sequences syntax words io namespaces hashtables
gadgets-scrolling gadgets-panes gadgets-messages ;

C: tool ( gadget -- tool )
    {
        {
            [ dup dup class tool 2array <toolbar> ]
            f
            f
            @top
        }
        {
            f
            set-tool-gadget
            f
            @center
        }
    } make-frame* ;

M: tool focusable-child* tool-gadget ;

M: tool call-tool* tool-gadget call-tool* ;

M: tool tool-scroller tool-gadget tool-scroller ;

M: tool tool-help tool-gadget tool-help ;

: help-window ( topic -- )
    [ [ help ] make-pane <scroller> ] keep
    article-title open-titled-window ;

: tool-help-window ( tool -- )
    tool-help [ help-window ] when* ;

tool "toolbar" {
    { "Tool help" T{ key-down f f "F1" } [ tool-help-window ] }
} define-commands

: workspace-tabs
    {
        { "Listener" <listener-gadget> }
        { "Messages" <messages> }
        { "Definitions" <browser> } 
        { "Documentation" <help-gadget> }
        { "Walker" <walker-gadget> }
        { "Dataflow" <dataflow-gadget> }
    } ;

C: workspace ( -- workspace )
    workspace-tabs 1 <column> [ execute <tool> ] map <book>
    over set-gadget-delegate dup dup set-control-self ;

M: workspace pref-dim* delegate pref-dim* { 550 650 } vmax ;

: <workspace-tabs> ( book -- tabs )
    control-model
    workspace-tabs dup length [ swap first 2array ] 2map
    <radio-box> ;

: init-status ( world -- )
    dup world-status <presentation-help> swap @bottom grid-add ;

: init-tabs ( world -- )
    [ world-gadget <workspace-tabs> ] keep @top grid-add ;

: workspace-window ( -- workspace )
    <workspace> dup <world>
    [ init-status ] keep
    [ init-tabs ] keep
    open-window
    listener-gadget get-tool start-listener ;

: tool-window ( class -- ) workspace-window show-tool 2drop ;

: tool-scroll-up ( workspace -- )
    current-page tool-scroller [ scroll-up-page ] when* ;

: tool-scroll-down ( workspace -- )
    current-page tool-scroller [ scroll-down-page ] when* ;

workspace "scrolling" {
    { "Scroll up" T{ key-down f { C+ } "PAGE_UP" } [ tool-scroll-up ] }
    { "Scroll down" T{ key-down f { C+ } "PAGE_DOWN" } [ tool-scroll-down ] }
} define-commands

workspace "tool-switch" {
    { "Listener" T{ key-down f f "F2" } [ listener-gadget select-tool ] }
    { "Messages" T{ key-down f f "F3" } [ messages select-tool ] }
    { "Definitions" T{ key-down f f "F4" } [ browser select-tool ] }
    { "Documentation" T{ key-down f f "F5" } [ help-gadget select-tool ] }
    { "Walker" T{ key-down f f "F6" } [ walker-gadget select-tool ] }
    { "Dataflow" T{ key-down f f "F7" } [ dataflow-gadget select-tool ] }
} define-commands

workspace "tool-window" {
    { "New listener" T{ key-down f { S+ } "F2" } [ listener-gadget tool-window ] }
    { "New definitions" T{ key-down f { S+ } "F3" } [ browser tool-window ] }
    { "New documentation" T{ key-down f { S+ } "F4" } [ help-gadget tool-window ] }
} define-commands

workspace "workflow" {
    { "Reload changed sources" T{ key-down f f "F8" } [ drop [ reload-modules ] call-listener ] }
    { "Recompile changed words" T{ key-down f { S+ } "F8" } [ drop [ recompile ] call-listener ] }
} define-commands
