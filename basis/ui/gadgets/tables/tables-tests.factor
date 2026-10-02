IN: ui.gadgets.tables.tests
USING: ui.gadgets.tables ui.gadgets.scrollers ui.gadgets.debug accessors
models namespaces tools.test kernel combinators prettyprint arrays classes
locals math math.rectangles sequences ui.gadgets ui.gadgets.line-support
ui.gadgets.tables.private ui.gestures ui.text.private ;
USING: assocs calendar continuations fonts fonts.shaping io io.encodings.utf8 io.launcher opengl system ;

SINGLETON: test-renderer

M: test-renderer row-columns drop ;

M: test-renderer column-titles drop { "First" "Last" } ;

: test-table ( -- table )
    {
        { "Britney" "Spears" }
        { "Justin" "Timberlake" }
        { "Don" "Stewart" }
    } <model> test-renderer <table> ;

{ } [
    test-table "table" set
] unit-test

! Draw different-height rows and click them in a native OpenGL world.
os windows? [
    { "legacy" "gl3" } [| mode |
        { t } [
            <process>
                vm-path "-no-user-init"
                "resource:basis/ui/gadgets/tables/fixtures/row-heights.factor" mode 4array >>command
                t >>hidden 20 seconds >>timeout
                +closed+ >>stdin +stdout+ >>stderr
            utf8 [ read-contents ] with-process-reader*
            0 = [ drop "ROW-HEIGHTS-PASS" subseq-of? ] [ output-process-error ] if
        ] unit-test
    ] each
] when

{ } [
    "table" get <scroller> "scroller" set
] unit-test

{ { "Justin" "Timberlake" } { "Britney" "Spears" } } [
    test-table t >>selection-required? dup [
        {
            [ 1 select-row ]
            [
                model>> {
                    { "Justin" "Timberlake" }
                    { "Britney" "Spears" }
                    { "Don" "Stewart" }
                } swap set-model
            ]
            [ selected-row drop ]
            [
                model>> {
                    { "Britney" "Spears" }
                    { "Don" "Stewart" }
                } swap set-model
            ]
            [ selected-row drop ]
        } cleave
    ] with-grafted-gadget
] unit-test

SINGLETON: silly-renderer

M: silly-renderer row-columns drop unparse 1array ;

M: silly-renderer column-titles drop { "Foo" } ;

: test-table-2 ( -- table )
    { 1 2 f } <model> silly-renderer <table> ;

{ f f } [
    test-table dup [
        selected-row
    ] with-grafted-gadget
] unit-test

! GitHub issue #1269: reject invalid models before grafting a table.
[
    { 1 2 } trivial-renderer <table>
] [ not-an-instance? ] must-fail-with

[
    { 1 2 } trivial-renderer table new-table
] [ not-an-instance? ] must-fail-with

{ t } [
    { { "1" "2" } } <model>
    dup trivial-renderer <table> model>> eq?
] unit-test

TUPLE: height-cell width height padding ;
C: <height-cell> height-cell
M: height-cell cell-dim nip [ width>> ] [ height>> ] [ padding>> ] tri ;
M: height-cell draw-cell 2drop ;

SYMBOL: height-measurements
height-measurements [ 0 ] initialize
TUPLE: measured-height-cell < height-cell ;
M: measured-height-cell cell-dim
    height-measurements [ 1 + ] change call-next-method ;

! Repeated pointer lookups reuse metrics; changing the font invalidates them.
{ 3 3 6 } [
    [let
        0 height-measurements set
        3 [ 8 30 0 measured-height-cell boa 1array ] replicate
        <model> trivial-renderer <table> 10 >>line-height :> table
        table ensure-row-metrics drop height-measurements get
        100 [ table y>line drop ] each-integer height-measurements get
        table [ clone t >>bold? ] change-font ensure-row-metrics drop
        height-measurements get
    ]
] unit-test

: variable-table ( -- table )
    8 10 0 <height-cell> 1array
    8 28 2 <height-cell> 1array
    8 20 0 <height-cell> 1array
    3array <model> trivial-renderer <table>
    10 >>line-height { 100 60 } >>dim ;

! Keep exact geometry checks independent of the host monitor's DPI.
:: with-table-scale ( ..a scale quot: ( ..a -- ..b ) -- ..b )
    gl-scale-factor get-global :> previous
    [ scale gl-scale-factor set-global quot call ]
    [ previous gl-scale-factor set-global ] finally ; inline

SYMBOL: width-computations
TUPLE: counted-width-table < table ;
M: counted-width-table compute-column-widths
    width-computations [ 1 + ] change call-next-method ;

: <counted-width-table> ( -- table )
    { { "a" "b" } { "c" "d" } } <model> trivial-renderer counted-width-table new-table
    10 >>line-height ;

! #689: repeated preferred-size and layout requests measure columns once.
{ 1 2 3 4 5 } [
    [let
        0 width-computations set
        <counted-width-table> :> table
        table [
            table f >>column-metrics drop 0 width-computations set
            10 [ table pref-dim* drop ] times
            table layout* width-computations get
            table font>> dup size>> 1 + >>size drop
            table pref-dim* drop width-computations get
            table 3 >>gap drop table pref-dim* drop width-computations get
            table test-renderer >>renderer drop
            table pref-dim* drop width-computations get
            table model>> touch-model
            table pref-dim* drop width-computations get
        ] with-grafted-gadget
    ]
] unit-test

