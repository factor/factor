! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs debugger ui.tools.workspace
ui.tools.operations ui.tools.browser ui.tools.inspector
ui.tools.listener ui.tools.profiler ui.tools.walker
ui.tools.operations inspector io kernel math models namespaces
prettyprint quotations sequences ui ui.commands ui.gadgets
ui.gadgets.books ui.gadgets.buttons ui.gadgets.controls
ui.gadgets.labelled ui.gadgets.scrollers ui.gadgets.tracks
ui.gadgets.worlds ui.gadgets.presentations ui.gestures words
vocabs.loader tools.test ui.gadgets.buttons
ui.gadgets.status-bar ;
IN: ui.tools

: workspace-tabs ( -- seq )
    {
        <stack-display>
        <browser-gadget>
        <inspector-gadget>
        <walker>
        <profiler-gadget>
    } ;

: <workspace-tabs> ( -- tabs )
    g control-model
    "tool-switching" workspace command-map
    [ command-string ] { } assoc>map
    [ length ] keep 2array flip
    <radio-box> ;

: <workspace-book> ( -- gadget )
    workspace-tabs [ execute ] map g control-model <book> ;

: <workspace> ( -- workspace )
    0 <model> { 0 1 } <track> workspace construct-control [
        [
            <listener-gadget> g set-workspace-listener
            <workspace-book> g set-workspace-book
            <workspace-tabs> f track,
            g workspace-book 1/5 track,
            g workspace-listener 4/5 track,
            toolbar,
        ] with-gadget
    ] keep ;

: resize-workspace ( workspace -- )
    dup track-sizes over control-value zero? [
        1/5 1 pick set-nth
        4/5 2 rot set-nth
    ] [
        2/3 1 pick set-nth
        1/3 2 rot set-nth
    ] if relayout ;

M: workspace model-changed
    dup workspace-listener listener-gadget-output scroll>bottom
    dup resize-workspace
    request-focus ;

[ workspace-window ] ui-hook set-global

: com-listener stack-display select-tool ;

: com-browser browser-gadget select-tool ;

: com-inspector inspector-gadget select-tool ;

: com-walker walker select-tool ;

: com-profiler profiler-gadget select-tool ;

workspace "tool-switching" f {
    { T{ key-down f f "F2" } com-listener }
    { T{ key-down f f "F3" } com-browser }
    { T{ key-down f f "F4" } com-inspector }
    { T{ key-down f f "F5" } com-walker }
    { T{ key-down f f "F6" } com-profiler }
} define-command-map

\ workspace-window
H{ { +nullary+ t } } define-command

\ refresh-all
H{ { +nullary+ t } { +listener+ t } } define-command

\ test-changes
H{ { +nullary+ t } { +listener+ t } } define-command

workspace "workflow" f {
    { T{ key-down f { C+ } "n" } workspace-window }
    { T{ key-down f f "ESC" } hide-popup }
    { T{ key-down f f "F8" } refresh-all }
    { T{ key-down f { A+ } "F8" } test-changes }
} define-command-map

[
    <workspace> "Factor workspace" open-status-window
] workspace-window-hook set-global
