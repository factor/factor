! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.strings arrays assocs classes.struct
combinators continuations destructors kernel locals math math.bitwise
namespaces sequences windows.errors windows.kernel32
windows.messages windows.shell32 windows.types windows.user32 ;
IN: windows.tray

CONSTANT: WM_FACTOR_TRAYICON 0x8033

TUPLE: tray-icon < disposable data action menu ;

ERROR: tray-icon-error operation ;
ERROR: too-many-tray-icons hwnd ;

<PRIVATE

SYMBOL: tray-icons
tray-icons [ H{ } clone ] initialize
SYMBOL: next-tray-id
next-tray-id [ 0 ] initialize

: icon-key ( hwnd id -- key ) [ alien-address ] dip 2array ;
: tray-icon-key ( icon -- key ) data>> [ hWnd>> ] [ uID>> ] bi icon-key ;

:: notify-icon ( operation data -- )
    operation data Shell_NotifyIcon zero? [ operation tray-icon-error ] when ;

: add-notify-icon ( data -- )
    dup NIM_ADD swap notify-icon
    [
        NOTIFYICON_VERSION_4 over timeout-version>> uVersion<<
        NIM_SETVERSION swap notify-icon
    ] [ NIM_DELETE rot Shell_NotifyIcon drop rethrow ] recover ;

:: free-icon-id ( hwnd -- id )
    0 :> checked!
    f :> id!
    [ id not checked 65535 < and ] [
        next-tray-id [ 65535 mod 1 + ] change-global
        next-tray-id get-global :> candidate
        hwnd candidate icon-key tray-icons get-global key?
        [ candidate id! ] unless
        checked 1 + checked!
    ] while
    id [ id ] [ hwnd too-many-tray-icons ] if ;

: icon-identity ( icon -- data )
    data>> [
        NOTIFYICONDATA new NOTIFYICONDATA heap-size >>cbSize
    ] dip [ hWnd>> >>hWnd ] [ uID>> >>uID ] bi ;

:: <tray-menu> ( items -- menu )
    CreatePopupMenu dup win32-error=0/f :> menu
    [
        items [| item index |
            item [
                menu MF_STRING index 1 + item first AppendMenu win32-error=0/f
            ] [ menu MF_SEPARATOR 0 f AppendMenu win32-error=0/f ] if
        ] each-index
        menu
    ] [ menu DestroyMenu drop rethrow ] recover ;

:: invoke-menu-item ( command items -- )
    command 0 > command items length <= and [
        command 1 - items nth [ second call( -- ) ] when*
    ] when ;

PRIVATE>

:: <tray-icon> ( title hwnd -- icon )
    NOTIFYICONDATA new NOTIFYICONDATA heap-size >>cbSize
        hwnd >>hWnd hwnd free-icon-id >>uID
        NIF_MESSAGE NIF_ICON bitor NIF_TIP bitor NIF_SHOWTIP bitor >>uFlags
        WM_FACTOR_TRAYICON >>uCallbackMessage
        f GetModuleHandle "APPICON" native-string>alien LoadIcon >>hIcon
        title swap set-notify-icon-tip :> data
    data add-notify-icon
    tray-icon new-disposable data >>data [ ] >>action { } >>menu :> icon
    icon icon tray-icon-key tray-icons get-global set-at
    icon ;

M: tray-icon dispose*
    [ tray-icon-key tray-icons get-global delete-at ]
    [ icon-identity NIM_DELETE swap Shell_NotifyIcon drop ] bi ;

: set-tray-icon-tip ( title icon -- )
    check-disposed data>> set-notify-icon-tip NIM_MODIFY swap notify-icon ;

:: show-tray-notification ( title text icon -- )
    icon check-disposed icon-identity
        NIF_INFO >>uFlags
        NIIF_INFO NIIF_RESPECT_QUIET_TIME bitor >>dwInfoFlags
        title swap set-notify-icon-info-title
        text swap set-notify-icon-info
    NIM_MODIFY swap notify-icon ;

:: show-tray-menu ( icon -- )
    icon check-disposed drop
    icon menu>> clone :> items
    items empty? [
        icon data>> hWnd>> :> hwnd
        items <tray-menu> :> menu
        [
            POINT new dup GetCursorPos win32-error=0/f :> point
            hwnd SetForegroundWindow drop
            menu TPM_RIGHTBUTTON TPM_NONOTIFY bitor TPM_RETURNCMD bitor
            point x>> point y>> 0 hwnd f TrackPopupMenu
        ] [
            menu DestroyMenu drop
            hwnd WM_NULL 0 0 PostMessage drop
            NIM_SETFOCUS icon icon-identity Shell_NotifyIcon drop
        ] finally
        items invoke-menu-item
    ] unless ;

:: handle-tray-event ( hwnd wParam lParam -- )
    hwnd lParam hi-word icon-key tray-icons get-global at [| icon |
        lParam lo-word {
            { NIN_SELECT [ icon action>> call( -- ) ] }
            { NIN_KEYSELECT [ icon action>> call( -- ) ] }
            { NIN_BALLOONUSERCLICK [ icon action>> call( -- ) ] }
            { WM_CONTEXTMENU [ icon show-tray-menu ] }
            [ drop ]
        } case
    ] when* ;

: dispose-window-tray-icons ( hwnd -- )
    alien-address tray-icons get-global values
    [ data>> hWnd>> alien-address = ] with filter dispose-each ;

: restore-tray-icons ( -- )
    tray-icons get-global values [ data>> add-notify-icon ] each ;
