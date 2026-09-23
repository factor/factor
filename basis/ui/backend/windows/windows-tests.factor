USING: accessors alien alien.syntax arrays assocs continuations
kernel layouts locals namespaces sequences tools.test
ui.backend.windows ui.gadgets ui.gadgets.private ui.gadgets.worlds
ui.private windows.types ;
USING: calendar concurrency.promises math threads windows.errors
windows.messages windows.user32 ;
IN: ui.backend.windows.tests

! A pending paint must be validated before the handler yields to another
! Factor thread. Use a nonactivating tool window positioned offscreen.
{ t t } [| |
    WS_EX_NOACTIVATE WS_EX_TOOLWINDOW bitor "STATIC" "paint-regression"
    WS_POPUP WS_VISIBLE bitor -32000 -32000 100 100 f f f f
    CreateWindowEx dup win32-error=0/f :> hwnd
    [
        world new \ invalidate* >>layout-state :> test-world
        test-world hwnd register-window
        hwnd f FALSE InvalidateRect win32-error=0/f
        hwnd f FALSE GetUpdateRect zero? not
        <promise> :> validated
        [ hwnd f FALSE GetUpdateRect zero? validated fulfill ]
        "paint validation observer" spawn drop
        hwnd WM_PAINT 0 0 handle-wm-paint
        validated 5 seconds ?promise-timeout
    ] [
        hwnd unregister-window
        hwnd DestroyWindow drop
    ] finally
] unit-test

:: window-callback-result ( result -- returned )
    wm-handlers get-global :> original-handlers
    [
        original-handlers clone wm-handlers set-global
        [ 4drop result ] 0x8001 wm-handlers get-global set-at
        f 0x8001 0 0 ui-wndproc
        LRESULT { HWND UINT WPARAM LPARAM } stdcall alien-indirect
    ] [ original-handlers wm-handlers set-global ] finally ;

{ -1 } [ -1 window-callback-result ] unit-test
{ 42 } [ 42 window-callback-result ] unit-test

! WNDPROC returns pointer-sized LRESULT, not a 32-bit unsigned integer.
64-bit? [
    { 0x1234567887654321 } [ 0x1234567887654321 window-callback-result ] unit-test
    { -0x1234567887654321 } [ -0x1234567887654321 window-callback-result ] unit-test
] when

:: test-monitor-layout-invalidation ( -- text-empty? images-empty? pref queued? )
    V{ } clone \ layout-queue [
        <gadget> { 20 10 } >>pref-dim :> child
        <world-attributes> child 1array >>gadgets <world>
            H{ { "old text texture" t } } clone >>text-handle
            H{ { "old image texture" t } } clone >>images :> window
        window window-scale-changed
        window text-handle>> assoc-empty?
        window images>> assoc-empty?
        child pref-dim>>
        window layout-queue member?
    ] with-variable ;

{ t t f t } [ test-monitor-layout-invalidation ] unit-test
