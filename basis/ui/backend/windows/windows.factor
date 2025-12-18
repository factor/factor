! Copyright (C) 2005, 2006 Doug Coleman.
! Portions copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
arrays ascii assocs assocs.extras byte-arrays calendar classes
classes.struct colors combinators continuations environment io io.crlf
io.encodings.string io.encodings.utf16 io.encodings.utf8 kernel
libc literals make math math.bitwise math.order math.parser namespaces opengl
sequences sets specialized-arrays strings threads ui ui.backend
ui.clipboards ui.event-loop ui.gadgets ui.gadgets.private
ui.gadgets.worlds ui.gestures ui.pixel-formats ui.private ui.theme
ui.theme.switching windows.advapi32 windows.dwmapi
windows.errors windows.gdi32 windows.kernel32 windows.messages
windows.offscreen windows.ole32 windows.opengl32
windows.registry windows.shell32 windows.types windows.user32 ;
FROM: unicode => upper-surrogate? under-surrogate? ;
SPECIALIZED-ARRAY: POINT
QUALIFIED-WITH: alien.c-types c
IN: ui.backend.windows

SINGLETON: windows-ui-backend

TUPLE: win-base hDC hRC ;
TUPLE: win < win-base hWnd world title ;
C: <win> win

<PRIVATE

CONSTANT: perm-attribs { $ WGL_SUPPORT_OPENGL_ARB 1 }

CONSTANT: attrib-table H{
    { double-buffered { $ WGL_DOUBLE_BUFFER_ARB 1 } }
    { stereo { $ WGL_STEREO_ARB 1 } }
    { offscreen { $ WGL_DRAW_TO_BITMAP_ARB 1 } }
    { fullscreen { $ WGL_DRAW_TO_WINDOW_ARB 1 } }
    { windowed { $ WGL_DRAW_TO_WINDOW_ARB 1 } }
    { accelerated { $ WGL_ACCELERATION_ARB $ WGL_FULL_ACCELERATION_ARB } }
    { software-rendered { $ WGL_ACCELERATION_ARB $ WGL_NO_ACCELERATION_ARB } }
    { backing-store { $ WGL_SWAP_METHOD_ARB $ WGL_SWAP_COPY_ARB } }
    { color-float { $ WGL_TYPE_RGBA_FLOAT_ARB 1 } }
    { color-bits { $ WGL_COLOR_BITS_ARB } }
    { red-bits { $ WGL_RED_BITS_ARB } }
    { green-bits { $ WGL_GREEN_BITS_ARB } }
    { blue-bits { $ WGL_BLUE_BITS_ARB } }
    { alpha-bits { $ WGL_ALPHA_BITS_ARB } }
    { accum-bits { $ WGL_ACCUM_BITS_ARB } }
    { accum-red-bits { $ WGL_ACCUM_RED_BITS_ARB } }
    { accum-green-bits { $ WGL_ACCUM_GREEN_BITS_ARB } }
    { accum-blue-bits { $ WGL_ACCUM_BLUE_BITS_ARB } }
    { accum-alpha-bits { $ WGL_ACCUM_ALPHA_BITS_ARB } }
    { depth-bits { $ WGL_DEPTH_BITS_ARB } }
    { stencil-bits { $ WGL_STENCIL_BITS_ARB } }
    { aux-buffers { $ WGL_AUX_BUFFERS_ARB } }
    { sample-buffers { $ WGL_SAMPLE_BUFFERS_ARB } }
    { samples { $ WGL_SAMPLES_ARB } }
}

: has-wglChoosePixelFormatARB? ( world -- ? )
    drop f ;

: arb-make-pixel-format ( world attributes -- pf )
    [ handle>> hDC>> ] dip
    perm-attribs attrib-table pixel-format-attributes>int-array
    f 1 { c:int c:int }
    [ wglChoosePixelFormatARB win32-error=0/f ] with-out-parameters drop ;

