! (c)2009 Joe Groff bsd license
USING: alien.c-types alien.libraries alien.syntax classes.struct windows.types ;
IN: windows.dwmapi

STRUCT: MARGINS
    { cxLeftWidth    int }
    { cxRightWidth   int }
    { cyTopHeight    int }
    { cyBottomHeight int } ;

STRUCT: DWM_BLURBEHIND
    { dwFlags                DWORD   }
    { fEnable                BOOL    }
    { hRgnBlur               HANDLE  }
    { fTransitionOnMaximized BOOL    } ;

: <MARGINS> ( l r t b -- MARGINS )
    MARGINS <struct-boa> ; inline

: full-window-margins ( -- MARGINS )
    -1 -1 -1 -1 <MARGINS> ; inline

<< "dwmapi" "dwmapi.dll" "stdcall" add-library >>

LIBRARY: dwmapi

FUNCTION: HRESULT DwmExtendFrameIntoClientArea ( HWND hWnd, MARGINS* pMarInset ) ;
FUNCTION: HRESULT DwmEnableBlurBehindWindow ( HWND hWnd, DWM_BLURBEHIND* pBlurBehind ) ;
