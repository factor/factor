! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.tools.workspace kernel quotations tools.profiler
ui.commands ui.gadgets ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.tracks ui.gestures ui.gadgets.buttons ;
IN: ui.tools.profiler

TUPLE: profiler-gadget pane ;

: <profiler-gadget> ( -- gadget )
    profiler-gadget construct-empty
    [
        toolbar,
        <pane> g-> set-profiler-gadget-pane
        <scroller> 1 track,
    ] { 0 1 } build-track ;

: with-profiler-pane ( gadget quot -- )
    >r profiler-gadget-pane r> with-pane ;

: com-full-profile ( gadget -- )
    [ profile. ] with-profiler-pane ;

: com-vocabs-profile ( gadget -- )
    [ vocabs-profile. ] with-profiler-pane ;

\ enable-profiler H{
    { +nullary+ t }
    { +listener+ t }
} define-command

\ disable-profiler H{
    { +nullary+ t }
    { +listener+ t }
} define-command

: profiler-help "ui-profiler" help-window ;

\ profiler-help H{ { +nullary+ t } } define-command

profiler-gadget "toolbar" f {
    { f enable-profiler }
    { f disable-profiler }
    { f com-full-profile }
    { f com-vocabs-profile }
    { T{ key-down f f "F1" } profiler-help }
} define-command-map

GENERIC: profiler-presentation ( obj -- quot )

M: usage-profile profiler-presentation
    usage-profile-word [ usage-profile. ] curry ;

M: vocab-profile profiler-presentation
    vocab-profile-vocab [ vocab-profile. ] curry ;

M: f profiler-presentation
    drop [ vocabs-profile. ] ;

M: profiler-gadget call-tool* ( obj gadget -- )
    swap profiler-presentation with-profiler-pane ;
