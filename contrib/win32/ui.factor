USING: alien arrays errors freetype gadgets gadgets-launchpad gadgets-layouts
       gadgets-listener hashtables io kernel lists math namespaces prettyprint 
       sequences strings vectors words windows-messages ;
USING: inspector threads memory ;
IN: win32

SYMBOL: windows
SYMBOL: msg-obj

! 'SYMBOL: windows' is a hashtable of 'gadget-window' objects indexed by hWnd.
! hDC = handle to device context, hRC = handle to render context
TUPLE: gadget-window world hWnd hDC hRC ;

: get-world ( hWnd -- world ) windows get hash gadget-window-world ;
: get-gadget-window ( hWnd -- gadget-window )
    windows get hash ;

: style ( -- n ) WS_OVERLAPPEDWINDOW ; inline
: ex-style ( -- n ) WS_EX_APPWINDOW WS_EX_WINDOWEDGE bitor ; inline

: adjust-RECT ( RECT -- )
    style 0 ex-style AdjustWindowRectEx win32-error=0 ;

: make-RECT ( width height -- RECT )
    "RECT" <c-object> [ set-RECT-bottom ] keep [ set-RECT-right ] keep ;

: make-adjusted-RECT ( width height -- RECT )
    make-RECT dup adjust-RECT ;

: cleanup-gadget-window ( gadget-window -- )
    dup gadget-window-hRC wglDeleteContext win32-error=0
    [ gadget-window-hWnd ] keep gadget-window-hDC ReleaseDC win32-error=0 ;

: get-RECT-dimensions ( RECT -- width height )
    [ RECT-right ] keep [ RECT-left - ] keep
    [ RECT-bottom ] keep RECT-top - ;

: handle-wm-paint ( hWnd uMsg wParam lParam -- )
    #! wParam and lParam are unused
    3drop get-world redraw-world ;

: handle-wm-size ( hWnd uMsg wParam lParam -- )
    [ lo-word ] keep hi-word make-RECT get-RECT-dimensions 0 3array
    2nip swap get-world set-gadget-dim ;

: wm-keydown-codes ( n -- key )
    H{
        { 8 "BACKSPACE" }
        { 9 "TAB" }
        { 13 "RETURN" }
        { 27 "ESCAPE" }
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
    } ;

: wm-char-exclude-keys
    H{
        { 8 "BACKSPACE" }
        { 13 "RETURN" }
    } ;

: handle-key? ( n -- bool ) wm-keydown-codes hash* nip ;
: exclude-key? ( n -- bool ) wm-char-exclude-keys hash* nip ;
: keystroke>gesture ( n -- list ) wm-keydown-codes hash unit ;

SYMBOL: lParam
SYMBOL: wParam
SYMBOL: uMsg
SYMBOL: hWnd

! wparam = keystroke, lparam = parameters
: handle-wm-keydown ( hWnd uMsg wParam lParam -- )
    lParam set wParam set uMsg set hWnd set
    wParam get handle-key? [
        wParam get keystroke>gesture
        hWnd get get-world world-focus handle-gesture 0
    ] [
        hWnd get uMsg get wParam get lParam get DefWindowProc
    ] if ;

: handle-wm-destroy ( hWnd uMsg wParam lParam -- )
    3drop 

    [
        get-gadget-window 
        dup gadget-window-world close-world
        cleanup-gadget-window
    ] keep
    windows get remove-hash
    0 PostQuitMessage ;


: handle-wm-char ( hWnd uMsg wParam lParam -- )
    lParam set wParam set uMsg set hWnd set
    wParam get exclude-key? [
        hWnd get uMsg get wParam get lParam get DefWindowProc
    ] [
        wParam get ch>string hWnd get get-world world-focus user-input
        0 ! retval
    ] if ;

! TODO: handle alt keystrokes as gestures
: handle-wm-syschar ( hWnd uMsg wParam lParam -- )
    lParam set wParam set uMsg set hWnd set
    ;

: mouse-button ( uMsg -- n )
    {
        { [ dup WM_LBUTTONDOWN = ] [ drop 1 ] }
        { [ dup WM_LBUTTONUP = ] [ drop 1 ] }
        { [ dup WM_MBUTTONDOWN = ] [ drop 2 ] }
        { [ dup WM_MBUTTONUP = ] [ drop 2 ] }
        { [ dup WM_RBUTTONDOWN = ] [ drop 3 ] }
        { [ dup WM_RBUTTONUP = ] [ drop 3 ] }
        { [ t ] [ "bad button" throw ] }
    } cond ;

: mouse-coordinate ( lParam -- seq ) [ lo-word ] keep hi-word 0 3array ;
: mouse-wheel ( lParam -- n ) hi-word 0 > 1 -1 ? ;

: prepare-mouse ( hWnd uMsg wParam lParam -- )
    nip >r mouse-button r> mouse-coordinate rot get-world ;

: handle-wm-buttondown ( hWnd uMsg wParam lParam -- )
    prepare-mouse send-button-down ;

: handle-wm-buttonup ( hWnd uMsg wParam lParam -- )
    prepare-mouse send-button-up ;

: handle-wm-mousemove ( hWnd uMsg wParam lParam -- )
    2nip mouse-coordinate swap get-world move-hand ;

: handle-wm-mousewheel ( hWnd uMsg wParam lParam -- )
    mouse-coordinate >r mouse-wheel nip r> rot get-world send-wheel ;

