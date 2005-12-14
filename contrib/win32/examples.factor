IN: win32
USING: alien namespaces math io prettyprint kernel ;

SYMBOL: hInst
SYMBOL: wc
SYMBOL: className "SimpleWindowClass" className set 

: hello-world
    f "Hello, world!" "First Application" MB_OK MessageBox win32-error drop ;


! : message-loop ( -- )
    ! message-loop ;

: app2
    f GetModuleHandle hInst set
    <WNDCLASSEX>
    "WNDCLASSEX" c-size over set-WNDCLASSEX-cbSize
    CS_HREDRAW CS_VREDRAW bitor over set-WNDCLASSEX-style
    ! [ event-loop ] over set-WNDCLASSEX-lpfnWndProc
    0 over set-WNDCLASSEX-cbClsExtra
    0 over set-WNDCLASSEX-cbWndExtra
    hInst get over set-WNDCLASSEX-hInstance
    COLOR_WINDOW 1 + over set-WNDCLASSEX-hbrBackground
    f over set-WNDCLASSEX-lpszMenuName
    className get over set-WNDCLASSEX-lpszClassName
    ! ! f IDI_APPLICATION LoadIcon over [ set-WNDCLASSEX-hIcon ] keep set-WNDCLASSEX-hIconSm
    ! f IDC_ARROW LoadCursor over set-WNDCLASSEX-hCursor
    ! RegisterClassEx
    
    ! 0 className get "Second Application" WS_OVERLAPPEDWINDOW CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT f f hInst get f ! CreateWindowEx
    
    ! dup SW_SHOWDEFAULT ShowWindow
    ! dup UpdateWindow
    ! message-loop
    
    
    ! f GetModuleHandle
    ;
