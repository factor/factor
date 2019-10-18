USING: alien.c-types alien.syntax classes.struct
windows.directx windows.directx.d3d10misc windows.directx.d3d11
windows.directx.d3dx11core windows.directx.dxgiformat windows.types ;
IN: windows.directx.d3dx11tex

LIBRARY: d3dx11

CONSTANT: D3DX11_FILTER_NONE             0x00000001
CONSTANT: D3DX11_FILTER_POINT            0x00000002
CONSTANT: D3DX11_FILTER_LINEAR           0x00000003
CONSTANT: D3DX11_FILTER_TRIANGLE         0x00000004
CONSTANT: D3DX11_FILTER_BOX              0x00000005

CONSTANT: D3DX11_FILTER_MIRROR_U         0x00010000
CONSTANT: D3DX11_FILTER_MIRROR_V         0x00020000
CONSTANT: D3DX11_FILTER_MIRROR_W         0x00040000
CONSTANT: D3DX11_FILTER_MIRROR           0x00070000

CONSTANT: D3DX11_FILTER_DITHER           0x00080000
CONSTANT: D3DX11_FILTER_DITHER_DIFFUSION 0x00100000

CONSTANT: D3DX11_FILTER_SRGB_IN          0x00200000
CONSTANT: D3DX11_FILTER_SRGB_OUT         0x00400000
CONSTANT: D3DX11_FILTER_SRGB             0x00600000
TYPEDEF: int D3DX11_FILTER_FLAG

CONSTANT: D3DX11_NORMALMAP_MIRROR_U          0x00010000
CONSTANT: D3DX11_NORMALMAP_MIRROR_V          0x00020000
CONSTANT: D3DX11_NORMALMAP_MIRROR            0x00030000
CONSTANT: D3DX11_NORMALMAP_INVERTSIGN        0x00080000
CONSTANT: D3DX11_NORMALMAP_COMPUTE_OCCLUSION 0x00100000
TYPEDEF: int D3DX11_NORMALMAP_FLAG

CONSTANT: D3DX11_CHANNEL_RED        1
CONSTANT: D3DX11_CHANNEL_BLUE       2
CONSTANT: D3DX11_CHANNEL_GREEN      4
CONSTANT: D3DX11_CHANNEL_ALPHA      8
CONSTANT: D3DX11_CHANNEL_LUMINANCE  16
TYPEDEF: int D3DX11_CHANNEL_FLAG

CONSTANT: D3DX11_IFF_BMP          0
CONSTANT: D3DX11_IFF_JPG          1
CONSTANT: D3DX11_IFF_PNG          3
CONSTANT: D3DX11_IFF_DDS          4
CONSTANT: D3DX11_IFF_TIFF         10
CONSTANT: D3DX11_IFF_GIF          11
CONSTANT: D3DX11_IFF_WMP          12
CONSTANT: D3DX11_IFF_FORCE_DWORD  0x7fffffff
TYPEDEF: int D3DX11_IMAGE_FILE_FORMAT

CONSTANT: D3DX11_STF_USEINPUTBLOB 1
TYPEDEF: int D3DX11_SAVE_TEXTURE_FLAG

STRUCT: D3DX11_IMAGE_INFO
    { Width             UINT                     }
    { Height            UINT                     }
    { Depth             UINT                     }
    { ArraySize         UINT                     }
    { MipLevels         UINT                     }
    { MiscFlags         UINT                     }
    { Format            DXGI_FORMAT              }
    { ResourceDimension D3D11_RESOURCE_DIMENSION }
    { ImageFileFormat   D3DX11_IMAGE_FILE_FORMAT } ;

STRUCT: D3DX11_IMAGE_LOAD_INFO
    { Width          UINT               }
    { Height         UINT               }
    { Depth          UINT               }
    { FirstMipLevel  UINT               }
    { MipLevels      UINT               }
    { Usage          D3D11_USAGE        }
    { BindFlags      UINT               }
    { CpuAccessFlags UINT               }
    { MiscFlags      UINT               }
    { Format         DXGI_FORMAT        }
    { Filter         UINT               }
    { MipFilter      UINT               }
    { pSrcInfo       D3DX11_IMAGE_INFO* } ;

