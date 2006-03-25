IN: win32
USING: alien kernel errors ;

LIBRARY: gdi

! Stock Logical Objects
: WHITE_BRUSH         0 ; inline
: LTGRAY_BRUSH        1 ; inline
: GRAY_BRUSH          2 ; inline
: DKGRAY_BRUSH        3 ; inline
: BLACK_BRUSH         4 ; inline
: NULL_BRUSH          5 ; inline
: HOLLOW_BRUSH        NULL_BRUSH ; inline
: WHITE_PEN           6 ; inline
: BLACK_PEN           7 ; inline
: NULL_PEN            8 ; inline
: OEM_FIXED_FONT      10 ; inline
: ANSI_FIXED_FONT     11 ; inline
: ANSI_VAR_FONT       12 ; inline
: SYSTEM_FONT         13 ; inline
: DEVICE_DEFAULT_FONT 14 ; inline
: DEFAULT_PALETTE     15 ; inline
: SYSTEM_FIXED_FONT   16 ; inline
: DEFAULT_GUI_FONT    17 ; inline
: DC_BRUSH            18 ; inline
: DC_PEN              19 ; inline

FUNCTION: HGDIOBJ GetStockObject ( int fnObject ) ;
FUNCTION: int ChoosePixelFormat ( HDC hDC, PFD* ppfd ) ;
FUNCTION: BOOL SetPixelFormat ( HDC hDC, int iPixelFormat, PFD* ppfd ) ;

FUNCTION: BOOL SwapBuffers ( HDC hDC ) ;


