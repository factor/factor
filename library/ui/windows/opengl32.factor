! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien parser namespaces kernel syntax words math io prettyprint ;
IN: win32-api

! PIXELFORMATDESCRIPTOR flags
: PFD_DOUBLEBUFFER            HEX: 00000001 ; inline
: PFD_STEREO                  HEX: 00000002 ; inline
: PFD_DRAW_TO_WINDOW          HEX: 00000004 ; inline
: PFD_DRAW_TO_BITMAP          HEX: 00000008 ; inline
: PFD_SUPPORT_GDI             HEX: 00000010 ; inline
: PFD_SUPPORT_OPENGL          HEX: 00000020 ; inline
: PFD_GENERIC_FORMAT          HEX: 00000040 ; inline
: PFD_NEED_PALETTE            HEX: 00000080 ; inline
: PFD_NEED_SYSTEM_PALETTE     HEX: 00000100 ; inline
: PFD_SWAP_EXCHANGE           HEX: 00000200 ; inline
: PFD_SWAP_COPY               HEX: 00000400 ; inline
: PFD_SWAP_LAYER_BUFFERS      HEX: 00000800 ; inline
: PFD_GENERIC_ACCELERATED     HEX: 00001000 ; inline
: PFD_SUPPORT_DIRECTDRAW      HEX: 00002000 ; inline

! PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only
: PFD_DEPTH_DONTCARE          HEX: 20000000 ; inline
: PFD_DOUBLEBUFFER_DONTCARE   HEX: 40000000 ; inline
: PFD_STEREO_DONTCARE         HEX: 80000000 ; inline

! pixel types
: PFD_TYPE_RGBA        0 ; inline
: PFD_TYPE_COLORINDEX  1 ; inline
 
! layer types
: PFD_MAIN_PLANE       0 ; inline
: PFD_OVERLAY_PLANE    1 ; inline
: PFD_UNDERLAY_PLANE   -1 ; inline

: LPD_TYPE_RGBA        0 ; inline
: LPD_TYPE_COLORINDEX  1 ; inline

! wglSwapLayerBuffers flags
: WGL_SWAP_MAIN_PLANE     HEX: 00000001 ; inline
: WGL_SWAP_OVERLAY1       HEX: 00000002 ; inline
: WGL_SWAP_OVERLAY2       HEX: 00000004 ; inline
: WGL_SWAP_OVERLAY3       HEX: 00000008 ; inline
: WGL_SWAP_OVERLAY4       HEX: 00000010 ; inline
: WGL_SWAP_OVERLAY5       HEX: 00000020 ; inline
: WGL_SWAP_OVERLAY6       HEX: 00000040 ; inline
: WGL_SWAP_OVERLAY7       HEX: 00000080 ; inline
: WGL_SWAP_OVERLAY8       HEX: 00000100 ; inline
: WGL_SWAP_OVERLAY9       HEX: 00000200 ; inline
: WGL_SWAP_OVERLAY10      HEX: 00000400 ; inline
: WGL_SWAP_OVERLAY11      HEX: 00000800 ; inline
: WGL_SWAP_OVERLAY12      HEX: 00001000 ; inline
: WGL_SWAP_OVERLAY13      HEX: 00002000 ; inline
: WGL_SWAP_OVERLAY14      HEX: 00004000 ; inline
: WGL_SWAP_OVERLAY15      HEX: 00008000 ; inline
: WGL_SWAP_UNDERLAY1      HEX: 00010000 ; inline
: WGL_SWAP_UNDERLAY2      HEX: 00020000 ; inline
: WGL_SWAP_UNDERLAY3      HEX: 00040000 ; inline
: WGL_SWAP_UNDERLAY4      HEX: 00080000 ; inline
: WGL_SWAP_UNDERLAY5      HEX: 00100000 ; inline
: WGL_SWAP_UNDERLAY6      HEX: 00200000 ; inline
: WGL_SWAP_UNDERLAY7      HEX: 00400000 ; inline
: WGL_SWAP_UNDERLAY8      HEX: 00800000 ; inline
: WGL_SWAP_UNDERLAY9      HEX: 01000000 ; inline
: WGL_SWAP_UNDERLAY10     HEX: 02000000 ; inline
: WGL_SWAP_UNDERLAY11     HEX: 04000000 ; inline
: WGL_SWAP_UNDERLAY12     HEX: 08000000 ; inline
: WGL_SWAP_UNDERLAY13     HEX: 10000000 ; inline
: WGL_SWAP_UNDERLAY14     HEX: 20000000 ; inline
: WGL_SWAP_UNDERLAY15     HEX: 40000000 ; inline



: pfd-dwFlags
    PFD_DRAW_TO_WINDOW PFD_SUPPORT_OPENGL bitor PFD_DOUBLEBUFFER bitor ;

! TODO: compare to http://www.nullterminator.net/opengl32.html
: make-pfd ( bits -- pfd )
    "PIXELFORMATDESCRIPTOR" <c-object>
    "PIXELFORMATDESCRIPTOR" c-size over set-PIXELFORMATDESCRIPTOR-nSize
    1 over set-PIXELFORMATDESCRIPTOR-nVersion
    pfd-dwFlags over set-PIXELFORMATDESCRIPTOR-dwFlags
    PFD_TYPE_RGBA over set-PIXELFORMATDESCRIPTOR-iPixelType
    [ set-PIXELFORMATDESCRIPTOR-cColorBits ] keep
    16 over set-PIXELFORMATDESCRIPTOR-cDepthBits
    PFD_MAIN_PLANE over set-PIXELFORMATDESCRIPTOR-dwLayerMask ;


LIBRARY: gl


! FUNCTION: int ReleaseDC ( HWND hWnd, HDC hDC ) ;
! FUNCTION: HDC ResetDC ( HDC hdc, DEVMODE* lpInitData ) ;
! FUNCTION: BOOL RestoreDC ( HDC hdc, int nSavedDC ) ;
! FUNCTION: int SaveDC( HDC hDC ) ;
! FUNCTION: HGDIOBJ SelectObject ( HDC hDC, HGDIOBJ hgdiobj ) ;

FUNCTION: HGLRC wglCreateContext ( HDC hDC ) ;
FUNCTION: BOOL wglDeleteContext ( HGLRC hRC ) ;
FUNCTION: BOOL wglMakeCurrent ( HDC hDC, HGLRC hglrc ) ;


