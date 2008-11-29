! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.tools.workspace kernel quotations tools.profiler
ui.commands ui.gadgets ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.tracks ui.gestures ui.gadgets.buttons accessors fry ;
IN: ui.tools.profiler

TUPLE: profiler-gadget < track pane ;

: <profiler-gadget> ( -- gadget )
    { 0 1 } profiler-gadget new-track
        add-toolbar
        <pane> >>pane
        dup pane>> <scroller> 1 track-add ;

: with-profiler-pane ( gadget quot -- )
    [ pane>> ] dip with-pane ;

: com-full-profile ( gadget -- )
    [ profile. ] with-profiler-pane ;

: com-vocabs-profile ( gadget -- )
    [ vocabs-profile. ] with-profiler-pane ;

: com-method-profile ( gadget -- )
    [ method-profile. ] with-profiler-pane ;

: profiler-help ( -- ) "ui-profiler" help-window ;

\ profiler-help H{ { +nullary+ t } } define-command

profiler-gadget "toolbar" f {
    { f com-full-profile }
    { f com-vocabs-profile }
    { f com-method-profile }
    { T{ key-down f f "F1" } profiler-help }
} define-command-map

GENERIC: profiler-presentation ( obj -- quot )

M: usage-profile profiler-presentation
    word>> '[ _ usage-profile. ] ;

M: vocab-profile profiler-presentation
    vocab>> '[ _ vocab-profile. ] ;

M: f profiler-presentation
    drop [ vocabs-profile. ] ;

M: profiler-gadget call-tool* ( obj gadget -- )
    swap profiler-presentation with-profiler-pane ;
