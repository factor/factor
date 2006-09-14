! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: arrays compiler gadgets gadgets-books gadgets-browser
gadgets-buttons gadgets-controls gadgets-dataflow gadgets-frames
gadgets-grids gadgets-help gadgets-listener
gadgets-presentations gadgets-walker gadgets-workspace generic
kernel math modules scratchpad sequences syntax words ;

C: tool ( gadget -- tool )
    {
        { [ dup <toolbar> ] f f @top }
        { [ ] set-tool-gadget f @center }
    } make-frame* ;

M: tool focusable-child* tool-gadget ;

M: tool call-tool* tool-gadget call-tool* ;

: workspace-tabs
    {
        { "Listener" <listener-gadget> }
        { "Definitions" <browser> } 
        { "Documentation" <help-gadget> }
        { "Walker" <walker-gadget> }
        { "Dataflow" <dataflow-gadget> }
    } ;

C: workspace ( -- workspace )
    workspace-tabs [ second execute <tool> ] map <book>
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
    open-window ;

: commands-window ( workspace -- )
    dup find-world world-focus [ ] [ gadget-child ] ?if
    [ commands. ] "Commands" pane-window ;

: tool-window ( class -- ) workspace-window show-tool drop ;

workspace {
    {
        "Tools"
        { "Keyboard help" T{ key-down f f "F1" } [ commands-window ] }
        { "Listener" T{ key-down f f "F2" } [ listener-gadget select-tool ] }
        { "Definitions" T{ key-down f f "F3" } [ browser select-tool ] }
        { "Documentation" T{ key-down f f "F4" } [ help-gadget select-tool ] }
        { "Walker" T{ key-down f f "F5" } [ walker-gadget select-tool ] }
        { "Dataflow" T{ key-down f f "F6" } [ walker-gadget select-tool ] }
    }

    {
        "Tools in new window"
        { "New listener" T{ key-down f { S+ } "F2" } [ listener-gadget tool-window drop ] }
        { "New definitions" T{ key-down f { S+ } "F3" } [ browser tool-window drop ] }
        { "New documentation" T{ key-down f { S+ } "F4" } [ help-gadget tool-window drop ] }
    }
    
    {
        "Workflow"
        { "Reload changed sources" T{ key-down f f "F7" } [ drop [ reload-modules ] listener-gadget call-tool ] }
        { "Recompile changed words" T{ key-down f f "F8" } [ drop [ recompile ] listener-gadget call-tool ] }
    }
} define-commands
