USING: parser ;
<<
"resource:basis/windows/dwmapi/dwmapi.factor" run-file
"resource:basis/opengl/textures/textures.factor" run-file
"resource:basis/ui/render/render.factor" run-file
"resource:basis/ui/gadgets/worlds/worlds.factor" run-file
"resource:basis/ui/ui.factor" run-file
"resource:basis/ui/backend/windows/windows.factor" run-file
>>
USING: accessors arrays concurrency.promises continuations io kernel
locals math namespaces sequences system tools.test ui ui.backend.windows
ui.gadgets ui.gadgets.private ui.gadgets.worlds ui.private ui.render windows.user32 ;
IN: ui.backend.windows.startup-failure-fixture

ERROR: demo-startup-error ;
SYMBOL: failed-hwnd
SYMBOL: child-grafts
SYMBOL: frames

TUPLE: failing-world < world ;
M: failing-world begin-world
    handle>> hWnd>> failed-hwnd set-global demo-startup-error ;

TUPLE: pending-child < gadget ;
M: pending-child graft* drop child-grafts [ 1 + ] change-global ;

TUPLE: healthy-child < gadget ;
M: healthy-child pref-dim* drop { 100 100 } ;
M: healthy-child draw-gadget* drop frames [ 1 + ] change-global ;

:: check-failure ( healthy -- )
    pending-child new :> child
    <world-attributes> failing-world >>world-class
        child 1array >>gadgets { 100 100 } >>pref-dim <world>
        { -32000 -32000 } >>window-loc :> failed
    failed layout-queue push
    child layout-queue push
    [ failed open-world-window notify-queued f ]
    [ demo-startup-error? ] recover t assert=
    failed handle>> f assert=
    failed graft-state>> { f f } assert=
    failed promise>> promise-fulfilled? t assert=
    failed-hwnd get-global IsWindow 0 assert=
    failed-hwnd get-global window f assert=
    failed layout-queue member? f assert=
    child layout-queue member? f assert=
    healthy layout-queue member? t assert=
    notify-queued
    child graft-state>> { f f } assert=
    child-grafts get-global 0 assert=
    healthy t >>active? drop
    update-ui
    frames get-global 0 > t assert= ;

:: check-close ( healthy -- )
    healthy handle>> hWnd>> :> hwnd
    healthy layout-queue push
    healthy children>> first layout-queue push
    healthy ungraft notify-queued
    healthy handle>> f assert=
    hwnd IsWindow 0 assert=
    layout-queue empty? t assert=
    update-ui ;

:: startup-failure-test ( -- )
    init-win32-ui
    0 child-grafts set-global
    0 frames set-global
    <world-attributes> healthy-child new 1array >>gadgets <world>
        { -32000 -32000 } >>window-loc :> healthy
    [
        healthy open-world-window notify-queued
        healthy check-failure
        healthy check-close
        "STARTUP-FAILURE-PASS" print
    ] [
        healthy handle>> [ healthy ungraft notify-queued ] when
        cleanup-win32-ui
    ] finally ;

startup-failure-test
0 exit
