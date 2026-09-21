! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays colors definitions.icons fonts io kernel
math math.functions math.order math.rectangles models models.arrow
models.product models.range namespaces prettyprint sequences
sequences.generalizations splitting ui ui.baseline-alignment ui.commands
ui.gadgets ui.gadgets.books ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.comboboxes ui.gadgets.editors ui.gadgets.frames
ui.gadgets.glass ui.gadgets.grids ui.gadgets.icons
ui.gadgets.labeled ui.gadgets.labels ui.gadgets.menus
ui.gadgets.packs ui.gadgets.panes ui.gadgets.paragraphs
ui.gadgets.scrollers ui.gadgets.search-tables ui.gadgets.sliders ui.gadgets.tabbed
ui.gadgets.tabbed.private ui.gadgets.tables ui.gadgets.toolbar
ui.gadgets.tracks ui.gestures ui.images ui.pens.gradient
ui.pens.polygon ui.pens.rounded ui.pens.solid ui.theme ;
FROM: models => change-model set-model ;
FROM: io.styles => background foreground font-style bold with-style ;
IN: ui-demo

! --- Helpers ---

CONSTANT: text-width 520

: <heading> ( string -- gadget )
    <label> [ clone t >>bold? ] change-font ;

: <note> ( string -- gadget )
    <label> [ clone dim-color >>foreground ] change-font ;

! Explanatory text, wrapped at text-width pixels.
: <prose> ( string -- gadget )
    text-width <paragraph> swap " " split [
        <label> add-gadget " " <word-break-gadget> add-gadget
    ] each ;

! Sections stack their children top to bottom, each stretched to
! the full width of the page.
: <section> ( -- pile )
    <filled-pile> { 8 8 } >>gap ;

: <page> ( gadget -- gadget )
    { 16 16 } <border> { 1 0 } >>fill { 0 0 } >>align ;

! Keeps a gadget at its preferred width inside a section.
: <pref-width> ( gadget -- gadget )
    <shelf> swap add-gadget ;

: <shelf-of> ( -- shelf )
    <shelf> { 8 0 } >>gap +baseline+ >>align ;

:: <box> ( pen dim -- gadget )
    <gadget> dim >>dim pen >>interior ;

: <color-box> ( color dim -- gadget )
    [ <solid> ] dip <box> ;

! Shows a model's value as Factor source, so that strings,
! booleans and numbers are all distinguishable.
: <readout> ( model -- gadget )
    [ unparse ] <arrow> <label-control> ;

:: <labeled-row> ( string gadget -- gadget )
    <shelf-of>
        string <label> add-gadget
        gadget add-gadget ;

! Padding that keeps its child in the top left corner.
: <inset> ( gadget -- gadget )
    { 10 10 } <border> { 0 0 } >>align ;

: <framed> ( gadget -- gadget )
    { 6 6 } <filled-border>
    content-background <solid> >>interior
    field-border-color <solid> >>boundary ;

! A preview rebuilds only its sample when the controls change.
TUPLE: demo-preview < border builder ;

M: demo-preview model-changed
    nip dup clear-gadget
    dup model>> dependencies>> [ value>> ] map
    over builder>> call( values -- gadget ) add-gadget relayout ;

:: <demo-preview> ( models builder -- gadget )
    demo-preview new { 0 0 } >>align
        models <product> >>model builder >>builder
        dup f swap model-changed ;

TUPLE: demo-stage < border stage-dim ;
M: demo-stage pref-dim* stage-dim>> ;

: <stage> ( gadget dim -- gadget )
    [ demo-stage new-border { 1 1 } >>fill t >>clipped?
      field-border-color <solid> >>boundary ] dip >>stage-dim ;

: <demo-range> ( value min max -- range )
    [ 0 ] 2dip 1 <range> ;

:: <range-row> ( title range -- gadget )
    <shelf-of>
        title <label> add-gadget
        range horizontal <slider>
        { 0 0 } <filled-border> { 200 18 } >>min-dim add-gadget
        range range-model <readout> add-gadget ;

:: <layout-controls> ( width gap align fill -- gadget )
    <section>
        "Width" width <range-row> add-gadget
        "Gap" gap <range-row> add-gadget
        align { { 0 "Start" } { 1/2 "Center" } { 1 "End" } }
        <radio-buttons> add-gadget
        "Alignment:" align <readout> <labeled-row> add-gadget
        fill "Fill available space" <checkbox> add-gadget
        "Fill:" fill <readout> <labeled-row> add-gadget ;

