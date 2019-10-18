! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs errors freetype gadgets gadgets-listener
       gadgets-workspace io kernel math namespaces
       prettyprint sequences strings vectors words win32-api
       win32-api-messages tools threads memory timers ;
IN: win32

! world-handle is a <win>
TUPLE: win hWnd hDC hRC world ;

SYMBOL: msg-obj
SYMBOL: class-name
SYMBOL: mouse-captured

: style ( -- n ) WS_OVERLAPPEDWINDOW ; inline
: ex-style ( -- n ) WS_EX_APPWINDOW WS_EX_WINDOWEDGE bitor ; inline

: adjust-RECT ( RECT -- )
    style 0 ex-style AdjustWindowRectEx win32-error=0/f ;

: make-RECT ( width height -- RECT )
    "RECT" <c-object> [ set-RECT-bottom ] keep [ set-RECT-right ] keep ;

: make-adjusted-RECT ( width height -- RECT )
    make-RECT dup adjust-RECT ;

: get-RECT-dimensions ( RECT -- width height )
    [ RECT-right ] keep [ RECT-left - ] keep
    [ RECT-bottom ] keep RECT-top - ;

: get-RECT-top-left ( RECT -- x y )
    [ RECT-left ] keep RECT-top ;

: handle-wm-paint ( hWnd uMsg wParam lParam -- )
    #! wParam and lParam are unused
    #! only paint if width/height both > 0
    3drop window dup draw-world ;

: handle-wm-size ( hWnd uMsg wParam lParam -- )
    [ lo-word ] keep hi-word make-RECT get-RECT-dimensions 2array
    2nip
    dup { 0 0 } = [ 2drop ] [ swap window set-gadget-dim ui-step ] if ;

: wm-keydown-codes ( -- key )
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
    } ;

: key-state-down?
    GetKeyState 1 16 shift bitand 0 > ;

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
: switch-case ( seq -- seq ) dup first CHAR: a >= [ >upper ] [ >lower ] if ;
: switch-case? ( -- ? ) shift? caps-lock? xor not ;

: key-modifiers ( -- seq )
    [
        shift? [ S+ , ] when
        ctrl? [ C+ , ] when
        alt? [ A+ , ] when
    ] { } make [ empty? not ] keep f ? ;

: exclude-keys-wm-keydown
    H{
        { 16 "SHIFT" }
        { 17 "CTRL" }
        { 18 "ALT" }
        { 20 "CAPS-LOCK" }
    } ;

: exclude-keys-wm-char
    ! Values are ignored
    H{
        { 8 "BACKSPACE" }
        { 9 "TAB" }
        { 13 "RET" }
        { 27 "ESC" }
    } ;

: exclude-key-wm-keydown? ( n -- bool )
    exclude-keys-wm-keydown key? ;

: exclude-key-wm-char? ( n -- bool )
    exclude-keys-wm-char key? ;

: keystroke>gesture ( n -- mods sym ? )
    dup wm-keydown-codes at* [
        nip >r key-modifiers r> t
    ] [
        drop 1string >r key-modifiers r>
        C+ pick member? >r A+ pick member? r> or [
            shift? [ >lower ] unless f
        ] [
            switch-case? [ switch-case ] when t
        ] if
    ] if ;

SYMBOL: lParam
SYMBOL: wParam
SYMBOL: uMsg
SYMBOL: hWnd

: handle-wm-keydown ( hWnd uMsg wParam lParam -- )
    lParam set wParam set uMsg set hWnd set
    wParam get exclude-key-wm-keydown? [
        wParam get keystroke>gesture <key-down>
        hWnd get window-focus send-gesture drop 
    ] unless ;

: handle-wm-char ( hWnd uMsg wParam lParam -- )
    lParam set wParam set uMsg set hWnd set
    wParam get exclude-key-wm-char? ctrl? alt? xor or [
        wParam get 1string
        hWnd get window-focus user-input
    ] unless ;

: handle-wm-keyup ( hWnd uMsg wParam lParam -- )
    lParam set wParam set uMsg set hWnd set
    wParam get keystroke>gesture <key-up>
    hWnd get window-focus send-gesture
    drop ;

: cleanup-window ( handle -- )
    [ win-hRC wglDeleteContext win32-error=0/f ] keep
    [ win-hWnd ] keep win-hDC ReleaseDC win32-error=0/f ;

: handle-wm-close ( hWnd uMsg wParam lParam -- )
    3drop
    window [ world-handle ] keep
    stop-world
    dup win-hWnd unregister-window
    dup cleanup-window
    win-hWnd DestroyWindow win32-error=0/f ;

: handle-wm-set-focus ( hWnd uMsg wParam lParam -- )
    3drop window [ focus-world ] when* ;

: handle-wm-kill-focus ( hWnd uMsg wParam lParam -- )
    3drop window [ unfocus-world ] when* ;

