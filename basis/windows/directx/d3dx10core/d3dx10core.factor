USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx windows.directx.d3d10
windows.directx.d3d10misc windows.directx.d3dx10math
windows.directx.dxgi windows.gdi32 windows.types ;
IN: windows.directx.d3dx10core

LIBRARY: d3dx10

CONSTANT: D3DX10_SDK_VERSION 42

FUNCTION: HRESULT D3DX10CreateDevice (
    IDXGIAdapter*     pAdapter,
    D3D10_DRIVER_TYPE DriverType,
    HMODULE           Software,
    UINT              Flags,
    ID3D10Device**    ppDevice )

FUNCTION: HRESULT D3DX10CreateDeviceAndSwapChain (
    IDXGIAdapter*         pAdapter,
    D3D10_DRIVER_TYPE     DriverType,
    HMODULE               Software,
    UINT                  Flags,
    DXGI_SWAP_CHAIN_DESC* pSwapChainDesc,
    IDXGISwapChain**      ppSwapChain,
    ID3D10Device**        ppDevice )

C-TYPE: ID3D10Device1

FUNCTION: HRESULT D3DX10GetFeatureLevel1 ( ID3D10Device* pDevice, ID3D10Device1** ppDevice1 )

FUNCTION: HRESULT D3DX10CheckVersion ( UINT D3DSdkVersion, UINT D3DX10SdkVersion )

CONSTANT: D3DX10_SPRITE_SORT_TEXTURE              0x01
CONSTANT: D3DX10_SPRITE_SORT_DEPTH_BACK_TO_FRONT  0x02
CONSTANT: D3DX10_SPRITE_SORT_DEPTH_FRONT_TO_BACK  0x04
CONSTANT: D3DX10_SPRITE_SAVE_STATE                0x08
CONSTANT: D3DX10_SPRITE_ADDREF_TEXTURES           0x10
TYPEDEF: int D3DX10_SPRITE_FLAG

STRUCT: D3DX10_SPRITE
    { matWorld            D3DXMATRIX                }
    { TexCoord            D3DXVECTOR2               }
    { TexSize             D3DXVECTOR2               }
    { ColorModulate       D3DXCOLOR                 }
    { pTexture            ID3D10ShaderResourceView* }
    { TextureIndex        UINT                      } ;

C-TYPE: ID3DX10Sprite
TYPEDEF: ID3DX10Sprite* LPD3DX10SPRITE

COM-INTERFACE: ID3DX10Sprite IUnknown {BA0B762D-8D28-43ec-B9DC-2F84443B0614}
    HRESULT Begin ( UINT flags )
    HRESULT DrawSpritesBuffered ( D3DX10_SPRITE* pSprites, UINT cSprites )
    HRESULT Flush ( )
    HRESULT DrawSpritesImmediate ( D3DX10_SPRITE* pSprites, UINT cSprites, UINT cbSprite, UINT flags )
    HRESULT End ( )
    HRESULT GetViewTransform ( D3DXMATRIX* pViewTransform )
    HRESULT SetViewTransform ( D3DXMATRIX* pViewTransform )
    HRESULT GetProjectionTransform ( D3DXMATRIX* pProjectionTransform )
    HRESULT SetProjectionTransform ( D3DXMATRIX* pProjectionTransform )
    HRESULT GetDevice ( ID3D10Device** ppDevice ) ;

FUNCTION: HRESULT
    D3DX10CreateSprite (
        ID3D10Device*         pDevice,
        UINT                  cDeviceBufferSize,
        LPD3DX10SPRITE*       ppSprite )

COM-INTERFACE: ID3DX10DataLoader f {00000000-0000-0000-0000-000000000000}
    HRESULT Load ( )
    HRESULT Decompress ( void** ppData, SIZE_T* pcBytes )
    HRESULT Destroy ( ) ;

COM-INTERFACE: ID3DX10DataProcessor f {00000000-0000-0000-0000-000000000000}
    HRESULT Process ( void* pData, SIZE_T cBytes )
    HRESULT CreateDeviceObject ( void** ppDataObject )
    HRESULT Destroy ( ) ;

COM-INTERFACE: ID3DX10ThreadPump IUnknown {C93FECFA-6967-478a-ABBC-402D90621FCB}
    HRESULT AddWorkItem ( ID3DX10DataLoader* pDataLoader, ID3DX10DataProcessor* pDataProcessor, HRESULT* pHResult, void** ppDeviceObject )
    UINT GetWorkItemCount ( )
    HRESULT WaitForAllItems ( )
    HRESULT ProcessDeviceWorkItems ( UINT iWorkItemCount )
    HRESULT PurgeAllItems ( )
    HRESULT GetQueueStatus ( UINT* pIoQueue, UINT* pProcessQueue, UINT* pDeviceQueue ) ;