CONSTANT: text-samples
"Mixed scripts: English · العربية · עברית\nEmoji: 👩‍💻 👍🏽 🇺🇸\nCombining: é ạ́ ö\nLongUnbrokenText_ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789_ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"

: <text-samples> ( -- gadget )
    <section>
        <shelf-of>
            "Small" <label> [ clone 10 >>size ] change-font add-gadget
            "Large" <label> [ clone 28 >>size ] change-font add-gadget
            "Italic é 👩‍💻" <label> [ clone t >>italic? ] change-font add-gadget
        add-gadget
        text-samples <label> add-gadget
        [
            H{ { background COLOR: LightPink } }
            [ "Pink background: é العربية" print ] with-style
            H{ { background COLOR: LightBlue } }
            [ "Blue background: 👩‍💻 עברית" print ] with-style
        ] make-pane add-gadget ;

! --- Labels ---

:: <labels-section> ( -- gadget )
    "Type here" <model> :> text
    <section>
        "A label draws a string, or an array of strings, in the theme font." <prose> add-gadget
        "Plain" <label> add-gadget
        "Bold" <label> [ clone t >>bold? ] change-font add-gadget
        "Italic" <label> [ clone t >>italic? ] change-font add-gadget
        "Twenty-four point" <label> [ clone 24 >>size ] change-font add-gadget
        "Colored" <label> [ clone link-color >>foreground ] change-font add-gadget
        { "An array of strings" "becomes a label" "several lines tall." } <label> add-gadget
        "A label-control tracks a model:" <heading> add-gadget
        <shelf-of>
            text <model-field> 20 >>min-cols add-gadget
            text <label-control> add-gadget
        add-gadget
        "Mixed fonts, scripts and backgrounds:" <heading> add-gadget
        <text-samples> add-gadget
        "Drag across the colored output to select and copy it." <note> add-gadget
    <page> ;

! --- Buttons ---

:: <buttons-section> ( -- gadget )
    0 <model> :> clicks
    [ drop clicks [ 1 + ] change-model ] :> bump
    <section>
        "A button calls a quotation when clicked, passing itself on the stack. A roll button only draws its border under the mouse, and a repeat button keeps firing while it is held down." <prose> add-gadget
        <shelf-of>
            "Border button" bump <border-button> add-gadget
            "Roll button" bump <roll-button> add-gadget
            "Repeat button" bump <repeat-button> add-gadget
        add-gadget
        "Clicks:" clicks <readout> <labeled-row> add-gadget
        "Reset" [ drop 0 clicks set-model ] <border-button> <pref-width> add-gadget
    <page> ;

! --- Checkboxes ---

:: <checkboxes-section> ( -- gadget )
    f <model> :> notify
    t <model> :> advanced
    f <model> :> diagnostics
    3 0 10 <demo-range> :> retries
    <section>
        "A checkbox toggles a boolean model." <prose> add-gadget
        notify "Send notifications" <checkbox> add-gadget
        advanced "Show advanced options" <checkbox> add-gadget
        advanced 1array [ first [
            <section>
                "Advanced options" <heading> add-gadget
                diagnostics "Include diagnostic details" <checkbox> add-gadget
                "Retry count" retries <range-row> add-gadget
        ] [ <gadget> ] if ] <demo-preview> add-gadget
        "Notifications:" notify <readout> <labeled-row> add-gadget
        "Advanced:" advanced <readout> <labeled-row> add-gadget
    <page> ;

! --- Radio buttons ---

:: <radio-buttons-section> ( -- gadget )
    "medium" <model> :> size
    <section>
        "Radio buttons set one model to the value of whichever button is selected." <prose> add-gadget
        size {
            { "small" "Small" }
            { "medium" "Medium" }
            { "large" "Large" }
        } <radio-buttons> add-gadget
        "Selected:" size <readout> <labeled-row> add-gadget
    <page> ;

! --- Editors ---

