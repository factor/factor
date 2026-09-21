USING: accessors arrays continuations kernel locals math models namespaces sequences tools.test
ui-demo ui.gadgets ui.gadgets.borders ui.gadgets.buttons ui.gadgets.debug
ui.gadgets.editors ui.gadgets.labels ui.gadgets.search-tables
ui.gadgets.tables ui.gadgets.tables.private ui.gestures ;
IN: ui-demo.tests

: descendants ( gadget -- gadgets )
    dup children>> [ descendants ] map concat swap prefix ;

:: demo-button ( gadget text -- button )
    gadget descendants [ button? ] filter
    [ gadget-child dup label? [ text>> text = ] [ drop f ] if ] find nip ;

! Build, activate and lay out every page, including model-driven previews.
{ } [
    sections [
        second call( -- gadget ) dup [ dup prefer layout ] with-grafted-gadget
    ] each
] unit-test

:: exercise-preview ( constructor -- ? )
    constructor call( -- gadget ) :> page
    page [
        page descendants [ demo-preview? ] find nip :> preview
        320 preview model>> dependencies>> first set-model
        page prefer page layout
        preview gadget-child dim>> first 320 number=
    ] with-grafted-gadget ;

{ t t t } [
    [ <borders-section> ] exercise-preview
    [ <packs-section> ] exercise-preview
    [ <tracks-section> ] exercise-preview
] unit-test

:: table-actions-test ( -- preserved? removed? empty? )
    <tables-section> :> page
    page [
        page descendants [ table? ] find nip :> table
        2 table select-table-row
        page "Add row" demo-button button-invoke
        table selection-index>> value>> 2 =
        page "Remove selected" demo-button button-invoke
        table selection-index>> value>> 0 =
        5 [ page "Remove selected" demo-button button-invoke ] times
        table selection>> value>> not
    ] with-grafted-gadget ;

{ t t t } [ table-actions-test ] unit-test

{ "Confirmed" "Cancelled" } [
    f <model> dup <confirm-dialog>
    dup "OK" demo-button button-invoke
    over value>> -rot
    "Cancel" demo-button button-invoke value>>
] unit-test

{ t } [
    <split-panes-section> dup [
        descendants [ demo-split? ] find nip
        75 over model>> set-model
        sizes>> { 3/4 f 1/4 } =
    ] with-grafted-gadget
] unit-test

{ 1 0 5 } [
    <search-tables-section> dup [ [let
        descendants [ search-table? ] find nip :> search
        search field>> field>> editor>> :> editor
        "Developer" editor set-editor-string
        search table>> control-value length
        "no matching person" editor set-editor-string
        search table>> control-value length
        "" editor set-editor-string
        search table>> control-value length
    ] ] with-grafted-gadget
] unit-test

{ t t } [
    <checkboxes-section> dup [ [let
        descendants [ demo-preview? ] find nip :> preview
        preview model>> dependencies>> first :> toggle
        f toggle set-model
        preview gadget-child children>> empty?
        t toggle set-model
        preview gadget-child children>> empty? not
    ] ] with-grafted-gadget
] unit-test

:: divider-drag-test ( -- left right )
    hand-loc get-global :> previous
    <split-panes-section> :> page
    page [
        page prefer page layout
        page descendants [ demo-divider? ] find nip :> divider
        [
            { -10000 0 } hand-loc set-global
            divider move-divider
            divider split>> model>> value>>
            { 10000 0 } hand-loc set-global
            divider move-divider
            divider split>> model>> value>>
        ] [ previous hand-loc set-global ] finally
    ] with-grafted-gadget ;

{ 10 90 } [ divider-drag-test ] unit-test