! return 0 if you handle the message, else just let DefWindowProc return its val
: ui-wndproc ( hWnd uMsg wParam lParam -- lresult )
    "uint" { "void*" "uint" "long" "long" } [
        [
        pick 
        ! "Message: " write dup get-windows-message-name write 
            ! " " write dup unparse print
            {
                { [ dup WM_DESTROY = ]    [ drop handle-wm-destroy 0 ] }
                { [ dup WM_PAINT = ]      [ drop handle-wm-paint 0 ] }
                { [ dup WM_SIZE = ]      [ drop handle-wm-size 0 ] }

                ! Keyboard events
                { [ dup WM_KEYDOWN = over WM_SYSKEYDOWN = or ]
                    [ drop handle-wm-keydown ] }
                { [ dup WM_CHAR = over WM_SYSCHAR = or ]
                    [ drop handle-wm-char ] }

                ! Mouse events
                { [ dup WM_LBUTTONDOWN = ] [ drop handle-wm-buttondown 0 ] }
                { [ dup WM_MBUTTONDOWN = ] [ drop handle-wm-buttondown 0 ] }
                { [ dup WM_RBUTTONDOWN = ] [ drop handle-wm-buttondown 0 ] }
                { [ dup WM_LBUTTONUP = ] [ drop handle-wm-buttonup 0 ] }
                { [ dup WM_MBUTTONUP = ] [ drop handle-wm-buttonup 0 ] }
                { [ dup WM_RBUTTONUP = ] [ drop handle-wm-buttonup 0 ] }
                { [ dup WM_MOUSEMOVE = ] [ drop handle-wm-mousemove 0 ] }
                { [ dup WM_MOUSEWHEEL = ] [ drop handle-wm-mousewheel 0 ] }

                { [ t ] [ drop DefWindowProc ] }
            } cond
        ] catch [ error. 0 ] when*
     ] alien-callback ;

: event-loop ( -- )
    msg-obj get f 0 0 PM_REMOVE PeekMessage 
    zero? not [
        msg-obj get MSG-message WM_QUIT = [
            msg-obj get [ TranslateMessage drop ] keep DispatchMessage drop
        ] unless
    ] when 
    ui-step windows get hash-empty? [ event-loop ] unless ;

: register-wndclassex ( classname wndproc -- )
    "WNDCLASSEX" <c-object>
    "WNDCLASSEX" c-size over set-WNDCLASSEX-cbSize
    CS_HREDRAW CS_VREDRAW bitor CS_OWNDC bitor over set-WNDCLASSEX-style 
    [ set-WNDCLASSEX-lpfnWndProc ] keep
    0 over set-WNDCLASSEX-cbClsExtra
    0 over set-WNDCLASSEX-cbWndExtra
    f GetModuleHandle over set-WNDCLASSEX-hInstance
    f IDI_APPLICATION LoadIcon over set-WNDCLASSEX-hIcon
    f IDC_ARROW LoadCursor over set-WNDCLASSEX-hCursor
    [ set-WNDCLASSEX-lpszClassName ] keep
    RegisterClassEx dup win32-error=0 ;

    
: create-window ( className title width height -- hwnd )
    make-adjusted-RECT
    >r >r >r ex-style r> r>
        WS_CLIPSIBLINGS WS_CLIPCHILDREN bitor style bitor
        0 0 r>
    get-RECT-dimensions
    f f f GetModuleHandle f CreateWindowEx dup win32-error=0 ;

: show-window ( hWnd -- )
    dup SW_SHOW ShowWindow drop ! always succeeds
    dup SetForegroundWindow drop
    SetFocus drop ;

: init-win32-ui
    "MSG" <c-object> msg-obj set
    "Factor" ui-wndproc register-wndclassex win32-error=0
    H{ } clone windows set
    init-ui ;

: cleanup-win32-ui ( -- ) "Factor" f UnregisterClass drop ;

: setup-pixel-format ( hdc -- )
    16 make-pfd [ ChoosePixelFormat dup win32-error=0 ] 2keep
    swapd SetPixelFormat win32-error=0 ;

: get-dc ( hWnd -- hDC ) GetDC dup win32-error=0 ;

: get-rc ( hDC -- hRC )
    dup wglCreateContext dup win32-error=0
    [ wglMakeCurrent win32-error=0 ] keep ;

: setup-gl ( hwnd -- hDC hRC )
    get-dc 
    dup setup-pixel-format
    dup get-rc ;

: make-gadget-window ( world title -- <gadget-window> )
    "Factor" swap pick rect-dim first2 create-window
    dup setup-gl <gadget-window> ;

IN: gadgets

: open-window* ( world title -- )
    make-gadget-window
    [ [ gadget-window-hWnd ] keep gadget-window-world set-world-handle ] keep
    dup gadget-window-hWnd [ windows get set-hash ] keep show-window ;

: select-gl-context ( handle -- )
    get-gadget-window 
    [
        [ gadget-window-hDC ] keep gadget-window-hRC
        wglMakeCurrent win32-error=0
    ] when* ;

: flush-gl-context ( handle -- )
    get-gadget-window [ gadget-window-hDC SwapBuffers win32-error=0 ] when* ;

IN: shells
: ui ( -- )
    [
        [
            init-win32-ui
            launchpad-window
            listener-window
            event-loop
        ] with-freetype 
    ] [ cleanup-win32-ui ] cleanup ;

: default-shell "ui" ;