FUNCTION: HRESULT D3DX10CreateThreadPump ( UINT cIoThreads, UINT cProcThreads, ID3DX10ThreadPump** ppThreadPump )

STRUCT: D3DX10_FONT_DESCA
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
TYPEDEF: D3DX10_FONT_DESCA* LPD3DX10_FONT_DESCA

STRUCT: D3DX10_FONT_DESCW
    { Height INT }
    { Width UINT }
    { Weight UINT }
    { MipLevels UINT }
    { Italic BOOL }
    { CharSet BYTE }
    { OutputPrecision BYTE }
    { Quality BYTE }
    { PitchAndFamily BYTE }
    { FaceName WCHAR[LF_FACESIZE] } ;
TYPEDEF: D3DX10_FONT_DESCW* LPD3DX10_FONT_DESCW

TYPEDEF: D3DX10_FONT_DESCW D3DX10_FONT_DESC
TYPEDEF: LPD3DX10_FONT_DESCW LPD3DX10_FONT_DESC

C-TYPE: TEXTMETRICA
C-TYPE: TEXTMETRICW

COM-INTERFACE: ID3DX10Font IUnknown {D79DBB70-5F21-4d36-BBC2-FF525C213CDC}
    HRESULT GetDevice ( ID3D10Device** ppDevice )
    HRESULT GetDescA ( D3DX10_FONT_DESCA* pDesc )
    HRESULT GetDescW ( D3DX10_FONT_DESCW* pDesc )
    BOOL GetTextMetricsA ( TEXTMETRICA* pTextMetrics )
    BOOL GetTextMetricsW ( TEXTMETRICW* pTextMetrics )
    HDC GetDC ( )
    HRESULT GetGlyphData ( UINT Glyph, ID3D10ShaderResourceView** ppTexture, RECT* pBlackBox, POINT* pCellInc )
    HRESULT PreloadCharacters ( UINT First, UINT Last )
    HRESULT PreloadGlyphs ( UINT First, UINT Last )
    HRESULT PreloadTextA ( LPCSTR pString, INT Count )
    HRESULT PreloadTextW ( LPCWSTR pString, INT Count )
    INT DrawTextA ( LPD3DX10SPRITE pSprite, LPCSTR pString, INT Count, LPRECT pRect, UINT Format, D3DXCOLOR Color )
    INT DrawTextW ( LPD3DX10SPRITE pSprite, LPCWSTR pString, INT Count, LPRECT pRect, UINT Format, D3DXCOLOR Color ) ;
TYPEDEF: ID3DX10Font* LPD3DX10FONT

FUNCTION: HRESULT
    D3DX10CreateFontA (
        ID3D10Device*           pDevice,
        INT                     Height,
        UINT                    Width,
        UINT                    Weight,
        UINT                    MipLevels,
        BOOL                    Italic,
        UINT                    CharSet,
        UINT                    OutputPrecision,
        UINT                    Quality,
        UINT                    PitchAndFamily,
        LPCSTR                  pFaceName,
        LPD3DX10FONT*           ppFont )

FUNCTION: HRESULT
    D3DX10CreateFontW (
        ID3D10Device*           pDevice,
        INT                     Height,
        UINT                    Width,
        UINT                    Weight,
        UINT                    MipLevels,
        BOOL                    Italic,
        UINT                    CharSet,
        UINT                    OutputPrecision,
        UINT                    Quality,
        UINT                    PitchAndFamily,
        LPCWSTR                 pFaceName,
        LPD3DX10FONT*           ppFont )

ALIAS: D3DX10CreateFont D3DX10CreateFontW

FUNCTION: HRESULT
    D3DX10CreateFontIndirectA (
        ID3D10Device*             pDevice,
        D3DX10_FONT_DESCA*        pDesc,
        LPD3DX10FONT*             ppFont )

FUNCTION: HRESULT
    D3DX10CreateFontIndirectW (
        ID3D10Device*             pDevice,
        D3DX10_FONT_DESCW*        pDesc,
        LPD3DX10FONT*             ppFont )

ALIAS: D3DX10CreateFontIndirect D3DX10CreateFontIndirectW

FUNCTION: HRESULT D3DX10UnsetAllDeviceObjects ( ID3D10Device* pDevice )

CONSTANT: D3DERR_INVALIDCALL     0x8876086C
CONSTANT: D3DERR_WASSTILLDRAWING 0x8876021C
