USING: parser vocabs ;
<<
"resource:basis/windows/user32/user32.factor" run-file
"resource:basis/windows/shell32/shell32.factor" run-file
"resource:basis/windows/dwmapi/dwmapi.factor" run-file
"windows.tray" require
"resource:basis/ui/backend/windows/windows.factor" run-file
>>
USING: accessors alien.c-types alien.data alien.strings alien.syntax arrays assocs continuations
destructors io kernel libc locals math math.bitwise namespaces
tools.test ui.backend.windows windows.errors windows.messages
windows.tray windows.types windows.user32 ;
IN: windows.tray.fixture

LIBRARY: user32
FUNCTION: UINT_PTR SetTimer ( HWND hwnd, UINT_PTR id, UINT interval, void* callback )
FUNCTION: BOOL KillTimer ( HWND hwnd, UINT_PTR id )
FUNCTION: HWND FindWindowExW ( HWND parent, HWND after, LPCWSTR class, LPCWSTR title )

SYMBOL: accept-menu?

:: menu-window ( hwnd after -- popup/f )
    f after "#32768" f FindWindowExW :> popup
    popup [
        hwnd f GetWindowThreadProcessId popup f GetWindowThreadProcessId =
        [ popup ] [ hwnd popup menu-window ] if
    ] [ f ] if ;

:: automate-menu ( hwnd msg wParam lParam -- result )
    accept-menu? get-global [
        hwnd f menu-window [| popup |
            popup f -32000 -32000 0 0
            SWP_NOSIZE SWP_NOZORDER bitor SWP_NOACTIVATE bitor SetWindowPos drop
            popup WM_KEYDOWN VK_DOWN 0 PostMessage drop
            popup WM_KEYDOWN VK_RETURN 0 PostMessage drop
        ] when*
    ] [ hwnd WM_CANCELMODE 0 0 PostMessage drop ] if
    0 ;

:: check-menus ( -- )
    [
        "FactorTrayMenuTest" native-string>alien malloc-byte-array &free
        register-window-class
    ] with-destructors
    WS_EX_NOACTIVATE WS_EX_TOOLWINDOW bitor "FactorTrayMenuTest" "menu-test"
    WS_POPUP -32000 -32000 100 100 f f f f CreateWindowEx
    dup win32-error=0/f :> hwnd
    [
        [ automate-menu ] WM_TIMER add-wm-handler
        "Menu test" hwnd <tray-icon> :> icon
        0 :> selections!
        "Select" [ selections 1 + selections! ] 2array 1array
        icon swap >>menu drop
        hwnd 1 50 f SetTimer dup win32-error=0/f drop
        t accept-menu? set-global
        ! Deliver a real tray context-menu callback through the native window.
        hwnd WM_FACTOR_TRAYICON 0
        icon data>> uID>> 16 shift WM_CONTEXTMENU bitor SendMessage drop
        selections 1 assert=
        f accept-menu? set-global
        icon show-tray-menu
        selections 1 assert=
    ] [
        hwnd 1 KillTimer drop
        hwnd DestroyWindow drop
    ] finally
    "TRAY-MENU-PASS" print ;

check-menus