:: <editors-section> ( -- gadget )
    "edit me" <model> :> bound
    f <model> :> submitted
    <editor> :> sample-editor
    text-samples sample-editor set-editor-string
    <section>
        "An editor is a multi-line text area with a caret, selection and undo. A field wraps one line of it in a border." <prose> add-gadget
        "Model field, bound in both directions:" <heading> add-gadget
        bound <model-field> 24 >>min-cols <pref-width> add-gadget
        "Model:" bound <readout> <labeled-row> add-gadget
        "Action field, fires on Enter:" <heading> add-gadget
        [ submitted set-model ] <action-field> "press Enter" >>default-text
            24 >>min-cols <pref-width> add-gadget
        "Submitted:" submitted <readout> <labeled-row> add-gadget
        "Plain editor:" <heading> add-gadget
        <editor> "Several lines fit here." >>default-text
        <framed> { 0 90 } >>min-dim add-gadget
        "Unicode, selection and long lines:" <heading> add-gadget
        sample-editor <scroller> <framed> { 0 150 } >>min-dim add-gadget
        <shelf-of>
            "Select all" [ drop sample-editor select-all sample-editor request-focus ] <border-button> add-gadget
            "Reset text" [ drop text-samples sample-editor set-editor-string ] <border-button> add-gadget
        add-gadget
        "Try editing, selecting, copying and undoing across scripts." <note> add-gadget
        "Baseline and background reference:" <heading> add-gadget
        <text-samples> add-gadget
    <page> ;

! --- Sliders ---

! A slider is a scrollbar, and only fills the box it is given.
:: <slider-box> ( range orientation dim -- gadget )
    range orientation <slider>
    { 0 0 } <filled-border> dim >>min-dim
    field-border-color <solid> >>boundary
    <pref-width> ;

:: <sliders-section> ( -- gadget )
    50 10 0 100 1 <range> :> across
    25 10 0 100 5 <range> :> down
    <section>
        "A slider edits a range model, which holds a value, a page size, a minimum, a maximum and a step." <prose> add-gadget
        "Horizontal, step 1:" <heading> add-gadget
        across horizontal { 320 0 } <slider-box> add-gadget
        "Value:" across range-model <readout> <labeled-row> add-gadget
        "Vertical, step 5:" <heading> add-gadget
        down vertical { 0 140 } <slider-box> add-gadget
        "Value:" down range-model <readout> <labeled-row> add-gadget
    <page> ;

! --- Borders ---

: <bordered-box> ( gap -- gadget )
    [ COLOR: DodgerBlue { 70 30 } <color-box> ] dip <border>
    field-border-color <solid> >>boundary ;

:: <borders-section> ( -- gadget )
    400 280 560 <demo-range> :> width
    12 0 40 <demo-range> :> gap
    1/2 <model> :> align
    f <model> :> fill
    <section>
        "Adjust padding, alignment and fill inside a fixed-height preview. The outline marks the available space." <prose> add-gadget
        width gap align fill <layout-controls> add-gadget
        width range-model gap range-model align fill 4array [
            first4 :> ( w g a f? )
            COLOR: DodgerBlue { 70 30 } <color-box>
            g dup 2array <border>
            a dup 2array >>align
            f? { 1 1 } { 0 0 } ? >>fill
            w 160 2array <stage>
        ] <demo-preview> add-gadget
    <page> ;

! --- Packs ---

: <three-boxes> ( pack -- pack )
    { 3 3 } >>gap
        COLOR: DodgerBlue { 60 25 } <color-box> add-gadget
        COLOR: MediumSeaGreen { 90 25 } <color-box> add-gadget
        COLOR: chocolate1 { 45 25 } <color-box> add-gadget ;

:: <packs-section> ( -- gadget )
    400 280 560 <demo-range> :> width
    8 0 24 <demo-range> :> gap
    0 <model> :> align
    f <model> :> fill
    horizontal <model> :> axis
    <section>
        "Switch between a shelf and a pile. Alignment and fill act across the packing direction; gap separates children." <prose> add-gadget
        axis { { { 1 0 } "Shelf" } { { 0 1 } "Pile" } } <radio-buttons> add-gadget
        width gap align fill <layout-controls> add-gadget
        width range-model gap range-model align fill axis 5 narray [
            [ first4 ] [ 4 swap nth ] bi :> ( w g a f? axis )
            axis <pack> <three-boxes>
            g dup 2array >>gap a >>align f? 1 0 ? >>fill
            w 170 2array <stage>
        ] <demo-preview> add-gadget
    <page> ;