! Backing scale affects native widths independently of model/font identity.
{ 1 2 3 } [
    1.0 [
        [let
            0 width-computations set <counted-width-table> :> table
            table pref-dim* drop width-computations get
            1.25 [ table pref-dim* drop width-computations get ] with-table-scale
            table pref-dim* drop width-computations get
        ]
    ] with-table-scale
] unit-test

! Font keys own mutable names and shaping options, rather than sharing
! their storage with the caller and silently accepting stale dimensions.
{ 1 2 3 } [
    [let
        0 width-computations set
        <counted-width-table> "Consolas" clone <font>
        H{ { "kern" 0 } } font-with-features >>font :> table
        table pref-dim* drop width-computations get
        CHAR: c 0 table font>> name>> set-nth
        table pref-dim* drop width-computations get
        1 "kern" table font>> font-features set-at
        table pref-dim* drop width-computations get
    ]
] unit-test

SINGLETON: width-test-text-renderer

! Switching text backends must not reuse dimensions from another renderer.
{ 1 2 2 t } [
    [let
        0 width-computations set
        8 30 0 <height-cell> 1array 1array <model> trivial-renderer
        counted-width-table new-table 10 >>line-height :> table
        table pref-dim* drop width-computations get
        width-test-text-renderer font-renderer [
            table pref-dim* drop width-computations get
            table column-metrics>>
        ] with-variable :> temporary-metrics
        ! The counter in with-variable belongs to its temporary namespace.
        table pref-dim* drop width-computations get
        table column-metrics>> temporary-metrics eq? not
    ]
] unit-test

SINGLETON: filled-width-renderer
M: filled-width-renderer row-columns drop ;
M: filled-width-renderer filled-column drop 0 ;

! Layout may stretch a column, but must leave intrinsic cached widths
! intact for later preferred-size requests and window resizes.
{ 8.0 100.0 8.0 200.0 8.0 1 } [
    [let
        0 width-computations set
        8 30 0 <height-cell> 1array 1array <model> filled-width-renderer
        counted-width-table new-table 10 >>line-height { 100 60 } >>dim :> table
        table pref-dim* first
        table layout* table column-widths>> first
        table pref-dim* first
        table { 200 60 } >>dim layout* table column-widths>> first
        table pref-dim* first width-computations get
    ]
] unit-test

! Actual cell height and padding determine row geometry, rather than prototypes.
{ { 10.0 30.0 20.0 } { 0 10.0 40.0 60.0 } 60.0 } [
    1.0 [
        variable-table ensure-row-metrics
        [ row-heights>> ] [ row-offsets>> ] [ pref-dim second ] tri
    ] with-table-scale
] unit-test

{ { -1 0 0 1 1 2 2 3 } } [
    1.0 [
        variable-table
        { -1 0 9 10 39 40 59 60 } [ over y>line ] map nip
    ] with-table-scale
] unit-test

{ { 0 10.0 } { 100 30.0 } } [
    1.0 [ variable-table 1 row-bounds ] with-table-scale
] unit-test

! Model updates invalidate height measurements and keep selection within range.
{ { 0 20.0 } 0 } [
    1.0 [
        variable-table t >>selection-required? dup [
            dup 2 select-row
            8 20 0 <height-cell> 1array 1array over model>> set-model
            ensure-row-metrics [ row-offsets>> ] [ selection-index>> value>> ] bi
        ] with-grafted-gadget
    ] with-table-scale
] unit-test

! Changing the minimum height must rebuild a previously populated cache.
{ { 0 25.0 55.0 80.0 } } [
    1.0 [
        variable-table ensure-row-metrics 25 >>line-height
        ensure-row-metrics row-offsets>>
    ] with-table-scale
] unit-test

{ { 0 } { 0 0 } } [
    { } <model> trivial-renderer <table> ensure-row-metrics
    [ row-offsets>> ] [ pref-dim ] bi
] unit-test

! Padding and empty columns are included without collapsing rows to zero height.
{ { 0 10.0 35.0 } } [
    1.0 [
        { } 3 5 20 <height-cell> 1array 2array
        <model> trivial-renderer <table> 10 >>line-height
        ensure-row-metrics row-offsets>>
    ] with-table-scale
] unit-test

! Moving a table between display scales must refresh pixel-rounded heights,
! even when its font, rows, and minimum line height are unchanged.
{ { 0 25.0 } { 0 25.6 } { 0 25.2 } { 0 25.0 } } [
    1.0 [| |
        8 25 0 <height-cell> 1array 1array
        <model> trivial-renderer <table> 10 >>line-height :> table
        table ensure-row-metrics row-offsets>>
        1.25 [ table ensure-row-metrics row-offsets>> ] with-table-scale
        2.5 [ table ensure-row-metrics row-offsets>> ] with-table-scale
        table ensure-row-metrics row-offsets>>
    ] with-table-scale
] unit-test

! Page movement follows pixel distance and still advances past a very tall row.
{ 1 2 1 0 } [
    1.0 [
        variable-table { 100 25 } >>dim t >>selection-required? dup [
            dup next-page dup selection-index>> value>> swap
            dup next-page dup selection-index>> value>> swap
            dup previous-page dup selection-index>> value>> swap
            dup previous-page selection-index>> value>>
        ] with-grafted-gadget
    ] with-table-scale
] unit-test