: >lo-hi ( WORD -- array ) [ lo-word ] keep hi-word 2array ;
: mouse-wheel ( lParam -- array ) >lo-hi [ sgn neg ] map ;

: mouse-absolute>relative ( lparam handle -- array )
    >r >lo-hi r>
    0 0 make-RECT [ GetWindowRect win32-error=0/f ] keep
    get-RECT-top-left 2array v- ;

: mouse-event>gesture ( uMsg -- button )
    key-modifiers swap
    {
        { [ dup WM_LBUTTONDOWN = ] [ drop 1 <button-down> ] }
        { [ dup WM_LBUTTONUP = ] [ drop 1 <button-up> ] }
        { [ dup WM_MBUTTONDOWN = ] [ drop 2 <button-down> ] }
        { [ dup WM_MBUTTONUP = ] [ drop 2 <button-up> ] }
        { [ dup WM_RBUTTONDOWN = ] [ drop 3 <button-down> ] }
        { [ dup WM_RBUTTONUP = ] [ drop 3 <button-up> ] }
        { [ t ] [ "bad button" throw ] }
    } cond ;

: mouse-buttons ( -- seq ) WM_LBUTTONDOWN WM_RBUTTONDOWN 2array ;

: capture-mouse? ( umsg -- ? )
    mouse-buttons member? ;

: prepare-mouse ( hWnd uMsg wParam lParam -- button coordinate world )
    nip >r mouse-event>gesture r> >lo-hi rot window ;

: mouse-captured? ( -- ? )
    mouse-captured get ;

: set-capture ( hwnd -- )
    mouse-captured get [
        drop
    ] [
        [ SetCapture drop ] keep mouse-captured set
    ] if ;

: release-capture ( -- )
    ReleaseCapture win32-error=0/f
    mouse-captured off ;

: handle-wm-buttondown ( hWnd uMsg wParam lParam -- )
    >r over capture-mouse? [ pick set-capture ] when r>
    prepare-mouse send-button-down ;

: handle-wm-buttonup ( hWnd uMsg wParam lParam -- )
    mouse-captured? [ release-capture ] when
    prepare-mouse send-button-up ;

: handle-wm-mousemove ( hWnd uMsg wParam lParam -- )
    2nip
    over "TRACKMOUSEEVENT" <c-object> [ set-TRACKMOUSEEVENT-hwndTrack ] keep
    "TRACKMOUSEEVENT" heap-size over set-TRACKMOUSEEVENT-cbSize
    TME_LEAVE over set-TRACKMOUSEEVENT-dwFlags
    0 over set-TRACKMOUSEEVENT-dwHoverTime
    TrackMouseEvent drop
    >lo-hi swap window move-hand fire-motion ;

: handle-wm-mousewheel ( hWnd uMsg wParam lParam -- )
    >r nip r>
    pick mouse-absolute>relative >r mouse-wheel r> rot window send-wheel ;

: handle-wm-cancelmode ( hWnd uMsg wParam lParam -- )
    #! message sent if windows needs application to stop dragging
    3drop drop release-capture ;

: handle-wm-mouseleave ( hWnd uMsg wParam lParam -- )
    #! message sent if mouse leaves main application 
    3drop drop forget-rollover ;

: 4dup ( a b c d -- a b c d a b c d )
    >r >r 2dup r> r> 2swap >r >r 2dup r> r> 2swap ;

! return 0 if you handle the message, else just let DefWindowProc return its val
: ui-wndproc ( -- object )
    "uint" { "void*" "uint" "long" "long" } "stdcall" [
        [
        pick
        ! "Message: " write dup get-windows-message-name write
            ! " " write dup unparse print flush
            {
                { [ dup WM_CLOSE = ]    [ drop handle-wm-close 0 ] }
                { [ dup WM_PAINT = ]
                      [ drop 4dup handle-wm-paint DefWindowProc ] }
                { [ dup WM_SIZE = ]      [ drop handle-wm-size 0 ] }

                ! Keyboard events
                { [ dup WM_KEYDOWN = over WM_SYSKEYDOWN = or ]
                    [ drop 4dup handle-wm-keydown DefWindowProc ] }
                { [ dup WM_CHAR = over WM_SYSCHAR = or ]
                    [ drop 4dup handle-wm-char DefWindowProc ] }
                { [ dup WM_KEYUP = over WM_SYSKEYUP = or ]
                    [ drop 4dup handle-wm-keyup DefWindowProc ] }

                { [ dup WM_SETFOCUS = ] [ drop handle-wm-set-focus 0 ] }
                { [ dup WM_KILLFOCUS = ] [ drop handle-wm-kill-focus 0 ] }

                ! Mouse events
                { [ dup WM_LBUTTONDOWN = ] [ drop handle-wm-buttondown 0 ] }
                { [ dup WM_MBUTTONDOWN = ] [ drop handle-wm-buttondown 0 ] }
                { [ dup WM_RBUTTONDOWN = ] [ drop handle-wm-buttondown 0 ] }
                { [ dup WM_LBUTTONUP = ] [ drop handle-wm-buttonup 0 ] }
                { [ dup WM_MBUTTONUP = ] [ drop handle-wm-buttonup 0 ] }
                { [ dup WM_RBUTTONUP = ] [ drop handle-wm-buttonup 0 ] }
                { [ dup WM_MOUSEMOVE = ] [ drop handle-wm-mousemove 0 ] }
                { [ dup WM_MOUSEWHEEL = ] [ drop handle-wm-mousewheel 0 ] }
                { [ dup WM_CANCELMODE = ] [ drop handle-wm-cancelmode 0 ] }
                { [ dup WM_MOUSELEAVE = ] [ drop handle-wm-mouseleave 0 ] }

                { [ t ] [ drop DefWindowProc ] }
            } cond
        ] ui-try
        ! "finished handling message" print .s flush
     ] alien-callback ;

