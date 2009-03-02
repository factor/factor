! Copyright (C) 2005, 2006 Doug Coleman.
! Portions copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings arrays assocs ui
ui.gadgets ui.backend ui.clipboards ui.gadgets.worlds
ui.gestures ui.event-loop io kernel math math.vectors namespaces
make sequences strings vectors words windows.kernel32
windows.gdi32 windows.user32 windows.opengl32 windows.messages
windows.types windows.nt windows threads libc combinators fry
combinators.short-circuit continuations command-line shuffle
opengl ui.render ascii math.bitwise locals accessors
math.geometry.rect math.order ascii calendar io.encodings.utf16n
;
IN: ui.windows

SINGLETON: windows-ui-backend

: crlf>lf ( str -- str' )
    CHAR: \r swap remove ;

: lf>crlf ( str -- str' )
    [ [ dup CHAR: \n = [ CHAR: \r , ] when , ] each ] "" make ;

: enum-clipboard ( -- seq )
    0 [ EnumClipboardFormats win32-error dup dup 0 > ] [ ] produce 2nip ;

: with-clipboard ( quot -- )
    f OpenClipboard win32-error=0/f
    call
    CloseClipboard win32-error=0/f ; inline

: paste ( -- str )
    [
        CF_UNICODETEXT IsClipboardFormatAvailable zero? [
            ! nothing to paste
            ""
        ] [
            CF_UNICODETEXT GetClipboardData dup win32-error=0/f
            dup GlobalLock dup win32-error=0/f
            GlobalUnlock win32-error=0/f
            utf16n alien>string
        ] if
    ] with-clipboard
    crlf>lf ;

: copy ( str -- )
    lf>crlf [
        utf16n string>alien
        EmptyClipboard win32-error=0/f
        GMEM_MOVEABLE over length 1+ GlobalAlloc
            dup win32-error=0/f
    
        dup GlobalLock dup win32-error=0/f
        swapd byte-array>memory
        dup GlobalUnlock win32-error=0/f
        CF_UNICODETEXT swap SetClipboardData win32-error=0/f
    ] with-clipboard ;

TUPLE: pasteboard ;
C: <pasteboard> pasteboard

M: pasteboard clipboard-contents drop paste ;
M: pasteboard set-clipboard-contents drop copy ;

: init-clipboard ( -- )
    <pasteboard> clipboard set-global
    <clipboard> selection set-global ;

TUPLE: win-base hDC hRC ;
TUPLE: win < win-base hWnd world title ;
TUPLE: win-offscreen < win-base hBitmap bits ;
C: <win> win
C: <win-offscreen> win-offscreen

SYMBOLS: msg-obj class-name-ptr mouse-captured ;

: style ( -- n ) WS_OVERLAPPEDWINDOW ; inline
: ex-style ( -- n ) WS_EX_APPWINDOW WS_EX_WINDOWEDGE bitor ; inline

: get-RECT-top-left ( RECT -- x y )
    [ RECT-left ] keep RECT-top ;

: get-RECT-dimensions ( RECT -- x y width height )
    [ get-RECT-top-left ] keep
    [ RECT-right ] keep [ RECT-left - ] keep
    [ RECT-bottom ] keep RECT-top - ;

: handle-wm-paint ( hWnd uMsg wParam lParam -- )
    #! wParam and lParam are unused
    #! only paint if width/height both > 0
    3drop window relayout-1 yield ;

: handle-wm-size ( hWnd uMsg wParam lParam -- )
    2nip
    [ lo-word ] keep hi-word 2array
    dup { 0 0 } = [ 2drop ] [ swap window (>>dim) ] if ;

: handle-wm-move ( hWnd uMsg wParam lParam -- )
    2nip
    [ lo-word ] keep hi-word 2array
    swap window (>>window-loc) ;

CONSTANT: wm-keydown-codes
    H{
        { 8 "BACKSPACE" }
        { 9 "TAB" }
        { 13 "RET" }
        { 27 "ESC" }
        { 33 "PAGE_UP" }
        { 34 "PAGE_DOWN" }
        { 35 "END" }
        { 36 "HOME" }
        { 37 "LEFT" }
        { 38 "UP" }
        { 39 "RIGHT" }
        { 40 "DOWN" }
        { 45 "INSERT" }
        { 46 "DELETE" }
        { 112 "F1" }
        { 113 "F2" }
        { 114 "F3" }
        { 115 "F4" }
        { 116 "F5" }
        { 117 "F6" }
        { 118 "F7" }
        { 119 "F8" }
        { 120 "F9" }
        { 121 "F10" }
        { 122 "F11" }
        { 123 "F12" }
    }

: key-state-down? ( key -- ? )
    GetKeyState 16 bit? ;

: left-shift? ( -- ? ) VK_LSHIFT key-state-down? ;
: left-ctrl? ( -- ? ) VK_LCONTROL key-state-down? ;
: left-alt? ( -- ? ) VK_LMENU key-state-down? ;
: right-shift? ( -- ? ) VK_RSHIFT key-state-down? ;
: right-ctrl? ( -- ? ) VK_RCONTROL key-state-down? ;
: right-alt? ( -- ? ) VK_RMENU key-state-down? ;
: shift? ( -- ? ) left-shift? right-shift? or ;
: ctrl? ( -- ? ) left-ctrl? right-ctrl? or ;
: alt? ( -- ? ) left-alt? right-alt? or ;
: caps-lock? ( -- ? ) VK_CAPITAL GetKeyState zero? not ;

: key-modifiers ( -- seq )
    [
        shift? [ S+ , ] when
        ctrl? [ C+ , ] when
        alt? [ A+ , ] when
    ] { } make [ empty? not ] keep f ? ;

CONSTANT: exclude-keys-wm-keydown
    H{
        { 16 "SHIFT" }
        { 17 "CTRL" }
        { 18 "ALT" }
        { 20 "CAPS-LOCK" }
    }

! Values are ignored
CONSTANT: exclude-keys-wm-char
    H{
        { 8 "BACKSPACE" }
        { 9 "TAB" }
        { 13 "RET" }
        { 27 "ESC" }
    }

: exclude-key-wm-keydown? ( n -- ? )
    exclude-keys-wm-keydown key? ;

: exclude-key-wm-char? ( n -- ? )
    exclude-keys-wm-char key? ;

: keystroke>gesture ( n -- mods sym )
    wm-keydown-codes at* [ key-modifiers swap ] [ drop f f ] if ;

: send-key-gesture ( sym action? quot hWnd -- )
    [ [ key-modifiers ] 3dip call ] dip
    window propagate-key-gesture ; inline

: send-key-down ( sym action? hWnd -- )
    [ [ <key-down> ] ] dip send-key-gesture ;

: send-key-up ( sym action? hWnd -- )
    [ [ <key-up> ] ] dip send-key-gesture ;

: key-sym ( wParam -- string/f action? )
    {
        {
            [ dup LETTER? ]
            [ shift? caps-lock? xor [ CHAR: a + CHAR: A - ] unless 1string f ]
        }
        { [ dup digit? ] [ 1string f ] }
        [ wm-keydown-codes at t ]
    } cond ;

:: handle-wm-keydown ( hWnd uMsg wParam lParam -- )
    wParam exclude-key-wm-keydown? [
        wParam key-sym over [
            dup ctrl? alt? xor or [
                hWnd send-key-down
            ] [ 2drop ] if
        ] [ 2drop ] if
    ] unless ;

:: handle-wm-char ( hWnd uMsg wParam lParam -- )
    wParam exclude-key-wm-char? [
        ctrl? alt? xor [
            wParam 1string
            [ f hWnd send-key-down ]
            [ hWnd window user-input ] bi
        ] unless
    ] unless ;

:: handle-wm-keyup ( hWnd uMsg wParam lParam -- )
    wParam exclude-key-wm-keydown? [
        wParam key-sym over [
            hWnd send-key-up
        ] [ 2drop ] if
    ] unless ;

:: set-window-active ( hwnd uMsg wParam lParam ? -- n )
    ? hwnd window (>>active?)
    hwnd uMsg wParam lParam DefWindowProc ;

: handle-wm-syscommand ( hWnd uMsg wParam lParam -- n )
    {
        { [ over SC_MINIMIZE = ] [ f set-window-active ] }
        { [ over SC_RESTORE = ] [ t set-window-active ] }
        { [ over SC_MAXIMIZE = ] [ t set-window-active ] }
        { [ dup alpha? ] [ 4drop 0 ] }
        { [ t ] [ DefWindowProc ] }
    } cond ;

: cleanup-window ( handle -- )
    dup title>> [ free ] when*
    dup hRC>> wglDeleteContext win32-error=0/f
    dup hWnd>> swap hDC>> ReleaseDC win32-error=0/f ;

M: windows-ui-backend (close-window)
    dup hWnd>> unregister-window
    dup cleanup-window
    hWnd>> DestroyWindow win32-error=0/f ;

: handle-wm-close ( hWnd uMsg wParam lParam -- )
    3drop window ungraft ;

: handle-wm-set-focus ( hWnd uMsg wParam lParam -- )
    3drop window [ focus-world ] when* ;

: handle-wm-kill-focus ( hWnd uMsg wParam lParam -- )
    3drop window [ unfocus-world ] when* ;

: message>button ( uMsg -- button down? )
    {
        { WM_LBUTTONDOWN   [ 1 t ] }
        { WM_LBUTTONUP     [ 1 f ] }
        { WM_MBUTTONDOWN   [ 2 t ] }
        { WM_MBUTTONUP     [ 2 f ] }
        { WM_RBUTTONDOWN   [ 3 t ] }
        { WM_RBUTTONUP     [ 3 f ] }

        { WM_NCLBUTTONDOWN [ 1 t ] }
        { WM_NCLBUTTONUP   [ 1 f ] }
        { WM_NCMBUTTONDOWN [ 2 t ] }
        { WM_NCMBUTTONUP   [ 2 f ] }
        { WM_NCRBUTTONDOWN [ 3 t ] }
        { WM_NCRBUTTONUP   [ 3 f ] }
    } case ;

! If the user clicks in the window border ("non-client area")
! Windows sends us an NC[LMR]BUTTONDOWN message; but if the
! mouse is subsequently released outside the NC area, we receive
! a [LMR]BUTTONUP message and Factor can get confused. So we
! ignore BUTTONUP's that are a result of an NC*BUTTONDOWN.
SYMBOL: nc-buttons

: handle-wm-ncbutton ( hWnd uMsg wParam lParam -- )
    2drop nip
    message>button nc-buttons get
    swap [ push ] [ delete ] if ;

: >lo-hi ( WORD -- array ) [ lo-word ] [ hi-word ] bi 2array ;

: mouse-wheel ( wParam -- array ) >lo-hi [ sgn neg ] map ;

: mouse-event>gesture ( uMsg -- button )
    key-modifiers swap message>button
    [ <button-down> ] [ <button-up> ] if ;

:: prepare-mouse ( hWnd uMsg wParam lParam -- button coordinate world )
    uMsg mouse-event>gesture
    lParam >lo-hi
    hWnd window ;

: set-capture ( hwnd -- )
    mouse-captured get [
        drop
    ] [
        [ SetCapture drop ] keep
        mouse-captured set
    ] if ;

: release-capture ( -- )
    ReleaseCapture win32-error=0/f
    mouse-captured off ;

: handle-wm-buttondown ( hWnd uMsg wParam lParam -- )
    [
        over set-capture
        dup message>button drop nc-buttons get delete
    ] 2dip prepare-mouse send-button-down ;

: handle-wm-buttonup ( hWnd uMsg wParam lParam -- )
    mouse-captured get [ release-capture ] when
    pick message>button drop dup nc-buttons get member? [
        nc-buttons get delete 4drop
    ] [
        drop prepare-mouse send-button-up
    ] if ;

: make-TRACKMOUSEEVENT ( hWnd -- alien )
    "TRACKMOUSEEVENT" <c-object> [ set-TRACKMOUSEEVENT-hwndTrack ] keep
    "TRACKMOUSEEVENT" heap-size over set-TRACKMOUSEEVENT-cbSize ;

: handle-wm-mousemove ( hWnd uMsg wParam lParam -- )
    2nip
    over make-TRACKMOUSEEVENT
    TME_LEAVE over set-TRACKMOUSEEVENT-dwFlags
    0 over set-TRACKMOUSEEVENT-dwHoverTime
    TrackMouseEvent drop
    >lo-hi swap window move-hand fire-motion ;

:: handle-wm-mousewheel ( hWnd uMsg wParam lParam -- )
    wParam mouse-wheel hand-loc get hWnd window send-wheel ;

: handle-wm-cancelmode ( hWnd uMsg wParam lParam -- )
    #! message sent if windows needs application to stop dragging
    4drop release-capture ;

: handle-wm-mouseleave ( hWnd uMsg wParam lParam -- )
    #! message sent if mouse leaves main application 
    4drop forget-rollover ;

SYMBOL: wm-handlers

H{ } clone wm-handlers set-global

: add-wm-handler ( quot wm -- )
    dup array?
    [ [ execute add-wm-handler ] with each ]
    [ wm-handlers get-global set-at ] if ;

[ handle-wm-close 0                  ] WM_CLOSE add-wm-handler
[ 4dup handle-wm-paint DefWindowProc ] WM_PAINT add-wm-handler

[ handle-wm-size 0 ] WM_SIZE add-wm-handler
[ handle-wm-move 0 ] WM_MOVE add-wm-handler

[ 4dup handle-wm-keydown DefWindowProc ] { WM_KEYDOWN WM_SYSKEYDOWN } add-wm-handler
[ 4dup handle-wm-char DefWindowProc    ] { WM_CHAR WM_SYSCHAR }       add-wm-handler
[ 4dup handle-wm-keyup DefWindowProc   ] { WM_KEYUP WM_SYSKEYUP }     add-wm-handler

[ handle-wm-syscommand   ] WM_SYSCOMMAND add-wm-handler
[ handle-wm-set-focus 0  ] WM_SETFOCUS add-wm-handler
[ handle-wm-kill-focus 0 ] WM_KILLFOCUS add-wm-handler

[ handle-wm-buttondown 0 ] WM_LBUTTONDOWN add-wm-handler
[ handle-wm-buttondown 0 ] WM_MBUTTONDOWN add-wm-handler
[ handle-wm-buttondown 0 ] WM_RBUTTONDOWN add-wm-handler
[ handle-wm-buttonup 0   ] WM_LBUTTONUP   add-wm-handler
[ handle-wm-buttonup 0   ] WM_MBUTTONUP   add-wm-handler
[ handle-wm-buttonup 0   ] WM_RBUTTONUP   add-wm-handler

[ 4dup handle-wm-ncbutton DefWindowProc ]
{ WM_NCLBUTTONDOWN WM_NCMBUTTONDOWN WM_NCRBUTTONDOWN
WM_NCLBUTTONUP WM_NCMBUTTONUP WM_NCRBUTTONUP }
add-wm-handler

[ nc-buttons get-global delete-all DefWindowProc ]
{ WM_EXITSIZEMOVE WM_EXITMENULOOP } add-wm-handler

[ handle-wm-mousemove 0  ] WM_MOUSEMOVE  add-wm-handler
[ handle-wm-mousewheel 0 ] WM_MOUSEWHEEL add-wm-handler
[ handle-wm-cancelmode 0 ] WM_CANCELMODE add-wm-handler
[ handle-wm-mouseleave 0 ] WM_MOUSELEAVE add-wm-handler

SYMBOL: trace-messages?

! return 0 if you handle the message, else just let DefWindowProc return its val
: ui-wndproc ( -- object )
    "uint" { "void*" "uint" "long" "long" } "stdcall" [
        pick
        trace-messages? get-global [ dup windows-message-name name>> print flush ] when
        wm-handlers get-global at* [ call ] [ drop DefWindowProc ] if
     ] alien-callback ;

: peek-message? ( msg -- ? ) f 0 0 PM_REMOVE PeekMessage zero? ;

M: windows-ui-backend do-events
    msg-obj get-global
    dup peek-message? [ drop ui-wait ] [
        [ TranslateMessage drop ]
        [ DispatchMessage drop ] bi
    ] if ;

: register-wndclassex ( -- class )
    "WNDCLASSEX" <c-object>
    f GetModuleHandle
    class-name-ptr get-global
    pick GetClassInfoEx zero? [
        "WNDCLASSEX" heap-size over set-WNDCLASSEX-cbSize
        { CS_HREDRAW CS_VREDRAW CS_OWNDC } flags over set-WNDCLASSEX-style
        ui-wndproc over set-WNDCLASSEX-lpfnWndProc
        0 over set-WNDCLASSEX-cbClsExtra
        0 over set-WNDCLASSEX-cbWndExtra
        f GetModuleHandle over set-WNDCLASSEX-hInstance
        f GetModuleHandle "fraptor" utf16n string>alien LoadIcon
        over set-WNDCLASSEX-hIcon
        f IDC_ARROW LoadCursor over set-WNDCLASSEX-hCursor

        class-name-ptr get-global over set-WNDCLASSEX-lpszClassName
        RegisterClassEx dup win32-error=0/f
    ] when ;

: adjust-RECT ( RECT -- )
    style 0 ex-style AdjustWindowRectEx win32-error=0/f ;

: make-RECT ( world -- RECT )
    [ window-loc>> dup ] [ rect-dim ] bi v+
    "RECT" <c-object>
    over first over set-RECT-right
    swap second over set-RECT-bottom
    over first over set-RECT-left
    swap second over set-RECT-top ;

: default-position-RECT ( RECT -- )
    dup get-RECT-dimensions [ 2drop ] 2dip
    CW_USEDEFAULT + pick set-RECT-bottom
    CW_USEDEFAULT + over set-RECT-right
    CW_USEDEFAULT over set-RECT-left
    CW_USEDEFAULT swap set-RECT-top ;

: make-adjusted-RECT ( rect -- RECT )
    make-RECT
    dup get-RECT-top-left [ zero? ] both? swap
    dup adjust-RECT
    swap [ dup default-position-RECT ] when ;

: create-window ( rect -- hwnd )
    make-adjusted-RECT
    [ class-name-ptr get-global f ] dip
    [
        [ ex-style ] 2dip
        { WS_CLIPSIBLINGS WS_CLIPCHILDREN style } flags
    ] dip get-RECT-dimensions
    f f f GetModuleHandle f CreateWindowEx dup win32-error=0/f ;

: show-window ( hWnd -- )
    dup SW_SHOW ShowWindow drop ! always succeeds
    dup SetForegroundWindow drop
    SetFocus drop ;

: init-win32-ui ( -- )
    V{ } clone nc-buttons set-global
    "MSG" malloc-object msg-obj set-global
    "Factor-window" utf16n malloc-string class-name-ptr set-global
    register-wndclassex drop
    GetDoubleClickTime milliseconds double-click-timeout set-global ;

: cleanup-win32-ui ( -- )
    class-name-ptr get-global [ dup f UnregisterClass drop free ] when*
    msg-obj get-global [ free ] when*
    f class-name-ptr set-global
    f msg-obj set-global ;

: setup-pixel-format ( hdc flags -- )
    32 make-pfd [ ChoosePixelFormat dup win32-error=0/f ] 2keep
    swapd SetPixelFormat win32-error=0/f ;

: get-dc ( hWnd -- hDC ) GetDC dup win32-error=0/f ;

: get-rc ( hDC -- hRC )
    dup wglCreateContext dup win32-error=0/f
    [ wglMakeCurrent win32-error=0/f ] keep ;

: setup-gl ( hwnd -- hDC hRC )
    get-dc dup windowed-pfd-dwFlags setup-pixel-format dup get-rc ;

M: windows-ui-backend (open-window) ( world -- )
    [ create-window [ setup-gl ] keep ] keep
    [ f <win> ] keep
    [ swap hWnd>> register-window ] 2keep
    dupd (>>handle)
    hWnd>> show-window ;

M: win-base select-gl-context ( handle -- )
    [ hDC>> ] keep hRC>> wglMakeCurrent win32-error=0/f
    GdiFlush drop ;

M: win-base flush-gl-context ( handle -- )
    hDC>> SwapBuffers win32-error=0/f ;

: (bitmap-info) ( dim -- BITMAPINFO )
    "BITMAPINFO" <c-object> [
        BITMAPINFO-bmiHeader {
            [ nip "BITMAPINFOHEADER" heap-size swap set-BITMAPINFOHEADER-biSize ]
            [ [ first ] dip set-BITMAPINFOHEADER-biWidth ]
            [ [ second ] dip set-BITMAPINFOHEADER-biHeight ]
            [ nip 1 swap set-BITMAPINFOHEADER-biPlanes ]
            [ nip 32 swap set-BITMAPINFOHEADER-biBitCount ]
            [ nip BI_RGB swap set-BITMAPINFOHEADER-biCompression ]
            [ [ first2 * 4 * ] dip set-BITMAPINFOHEADER-biSizeImage ]
            [ nip 72 swap set-BITMAPINFOHEADER-biXPelsPerMeter ]
            [ nip 72 swap set-BITMAPINFOHEADER-biYPelsPerMeter ]
            [ nip 0 swap set-BITMAPINFOHEADER-biClrUsed ]
            [ nip 0 swap set-BITMAPINFOHEADER-biClrImportant ]
        } 2cleave
    ] keep ;

: make-offscreen-dc-and-bitmap ( dim -- hDC hBitmap bits )
    f CreateCompatibleDC
    dup rot (bitmap-info) DIB_RGB_COLORS f <void*>
    [ f 0 CreateDIBSection ] keep *void*
    [ 2dup SelectObject drop ] dip ;

: setup-offscreen-gl ( dim -- hDC hRC hBitmap bits )
    make-offscreen-dc-and-bitmap [
        [ dup offscreen-pfd-dwFlags setup-pixel-format ]
        [ get-rc ] bi
    ] 2dip ;

M: windows-ui-backend (open-offscreen-buffer) ( world -- )
    dup dim>> setup-offscreen-gl <win-offscreen>
    >>handle drop ;
M: windows-ui-backend (close-offscreen-buffer) ( handle -- )
    [ hDC>> DeleteDC drop ]
    [ hBitmap>> DeleteObject drop ] bi ;

! Windows 32-bit bitmaps don't actually use the alpha byte of
! each pixel; it's left as zero

: (make-opaque) ( byte-array -- byte-array' )
    [ length 4 / ]
    [ '[ 255 swap 4 * 3 + _ set-nth ] each ]
    [ ] tri ;

: (opaque-pixels) ( world -- pixels )
    [ handle>> bits>> ] [ dim>> first2 * 4 * ] bi
    memory>byte-array (make-opaque) ;

M: windows-ui-backend offscreen-pixels ( world -- alien w h )
    [ (opaque-pixels) ] [ dim>> first2 ] bi ;

M: windows-ui-backend raise-window* ( world -- )
    handle>> [
        hWnd>> SetFocus drop
    ] when* ;

M: windows-ui-backend set-title ( string world -- )
    handle>>
    dup title>> [ free ] when*
    [ utf16n malloc-string ] dip
    2dup (>>title)
    hWnd>> WM_SETTEXT 0 roll alien-address SendMessage drop ;

M: windows-ui-backend ui
    [
        [
            init-clipboard
            init-win32-ui
            start-ui
            event-loop
        ] [ cleanup-win32-ui ] [ ] cleanup
    ] ui-running ;

M: windows-ui-backend beep ( -- )
    0 MessageBeep drop ;

windows-ui-backend ui-backend set-global

[ "ui" ] main-vocab-hook set-global
