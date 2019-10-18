USING: alien.syntax windows.types windows.directx.d3d9 windows.com.syntax
windows.com windows.directx windows.directx.d3dx9math windows.directx.d3d9types
classes.struct windows.gdi32 ;
IN: windows.directx.d3dx9core

LIBRARY: d3dx9

CONSTANT: D3DX_VERSION 0x0902
CONSTANT: D3DX_SDK_VERSION 42

FUNCTION: BOOL D3DXCheckVersion ( UINT D3DSdkVersion, UINT D3DXSdkVersion )
FUNCTION: BOOL D3DXDebugMute ( BOOL Mute )
FUNCTION: UINT D3DXGetDriverLevel ( LPDIRECT3DDEVICE9 pDevice )

C-TYPE: ID3DXBuffer
TYPEDEF: ID3DXBuffer* LPD3DXBUFFER

COM-INTERFACE: ID3DXBuffer IUnknown {8BA5FB08-5195-40e2-AC58-0D989C3A0102}
    LPVOID GetBufferPointer ( )
    DWORD GetBufferSize ( ) ;

CONSTANT: D3DXSPRITE_DONOTSAVESTATE               1
CONSTANT: D3DXSPRITE_DONOTMODIFY_RENDERSTATE      2
CONSTANT: D3DXSPRITE_OBJECTSPACE                  4
CONSTANT: D3DXSPRITE_BILLBOARD                    8
CONSTANT: D3DXSPRITE_ALPHABLEND                   16
CONSTANT: D3DXSPRITE_SORT_TEXTURE                 32
CONSTANT: D3DXSPRITE_SORT_DEPTH_FRONTTOBACK       64
CONSTANT: D3DXSPRITE_SORT_DEPTH_BACKTOFRONT       128
CONSTANT: D3DXSPRITE_DO_NOT_ADDREF_TEXTURE        256

C-TYPE: ID3DXSprite
TYPEDEF: ID3DXSprite* LPD3DXSPRITE

COM-INTERFACE: ID3DXSprite IUnknown {BA0B762D-7D28-43ec-B9DC-2F84443B0614}
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT GetTransform ( D3DXMATRIX* pTransform )
    HRESULT SetTransform ( D3DXMATRIX* pTransform )
    HRESULT SetWorldViewRH ( D3DXMATRIX* pWorld, D3DXMATRIX* pView )
    HRESULT SetWorldViewLH ( D3DXMATRIX* pWorld, D3DXMATRIX* pView )
    HRESULT Begin ( DWORD Flags )
    HRESULT Draw ( LPDIRECT3DTEXTURE9 pTexture, RECT* pSrcRect, D3DXVECTOR3* pCenter, D3DXVECTOR3* pPosition, D3DCOLOR Color )
    HRESULT Flush ( )
    HRESULT End ( )
    HRESULT OnLostDevice ( )
    HRESULT OnResetDevice ( ) ;

FUNCTION: HRESULT
    D3DXCreateSprite (
        LPDIRECT3DDEVICE9   pDevice,
        LPD3DXSPRITE*       ppSprite )

STRUCT: D3DXFONT_DESCA
    { Height          INT               }
    { Width           UINT              }
    { Weight          UINT              }
    { MipLevels       UINT              }
    { Italic          BOOL              }
    { CharSet         BYTE              }
    { OutputPrecision BYTE              }
    { Quality         BYTE              }
    { PitchAndFamily  BYTE              }
    { FaceName        CHAR[LF_FACESIZE] } ;
TYPEDEF: D3DXFONT_DESCA* LPD3DXFONT_DESCA

STRUCT: D3DXFONT_DESCW
    { Height          INT                }
    { Width           UINT               }
    { Weight          UINT               }
    { MipLevels       UINT               }
    { Italic          BOOL               }
    { CharSet         BYTE               }
    { OutputPrecision BYTE               }
    { Quality         BYTE               }
    { PitchAndFamily  BYTE               }
    { FaceName        WCHAR[LF_FACESIZE] } ;
