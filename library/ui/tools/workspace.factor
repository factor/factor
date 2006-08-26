! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: arrays gadgets gadgets-listener gadgets-buttons
gadgets-walker gadgets-help gadgets-walker sequences
gadgets-browser gadgets-books gadgets-frames gadgets-controls
gadgets-grids gadgets-presentations kernel models namespaces ;

TUPLE: tool ;

C: tool ( gadget -- tool )
    {
        { [ dup <toolbar> ] f f @top }
        { [ ] f f @center }
    } make-frame* ;

M: tool gadget-title gadget-child gadget-title ;

M: tool focusable-child* gadget-child ;

TUPLE: workspace model ;

: workspace-tabs
    {
        { "Listener" listener-gadget [ <listener-gadget> ] }
        { "Walker" walker-gadget [ <walker-gadget> ] }
        { "Dictionary" browser [ <browser> ] } 
        { "Documentation" help-gadget [ <help-gadget> ] }
    } ;

: <workspace> ( -- book )
    workspace-tabs [ third [ <tool> ] append ] map <book> ;

: <workspace-tabs> ( book -- tabs )
    control-model
    workspace-tabs dup length [ swap first 2array ] 2map
    <radio-box> ;

: init-status ( world -- )
    dup world-status <presentation-help> swap @bottom grid-add ;

: init-tabs ( workspace world -- )
    swap <workspace-tabs> swap @top grid-add ;

: workspace-window ( -- )
    <workspace> dup <world>
    [ init-status ] keep
    [ init-tabs ] keep
    open-window ;