CONSTANT: pfd-flag-map H{
    { double-buffered $ PFD_DOUBLEBUFFER }
    { stereo $ PFD_STEREO }
    { offscreen $ PFD_DRAW_TO_BITMAP }
    { fullscreen $ PFD_DRAW_TO_WINDOW }
    { windowed $ PFD_DRAW_TO_WINDOW }
    { backing-store $ PFD_SWAP_COPY }
    { software-rendered $ PFD_GENERIC_FORMAT }
}

: >pfd-flag ( attribute -- value )
    pfd-flag-map at [ ] [ 0 ] if* ;

: >pfd-flags ( attributes -- flags )
    [ >pfd-flag ] [ bitor ] map-reduce
    PFD_SUPPORT_OPENGL bitor ;

: attr-value ( attributes name -- value )
    [ instance? ] curry find nip
    [ value>> ] [ 0 ] if* ;

: >pfd ( attributes -- pfd )
    [ PIXELFORMATDESCRIPTOR new ] dip
    {
        [ drop PIXELFORMATDESCRIPTOR c:heap-size >>nSize ]
        [ drop 1 >>nVersion ]
        [ >pfd-flags >>dwFlags ]
        [ drop PFD_TYPE_RGBA >>iPixelType ]
        [ color-bits attr-value >>cColorBits ]
        [ red-bits attr-value >>cRedBits ]
        [ green-bits attr-value >>cGreenBits ]
        [ blue-bits attr-value >>cBlueBits ]
        [ alpha-bits attr-value >>cAlphaBits ]
        [ accum-bits attr-value >>cAccumBits ]
        [ accum-red-bits attr-value >>cAccumRedBits ]
        [ accum-green-bits attr-value >>cAccumGreenBits ]
        [ accum-blue-bits attr-value >>cAccumBlueBits ]
        [ accum-alpha-bits attr-value >>cAccumAlphaBits ]
        [ depth-bits attr-value >>cDepthBits ]
        [ stencil-bits attr-value >>cStencilBits ]
        [ aux-buffers attr-value >>cAuxBuffers ]
        [ drop PFD_MAIN_PLANE >>dwLayerMask ]
    } cleave ;

: pfd-make-pixel-format ( world attributes -- pf )
    [ handle>> hDC>> ] [ >pfd ] bi*
    ChoosePixelFormat dup win32-error=0/f ;

M: windows-ui-backend (make-pixel-format)
    over has-wglChoosePixelFormatARB?
    [ arb-make-pixel-format ] [ pfd-make-pixel-format ] if ;

M: windows-ui-backend (free-pixel-format)
    drop ;

PRIVATE>

: GET_APPCOMMAND_LPARAM ( lParam -- appCommand )
    hi-word FAPPCOMMAND_MASK lo-word bitnot bitand ; inline

: enum-clipboard ( -- seq )
    0
    [ EnumClipboardFormats win32-error dup dup 0 > ]
    [ ]
    produce 2nip ;

: with-clipboard ( quot -- )
    f OpenClipboard win32-error=0/f
    [ CloseClipboard win32-error=0/f ] finally ; inline

: paste ( -- str )
    [
        CF_UNICODETEXT GetClipboardData [
            dup GlobalLock dup win32-error=0/f
            [ alien>native-string ]
            [ swap GlobalUnlock win32-error=0/f ] finally
        ] [
            ! nothing to paste
            ""
        ] if*
    ] with-clipboard
    crlf>lf ;