: do-events ( -- )
    msg-obj get f 0 0 PM_REMOVE PeekMessage 
    zero? not [
        msg-obj get MSG-message WM_QUIT = [
            msg-obj get [ TranslateMessage drop ] keep DispatchMessage drop
        ] unless
    ] when ;

: event-loop ( -- )
    windows get empty? [
        [ do-events ui-step ] ui-try event-loop
    ] unless ;

: register-wndclassex ( -- class )
    "WNDCLASSEX" <c-object>
    f GetModuleHandle
    class-name get malloc-u16-string
    pick GetClassInfoEx 0 =
    [
      "WNDCLASSEX" heap-size over set-WNDCLASSEX-cbSize
      CS_HREDRAW CS_VREDRAW bitor CS_OWNDC bitor over set-WNDCLASSEX-style
      ui-wndproc over set-WNDCLASSEX-lpfnWndProc
      0 over set-WNDCLASSEX-cbClsExtra
      0 over set-WNDCLASSEX-cbWndExtra
      f GetModuleHandle over set-WNDCLASSEX-hInstance
      f GetModuleHandle "fraptor" string>u16-alien LoadIcon over set-WNDCLASSEX-hIcon
      f IDC_ARROW LoadCursor over set-WNDCLASSEX-hCursor

      class-name get malloc-u16-string over set-WNDCLASSEX-lpszClassName

      RegisterClassEx dup win32-error=0/f
    ] when ;

: create-window ( width height -- hwnd )
    make-adjusted-RECT
    >r class-name get malloc-u16-string f r>
    >r >r >r ex-style r> r>
        WS_CLIPSIBLINGS WS_CLIPCHILDREN bitor style bitor
        0 0 r>
    get-RECT-dimensions
    f f f GetModuleHandle f CreateWindowEx dup win32-error=0/f ;

: show-window ( hWnd -- )
    dup SW_SHOW ShowWindow drop ! always succeeds
    dup SetForegroundWindow drop
    SetFocus drop ;

: init-win32-ui
    "MSG" <c-object> msg-obj set
    "Factor-window" class-name set
    register-wndclassex win32-error=0/f
    GetDoubleClickTime double-click-timeout set-global ;

: cleanup-win32-ui ( -- )
    class-name get string>char-alien f UnregisterClass drop ;

: setup-pixel-format ( hdc -- )
    16 make-pfd [ ChoosePixelFormat dup win32-error=0/f ] 2keep
    swapd SetPixelFormat win32-error=0/f ;

: get-dc ( hWnd -- hDC ) GetDC dup win32-error=0/f ;

: get-rc ( hDC -- hRC )
    dup wglCreateContext dup win32-error=0/f
    [ wglMakeCurrent win32-error=0/f ] keep ;

: setup-gl ( hwnd -- hDC hRC )
    get-dc
    dup setup-pixel-format
    dup get-rc ;

IN: gadgets

: open-window* ( world -- ) ! new
    [ rect-dim first2 create-window dup setup-gl ] keep
    [ <win> ] keep
    [ swap win-hWnd register-window ] 2keep
    [ set-world-handle ] 2keep 
    start-world win-hWnd show-window ;

: select-gl-context ( handle -- )
    [ win-hDC ] keep win-hRC wglMakeCurrent win32-error=0/f ;

: flush-gl-context ( handle -- )
    win-hDC SwapBuffers win32-error=0/f ;

! Move window to front
: raise-window ( world -- )
    world-handle [
        win-hWnd SetFocus drop release-capture
    ] when* ;

: set-title ( string world -- )
    world-handle win-hWnd
    swap malloc-u16-string alien-address >r WM_SETTEXT 0 r> SendMessage drop ;

IN: shells
: ui
    [
        [
            init-clipboard
            init-win32-ui
            start-ui
            event-loop
        ] with-freetype
    ] [ cleanup-win32-ui ] cleanup ;

