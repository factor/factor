IN: win32
USING: alien namespaces math io prettyprint kernel words ;
USING: inspector ;

SYMBOL: hInst
SYMBOL: wc
SYMBOL: className "SimpleWindowClass" className set 

: hello-world
    f "Hello, world!" "First Application" MB_OK MessageBox win32-error drop ;


! : message-loop ( -- )
    ! message-loop ;

: wndproc ( hwnd uMsg wParam lParam -- lresult )
    "uint" { "void*" "uint" "long" "long" } [
        pick WM_DESTROY = [
            3drop drop
            f PostQuitMessage 0
        ] [
            DefWindowProc
        ] if 
     ] alien-callback ;

: register-wndclassex ( name wndproc -- )
    "WNDCLASSEX" <c-object>
    "WNDCLASSEX" c-size over set-WNDCLASSEX-cbSize
    CS_HREDRAW CS_VREDRAW bitor over set-WNDCLASSEX-style
    >r execute r> [ set-WNDCLASSEX-lpfnWndProc ] keep
    0 over set-WNDCLASSEX-cbClsExtra
    0 over set-WNDCLASSEX-cbWndExtra
    hInst get over set-WNDCLASSEX-hInstance
    ! COLOR_WINDOW 1+ GetSysColorBrush over set-WNDCLASSEX-hbrBackground
    ! "" over set-WNDCLASSEX-lpszMenuName
    ! [ set-WNDCLASSEX-lpszClassName ] keep
    f IDI_APPLICATION LoadIcon over [ set-WNDCLASSEX-hIcon ] 2keep
        set-WNDCLASSEX-hIconSm
    f IDC_ARROW LoadCursor over set-WNDCLASSEX-hCursor
    ! RegisterClassEx
    ;

: app2
    f GetModuleHandle hInst set
    "App2" \ wndproc register-wndclassex

    ! 0 className get "Second Application" WS_OVERLAPPEDWINDOW CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT f f hInst get f CreateWindowEx
    
    ! dup SW_SHOWDEFAULT ShowWindow
    ! dup UpdateWindow
    ! message-loop
    
    
    ! f GetModuleHandle
    ;
