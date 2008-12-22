! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.tools.workspace kernel quotations accessors fry
assocs present math math.order math.vectors arrays
models.search models.sort models sequences vocabs
tools.profiler ui ui.commands ui.gadgets ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.tracks ui.gestures
ui.gadgets.buttons ui.gadgets.tables ui.gadgets.search-tables
ui.gadgets.labelled ui.gadgets.buttons ui.gadgets.packs
ui.gadgets.labels ;
FROM: models.filter => <filter> ;
FROM: models.compose => <compose> ;
IN: ui.tools.profiler

TUPLE: profiler-gadget < track sort vocabs vocab words ;

SINGLETON: profile-renderer

! Value is a { word count } pair
M: profile-renderer row-columns
    drop [ [ present ] map ] [ { "All" "" } ] if* ;

: <profiler-model> ( values profiler -- model )
    [ [ [ second 0 > ] filter ] <filter> ] [ sort>> ] bi* <sort> ;

: <words-model> ( profiler -- model )
    [
        [ words>> ] [ vocab>> ] bi
        [ [ [ first vocabulary>> ] [ first ] bi* = ] when* ] <search>
    ] keep <profiler-model> ;

: <profiler-table> ( model -- table )
    [ swap dup [ first present subseq? ] [ 2drop t ] if ] <search-table>
    profile-renderer >>renderer ;

: <vocab-model> ( profiler -- model )
    [ vocab-counters <model> ] dip
    <profiler-model> [ f prefix ] <filter> ;

: sort-options ( -- alist )
    {
        { [ [ first ] compare ] "by name" }
        { [ [ second ] compare invert-comparison ] "by call count" }
    } ;

: <profiler-tool-bar> ( profiler -- gadget )
    <shelf>
        { 5 5 } >>gap
        over <toolbar> add-gadget
        "Sort by:" <label> add-gadget
        swap sort>> sort-options <radio-buttons> { 1 0 } >>orientation add-gadget ;

: <profiler-gadget> ( -- profiler )
    { 0 1 } profiler-gadget new-track
        [ [ first ] compare ] <model> >>sort
        all-words counters <model> >>words
        dup <vocab-model> >>vocabs
        { f 0 } <model> >>vocab
        dup <profiler-tool-bar> f track-add
        { 1 0 } <track>
                over vocabs>> <profiler-table>
                    pick vocab>> >>selected-value
                "Vocabularies" <labelled-gadget>
            1/2 track-add
                over <words-model> <profiler-table>
                "Words" <labelled-gadget>
            1/2 track-add
        1 track-add ;

M: profiler-gadget pref-dim* call-next-method { 700 400 } vmax ;

: profiler-help ( -- ) "ui-profiler" help-window ;

\ profiler-help H{ { +nullary+ t } } define-command

profiler-gadget "toolbar" f {
    { T{ key-down f f "F1" } profiler-help }
} define-command-map

: profiler-window ( -- )
    <profiler-gadget> "Profiler" open-window ;

MAIN: profiler-window