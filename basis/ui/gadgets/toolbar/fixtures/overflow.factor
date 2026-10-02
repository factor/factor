USING: parser ;
<< "resource:basis/ui/gadgets/toolbar/toolbar.factor" run-file >>
USING: accessors arrays continuations io kernel locals math
math.vectors namespaces sequences system tools.test ui ui.backend
ui.backend.windows ui.commands ui.gadgets ui.gadgets.buttons
ui.gadgets.menus ui.gadgets.private ui.gadgets.toolbar
ui.gadgets.toolbar.private ui.gadgets.worlds ui.gestures ui.render
windows.user32 ;
IN: ui.gadgets.toolbar.native-fixture
TUPLE: toolbar-target clicked ;
: com-native-a ( target -- ) 1 >>clicked drop ;
: com-native-b ( target -- ) 2 >>clicked drop ;
: com-native-c ( target -- ) 3 >>clicked drop ;
toolbar-target "toolbar" f {
    { f com-native-a } { f com-native-b } { f com-native-c }
} define-command-map

:: native-toolbar-test ( -- )
    init-win32-ui
    toolbar-target new :> target
    target <toolbar> :> toolbar
    <world-attributes> "Toolbar overflow regression" >>title
        toolbar 1array >>gadgets <world>
        { -32000 -32000 } >>window-loc :> window
    [
        window open-world-window notify-queued
        window handle>> hWnd>> SW_SHOWNOACTIVATE ShowWindow drop
        window { 100 60 } resize-window
        window set-gl-context window layout window t >>active? draw-world
        window active?>> t assert=
        toolbar overflow-button>> visible?>> t assert=
        toolbar toolbar-overflow-menu items>> length 0 > t assert=
        toolbar overflow-button>> screen-loc hand-loc set-global
        toolbar show-toolbar-overflow notify-queued
        window layout window draw-world
        window active?>> t assert=
        window layers>> last gadget-child :> menu
        menu items>> last button-invoke notify-queued
        target clicked>> 3 assert=
        window layers>> empty? t assert=
        window { 600 60 } resize-window window layout window draw-world
        window active?>> t assert=
        toolbar overflow-button>> visible?>> f assert=
        toolbar toolbar-command-buttons [ visible?>> ] all? t assert=
        "TOOLBAR-NATIVE-PASS" print
    ] [
        [ window ungraft notify-queued ] [ cleanup-win32-ui ] finally
    ] finally ;

native-toolbar-test
0 exit
