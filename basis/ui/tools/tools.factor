! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs debugger ui.tools.workspace
ui.tools.operations ui.tools.traceback ui.tools.browser
ui.tools.inspector ui.tools.listener
ui.tools.operations ui ui.commands ui.gadgets
ui.gadgets.books ui.gadgets.buttons ui.gadgets.labelled
ui.gadgets.scrollers ui.gadgets.tracks ui.gadgets.worlds
ui.gadgets.presentations ui.gestures words vocabs.loader
tools.test tools.vocabs ui.gadgets.buttons ui.gadgets.status-bar
mirrors fry inspector io kernel math models namespaces
prettyprint quotations sequences ;
IN: ui.tools
  
: <workspace> ( -- workspace )
    { 0 1 } workspace new-track
        <listener-gadget> >>listener
        dup listener>> 1 track-add
        add-toolbar ;

[ workspace-window ] ui-hook set-global

workspace "multi-touch" f {
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
    control-value '[ _ inspect ] call-listener ;

traceback-gadget "toolbar" f {
    { T{ key-down f f "v" } variables }
    { T{ key-down f f "n" } inspect-continuation }
} define-command-map