: copy ( str -- )
    lf>crlf [
        native-string>alien
        EmptyClipboard win32-error=0/f
        GMEM_MOVEABLE over length 1 + GlobalAlloc
            dup win32-error=0/f

        dup GlobalLock dup win32-error=0/f
        rot binary-object memcpy
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

DEFER: get-default-device-caps

: detect-scale-factor ( -- n )
    get-default-device-caps [ 96 /f ] bi@ min ;

: init-scale-factor ( -- )
    detect-scale-factor
    [ 1.0 > ] keep f ? gl-scale-factor set-global ;

SYMBOLS: msg-obj class-name-ptr mouse-captured ;

CONSTANT: window-control>style
    H{
        { close-button 0 }
        { textured-background 0 }
        { minimize-button $ WS_MINIMIZEBOX }
        { maximize-button $ WS_MAXIMIZEBOX }
        { resize-handles $ WS_THICKFRAME }
        { small-title-bar $ WS_CAPTION }
        { normal-title-bar $ WS_CAPTION }
        { dialog-window 0 }
    }

CONSTANT: window-control>ex-style
    H{
        { close-button 0 }
        { textured-background 0 }
        { minimize-button 0 }
        { maximize-button 0 }
        { resize-handles $ WS_EX_WINDOWEDGE }
        { small-title-bar flags{ WS_EX_TOOLWINDOW WS_EX_TOPMOST } }
        { normal-title-bar $ WS_EX_APPWINDOW }
        { dialog-window 0 }
    }

: needs-sysmenu? ( controls -- ? )
    { close-button minimize-button maximize-button } intersects? ;

: has-titlebar? ( controls -- ? )
    { small-title-bar normal-title-bar } intersects? ;

: world>style ( world -- n )
    window-controls>>
    [ window-control>style symbols>flags ]
    [ needs-sysmenu? [ WS_SYSMENU bitor ] when ]
    [ has-titlebar? [ WS_POPUP bitor ] unless ] tri ;

: world>ex-style ( world -- n )
    window-controls>> window-control>ex-style symbols>flags ;

: get-RECT-top-left ( RECT -- x y )
    [ left>> ] [ top>> ] bi ;

: get-RECT-width/height ( RECT -- width height )
    [ [ right>> ] [ left>> ] bi - ]
    [ [ bottom>> ] [ top>> ] bi - ] bi ;

: get-RECT-dimensions ( RECT -- x y width height )
    [ get-RECT-top-left ] [ get-RECT-width/height ] bi ;

: handle-wm-paint ( hWnd uMsg wParam lParam -- )
    ! wParam and lParam are unused
    ! only paint if width/height both > 0
    3drop window t >>active? relayout-1 yield ;

: handle-wm-size ( hWnd uMsg wParam lParam -- )
    2nip >lo-hi [ gl-unscale ] map
    dup { 0 0 } = [ 2drop ] [ swap window [ dim<< ] [ drop ] if* ] if ;

: handle-wm-move ( hWnd uMsg wParam lParam -- )
    2nip >lo-hi [ gl-unscale ] map
    swap window [ window-loc<< ] [ drop ] if* ;

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

: key-sym ( wParam -- string/f )
    wm-keydown-codes at ; inline

:: (handle-wm-keydown/up) ( hWnd uMsg wParam lParam send-key-down/up -- )
    wParam exclude-key-wm-keydown? [
        wParam key-sym [
            t hWnd send-key-down/up execute( sym action? hWnd -- )
        ] [
            256 <byte-array> :> keyboard-state
            4 <byte-array> :> chars
            lParam -16 shift 0xff bitand :> scan-code
            keyboard-state GetKeyboardState win32-error=0/f
            VK_CONTROL VK_CAPITAL [ 0 swap keyboard-state set-nth ] bi@
            wParam scan-code keyboard-state chars 2 0 ToUnicode
            1 <=  [
                1 chars nth 8 shift 0 chars nth bitor
            ] [
                3 chars nth 8 shift 2 chars nth bitor ! dead-key
            ] if
            1string f hWnd send-key-down/up execute( sym action? hWnd -- )
        ] if*
    ] unless ; inline

: handle-wm-keydown ( hWnd uMsg wParam lParam -- )
    \ send-key-down (handle-wm-keydown/up) ;

SYMBOL: upper-surrogate-wm-char

:: handle-wm-char ( hWnd uMsg wParam lParam -- )
    wParam exclude-key-wm-char? [
        ctrl? alt? xor [ ! enable AltGr combination inputs
            wParam {
                { [ dup upper-surrogate? ] [
                      upper-surrogate-wm-char set-global
                ] }
                { [ dup under-surrogate? ] [
                    drop
                    upper-surrogate-wm-char get-global [
                        wParam "" 2sequence
                        utf16n encode utf16n decode hWnd window user-input
                    ] when*
                ] }
                [ 1string hWnd window user-input
                  f upper-surrogate-wm-char set-global ]
            } cond
        ] unless
    ] unless ;

: handle-wm-keyup ( hWnd uMsg wParam lParam -- )
    \ send-key-up (handle-wm-keydown/up) ;

:: set-window-active ( hwnd uMsg wParam lParam ? -- n )
    ? hwnd window active?<<
    hwnd uMsg wParam lParam DefWindowProc ;

: handle-wm-syscommand ( hWnd uMsg wParam lParam -- n )
    {
        { [ over SC_MINIMIZE = ] [ f set-window-active ] }
        { [ over SC_RESTORE = ] [ t set-window-active ] }
        { [ over SC_MAXIMIZE = ] [ t set-window-active ] }
        { [ dup alpha? ] [ 4drop 0 ] }
        [ DefWindowProc ]
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
    swap [ push ] [ remove! drop ] if ;

: scroll-distance ( wParam -- n )
    [ hi-word 80 /f ] [ lo-word ] bi MK_SHIFT mask? [ 10 * ] when ;

: mouse-scroll ( wParam -- direction )
    scroll-distance -2 * 0 swap 2array ;

: mouse-horizontal-scroll ( wParam -- direction )
    scroll-distance 0 2array ;

: mouse-event>gesture ( uMsg -- button )
    key-modifiers swap message>button
    [ <button-down> ] [ <button-up> ] if ;

:: prepare-mouse ( hWnd uMsg wParam lParam -- button coordinate world )
    uMsg mouse-event>gesture
    lParam >lo-hi [ gl-unscale ] map
    hWnd window ;

: set-capture ( hwnd -- )
    mouse-captured get [
        drop
    ] [
        [ SetCapture drop ] keep
        mouse-captured namespaces:set
    ] if ;

: release-capture ( -- )
    ReleaseCapture win32-error=0/f
    mouse-captured off ;

: handle-app-command ( hWnd uMsg wParam lParam -- )
    GET_APPCOMMAND_LPARAM
    {
        { APPCOMMAND_BROWSER_BACKWARD [ pick window left-action send-action ] }
        { APPCOMMAND_BROWSER_FORWARD [ pick window right-action send-action ] }
        [ drop ]
    } case 3drop ;

: handle-wm-buttondown ( hWnd uMsg wParam lParam -- )
    [
        over set-capture
        dup message>button drop nc-buttons get remove! drop
    ] 2dip prepare-mouse send-button-down ;

: handle-wm-buttonup ( hWnd uMsg wParam lParam -- )
    mouse-captured get [ release-capture ] when
    pick message>button drop dup nc-buttons get member? [
        nc-buttons get remove! 5drop
    ] [
        drop prepare-mouse send-button-up
    ] if ;

: make-TRACKMOUSEEVENT ( hWnd -- alien )
    TRACKMOUSEEVENT new
        swap >>hwndTrack
        TRACKMOUSEEVENT c:heap-size >>cbSize ;

: handle-wm-mousemove ( hWnd uMsg wParam lParam -- )
    2nip
    over make-TRACKMOUSEEVENT
        TME_LEAVE >>dwFlags
        0 >>dwHoverTime
    TrackMouseEvent win32-error=0/f
    >lo-hi [ gl-unscale ] map swap window move-hand fire-motion ;

: (handle-mousewheel) ( direction hWnd -- )
    hand-loc get-global swap window send-scroll ; inline

:: handle-wm-mousewheel ( hWnd uMsg wParam lParam -- )
    wParam mouse-scroll hWnd (handle-mousewheel) ;

:: handle-wm-mousehwheel ( hWnd uMsg wParam lParam -- )
    wParam mouse-horizontal-scroll hWnd (handle-mousewheel) ;

: handle-wm-cancelmode ( hWnd uMsg wParam lParam -- )
    ! message sent if windows needs application to stop dragging
    4drop release-capture ;

: handle-wm-mouseleave ( hWnd uMsg wParam lParam -- )
    ! message sent if mouse leaves main application
    4drop forget-rollover ;

: system-background-color ( -- color )
    COLOR_BTNFACE GetSysColor RGB>color ;

: ?make-glass ( world hwnd -- )
    over window-controls>> textured-background swap member-eq? [
        composition-enabled? [
            full-window-margins DwmExtendFrameIntoClientArea check-hresult
            T{ rgba f 0.0 0.0 0.0 0.0 }
        ] [ drop system-background-color ] if >>background-color
        drop
    ] [ 2drop ] if ;

: handle-wm-dwmcompositionchanged ( hWnd uMsg wParam lParam -- )
    3drop [ window ] keep ?make-glass ;

SYMBOL: wm-handlers

: add-wm-handler ( quot: ( hWnd Msg wParam lParam -- LRESULT ) wm -- )
    dup array?
    [ [ execute( -- wm ) add-wm-handler ] with each ]
    [ wm-handlers get-global set-at ] if ;

: remove-wm-handler ( wm -- )
    wm-handlers get-global delete-at ;

wm-handlers [
    H{
        ${ WM_CLOSE [ handle-wm-close 0 ] }
        ! ${ WM_NCCREATE [ [ 3drop EnableNonClientDpiScaling drop ] [ DefWindowProc ] 4bi ] }
        ! ${ WM_GETDPISCALEDSIZE [ DefWindowProc ] }
        ! ${ WM_DPICHANGED [ DefWindowProc ] }
        ${ WM_PAINT [ 4dup handle-wm-paint DefWindowProc ] }

        ${ WM_SIZE [ handle-wm-size 0 ] }
        ${ WM_MOVE [ handle-wm-move 0 ] }

        { ${ WM_CHAR WM_SYSCHAR } [ 4dup handle-wm-char DefWindowProc ] }
        { ${ WM_KEYDOWN WM_SYSKEYDOWN } [ 4dup handle-wm-keydown DefWindowProc ] }
        { ${ WM_KEYUP WM_SYSKEYUP } [ 4dup handle-wm-keyup DefWindowProc ] }

        ${ WM_SYSCOMMAND [ handle-wm-syscommand ] }
        ${ WM_SETFOCUS [ handle-wm-set-focus 0 ]  }
        ${ WM_KILLFOCUS [ handle-wm-kill-focus 0 ] }

        ${ WM_APPCOMMAND [ handle-app-command 0 ] }

        { ${ WM_LBUTTONDOWN WM_MBUTTONDOWN WM_RBUTTONDOWN } [ handle-wm-buttondown 0 ] }
        { ${ WM_LBUTTONUP WM_MBUTTONUP WM_RBUTTONUP } [ handle-wm-buttonup 0 ] }
        ${ WM_DWMCOMPOSITIONCHANGED [ handle-wm-dwmcompositionchanged 0 ] }

        {
            ${
                WM_NCLBUTTONDOWN WM_NCMBUTTONDOWN WM_NCRBUTTONDOWN
                WM_NCLBUTTONUP WM_NCMBUTTONUP WM_NCRBUTTONUP
            } [ 4dup handle-wm-ncbutton DefWindowProc ]
        }

        { ${ WM_EXITMENULOOP WM_EXITSIZEMOVE } [ nc-buttons get-global delete-all DefWindowProc ] }

        ${ WM_MOUSEMOVE [ handle-wm-mousemove 0 ] }
        ${ WM_MOUSEWHEEL [ handle-wm-mousewheel 0 ] }
        ${ WM_MOUSEHWHEEL [ handle-wm-mousehwheel 0 ] }
        ${ WM_CANCELMODE [ handle-wm-cancelmode 0 ] }
        ${ WM_MOUSELEAVE [ handle-wm-mouseleave 0 ] }
    } expand-keys-set-at
] initialize

SYMBOL: trace-messages?

! return 0 if you handle the message, else just let DefWindowProc return its val
: ui-wndproc ( -- object )
    c:uint { c:void* c:uint WPARAM LPARAM } stdcall [
        pick wm-handlers get-global at*
        [ flush call( hWnd Msg wParam lParam -- result ) ] [ drop DefWindowProc ] if
    ] alien-callback ;

: peek-message? ( msg -- ? ) f 0 0 PM_REMOVE PeekMessage zero? ;

M: windows-ui-backend do-events
    msg-obj get-global
    dup peek-message? [ drop ui-wait ] [
        [ TranslateMessage drop ]
        [ DispatchMessage drop ] bi
    ] if ;

:: register-window-class ( class-name-ptr -- )
    WNDCLASSEX new f GetModuleHandle
    class-name-ptr pick GetClassInfoEx 0 = [
        WNDCLASSEX c:heap-size >>cbSize
        flags{ CS_HREDRAW CS_VREDRAW CS_OWNDC } >>style
        ui-wndproc >>lpfnWndProc
        0 >>cbClsExtra
        0 >>cbWndExtra
        f GetModuleHandle >>hInstance
        f GetModuleHandle "APPICON" native-string>alien LoadIcon >>hIcon
        f IDC_ARROW MAKEINTRESOURCE LoadCursor >>hCursor

        class-name-ptr >>lpszClassName
        RegisterClassEx win32-error=0/f
    ] [ drop ] if ;

: adjust-RECT ( RECT style ex-style -- )
    ! [ 0 ] dip GetDpiForSystem AdjustWindowRectExForDpi win32-error=0/f ;
    [ 0 ] dip AdjustWindowRectEx win32-error=0/f ;

: make-RECT ( world -- RECT )
    [ window-loc>> ] [ dim>> ] bi <RECT> ;

: default-position-RECT ( RECT -- RECT' )
    dup get-RECT-width/height
        [ CW_USEDEFAULT + >>right ] dip
        CW_USEDEFAULT + >>bottom
        CW_USEDEFAULT >>left
        CW_USEDEFAULT >>top ;

: make-adjusted-RECT ( rect style ex-style -- RECT )
    [
        make-RECT
        dup get-RECT-top-left [ zero? ] both? swap
        dup
    ] 2dip adjust-RECT
    swap [ default-position-RECT ] when ;

: get-window-class ( -- class-name )
    class-name-ptr [
        dup expired? [ drop "Factor-window" utf16n malloc-string ] when
        dup register-window-class
        dup
    ] change-global ;

: get-device-caps ( handle -- x y )
    GetDC
    [ LOGPIXELSX GetDeviceCaps ]
    [ LOGPIXELSY GetDeviceCaps ] bi ;

: get-default-device-caps ( -- x y )
    f get-device-caps ;

: map-rect ( rect quot -- rect' )
    [ '[ _ map ] change-loc ] [ '[ _ map ] change-dim ] bi ; inline

:: create-window ( rect style ex-style -- hwnd )
    rect [ gl-scale ] map-rect style ex-style make-adjusted-RECT
    [ get-window-class f ] dip
    [
        [ ex-style ] 2dip
        flags{ WS_CLIPSIBLINGS WS_CLIPCHILDREN } style bitor
    ] dip get-RECT-dimensions
    f f f GetModuleHandle f CreateWindowEx dup win32-error=0/f ;

: show-window ( hWnd -- )
    dup SW_SHOW ShowWindow drop ! always succeeds
    dup SetForegroundWindow drop
    SetFocus drop ;

: init-win32-ui ( -- )
    V{ } clone nc-buttons set-global
    MSG malloc-struct msg-obj set-global
    GetDoubleClickTime milliseconds double-click-timeout set-global ;

: cleanup-win32-ui ( -- )
    class-name-ptr [ [ [ f UnregisterClass drop ] [ free ] bi ] when* f ] change-global
    msg-obj [ [ free ] when* f ] change-global ;

: get-dc ( world -- )
    handle>> dup hWnd>> GetDC dup win32-error=0/f >>hDC drop ;

<<
CONSTANT: WGL_CONTEXT_MAJOR_VERSION_ARB           0x2091
CONSTANT: WGL_CONTEXT_MINOR_VERSION_ARB           0x2092
CONSTANT: WGL_CONTEXT_LAYER_PLANE_ARB             0x2093
CONSTANT: WGL_CONTEXT_FLAGS_ARB                   0x2094
CONSTANT: WGL_CONTEXT_PROFILE_MASK_ARB            0x9126

CONSTANT: WGL_CONTEXT_DEBUG_BIT_ARB               0x0001
CONSTANT: WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB  0x0002

CONSTANT: WGL_CONTEXT_CORE_PROFILE_BIT_ARB        0x00000001
CONSTANT: WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB 0x00000002

CONSTANT: ERROR_INVALID_VERSION_ARB               0x2095
CONSTANT: ERROR_INVALID_PROFILE_ARB               0x2096
>>

CONSTANT: gl3-attribs int-array{
    $ WGL_CONTEXT_MAJOR_VERSION_ARB 3
    $ WGL_CONTEXT_MINOR_VERSION_ARB 2
    $ WGL_CONTEXT_PROFILE_MASK_ARB $ WGL_CONTEXT_CORE_PROFILE_BIT_ARB
    0
}

: get-rc ( world -- )
    handle>> dup hDC>>
    ! dup f gl3-attribs wglCreateContextAttribsARB
    dup wglCreateContext
    dup win32-error=0/f
    [ wglMakeCurrent win32-error=0/f ] keep >>hRC drop ;

: set-pixel-format ( pixel-format hdc -- )
    swap handle>>
    PIXELFORMATDESCRIPTOR new SetPixelFormat win32-error=0/f ;

: setup-gl ( world -- )
    [ get-dc ] keep
    [ swap [ handle>> hDC>> set-pixel-format ] [ get-rc ] bi ]
    with-world-pixel-format ;

: disable-close-button ( hwnd -- )
    0 GetSystemMenu
    SC_CLOSE MF_BYCOMMAND MF_GRAYED bitor EnableMenuItem drop ;

: ?disable-close-button ( world hwnd -- )
    swap window-controls>> close-button swap member? not
    [ disable-close-button ] [ drop ] if ;

M: windows-ui-backend (open-window)
    gl-scale-factor get-global [ init-scale-factor ] unless
    [
        dup
        [ ] [ world>style ] [ world>ex-style ] tri create-window
        [ ?make-glass ]
        [ ?disable-close-button ]
        [ [ f f ] dip f f <win> >>handle setup-gl ] 2tri
    ]
    [ dup handle>> hWnd>> register-window ]
    [ handle>> hWnd>> show-window ] tri ;

! https://github.com/factor/factor/issues/2173
! ignore timeout (error 258)
M: win-base select-gl-context
    [ hDC>> ] [ hRC>> ] bi wglMakeCurrent win32-error=0/f-ignore-timeout
    GdiFlush win32-error=0/f ;

M: win-base flush-gl-context
    hDC>> SwapBuffers win32-error=0/f ;

! Windows 32-bit bitmaps don't actually use the alpha byte of
! each pixel; it's left as zero

: (make-opaque) ( byte-array -- byte-array' )
    [ length 4 /i ]
    [ '[ 255 swap 4 * 3 + _ set-nth ] each ]
    [ ] tri ;

: (opaque-pixels) ( world -- pixels )
    [ handle>> bits>> ] [ dim>> ] bi bitmap>byte-array (make-opaque) ;

M: windows-ui-backend raise-window*
    handle>> [ hWnd>> SetFocus drop ] when* ;

M: windows-ui-backend set-title
    handle>>
    dup title>> [ free ] when*
    swap utf16n malloc-string
    [ >>title ]
    [ [ hWnd>> WM_SETTEXT 0 ] dip alien-address SendMessage drop ] bi ;

: detect-theme ( -- )
    [
        HKEY_CURRENT_USER
        "Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize"
        "AppsUseLightTheme" query-registry first 1 =
        light-theme dark-theme ? switch-theme-if-default
    ] ignore-errors ;

M: windows-ui-backend (with-ui)
    [
        init-clipboard
        init-scale-factor
        init-win32-ui
        detect-theme
        start-ui
        event-loop
    ] [ cleanup-win32-ui ] finally ;

M: windows-ui-backend beep
    0 MessageBeep drop ;

M: windows-ui-backend system-alert
    [ f ] 2dip swap MB_OK MessageBox drop ;

: fullscreen-RECT ( hwnd -- RECT )
    MONITOR_DEFAULTTONEAREST MonitorFromWindow
    MONITORINFOEX new
        MONITORINFOEX c:heap-size >>cbSize
    [ GetMonitorInfo win32-error=0/f ] keep rcMonitor>> ;

: client-area>RECT ( hwnd -- RECT )
    RECT new
    [ GetClientRect win32-error=0/f ]
    [ >c-ptr POINT cast-array [ ClientToScreen drop ] with each ]
    [ nip ] 2tri ;

: hwnd>RECT ( hwnd -- RECT )
    RECT new [ GetWindowRect win32-error=0/f ] keep ;

M: windows-ui-backend (grab-input)
    0 ShowCursor drop
    hWnd>> client-area>RECT ClipCursor drop ;

M: windows-ui-backend (ungrab-input)
    drop
    f ClipCursor drop
    1 ShowCursor drop ;

CONSTANT: fullscreen-flags flags{ WS_CAPTION WS_BORDER WS_THICKFRAME }

: enter-fullscreen ( world -- )
    handle>> hWnd>>
    {
        [
            GWL_STYLE GetWindowLong
            fullscreen-flags unmask
        ]
        [ GWL_STYLE rot SetWindowLong win32-error=0/f ]
        [
            HWND_TOP
            over hwnd>RECT get-RECT-dimensions
            SWP_FRAMECHANGED
            SetWindowPos win32-error=0/f
        ]
        [ SW_MAXIMIZE ShowWindow win32-error=0/f ]
    } cleave ;

: exit-fullscreen ( world -- )
    [ handle>> hWnd>> ] [ world>style ] bi
    {
        [ [ GWL_STYLE ] dip SetWindowLong win32-error=0/f ]
        [
            drop
            f
            over hwnd>RECT get-RECT-dimensions
            flags{ SWP_NOMOVE SWP_NOSIZE SWP_NOZORDER SWP_FRAMECHANGED }
            SetWindowPos win32-error=0/f
        ]
        [ drop SW_RESTORE ShowWindow win32-error=0/f ]
    } 2cleave ;

: ensure-null-terminated ( str -- str' )
    dup ?last 0 = [ "\0" append ] unless ; inline

: add-tray-icon ( title -- )
    NIM_ADD
    NOTIFYICONDATA new
        NOTIFYICONDATA heap-size >>cbSize
        NOTIFYICON_VERSION_4 over timeout-version>> uVersion<<
        NIF_TIP NIF_ICON bitor >>uFlags
        world get handle>> hWnd>> >>hWnd
        f GetModuleHandle "APPICON" native-string>alien LoadIcon >>hIcon
        rot ensure-null-terminated utf8 encode >>szTip
        Shell_NotifyIcon win32-error=0/f ;

: remove-tray-icon ( -- )
    NIM_DELETE
    NOTIFYICONDATA new
        NOTIFYICONDATA heap-size >>cbSize
        world get handle>> hWnd>> >>hWnd
    Shell_NotifyIcon win32-error=0/f ;

M: windows-ui-backend (set-fullscreen)
    [ enter-fullscreen ] [ exit-fullscreen ] if ;

M: windows-ui-backend (fullscreen?)
    handle>> [
        hWnd>>
        [ hwnd>RECT ] [ fullscreen-RECT ] bi
        [ get-RECT-dimensions 2array 2nip ] same?
    ] [
        [ "windows-ui-backend no hWnd" print ] with-global
        f
    ] if* ;

M:: windows-ui-backend resize-window ( world dim -- )
    world handle>> hWnd>>
    world window-loc>> [ gl-scale ] map
    dim [ gl-scale ] map <RECT> dup
    world world>style
    world world>ex-style
    adjust-RECT get-RECT-dimensions FALSE
    MoveWindow win32-error=0/f ;

M: windows-ui-backend ui-backend-available?
    t ;

windows-ui-backend ui-backend set-global