FUNCTION: HRESULT
    D3DX11GetImageInfoFromFileA (
        LPCSTR                    pSrcFile,
        ID3DX11ThreadPump*        pPump,
        D3DX11_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

FUNCTION: HRESULT
    D3DX11GetImageInfoFromFileW (
        LPCWSTR                   pSrcFile,
        ID3DX11ThreadPump*        pPump,
        D3DX11_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

ALIAS: D3DX11GetImageInfoFromFile D3DX11GetImageInfoFromFileW

FUNCTION: HRESULT
    D3DX11GetImageInfoFromResourceA (
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        ID3DX11ThreadPump*        pPump,
        D3DX11_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

FUNCTION: HRESULT
    D3DX11GetImageInfoFromResourceW (
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        ID3DX11ThreadPump*        pPump,
        D3DX11_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

ALIAS: D3DX11GetImageInfoFromResource D3DX11GetImageInfoFromResourceW

FUNCTION: HRESULT
    D3DX11GetImageInfoFromMemory (
        LPCVOID                   pSrcData,
        SIZE_T                    SrcDataSize,
        ID3DX11ThreadPump*        pPump,
        D3DX11_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

FUNCTION: HRESULT
    D3DX11CreateShaderResourceViewFromFileA (
        ID3D11Device*               pDevice,
        LPCSTR                      pSrcFile,
        D3DX11_IMAGE_LOAD_INFO*     pLoadInfo,
        ID3DX11ThreadPump*          pPump,
        ID3D11ShaderResourceView**  ppShaderResourceView,
        HRESULT*                    pHResult )

FUNCTION: HRESULT
    D3DX11CreateShaderResourceViewFromFileW (
        ID3D11Device*               pDevice,
        LPCWSTR                     pSrcFile,
        D3DX11_IMAGE_LOAD_INFO*     pLoadInfo,
        ID3DX11ThreadPump*          pPump,
        ID3D11ShaderResourceView**  ppShaderResourceView,
        HRESULT*                    pHResult )

ALIAS: D3DX11CreateShaderResourceViewFromFile D3DX11CreateShaderResourceViewFromFileW

FUNCTION: HRESULT
    D3DX11CreateTextureFromFileA (
        ID3D11Device*               pDevice,
        LPCSTR                      pSrcFile,
        D3DX11_IMAGE_LOAD_INFO*     pLoadInfo,
        ID3DX11ThreadPump*          pPump,
        ID3D11Resource**            ppTexture,
        HRESULT*                    pHResult )

FUNCTION: HRESULT
    D3DX11CreateTextureFromFileW (
        ID3D11Device*               pDevice,
        LPCWSTR                     pSrcFile,
        D3DX11_IMAGE_LOAD_INFO*     pLoadInfo,
        ID3DX11ThreadPump*          pPump,
        ID3D11Resource**            ppTexture,
        HRESULT*                    pHResult )

ALIAS: D3DX11CreateTextureFromFile D3DX11CreateTextureFromFileW

FUNCTION: HRESULT
    D3DX11CreateShaderResourceViewFromResourceA (
        ID3D11Device*              pDevice,
        HMODULE                    hSrcModule,
        LPCSTR                     pSrcResource,
        D3DX11_IMAGE_LOAD_INFO*    pLoadInfo,
        ID3DX11ThreadPump*         pPump,
        ID3D11ShaderResourceView** ppShaderResourceView,
        HRESULT*                   pHResult )

FUNCTION: HRESULT
    D3DX11CreateShaderResourceViewFromResourceW (
        ID3D11Device*              pDevice,
        HMODULE                    hSrcModule,
        LPCWSTR                    pSrcResource,
        D3DX11_IMAGE_LOAD_INFO*    pLoadInfo,
        ID3DX11ThreadPump*         pPump,
        ID3D11ShaderResourceView** ppShaderResourceView,
        HRESULT*                   pHResult )

ALIAS: D3DX11CreateShaderResourceViewFromResource D3DX11CreateShaderResourceViewFromResourceW

FUNCTION: HRESULT
    D3DX11CreateTextureFromResourceA (
        ID3D11Device*            pDevice,
        HMODULE                  hSrcModule,
        LPCSTR                   pSrcResource,
        D3DX11_IMAGE_LOAD_INFO*  pLoadInfo,
        ID3DX11ThreadPump*       pPump,
        ID3D11Resource**         ppTexture,
        HRESULT*                 pHResult )

FUNCTION: HRESULT
    D3DX11CreateTextureFromResourceW (
        ID3D11Device*           pDevice,
        HMODULE                 hSrcModule,
        LPCWSTR                 pSrcResource,
        D3DX11_IMAGE_LOAD_INFO* pLoadInfo,
        ID3DX11ThreadPump*      pPump,
        ID3D11Resource**        ppTexture,
        HRESULT*                pHResult )

ALIAS: D3DX11CreateTextureFromResource D3DX11CreateTextureFromResourceW

FUNCTION: HRESULT
    D3DX11CreateShaderResourceViewFromMemory (
        ID3D11Device*              pDevice,
        LPCVOID                    pSrcData,
        SIZE_T                     SrcDataSize,
        D3DX11_IMAGE_LOAD_INFO*    pLoadInfo,
        ID3DX11ThreadPump*         pPump,
        ID3D11ShaderResourceView** ppShaderResourceView,
        HRESULT*                   pHResult )

FUNCTION: HRESULT
    D3DX11CreateTextureFromMemory (
        ID3D11Device*             pDevice,
        LPCVOID                   pSrcData,
        SIZE_T                    SrcDataSize,
        D3DX11_IMAGE_LOAD_INFO*   pLoadInfo,
        ID3DX11ThreadPump*        pPump,
        ID3D11Resource**          ppTexture,
        HRESULT*                  pHResult )

STRUCT: D3DX11_TEXTURE_LOAD_INFO
    { pSrcBox         D3D11_BOX* }
    { pDstBox         D3D11_BOX* }
    { SrcFirstMip     UINT       }
    { DstFirstMip     UINT       }
    { NumMips         UINT       }
    { SrcFirstElement UINT       }
    { DstFirstElement UINT       }
    { NumElements     UINT       }
    { Filter          UINT       }
    { MipFilter       UINT       } ;

FUNCTION: HRESULT
    D3DX11LoadTextureFromTexture (
        ID3D11DeviceContext*       pContext,
        ID3D11Resource*            pSrcTexture,
        D3DX11_TEXTURE_LOAD_INFO*  pLoadInfo,
        ID3D11Resource*            pDstTexture )

FUNCTION: HRESULT
    D3DX11FilterTexture (
        ID3D11DeviceContext*      pContext,
        ID3D11Resource*           pTexture,
        UINT                      SrcLevel,
        UINT                      MipFilter )

FUNCTION: HRESULT
    D3DX11SaveTextureToFileA (
        ID3D11DeviceContext*      pContext,
        ID3D11Resource*           pSrcTexture,
        D3DX11_IMAGE_FILE_FORMAT  DestFormat,
        LPCSTR                    pDestFile )

FUNCTION: HRESULT
    D3DX11SaveTextureToFileW (
        ID3D11DeviceContext*      pContext,
        ID3D11Resource*           pSrcTexture,
        D3DX11_IMAGE_FILE_FORMAT  DestFormat,
        LPCWSTR                   pDestFile )

ALIAS: D3DX11SaveTextureToFile D3DX11SaveTextureToFileW

FUNCTION: HRESULT
    D3DX11SaveTextureToMemory (
        ID3D11DeviceContext*       pContext,
        ID3D11Resource*            pSrcTexture,
        D3DX11_IMAGE_FILE_FORMAT   DestFormat,
        ID3D10Blob**               ppDestBuf,
        UINT                       Flags )

FUNCTION: HRESULT
    D3DX11ComputeNormalMap (
        ID3D11DeviceContext*      pContext,
        ID3D11Texture2D*          pSrcTexture,
        UINT                      Flags,
        UINT                      Channel,
        FLOAT                     Amplitude,
        ID3D11Texture2D*          pDestTexture )

FUNCTION: HRESULT
    D3DX11SHProjectCubeMap (
        ID3D11DeviceContext* pContext,
        UINT                 Order,
        ID3D11Texture2D*     pCubeMap,
        FLOAT*               pROut,
        FLOAT*               pGOut,
        FLOAT*               pBOut )
