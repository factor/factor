! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel quotations accessors fry
assocs present math.order math.vectors arrays locals
models.search models.sort models sequences vocabs
tools.profiler words prettyprint ui ui.commands ui.gadgets
ui.gadgets.panes ui.gadgets.scrollers ui.gadgets.tracks ui.gestures
ui.gadgets.buttons ui.gadgets.tables ui.gadgets.search-tables
ui.gadgets.labeled ui.gadgets.buttons ui.gadgets.packs
ui.gadgets.labels ui.gadgets.tabbed ui.gadgets.status-bar
ui.gadgets.borders ui.tools.browser ui.tools.common ;
FROM: models.filter => <filter> ;
FROM: models.compose => <compose> ;
IN: ui.tools.profiler

TUPLE: profiler-gadget < tool
sort
vocabs vocab
words
methods
generic class ;

{ 700 400 } profiler-gadget set-tool-dim

SINGLETONS: word-renderer vocab-renderer ;
UNION: profiler-renderer word-renderer vocab-renderer ;

! Value is a { word count } pair
M: profiler-renderer row-columns
    drop [ [ present ] map ] [ { "All" "" } ] if* ;

M: profiler-renderer row-value
    drop dup [ first ] when ;

M: vocab-renderer row-value
    call-next-method dup [ vocab ] when ;

SINGLETON: method-renderer

! Value is a { method-body count } pair
M: method-renderer row-columns
    drop [ first synopsis ] [ second present ] bi 2array ;

M: method-renderer row-value drop first ;

: <profiler-model> ( values profiler -- model )
    [ [ filter-counts ] <filter> ] [ sort>> ] bi* <sort> ;

: <words-model> ( profiler -- model )
    [
        [ words>> ] [ vocab>> ] bi
        [
            [
                [ first vocabulary>> ]
                [ vocab-name ]
                bi* =
            ] when*
        ] <search>
    ] keep <profiler-model> ;

: match? ( pair/f str -- ? )
    swap dup [ first present subseq? ] [ 2drop t ] if ;

: <profiler-table> ( model -- table )
    [ match? ] <search-table>
        { 0 1 } >>column-alignment
        0 >>filled-column ;

: <profiler-filter-model> ( counts profiler -- model' )
    [ <model> ] dip <profiler-model> [ f prefix ] <filter> ;

: <vocabs-model> ( profiler -- model )
    [ vocab-counters ] dip <profiler-filter-model> ;

: <generic-model> ( profiler -- model )
    [ generic-counters ] dip <profiler-filter-model> ;

: <class-model> ( profiler -- model )
    [ class-counters ] dip <profiler-filter-model> ;

: method-matches? ( method generic class -- ? )
    [ first ] 2dip
    [ drop dup [ subwords memq? ] [ 2drop t ] if ]
    [ nip dup [ swap "method-class" word-prop = ] [ 2drop t ] if ]
    3bi and ;

: <methods-model> ( profiler -- model )
    [
        [ method-counters <model> ] dip
        [ generic>> ] [ class>> ] bi 3array <compose>
        [ first3 '[ _ _ method-matches? ] filter ] <filter>
    ] keep <profiler-model> ;

: sort-options ( -- alist )
    {
        { [ [ first ] compare ] "by name" }
        { [ [ second ] compare invert-comparison ] "by call count" }
    } ;

: <sort-options> ( model -- gadget )
    <shelf>
        +baseline+ >>align
        { 5 5 } >>gap
        "Sort by:" <label> add-gadget
        swap sort-options <radio-buttons> horizontal >>orientation add-gadget ;

: <profiler-tool-bar> ( profiler -- gadget )
    <shelf>
        1/2 >>align
        { 5 5 } >>gap
        swap
        [ <toolbar> add-gadget ]
        [ sort>> <sort-options> add-gadget ] bi ;

:: <words-tab> ( profiler -- gadget )
    horizontal <track>
        { 3 3 } >>gap
        profiler vocabs>> <profiler-table>
            profiler vocab>> >>selected-value
            vocab-renderer >>renderer
        "Vocabularies" <labeled-gadget>
    1/2 track-add
        profiler <words-model> <profiler-table>
            word-renderer >>renderer
        "Words" <labeled-gadget>
    1/2 track-add ;

:: <methods-tab> ( profiler -- gadget )
    vertical <track>
        { 3 3 } >>gap
        horizontal <track>
            { 3 3 } >>gap
            profiler <generic-model> <profiler-table>
                profiler generic>> >>selected-value
                word-renderer >>renderer
            "Generic words" <labeled-gadget>
        1/2 track-add
            profiler <class-model> <profiler-table>
                profiler class>> >>selected-value
                word-renderer >>renderer
            "Classes" <labeled-gadget>
        1/2 track-add
    1/2 track-add
        profiler methods>> <profiler-table>
            method-renderer >>renderer
        "Methods" <labeled-gadget>
    1/2 track-add ;

: <selection-model> ( -- model ) { f 0 } <model> ;

: <profiler-gadget> ( -- profiler )
    vertical profiler-gadget new-track
        { 5 5 } >>gap
        [ [ first ] compare ] <model> >>sort
        all-words counters <model> >>words
        <selection-model> >>vocab
        dup <vocabs-model> >>vocabs
        <selection-model> >>generic
        <selection-model> >>class
        dup <methods-model> >>methods
        dup <profiler-tool-bar> { 3 3 } <filled-border> f track-add
        <tabbed-gadget>
            over <words-tab> "Words" add-tab
            over <methods-tab> "Methods" add-tab
        1 track-add ;

: profiler-help ( -- ) "ui-profiler" com-follow ;

\ profiler-help H{ { +nullary+ t } } define-command

profiler-gadget "toolbar" f {
    { T{ key-down f f "F1" } profiler-help }
} define-command-map

: profiler-window ( -- )
    <profiler-gadget> "Profiling results" open-status-window ;

MAIN: profiler-window