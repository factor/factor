! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.libraries
alien.syntax classes.struct kernel math system-info.windows
windows.types ;
IN: windows.dwmapi

STRUCT: MARGINS
    { cxLeftWidth    int }
    { cxRightWidth   int }
    { cyTopHeight    int }
    { cyBottomHeight int } ;

C: <MARGINS> MARGINS

STRUCT: DWM_BLURBEHIND
    { dwFlags                DWORD   }
    { fEnable                BOOL    }
    { hRgnBlur               HANDLE  }
    { fTransitionOnMaximized BOOL    } ;

: full-window-margins ( -- MARGINS )
    -1 -1 -1 -1 <MARGINS> ; inline

<< "dwmapi" "dwmapi.dll" stdcall add-library >>

LIBRARY: dwmapi

FUNCTION: HRESULT DwmExtendFrameIntoClientArea ( HWND hWnd, MARGINS* pMarInset )
FUNCTION: HRESULT DwmEnableBlurBehindWindow ( HWND hWnd, DWM_BLURBEHIND* pBlurBehind )
FUNCTION: HRESULT DwmIsCompositionEnabled ( BOOL* pfEnabled )
FUNCTION: HRESULT DwmSetWindowAttribute ( HWND hwnd, DWORD attribute, void* value, DWORD size )
FUNCTION: HRESULT DwmGetWindowAttribute ( HWND hwnd, DWORD attribute, void* value, DWORD size )

CONSTANT: DWMWA_CLOAK 13
CONSTANT: DWMWA_CLOAKED 14
CONSTANT: DWMWA_USE_IMMERSIVE_DARK_MODE 20

CONSTANT: WM_DWMCOMPOSITIONCHANGED 0x31E

: composition-enabled? ( -- ? )
    windows-major 6 >=
    [ { bool } [ DwmIsCompositionEnabled drop ] with-out-parameters ]
    [ f ] if ;
