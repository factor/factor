USING: alien.c-types alien.syntax classes.struct
windows.directx windows.directx.d3d10 windows.directx.d3d10misc
windows.directx.d3dx10async windows.directx.dxgiformat
windows.types ;
IN: windows.directx.d3dx10tex

LIBRARY: d3dx10

CONSTANT: D3DX10_FILTER_NONE             0x00000001
CONSTANT: D3DX10_FILTER_POINT            0x00000002
CONSTANT: D3DX10_FILTER_LINEAR           0x00000003
CONSTANT: D3DX10_FILTER_TRIANGLE         0x00000004
CONSTANT: D3DX10_FILTER_BOX              0x00000005

CONSTANT: D3DX10_FILTER_MIRROR_U         0x00010000
CONSTANT: D3DX10_FILTER_MIRROR_V         0x00020000
CONSTANT: D3DX10_FILTER_MIRROR_W         0x00040000
CONSTANT: D3DX10_FILTER_MIRROR           0x00070000

CONSTANT: D3DX10_FILTER_DITHER           0x00080000
CONSTANT: D3DX10_FILTER_DITHER_DIFFUSION 0x00100000

CONSTANT: D3DX10_FILTER_SRGB_IN          0x00200000
CONSTANT: D3DX10_FILTER_SRGB_OUT         0x00400000
CONSTANT: D3DX10_FILTER_SRGB             0x00600000
TYPEDEF: int D3DX10_FILTER_FLAG

CONSTANT: D3DX10_NORMALMAP_MIRROR_U          0x00010000
CONSTANT: D3DX10_NORMALMAP_MIRROR_V          0x00020000
CONSTANT: D3DX10_NORMALMAP_MIRROR            0x00030000
CONSTANT: D3DX10_NORMALMAP_INVERTSIGN        0x00080000
CONSTANT: D3DX10_NORMALMAP_COMPUTE_OCCLUSION 0x00100000
TYPEDEF: int D3DX10_NORMALMAP_FLAG

CONSTANT: D3DX10_CHANNEL_RED        1
CONSTANT: D3DX10_CHANNEL_BLUE       2
CONSTANT: D3DX10_CHANNEL_GREEN      4
CONSTANT: D3DX10_CHANNEL_ALPHA      8
CONSTANT: D3DX10_CHANNEL_LUMINANCE  16
TYPEDEF: int D3DX10_CHANNEL_FLAG

CONSTANT: D3DX10_IFF_BMP          0
CONSTANT: D3DX10_IFF_JPG          1
CONSTANT: D3DX10_IFF_PNG          3
CONSTANT: D3DX10_IFF_DDS          4
CONSTANT: D3DX10_IFF_TIFF         10
CONSTANT: D3DX10_IFF_GIF          11
CONSTANT: D3DX10_IFF_WMP          12
CONSTANT: D3DX10_IFF_FORCE_DWORD  0x7fffffff
TYPEDEF: int D3DX10_IMAGE_FILE_FORMAT

CONSTANT: D3DX10_STF_USEINPUTBLOB 1
TYPEDEF: int D3DX10_SAVE_TEXTURE_FLAG

STRUCT: D3DX10_IMAGE_INFO
    { Width             UINT                     }
    { Height            UINT                     }
    { Depth             UINT                     }
    { ArraySize         UINT                     }
    { MipLevels         UINT                     }
    { MiscFlags         UINT                     }
    { Format            DXGI_FORMAT              }
    { ResourceDimension D3D10_RESOURCE_DIMENSION }
    { ImageFileFormat   D3DX10_IMAGE_FILE_FORMAT } ;

STRUCT: D3DX10_IMAGE_LOAD_INFO
    { Width          UINT               }
    { Height         UINT               }
    { Depth          UINT               }
    { FirstMipLevel  UINT               }
    { MipLevels      UINT               }
    { Usage          D3D10_USAGE        }
    { BindFlags      UINT               }
    { CpuAccessFlags UINT               }
    { MiscFlags      UINT               }
    { Format         DXGI_FORMAT        }
    { Filter         UINT               }
    { MipFilter      UINT               }
    { pSrcInfo       D3DX10_IMAGE_INFO* } ;