TYPEDEF: D3DXFONT_DESCW* LPD3DXFONT_DESCW

TYPEDEF: D3DXFONT_DESCW D3DXFONT_DESC
TYPEDEF: LPD3DXFONT_DESCW LPD3DXFONT_DESC

C-TYPE: ID3DXFont
TYPEDEF: ID3DXFont* LPD3DXFONT
C-TYPE: TEXTMETRICA
C-TYPE: TEXTMETRICW

COM-INTERFACE: ID3DXFont IUnknown {D79DBB70-5F21-4d36-BBC2-FF525C213CDC}
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT GetDescA ( D3DXFONT_DESCA* pDesc )
    HRESULT GetDescW ( D3DXFONT_DESCW* pDesc )
    BOOL GetTextMetricsA ( TEXTMETRICA* pTextMetrics )
    BOOL GetTextMetricsW ( TEXTMETRICW* pTextMetrics )
    HDC GetDC ( )
    HRESULT GetGlyphData ( UINT Glyph, LPDIRECT3DTEXTURE9* ppTexture, RECT* pBlackBox, POINT* pCellInc )
    HRESULT PreloadCharacters ( UINT First, UINT Last )
    HRESULT PreloadGlyphs ( UINT First, UINT Last )
    HRESULT PreloadTextA ( LPCSTR pString, INT Count )
    HRESULT PreloadTextW ( LPCWSTR pString, INT Count )
    INT DrawTextA ( LPD3DXSPRITE pSprite, LPCSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color )
    INT DrawTextW ( LPD3DXSPRITE pSprite, LPCWSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color )
    HRESULT OnLostDevice ( )
    HRESULT OnResetDevice ( ) ;

FUNCTION: HRESULT
    D3DXCreateFontA (
        LPDIRECT3DDEVICE9       pDevice,
        INT                     Height,
        UINT                    Width,
        UINT                    Weight,
        UINT                    MipLevels,
        BOOL                    Italic,
        DWORD                   CharSet,
        DWORD                   OutputPrecision,
        DWORD                   Quality,
        DWORD                   PitchAndFamily,
        LPCSTR                  pFaceName,
        LPD3DXFONT*             ppFont )

FUNCTION: HRESULT
    D3DXCreateFontW (
        LPDIRECT3DDEVICE9       pDevice,
        INT                     Height,
        UINT                    Width,
        UINT                    Weight,
        UINT                    MipLevels,
        BOOL                    Italic,
        DWORD                   CharSet,
        DWORD                   OutputPrecision,
        DWORD                   Quality,
        DWORD                   PitchAndFamily,
        LPCWSTR                 pFaceName,
        LPD3DXFONT*             ppFont )

ALIAS: D3DXCreateFont D3DXCreateFontW

FUNCTION: HRESULT
    D3DXCreateFontIndirectA (
        LPDIRECT3DDEVICE9       pDevice,
        D3DXFONT_DESCA*         pDesc,
        LPD3DXFONT*             ppFont )

FUNCTION: HRESULT
    D3DXCreateFontIndirectW (
        LPDIRECT3DDEVICE9       pDevice,
        D3DXFONT_DESCW*         pDesc,
        LPD3DXFONT*             ppFont )

ALIAS: D3DXCreateFontIndirect D3DXCreateFontIndirectW

STRUCT: D3DXRTS_DESC
    { Width                        UINT      }
    { Height                       UINT      }
    { Format                       D3DFORMAT }
    { DepthStencil                 BOOL      }
    { DepthStencilFormat           D3DFORMAT } ;
TYPEDEF: D3DXRTS_DESC* LPD3DXRTS_DESC

C-TYPE: ID3DXRenderToSurface
TYPEDEF: ID3DXRenderToSurface* LPD3DXRENDERTOSURFACE