! --- Tracks ---

:: <tracks-section> ( -- gadget )
    400 280 560 <demo-range> :> width
    4 0 24 <demo-range> :> gap
    0 <model> :> align
    t <model> :> fill
    2 1 6 <demo-range> :> share
    <section>
        "The outer cells each receive one share. Change the middle cell's share to see how a track divides the available width." <prose> add-gadget
        width gap align fill <layout-controls> add-gadget
        "Middle share (1 : n : 1)" share <range-row> add-gadget
        width range-model gap range-model align fill share range-model 5 narray [
            [ first4 ] [ 4 swap nth ] bi :> ( w g a f? share )
            horizontal <track> g dup 2array >>gap a >>align f? 1 0 ? >>fill
                COLOR: DodgerBlue { 0 30 } <color-box> 1 track-add
                COLOR: MediumSeaGreen { 0 50 } <color-box> share track-add
                COLOR: chocolate1 { 0 30 } <color-box> 1 track-add
            w 160 2array <stage>
        ] <demo-preview> add-gadget
    <page> ;

! --- Frames ---

: <frames-section> ( -- gadget )
    <section>
        "A frame is a grid with one filled cell, which soaks up all the space the other cells do not need." <prose> add-gadget
        3 3 <frame> { 1 1 } >>filled-cell { 4 4 } >>gap
            COLOR: DodgerBlue { 60 24 } <color-box> { 1 0 } grid-add
            COLOR: DodgerBlue { 60 24 } <color-box> { 1 2 } grid-add
            COLOR: MediumSeaGreen { 24 60 } <color-box> { 0 1 } grid-add
            COLOR: MediumSeaGreen { 24 60 } <color-box> { 2 1 } grid-add
            COLOR: chocolate1 { 0 0 } <color-box> { 1 1 } grid-add
        { 0 0 } <filled-border> { 0 180 } >>min-dim add-gadget
        "The orange cell is the one { 1 1 } >>filled-cell names." <note> add-gadget
    <page> ;

! --- Grids ---

:: <grids-section> ( -- gadget )
    "Property" <heading> :> h1  "Value" <heading> :> h2
    "Width" <label> :> r1       "100 px" <label> :> r2
    "Height" <label> :> r3      "50 px" <label> :> r4
    "Color" <label> :> r5       "Blue" <label> :> r6
    COLOR: DodgerBlue { 60 30 } <color-box> :> c1
    COLOR: MediumSeaGreen { 90 30 } <color-box> :> c2
    COLOR: chocolate1 { 45 30 } <color-box> :> c3
    COLOR: HotPink { 90 30 } <color-box> :> c4
    COLOR: gold { 45 30 } <color-box> :> c5
    COLOR: MediumPurple { 60 30 } <color-box> :> c6
    <section>
        "A grid takes an array of rows, and gives every column the width of its widest cell." <prose> add-gadget
        { { h1 h2 } { r1 r2 } { r3 r4 } { r5 r6 } } <grid> { 24 4 } >>gap
        <pref-width> add-gadget
        "Cells need not be labels:" <heading> add-gadget
        { { c1 c2 c3 } { c4 c5 c6 } } <grid> { 4 4 } >>gap
        <pref-width> add-gadget
    <page> ;

! --- Scrollers ---

! A scroller asks its child, through the optional scrollable
! gadget protocol, how large a window to open onto it. Without
! an answer the scroller would simply grow to fit everything.
TUPLE: window-pile < pack window-dim ;

M: window-pile pref-viewport-dim window-dim>> ;

:: <window-pile> ( dim -- pile )
    window-pile new
        vertical >>orientation
        1 >>fill
        dim >>window-dim ;

: <scrollers-section> ( -- gadget )
    <section>
        "A scroller shows one window onto a child that is larger than the space available to it." <prose> add-gadget
        { 260 180 } <window-pile> { 2 2 } >>gap
            40 <iota> [ "Item " swap unparse append <label> add-gadget ] each
        <scroller> <framed> <pref-width> add-gadget
    <page> ;

! --- Labeled ---

