USING: alien alien.syntax assocs continuations kernel layouts locals
namespaces tools.test ui.backend.windows windows.types ;
IN: ui.backend.windows.tests

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
