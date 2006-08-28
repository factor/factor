! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays gadgets gadgets-listener gadgets-buttons
gadgets-walker gadgets-help gadgets-walker sequences
gadgets-browser gadgets-books gadgets-frames gadgets-controls
gadgets-grids gadgets-presentations kernel models namespaces
styles words help parser inspector memory generic threads
gadgets-text definitions ;
IN: gadgets-workspace

GENERIC: call-tool* ( arg tool -- )

TUPLE: tool gadget ;

C: tool ( gadget -- tool )
    {
        { [ dup <toolbar> ] f f @top }
        { [ ] set-tool-gadget f @center }
    } make-frame* ;

M: tool gadget-title tool-gadget gadget-title ;

M: tool focusable-child* tool-gadget ;

M: tool call-tool* tool-gadget call-tool* ;

TUPLE: workspace ;

: workspace-tabs
    {
        { "Listener" listener-gadget [ <listener-gadget> ] }
        { "Walker" walker-gadget [ <walker-gadget> ] }
        { "Dictionary" browser [ <browser> ] } 
        { "Documentation" help-gadget [ <help-gadget> ] }
    } ;

C: workspace ( -- workspace )
    workspace-tabs
    [ third [ <tool> ] append ] map <book>
    over set-gadget-delegate
    dup dup set-control-self ;

M: workspace pref-dim* drop { 500 600 } ;

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

: show-tool ( class workspace -- tool )
    >r workspace-tabs [ second eq? ] find-with drop r>
    [ get-page ] 2keep control-model set-model ;

: select-tool ( workspace class -- ) swap show-tool drop ;

: find-workspace ( -- workspace )
    [ workspace? ] find-window
    [ world-gadget ] [ workspace-window find-workspace ] if* ;

: call-tool ( arg class -- )
    find-workspace show-tool call-tool* ;

: commands-window ( workspace -- )
    dup find-world world-focus [ ] [ gadget-child ] ?if
    [ commands. ] "Commands" pane-window ;

workspace {
    { f "Keyboard help" T{ key-down f f "F1" } [ commands-window ] }
    { f "Listener" T{ key-down f f "F2" } [ listener-gadget select-tool ] }
    { f "Walker" T{ key-down f f "F3" } [ walker-gadget select-tool ] }
    { f "Dictionary" T{ key-down f f "F4" } [ browser select-tool ] }
    { f "Documentation" T{ key-down f f "F5" } [ help-gadget select-tool ] }
    { f "New workspace" T{ key-down f { C+ } "n" } [ workspace-window drop ] }
} define-commands

V{ } clone operations set-global

: define-operation ( pred button# name tool quot -- )
    [ % , \ call-tool , ] [ ] make <operation> 3array
    operations get push-new ;

\ word 2 "Edit" listener-gadget [ [ edit ] curry ] define-operation
link 2 "Edit" listener-gadget [ [ edit ] curry ] define-operation

! Listener tool
M: listener-gadget call-tool* ( quot/string listener -- )
    listener-gadget-input over quotation?
    [ interactor-call ] [ set-editor-text ] if ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ [ run-file ] each ] curry listener-gadget call-tool
    ] if ;

listener-gadget {
    { f "Clear" T{ key-down f f "CLEAR" } [ clear-listener ] }
    { f "Globals" f [ global inspect ] }
    { f "Memory" f [ heap-stats. room. ] }
}
[ first4 [ listener-gadget call-tool ] curry 4array ] map
define-commands

object 1 "Inspect" listener-gadget [ [ inspect ] curry ] define-operation
object 3 "Inspect" listener-gadget [ [ inspect ] curry ] define-operation
input 1 "Input" listener-gadget [ input-string ] define-operation

! Browser tool
M: browser call-tool*
    over vocab-link? [
        >r vocab-link-name r> show-vocab
    ] [
        show-word
    ] if ;

\ word 1 "Browse" browser [ ] define-operation
vocab-link 1 "Browse" browser [ ] define-operation

! Help tool
M: help-gadget call-tool* show-help ;

link 1 "Follow link" help-gadget [ ] define-operation

! Walker tool
M: walker-gadget call-tool* ( arg tool -- )
    >r first2 r> (walk) ;

: walk ( quot -- )
    continuation dup continuation-data pop* 2array
    walker-gadget call-tool stop ;