: <labeled-section> ( -- gadget )
    <section>
        "A labeled gadget puts a title bar above its child." <prose> add-gadget
        "Anything can go inside." <label> <inset>
        "Plain" <labeled-gadget> add-gadget
        <filled-pile> { 4 4 } >>gap
            f <model> "Dark mode" <checkbox> add-gadget
            f <model> "Line numbers" <checkbox> add-gadget
        <inset>
        "Colored" panel-background-color <colored-labeled-gadget> add-gadget
        "With a border around the whole thing." <label> <inset>
        "Framed" panel-background-color <framed-labeled-gadget> add-gadget
    <page> ;

! --- Tabs ---

: <tabs-section> ( -- gadget )
    <section>
        "A tabbed gadget is a row of tab buttons driving a book, which shows one page at a time." <prose> add-gadget
        <tabbed-gadget>
            "The book shows whichever page its model selects." <label>
            <inset> "First" add-tab

            <filled-pile> { 4 4 } >>gap
                f <model> "Option A" <checkbox> add-gadget
                f <model> "Option B" <checkbox> add-gadget
            <inset> "Second" add-tab

            COLOR: DodgerBlue { 200 60 } <color-box>
            <inset> "Third" add-tab
        { 0 0 } <filled-border> { 460 200 } >>min-dim <pref-width> add-gadget
    <page> ;

! --- Tables ---

SINGLETON: person-renderer

M: person-renderer column-titles drop { "Name" "Role" "Status" } ;
M: person-renderer row-columns drop ;
M: person-renderer prototype-row drop { "Wilhelmina" "Developer" "Inactive" } ;
! row-color gives a row its text color; f leaves the default.
M: person-renderer row-color
    drop third "Away" = [ dim-color ] [ f ] if ;

CONSTANT: people {
    { "Alice" "Developer" "Active" }
    { "Bob" "Designer" "Away" }
    { "Carol" "Manager" "Active" }
    { "Dave" "Tester" "Away" }
    { "Eve" "Operations" "Active" }
}

:: <tables-section> ( -- gadget )
    people clone <model> :> rows
    0 <model> :> added
    rows person-renderer <table>
        t >>selection-required?
        12 >>gap :> table
    <section>
        "A table renders rows through a renderer, which says what the columns are and how to pull them out of a row." <prose> add-gadget
        table <scroller> <framed> add-gadget
        <shelf-of>
            "Add row" [
                drop added [ 1 + ] change-model
                "Guest " added value>> unparse append "Visitor" "Active" 3array
                rows [ swap suffix ] change-model
            ] <border-button> add-gadget
            "Remove selected" [
                drop table selection-index>> value>> [| index |
                    rows [ index swap remove-nth ] change-model
                ] when*
            ] <border-button> add-gadget
            "Reset rows" [ drop people clone rows set-model ] <border-button> add-gadget
        add-gadget
        "Selected:" table selection>> <readout> <labeled-row> add-gadget
        "Row index:" table selection-index>> <readout> <labeled-row> add-gadget
        "Adding rows preserves selection. Removing the selected row selects the first remaining row; an empty table has no selection." <prose> add-gadget
        "Rows whose status is Away are dimmed by the renderer's row-color." <note> add-gadget
    <page> ;

:: <search-tables-section> ( -- gadget )
    people <model> person-renderer [ " " join ] <search-table> :> search
    <section>
        "Search across names, roles and statuses. Use the arrow keys to move through matching rows, or clear the search to restore all rows." <prose> add-gadget
        search <framed> { 0 220 } >>min-dim add-gadget
        "Selected:" search table>> selection>> <readout> <labeled-row> add-gadget
    <page> ;

:: <comboboxes-section> ( -- gadget )
    { "Small" "Medium" "Large" } <combobox> :> combo
    <section>
        "Click the dropdown and choose an option. The model below shows the combobox's displayed value, including its dropdown marker." <prose> add-gadget
        combo <pref-width> add-gadget
        "Displayed value:" combo model>> <readout> <labeled-row> add-gadget
    <page> ;

! A draggable divider built from a track and the standard gesture protocol.
TUPLE: demo-split < track ;
TUPLE: demo-divider < gadget split ;

M:: demo-split model-changed ( model split -- )
    model value>> 100 / :> share
    split share f 1 share - 3array >>sizes relayout ;

:: move-divider ( divider -- )
    divider split>> :> split
    hand-loc get-global first split screen-loc first - 4 -
    split dim>> first 8 - 1 max / 100 * round 10 90 clamp
    split model>> set-model ;

