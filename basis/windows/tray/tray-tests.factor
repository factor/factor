USING: accessors alien alien.c-types alien.data alien.strings alien.syntax arrays assocs
calendar classes.struct continuations destructors io io.encodings.utf8
io.launcher kernel libc locals math math.bitwise
namespaces opengl sequences strings system tools.test ui.backend.windows
windows.errors windows.messages windows.shell32 windows.tray windows.tray.private
windows.types windows.user32 ;
IN: windows.tray.tests

LIBRARY: user32
FUNCTION: int GetMenuItemCount ( HMENU hMenu )
FUNCTION: UINT GetMenuItemID ( HMENU hMenu, int nPos )
FUNCTION: int GetMenuStringW ( HMENU hMenu, UINT uIDItem, WCHAR* lpString, int cchMax, UINT flags )

:: with-tray-test-window ( quot: ( hwnd -- ) -- )
    gl-scale-factor get-global :> old-scale
    [
        "FactorTrayTest" native-string>alien malloc-byte-array &free
        register-window-class
    ] with-destructors
    WS_EX_NOACTIVATE WS_EX_TOOLWINDOW bitor "FactorTrayTest" "tray-test"
    WS_POPUP -32000 -32000 100 100 f f f f CreateWindowEx
    dup win32-error=0/f :> hwnd
    [ hwnd quot call ] [
        hwnd dispose-window-tray-icons
        hwnd DestroyWindow drop
        old-scale gl-scale-factor set-global
    ] finally ; inline

! Exercise real Shell_NotifyIcon calls against a hidden owner window.
{ t t t t } [
    [| hwnd |
        "first" hwnd <tray-icon> :> first-icon
        "second" hwnd <tray-icon> :> second-icon
        first-icon data>> uID>> second-icon data>> uID>> = not
        "renamed" first-icon set-tray-icon-tip
        first-icon data>> szTip>> first CHAR: r =
        first-icon dispose
        first-icon disposed>>
        hwnd dispose-window-tray-icons
        second-icon disposed>>
    ] with-tray-test-window
] unit-test

! Send actual window messages using the version-4 icon ID/event encoding.
{ 3 0 } [
    [| hwnd |
        0 :> clicks!
        "callbacks" hwnd <tray-icon> [ clicks 1 + clicks! ] >>action :> icon
        icon data>> uID>> 16 shift :> id
        NIN_SELECT NIN_KEYSELECT NIN_BALLOONUSERCLICK 3array [| event |
            hwnd WM_FACTOR_TRAYICON 0 id event bitor SendMessage drop
        ] each
        clicks
        icon dispose
        "survivor" hwnd <tray-icon> [ clicks 1 + clicks! ] >>action :> survivor
        ! A disposed icon's messages must not invoke its old quotation.
        hwnd WM_FACTOR_TRAYICON 0 id NIN_SELECT bitor SendMessage drop
        clicks 3 -
        survivor dispose
    ] with-tray-test-window
] unit-test

! Menu labels are Unicode; separators preserve command indices.
{ 3 1 3 { 65 937 55357 56832 0 } } [| |
    { { "AΩ😀" [ ] } f { "Last" [ ] } } <tray-menu> :> menu
    [
        menu GetMenuItemCount
        menu 0 GetMenuItemID
        menu 2 GetMenuItemID
        5 WCHAR <c-array> :> buffer
        menu 0 buffer 5 MF_BYPOSITION GetMenuStringW drop
        buffer >array
    ] [ menu DestroyMenu drop ] finally
] unit-test

{ 1 } [| |
    0 :> calls!
    "Run" [ calls 1 + calls! ] 2array f 2array :> items
    0 items invoke-menu-item
    2 items invoke-menu-item
    99 items invoke-menu-item
    1 items invoke-menu-item
    calls
] unit-test

! Re-add the native icon, as if Explorer had discarded the taskbar state.
{ t } [
    [| hwnd |
        "restart" hwnd <tray-icon> :> icon
        NIM_DELETE icon data>> Shell_NotifyIcon zero? not
        hwnd "TaskbarCreated" RegisterWindowMessage 0 0 SendMessage drop
        "restored" icon set-tray-icon-tip
    ] with-tray-test-window
] unit-test

! An empty body removes a notification, without displaying a test popup.
{ } [
    [| hwnd |
        "notification" hwnd <tray-icon> :> icon
        "Title" "" icon show-tray-notification
    ] with-tray-test-window
] unit-test

[ "orphan" f <tray-icon> ] [ tray-icon-error? ] must-fail-with

[ tray-icon new t >>disposed "title" swap set-tray-icon-tip ]
[ already-disposed? ] must-fail-with

! Exercise native selection and cancellation in a child with a hard timeout.
{ t } [
    <process>
        vm-path "-no-user-init"
        "resource:basis/windows/tray/fixtures/menu.factor" 3array >>command
        t >>hidden 15 seconds >>timeout
        +closed+ >>stdin +stdout+ >>stderr
    utf8 [ read-contents ] with-process-reader*
    0 = [ drop "TRAY-MENU-PASS" subseq-of? ] [ output-process-error ] if
] unit-test

! Destruction through the native window procedure also disposes its icons.
{ t } [
    [| hwnd |
        "owned" hwnd <tray-icon> :> icon
        hwnd DestroyWindow win32-error=0/f
        icon disposed>>
    ] with-tray-test-window
] unit-test