FUNCTION: HRESULT
    D3DX10GetImageInfoFromFileA (
        LPCSTR                    pSrcFile,
        ID3DX10ThreadPump*        pPump,
        D3DX10_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

FUNCTION: HRESULT
    D3DX10GetImageInfoFromFileW (
        LPCWSTR                   pSrcFile,
        ID3DX10ThreadPump*        pPump,
        D3DX10_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

ALIAS: D3DX10GetImageInfoFromFile D3DX10GetImageInfoFromFileW

FUNCTION: HRESULT
    D3DX10GetImageInfoFromResourceA (
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        ID3DX10ThreadPump*        pPump,
        D3DX10_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

FUNCTION: HRESULT
    D3DX10GetImageInfoFromResourceW (
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        ID3DX10ThreadPump*        pPump,
        D3DX10_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

ALIAS: D3DX10GetImageInfoFromResource D3DX10GetImageInfoFromResourceW

FUNCTION: HRESULT
    D3DX10GetImageInfoFromMemory (
        LPCVOID                   pSrcData,
        SIZE_T                    SrcDataSize,
        ID3DX10ThreadPump*        pPump,
        D3DX10_IMAGE_INFO*        pSrcInfo,
        HRESULT*                  pHResult )

FUNCTION: HRESULT
    D3DX10CreateShaderResourceViewFromFileA (
        ID3D10Device*               pDevice,
        LPCSTR                      pSrcFile,
        D3DX10_IMAGE_LOAD_INFO*     pLoadInfo,
        ID3DX10ThreadPump*          pPump,
        ID3D10ShaderResourceView**  ppShaderResourceView,
        HRESULT*                    pHResult )

FUNCTION: HRESULT
    D3DX10CreateShaderResourceViewFromFileW (
        ID3D10Device*               pDevice,
        LPCWSTR                     pSrcFile,
        D3DX10_IMAGE_LOAD_INFO*     pLoadInfo,
        ID3DX10ThreadPump*          pPump,
        ID3D10ShaderResourceView**  ppShaderResourceView,
        HRESULT*                    pHResult )

ALIAS: D3DX10CreateShaderResourceViewFromFile D3DX10CreateShaderResourceViewFromFileW

FUNCTION: HRESULT
    D3DX10CreateTextureFromFileA (
        ID3D10Device*               pDevice,
        LPCSTR                      pSrcFile,
        D3DX10_IMAGE_LOAD_INFO*     pLoadInfo,
        ID3DX10ThreadPump*          pPump,
        ID3D10Resource**            ppTexture,
        HRESULT*                    pHResult )

FUNCTION: HRESULT
    D3DX10CreateTextureFromFileW (
        ID3D10Device*               pDevice,
        LPCWSTR                     pSrcFile,
        D3DX10_IMAGE_LOAD_INFO*     pLoadInfo,
        ID3DX10ThreadPump*          pPump,
        ID3D10Resource**            ppTexture,
        HRESULT*                    pHResult )

ALIAS: D3DX10CreateTextureFromFile D3DX10CreateTextureFromFileW

FUNCTION: HRESULT
    D3DX10CreateShaderResourceViewFromResourceA (
        ID3D10Device*              pDevice,
        HMODULE                    hSrcModule,
        LPCSTR                     pSrcResource,
        D3DX10_IMAGE_LOAD_INFO*    pLoadInfo,
        ID3DX10ThreadPump*         pPump,
        ID3D10ShaderResourceView** ppShaderResourceView,
        HRESULT*                   pHResult )

FUNCTION: HRESULT
    D3DX10CreateShaderResourceViewFromResourceW (
        ID3D10Device*              pDevice,
        HMODULE                    hSrcModule,
        LPCWSTR                    pSrcResource,
        D3DX10_IMAGE_LOAD_INFO*    pLoadInfo,
        ID3DX10ThreadPump*         pPump,
        ID3D10ShaderResourceView** ppShaderResourceView,
        HRESULT*                   pHResult )

ALIAS: D3DX10CreateShaderResourceViewFromResource D3DX10CreateShaderResourceViewFromResourceW

FUNCTION: HRESULT
    D3DX10CreateTextureFromResourceA (
        ID3D10Device*            pDevice,
        HMODULE                  hSrcModule,
        LPCSTR                   pSrcResource,
        D3DX10_IMAGE_LOAD_INFO*  pLoadInfo,
        ID3DX10ThreadPump*       pPump,
        ID3D10Resource**         ppTexture,
        HRESULT*                 pHResult )

FUNCTION: HRESULT
    D3DX10CreateTextureFromResourceW (
        ID3D10Device*           pDevice,
        HMODULE                 hSrcModule,
        LPCWSTR                 pSrcResource,
        D3DX10_IMAGE_LOAD_INFO* pLoadInfo,
        ID3DX10ThreadPump*      pPump,
        ID3D10Resource**        ppTexture,
        HRESULT*                pHResult )

ALIAS: D3DX10CreateTextureFromResource D3DX10CreateTextureFromResourceW

FUNCTION: HRESULT
    D3DX10CreateShaderResourceViewFromMemory (
        ID3D10Device*              pDevice,
        LPCVOID                    pSrcData,
        SIZE_T                     SrcDataSize,
        D3DX10_IMAGE_LOAD_INFO*    pLoadInfo,
        ID3DX10ThreadPump*         pPump,
        ID3D10ShaderResourceView** ppShaderResourceView,
        HRESULT*                   pHResult )

FUNCTION: HRESULT
    D3DX10CreateTextureFromMemory (
        ID3D10Device*             pDevice,
        LPCVOID                   pSrcData,
        SIZE_T                    SrcDataSize,
        D3DX10_IMAGE_LOAD_INFO*   pLoadInfo,
        ID3DX10ThreadPump*        pPump,
        ID3D10Resource**          ppTexture,
        HRESULT*                  pHResult )

STRUCT: D3DX10_TEXTURE_LOAD_INFO
    { pSrcBox                    D3D10_BOX* }
    { pDstBox                    D3D10_BOX* }
    { SrcFirstMip                UINT       }
    { DstFirstMip                UINT       }
    { NumMips                    UINT       }
    { SrcFirstElement            UINT       }
    { DstFirstElement            UINT       }
    { NumElements                UINT       }
    { Filter                     UINT       }
    { MipFilter                  UINT       } ;

FUNCTION: HRESULT
    D3DX10LoadTextureFromTexture (
        ID3D10Resource*            pSrcTexture,
        D3DX10_TEXTURE_LOAD_INFO*  pLoadInfo,
        ID3D10Resource*            pDstTexture )

FUNCTION: HRESULT
    D3DX10FilterTexture (
        ID3D10Resource*           pTexture,
        UINT                      SrcLevel,
        UINT                      MipFilter )

FUNCTION: HRESULT
    D3DX10SaveTextureToFileA (
        ID3D10Resource*           pSrcTexture,
        D3DX10_IMAGE_FILE_FORMAT  DestFormat,
        LPCSTR                    pDestFile )

FUNCTION: HRESULT
    D3DX10SaveTextureToFileW (
        ID3D10Resource*           pSrcTexture,
        D3DX10_IMAGE_FILE_FORMAT  DestFormat,
        LPCWSTR                   pDestFile )

ALIAS: D3DX10SaveTextureToFile D3DX10SaveTextureToFileW

FUNCTION: HRESULT
    D3DX10SaveTextureToMemory (
        ID3D10Resource*            pSrcTexture,
        D3DX10_IMAGE_FILE_FORMAT   DestFormat,
        LPD3D10BLOB*               ppDestBuf,
        UINT                       Flags )

FUNCTION: HRESULT
    D3DX10ComputeNormalMap (
        ID3D10Texture2D* pSrcTexture,
        UINT             Flags,
        UINT             Channel,
        FLOAT            Amplitude,
        ID3D10Texture2D* pDestTexture )

FUNCTION: HRESULT
    D3DX10SHProjectCubeMap (
        UINT             Order,
        ID3D10Texture2D* pCubeMap,
        FLOAT*           pROut,
        FLOAT*           pGOut,
        FLOAT*           pBOut )