demo-divider H{
    { T{ button-down } [ move-divider ] }
    { T{ drag { # 1 } } [ move-divider ] }
} set-gestures

:: <split-panes-section> ( -- gadget )
    50 <model> :> ratio
    horizontal demo-split new-track ratio >>model :> split
    split
        "Left pane" <label> <framed> 1 track-add
        demo-divider new split >>split { 8 0 } >>dim
        toolbar-background <solid> >>interior f track-add
        "Right pane" <label> <framed> 1 track-add drop
    <section>
        "Drag the divider to resize the two panes. This example composes a track with a draggable gadget; the split is kept between 10% and 90%." <prose> add-gadget
        split { 520 180 } <stage> add-gadget
        "Left share (%):" ratio <readout> <labeled-row> add-gadget
        "Reset split" [ drop 50 ratio set-model ] <border-button> <pref-width> add-gadget
    <page> ;

! --- Panes ---

: <panes-section> ( -- gadget )
    <section>
        "A pane is an output stream. The listener, the help browser and the inspector are all panes." <prose> add-gadget
        [
            "Anything printable goes to a pane." print
            nl
            H{ { foreground COLOR: DodgerBlue } }
            [ "Styles come from io.styles." print ] with-style
            H{ { font-style bold } } [ "Including bold." print ] with-style
            nl
            "Gadgets can be written to the stream too:" print
            COLOR: MediumSeaGreen { 140 20 } <color-box> gadget.
        ] make-pane <scroller> <framed> add-gadget
    <page> ;

! --- Paragraphs ---

CONSTANT: lorem
"Factor is a stack-based language with a practical standard library. Words are composed on the data stack, and the UI framework builds interfaces out of gadgets that nest inside one another."

: <lorem-paragraph> ( width -- gadget )
    <paragraph> lorem " " split [
        <label> add-gadget " " <word-break-gadget> add-gadget
    ] each ;

:: <paragraphs-section> ( -- gadget )
    400 180 560 <demo-range> :> width
    <section>
        "Move the width slider to rewrap the paragraph. Word-break gadgets determine where wrapping is allowed." <prose> add-gadget
        "Wrap width" width <range-row> add-gadget
        width range-model 1array [ first <lorem-paragraph> <framed> ] <demo-preview> add-gadget
        "An unbroken word can exceed the wrap width:" <heading> add-gadget
        width range-model 1array [
            first <paragraph>
            "LongUnbrokenText_ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789" <label> add-gadget
            <framed>
        ] <demo-preview> add-gadget
    <page> ;

! --- Pens ---

: <pens-section> ( -- gadget )
    <section>
        "A pen paints a gadget's interior or its boundary." <prose> add-gadget
        <shelf-of>
            COLOR: DodgerBlue <solid> { 90 60 } <box> add-gadget
            { COLOR: DodgerBlue COLOR: MediumSeaGreen } <gradient>
            { 90 60 } <box> add-gadget
            COLOR: chocolate1 12 <rounded> { 90 60 } <box> add-gadget
            COLOR: MediumPurple 6 60 polygon-circle <polygon>
            { 90 60 } <box> add-gadget
        add-gadget
        "solid, gradient, rounded, polygon" <note> add-gadget
        "The same pens draw boundaries:" <heading> add-gadget
        <shelf-of>
            <gadget> { 90 60 } >>dim
                COLOR: firebrick <solid> >>boundary add-gadget
            <gadget> { 90 60 } >>dim
                COLOR: firebrick 12 <rounded> >>boundary add-gadget
        add-gadget
    <page> ;

! --- Icons ---

CONSTANT: demo-icons {
    "class-word" "generic-word" "macro-word" "normal-word"
    "primitive-word" "symbol-word" "open-vocab" "help-article"
}

: <icons-section> ( -- gadget )
    <section>
        "An icon draws an image from disk, picking the variant that suits the display's scale factor." <prose> add-gadget
        <shelf-of>
            demo-icons [
                definition-icon-path <image-name> <icon> add-gadget
            ] each
        add-gadget
        "These are the icons the browser uses for definitions." <note> add-gadget
    <page> ;

! --- Toolbars ---

TUPLE: counter < track count ;

: com-increment ( counter -- ) count>> [ 1 + ] change-model ;
: com-decrement ( counter -- ) count>> [ 1 - ] change-model ;
: com-reset ( counter -- ) count>> 0 swap set-model ;

counter "toolbar" f {
    { T{ key-down f f "UP" } com-increment }
    { T{ key-down f f "DOWN" } com-decrement }
    { T{ key-down f f "ESC" } com-reset }
} define-command-map

: <counter> ( -- counter )
    vertical counter new-track
        0 <model> >>count
        { 8 8 } >>gap
        dup <toolbar> format-toolbar f track-add
        dup count>> <readout> "Count:" swap <labeled-row> f track-add ;

: <toolbars-section> ( -- gadget )
    <section>
        "A toolbar turns a command map into buttons. The same commands answer to the key bindings they were declared with." <prose> add-gadget
        <counter> add-gadget
        "Click the counter first, then try the arrow keys or escape." <note> add-gadget
    <page> ;

! --- Popups ---

: popup-below ( owner child -- )
    over [ { 0 0 } ] dip dim>> <rect> show-glass ;

:: <confirm-dialog> ( result -- gadget )
    <filled-pile> { 8 8 } >>gap
        "Are you sure?" <heading> add-gadget
        <shelf-of>
            "Cancel" [ "Cancelled" result set-model hide-glass ] <border-button> add-gadget
            "OK" [ "Confirmed" result set-model hide-glass ] <border-button> add-gadget
        add-gadget
    { 12 12 } <border>
    content-background <solid> >>interior
    field-border-color <solid> >>boundary ;

:: <popups-section> ( -- gadget )
    <counter> :> counter
    "No choice yet" <model> :> result
    <section>
        "Glass layers float above the rest of the window and go away when you click outside them." <prose> add-gadget
        <shelf-of>
            "Dialog" [ result <confirm-dialog> popup-below ] <border-button> add-gadget
            "Menu" [
                drop counter
                { com-increment com-decrement ---- com-reset }
                show-commands-menu
            ] <border-button> add-gadget
        add-gadget
        "Last dialog choice:" result <readout> <labeled-row> add-gadget
        "The menu drives the counter below, using the command map from the previous page." <prose> add-gadget
        counter add-gadget
    <page> ;

! --- The gallery itself ---

CONSTANT: sections {
    { "Labels" [ <labels-section> ] }
    { "Buttons" [ <buttons-section> ] }
    { "Checkboxes" [ <checkboxes-section> ] }
    { "Radio Buttons" [ <radio-buttons-section> ] }
    { "Editors" [ <editors-section> ] }
    { "Sliders" [ <sliders-section> ] }
    { "Borders" [ <borders-section> ] }
    { "Packs" [ <packs-section> ] }
    { "Tracks" [ <tracks-section> ] }
    { "Frames" [ <frames-section> ] }
    { "Grids" [ <grids-section> ] }
    { "Scrollers" [ <scrollers-section> ] }
    { "Labeled" [ <labeled-section> ] }
    { "Tabs" [ <tabs-section> ] }
    { "Tables" [ <tables-section> ] }
    { "Search Tables" [ <search-tables-section> ] }
    { "Combo Boxes" [ <comboboxes-section> ] }
    { "Split Panes" [ <split-panes-section> ] }
    { "Panes" [ <panes-section> ] }
    { "Paragraphs" [ <paragraphs-section> ] }
    { "Pens" [ <pens-section> ] }
    { "Icons" [ <icons-section> ] }
    { "Toolbars" [ <toolbars-section> ] }
    { "Popups" [ <popups-section> ] }
}

:: <sidebar> ( model -- gadget )
    <filled-pile> { 0 1 } >>gap
        sections [| section i |
            i model section first <tab> { 0 1/2 } >>align add-gadget
        ] each-index
    toolbar-background <solid> >>interior <scroller> ;

:: <content> ( model -- gadget )
    model <empty-book> :> book
    sections [
        second call( -- gadget ) <scroller> book swap add-gadget drop
    ] each
    book dup hide-all dup current-page show-gadget ;

: <ui-demo> ( -- gadget )
    0 <model> horizontal <track>
        over <sidebar> f track-add
        swap <content> 1 track-add ;

MAIN-WINDOW: ui-demo {
    { title "UI Demo" }
    { pref-dim { 860 620 } }
}
    <ui-demo> >>gadgets ;
