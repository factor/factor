! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs debugger ui.tools.workspace
ui.tools.operations ui.tools.traceback ui.tools.browser
ui.tools.inspector ui.tools.listener ui.tools.profiler
ui.tools.operations inspector io kernel math models namespaces
prettyprint quotations sequences ui ui.commands ui.gadgets
ui.gadgets.books ui.gadgets.buttons ui.gadgets.labelled
ui.gadgets.scrollers ui.gadgets.tracks ui.gadgets.worlds
ui.gadgets.presentations ui.gestures words vocabs.loader
tools.test tools.vocabs ui.gadgets.buttons ui.gadgets.status-bar
mirrors ;
IN: ui.tools

: <workspace-tabs> ( workspace -- tabs )
    model>>
        "tool-switching" workspace command-map commands>>
        [ command-string ] { } assoc>map <enum> >alist
    <toggle-buttons> ;

: <workspace-book> ( workspace -- gadget )
        <gadget>
        <browser-gadget>
        <inspector-gadget>
        <profiler-gadget>
    4array
    swap model>> <book> ;
  
: <workspace> ( -- workspace )
    { 0 1 } workspace new-track
        0 <model> >>model
        <listener-gadget> >>listener
        dup <workspace-book> >>book

        dup <workspace-tabs> f track-add
        dup book>> 0 track-add
        dup listener>> 1 track-add
        add-toolbar ;

: resize-workspace ( workspace -- )
    dup sizes>> over control-value 0 = [
        0 over set-second
        1 swap set-third
    ] [
        2/3 over set-second
        1/3 swap set-third
    ] if relayout ;

M: workspace model-changed
    nip
    dup listener>> output>> scroll>bottom
    dup resize-workspace
    request-focus ;

[ workspace-window ] ui-hook set-global

: select-tool ( workspace n -- ) swap book>> model>> set-model ;

: com-listener ( workspace -- ) 0 select-tool ;

: com-browser ( workspace -- ) 1 select-tool ;

: com-inspector ( workspace -- ) 2 select-tool ;

: com-profiler ( workspace -- ) 3 select-tool ;

workspace "tool-switching" f {
    { T{ key-down f { A+ } "1" } com-listener }
    { T{ key-down f { A+ } "2" } com-browser }
    { T{ key-down f { A+ } "3" } com-inspector }
    { T{ key-down f { A+ } "4" } com-profiler }
} define-command-map

workspace "multi-touch" f {
    { T{ zoom-out-action } com-listener }
    { T{ up-action } refresh-all }
} define-command-map

\ workspace-window
H{ { +nullary+ t } } define-command

\ refresh-all
H{ { +nullary+ t } { +listener+ t } } define-command

workspace "workflow" f {
    { T{ key-down f { C+ } "n" } workspace-window }
    { T{ key-down f f "ESC" } hide-popup }
    { T{ key-down f f "F2" } refresh-all }
} define-command-map

[
    <workspace> dup "Factor workspace" open-status-window
] workspace-window-hook set-global

: inspect-continuation ( traceback -- )
    control-value [ inspect ] curry call-listener ;

traceback-gadget "toolbar" f {
    { T{ key-down f f "v" } variables }
    { T{ key-down f f "n" } inspect-continuation }
} define-command-map