COM-INTERFACE: ID3DXRenderToSurface IUnknown {6985F346-2C3D-43b3-BE8B-DAAE8A03D894}
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT GetDesc ( D3DXRTS_DESC* pDesc )
    HRESULT BeginScene ( LPDIRECT3DSURFACE9 pSurface, D3DVIEWPORT9* pViewport )
    HRESULT EndScene ( DWORD MipFilter )
    HRESULT OnLostDevice ( )
    HRESULT OnResetDevice ( ) ;

FUNCTION: HRESULT
    D3DXCreateRenderToSurface (
        LPDIRECT3DDEVICE9       pDevice,
        UINT                    Width,
        UINT                    Height,
        D3DFORMAT               Format,
        BOOL                    DepthStencil,
        D3DFORMAT               DepthStencilFormat,
        LPD3DXRENDERTOSURFACE*  ppRenderToSurface )

STRUCT: D3DXRTE_DESC
    { Size                 UINT      }
    { MipLevels            UINT      }
    { Format               D3DFORMAT }
    { DepthStencil         BOOL      }
    { DepthStencilFormat   D3DFORMAT } ;
TYPEDEF: D3DXRTE_DESC* LPD3DXRTE_DESC

C-TYPE: ID3DXRenderToEnvMap
TYPEDEF: ID3DXRenderToEnvMap* LPD3DXRenderToEnvMap

COM-INTERFACE: ID3DXRenderToEnvMap IUnknown {313F1B4B-C7B0-4fa2-9D9D-8D380B64385E}
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT GetDesc ( D3DXRTE_DESC* pDesc )
    HRESULT BeginCube ( LPDIRECT3DCUBETEXTURE9 pCubeTex )
    HRESULT BeginSphere ( LPDIRECT3DTEXTURE9 pTex )
    HRESULT BeginHemisphere ( LPDIRECT3DTEXTURE9 pTexZPos, LPDIRECT3DTEXTURE9 pTexZNeg )
    HRESULT BeginParabolic ( LPDIRECT3DTEXTURE9 pTexZPos, LPDIRECT3DTEXTURE9 pTexZNeg )
    HRESULT Face ( D3DCUBEMAP_FACES Face, DWORD MipFilter )
    HRESULT End ( DWORD MipFilter )
    HRESULT OnLostDevice ( )
    HRESULT OnResetDevice ( ) ;

FUNCTION: HRESULT
    D3DXCreateRenderToEnvMap (
        LPDIRECT3DDEVICE9       pDevice,
        UINT                    Size,
        UINT                    MipLevels,
        D3DFORMAT               Format,
        BOOL                    DepthStencil,
        D3DFORMAT               DepthStencilFormat,
        LPD3DXRenderToEnvMap*   ppRenderToEnvMap )

C-TYPE: ID3DXLine
TYPEDEF: ID3DXLine* LPD3DXLINE
COM-INTERFACE: ID3DXLine IUnknown {D379BA7F-9042-4ac4-9F5E-58192A4C6BD8}
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT Begin ( )
    HRESULT Draw ( D3DXVECTOR2* pVertexList, DWORD dwVertexListCount, D3DCOLOR Color )
    HRESULT DrawTransform ( D3DXVECTOR3* pVertexList,
        DWORD dwVertexListCount, D3DXMATRIX* pTransform,
        D3DCOLOR Color )
    HRESULT SetPattern ( DWORD dwPattern )
    DWORD GetPattern ( )
    HRESULT SetPatternScale ( FLOAT fPatternScale )
    FLOAT GetPatternScale ( )
    HRESULT SetWidth ( FLOAT fWidth )
    FLOAT GetWidth ( )
    HRESULT SetAntialias ( BOOL bAntialias )
    BOOL GetAntialias ( )
    HRESULT SetGLLines ( BOOL bGLLines )
    BOOL GetGLLines ( )
    HRESULT End ( )
    HRESULT OnLostDevice ( )
    HRESULT OnResetDevice ( ) ;

FUNCTION: HRESULT
    D3DXCreateLine (
        LPDIRECT3DDEVICE9   pDevice,
        LPD3DXLINE*         ppLine )
