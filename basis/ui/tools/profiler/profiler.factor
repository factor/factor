! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel quotations accessors fry assocs present math.order
math.vectors arrays locals models.search models.sort models sequences
vocabs tools.profiler words prettyprint combinators.smart
definitions.icons see ui ui.commands ui.gadgets ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.tracks ui.gestures ui.gadgets.buttons
ui.gadgets.tables ui.gadgets.search-tables ui.gadgets.labeled
ui.gadgets.buttons ui.gadgets.packs ui.gadgets.labels
ui.gadgets.tabbed ui.gadgets.status-bar ui.gadgets.borders
ui.tools.browser ui.tools.common ui.baseline-alignment
ui.operations ui.images ;
FROM: models.arrow => <arrow> ;
FROM: models.product => <product> ;
IN: ui.tools.profiler

TUPLE: profiler-gadget < tool
sort
vocabs vocab
words
methods
generic class ;

SINGLETONS: word-renderer vocab-renderer ;
UNION: profiler-renderer word-renderer vocab-renderer ;

<PRIVATE

: with-datastack* ( seq quot -- seq' )
    '[ _ input<sequence ] output>array ; inline

PRIVATE>

! Value is a { word count } pair
M: profiler-renderer row-columns
    drop
    [
        [
            [ [ definition-icon <image-name> ] [ present ] bi ]
            [ present ]
            bi*
        ] with-datastack*
    ] [ { "" "All" "" } ] if* ;

M: profiler-renderer prototype-row
    drop \ = definition-icon <image-name> "" "" 3array ;

M: profiler-renderer row-value
    drop dup [ first ] when ;

M: profiler-renderer column-alignment drop { 0 0 1 } ;
M: profiler-renderer filled-column drop 1 ;

M: word-renderer column-titles drop { "" "Word" "Count" } ;
M: vocab-renderer column-titles drop { "" "Vocabulary" "Count" } ;

SINGLETON: method-renderer

M: method-renderer column-alignment drop { 0 0 1 } ;
M: method-renderer filled-column drop 1 ;

! Value is a { method-body count } pair
M: method-renderer row-columns
    drop [
        [ [ definition-icon <image-name> ] [ synopsis ] bi ]
        [ present ]
        bi*
    ] with-datastack* ;

M: method-renderer row-value drop first ;

M: method-renderer column-titles drop { "" "Method" "Count" } ;

: <profiler-model> ( values profiler -- model )
    [ [ filter-counts ] <arrow> ] [ sort>> ] bi* <sort> ;

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

: <profiler-table> ( model renderer -- table )
    [ dup [ first present ] when ] <search-table>
        [ invoke-primary-operation ] >>action ;

: <profiler-filter-model> ( counts profiler -- model' )
    [ <model> ] dip <profiler-model> [ f prefix ] <arrow> ;

: <vocabs-model> ( profiler -- model )
    [ vocab-counters [ [ vocab ] dip ] assoc-map ] dip
    <profiler-filter-model> ;

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
        [ generic>> ] [ class>> ] bi 3array <product>
        [ first3 '[ _ _ method-matches? ] filter ] <arrow>
    ] keep <profiler-model> ;

: sort-by-name ( obj1 obj2 -- <=> )
    [ first name>> ] compare ;

: sort-by-call-count ( obj1 obj2 -- <=> )
    [ second ] compare invert-comparison ;

: sort-options ( -- alist )
    {
        { [ sort-by-name ] "by name" }
        { [ sort-by-call-count ] "by call count" }
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
        profiler vocabs>> vocab-renderer <profiler-table>
            profiler vocab>> >>selected-value
            10 >>min-rows
            10 >>max-rows
        "Vocabularies" <labeled-gadget>
    1/2 track-add
        profiler <words-model> word-renderer <profiler-table>
            10 >>min-rows
            10 >>max-rows
        "Words" <labeled-gadget>
    1/2 track-add ;

:: <methods-tab> ( profiler -- gadget )
    vertical <track>
        { 3 3 } >>gap
        horizontal <track>
            { 3 3 } >>gap
            profiler <generic-model> word-renderer <profiler-table>
                profiler generic>> >>selected-value
            "Generic words" <labeled-gadget>
        1/2 track-add
            profiler <class-model> word-renderer <profiler-table>
                profiler class>> >>selected-value
            "Classes" <labeled-gadget>
        1/2 track-add
    1/2 track-add
        profiler methods>> method-renderer <profiler-table>
            5 >>min-rows
            5 >>max-rows
            40 >>min-cols
        "Methods" <labeled-gadget>
    1/2 track-add ;

: <selection-model> ( -- model ) { f 0 } <model> ;

: <profiler-gadget> ( -- profiler )
    vertical profiler-gadget new-track
        { 5 5 } >>gap
        [ sort-by-name ] <model> >>sort
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

: profiler-help ( -- ) "ui-profiler" com-browse ;

\ profiler-help H{ { +nullary+ t } } define-command

profiler-gadget "toolbar" f {
    { T{ key-down f f "F1" } profiler-help }
} define-command-map

: profiler-window ( -- )
    <profiler-gadget> "Profiling results" open-status-window ;

: com-profile ( quot -- ) profile profiler-window ;

MAIN: profiler-window