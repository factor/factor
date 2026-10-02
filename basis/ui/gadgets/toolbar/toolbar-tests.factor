USING: accessors arrays kernel locals math namespaces sequences
tools.test ui.commands ui.gadgets ui.gadgets.buttons ui.gadgets.menus
ui.gadgets.toolbar ui.gadgets.toolbar.private ui.gadgets.tracks ;
FROM: ui.gadgets.private => in-layout? ;
USING: calendar io io.encodings.utf8 io.launcher system ;
IN: ui.gadgets.toolbar.tests

TUPLE: foo-gadget ;

: com-foo-a ( -- ) ;

: com-foo-b ( -- ) ;

\ foo-gadget "toolbar" f {
    { f com-foo-a }
    { f com-foo-b }
} define-command-map

T{ foo-gadget } <toolbar> "t" set

{ 2 f } [ "t" get [ toolbar-command-buttons length ] [ overflow-button>> visible?>> ] bi ] unit-test
{ "Foo A" } [ "t" get gadget-child gadget-child string>> ] unit-test

: layout-toolbar ( toolbar -- toolbar )
    dup t in-layout? [ layout ] with-variable ;

:: test-toolbar ( width -- toolbar )
    T{ foo-gadget } <toolbar> :> toolbar
    toolbar toolbar-command-buttons first { 40 20 } >>pref-dim drop
    toolbar toolbar-command-buttons second { 60 20 } >>pref-dim drop
    toolbar overflow-button>> { 20 20 } >>pref-dim drop
    toolbar width 30 2array >>dim layout-toolbar ;

! Natural preferred size does not reserve space for the hidden overflow button.
{ 105 } [ 80 test-toolbar pref-dim first ] unit-test

{ { t f } t { 45.0 0.0 } } [
    80 test-toolbar
    [ toolbar-command-buttons [ visible?>> ] map >array ]
    [ overflow-button>> visible?>> ]
    [ overflow-button>> loc>> ] tri
] unit-test

{ { t t } f 0 } [
    105 test-toolbar
    [ toolbar-command-buttons [ visible?>> ] map >array ]
    [ overflow-button>> visible?>> ]
    [ toolbar-overflow-menu items>> length ] tri
] unit-test

{ { f f } t 2 } [
    30 test-toolbar
    [ toolbar-command-buttons [ visible?>> ] map >array ]
    [ overflow-button>> visible?>> ]
    [ toolbar-overflow-menu items>> length ] tri
] unit-test

! Widening a toolbar restores its original buttons and hides the menu button.
{ { t t } f } [
    30 test-toolbar { 150 30 } >>dim dup relayout layout-toolbar
    [ toolbar-command-buttons [ visible?>> ] map >array ]
    [ overflow-button>> visible?>> ] bi
] unit-test

! Extra controls added with track-add keep their space and relative sizing.
{ { f f } t { 25.0 0.0 } { 55.0 30.0 } } [| |
    80 test-toolbar :> toolbar
    <gadget> { 35 30 } >>dim :> extra
    toolbar extra 1 track-add layout-toolbar
    [ toolbar-command-buttons [ visible?>> ] map >array ]
    [ overflow-button>> visible?>> ] bi
    extra [ loc>> ] [ dim>> ] bi
] unit-test

SYMBOL: overflow-target
TUPLE: command-target ;
: com-overflow ( target -- ) overflow-target set ;
command-target "toolbar" f { { f com-overflow } } define-command-map

! Menu buttons dispatch through the original command target.
{ t } [| |
    command-target new :> target
    target <toolbar> { 1 30 } >>dim layout-toolbar
    toolbar-overflow-menu items>> first button-invoke
    overflow-target get target eq?
] unit-test

! Hidden buttons never intercept pointer events at their old positions.
{ 1 } [ 30 test-toolbar f swap children-on length ] unit-test

! Removing a command must remove it from overflow menus too.
{ 1 1 } [| |
    30 test-toolbar :> toolbar
    toolbar toolbar-command-buttons first :> button
    button unparent
    toolbar relayout toolbar layout-toolbar drop
    toolbar toolbar-command-buttons length
    toolbar toolbar-overflow-menu items>> length
] unit-test

! Dynamically added commands retain their own command target.
{ t } [| |
    command-target new :> target
    30 test-toolbar :> toolbar
    toolbar target f \ com-overflow <toolbar-button> f track-add
    layout-toolbar toolbar-overflow-menu items>> last button-invoke
    overflow-target get target eq?
] unit-test

TUPLE: empty-toolbar-target ;
empty-toolbar-target "toolbar" f { } define-command-map
{ 0 f } [
    empty-toolbar-target new <toolbar> { 10 30 } >>dim layout-toolbar
    [ pref-dim first ] [ overflow-button>> visible?>> ] bi
] unit-test

{ { 0.0 30.0 } } [| |
    10 test-toolbar :> toolbar
    <gadget> { 35 30 } >>dim :> extra
    toolbar extra 1 track-add layout-toolbar drop
    extra dim>>
] unit-test

! Verify rendering, popup lifecycle, dispatch and resize in a native window.
os windows? [
    { t } [
        <process> vm-path "-no-user-init"
            "resource:basis/ui/gadgets/toolbar/fixtures/overflow.factor" 3array >>command
            t >>hidden 20 seconds >>timeout
            +closed+ >>stdin +stdout+ >>stderr
        utf8 [ read-contents ] with-process-reader*
        0 = [ drop "TOOLBAR-NATIVE-PASS" subseq-of? ] [ output-process-error ] if
    ] unit-test
] when
