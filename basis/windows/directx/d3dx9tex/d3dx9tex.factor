USING: alien.c-types alien.syntax classes.struct math
windows.directx windows.directx.d3d9 windows.directx.d3d9types
windows.directx.d3dx9core windows.directx.d3dx9shader
windows.types ;
IN: windows.directx.d3dx9tex

LIBRARY: d3dx9

: D3DX_FILTER_NONE             ( -- n ) 1 0 shift ; inline
: D3DX_FILTER_POINT            ( -- n ) 2 0 shift ; inline
: D3DX_FILTER_LINEAR           ( -- n ) 3 0 shift ; inline
: D3DX_FILTER_TRIANGLE         ( -- n ) 4 0 shift ; inline
: D3DX_FILTER_BOX              ( -- n ) 5 0 shift ; inline

: D3DX_FILTER_MIRROR_U         ( -- n ) 1 16 shift ; inline
: D3DX_FILTER_MIRROR_V         ( -- n ) 2 16 shift ; inline
: D3DX_FILTER_MIRROR_W         ( -- n ) 4 16 shift ; inline
: D3DX_FILTER_MIRROR           ( -- n ) 7 16 shift ; inline

: D3DX_FILTER_DITHER           ( -- n ) 1 19 shift ; inline
: D3DX_FILTER_DITHER_DIFFUSION ( -- n ) 2 19 shift ; inline

: D3DX_FILTER_SRGB_IN          ( -- n ) 1 21 shift ; inline
: D3DX_FILTER_SRGB_OUT         ( -- n ) 2 21 shift ; inline
: D3DX_FILTER_SRGB             ( -- n ) 3 21 shift ; inline

CONSTANT: D3DX_SKIP_DDS_MIP_LEVELS_MASK   0x1F
CONSTANT: D3DX_SKIP_DDS_MIP_LEVELS_SHIFT  26

: D3DX_NORMALMAP_MIRROR_U     ( -- n ) 1 16 shift ; inline
: D3DX_NORMALMAP_MIRROR_V     ( -- n ) 2 16 shift ; inline
: D3DX_NORMALMAP_MIRROR       ( -- n ) 3 16 shift ; inline
: D3DX_NORMALMAP_INVERTSIGN   ( -- n ) 8 16 shift ; inline
: D3DX_NORMALMAP_COMPUTE_OCCLUSION ( -- n ) 16 16 shift ; inline

: D3DX_CHANNEL_RED            ( -- n ) 1 0 shift ; inline
: D3DX_CHANNEL_BLUE           ( -- n ) 1 1 shift ; inline
: D3DX_CHANNEL_GREEN          ( -- n ) 1 2 shift ; inline
: D3DX_CHANNEL_ALPHA          ( -- n ) 1 3 shift ; inline
: D3DX_CHANNEL_LUMINANCE      ( -- n ) 1 4 shift ; inline

CONSTANT: D3DXIFF_BMP         0
CONSTANT: D3DXIFF_JPG         1
CONSTANT: D3DXIFF_TGA         2
CONSTANT: D3DXIFF_PNG         3
CONSTANT: D3DXIFF_DDS         4
CONSTANT: D3DXIFF_PPM         5
CONSTANT: D3DXIFF_DIB         6
CONSTANT: D3DXIFF_HDR         7
CONSTANT: D3DXIFF_PFM         8
CONSTANT: D3DXIFF_FORCE_DWORD 0x7fffffff
TYPEDEF: int D3DXIMAGE_FILEFORMAT

TYPEDEF: void* LPD3DXFILL2D
TYPEDEF: void* LPD3DXFILL3D

STRUCT: D3DXIMAGE_INFO
    { Width                        UINT                 }
    { Height                       UINT                 }
    { Depth                        UINT                 }
    { MipLevels                    UINT                 }
    { Format                       D3DFORMAT            }
    { ResourceType                 D3DRESOURCETYPE      }
    { ImageFileFormat              D3DXIMAGE_FILEFORMAT } ;

FUNCTION: HRESULT
    D3DXGetImageInfoFromFileA (
        LPCSTR                    pSrcFile,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXGetImageInfoFromFileW (
        LPCWSTR                   pSrcFile,
        D3DXIMAGE_INFO*           pSrcInfo )

ALIAS: D3DXGetImageInfoFromFile D3DXGetImageInfoFromFileW

FUNCTION: HRESULT
    D3DXGetImageInfoFromResourceA (
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXGetImageInfoFromResourceW (
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        D3DXIMAGE_INFO*           pSrcInfo )

ALIAS: D3DXGetImageInfoFromResource D3DXGetImageInfoFromResourceW

FUNCTION: HRESULT
    D3DXGetImageInfoFromFileInMemory (
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXLoadSurfaceFromFileA (
        LPDIRECT3DSURFACE9        pDestSurface,
        PALETTEENTRY*             pDestPalette,
        RECT*                     pDestRect,
        LPCSTR                    pSrcFile,
        RECT*                     pSrcRect,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXLoadSurfaceFromFileW (
        LPDIRECT3DSURFACE9        pDestSurface,
        PALETTEENTRY*             pDestPalette,
        RECT*                     pDestRect,
        LPCWSTR                   pSrcFile,
        RECT*                     pSrcRect,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

ALIAS: D3DXLoadSurfaceFromFile D3DXLoadSurfaceFromFileW

FUNCTION: HRESULT
    D3DXLoadSurfaceFromResourceA (
        LPDIRECT3DSURFACE9        pDestSurface,
        PALETTEENTRY*             pDestPalette,
        RECT*                     pDestRect,
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        RECT*                     pSrcRect,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXLoadSurfaceFromResourceW (
        LPDIRECT3DSURFACE9        pDestSurface,
        PALETTEENTRY*             pDestPalette,
        RECT*                     pDestRect,
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        RECT*                     pSrcRect,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

ALIAS: D3DXLoadSurfaceFromResource D3DXLoadSurfaceFromResourceW

FUNCTION: HRESULT
    D3DXLoadSurfaceFromFileInMemory (
        LPDIRECT3DSURFACE9        pDestSurface,
        PALETTEENTRY*             pDestPalette,
        RECT*                     pDestRect,
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        RECT*                     pSrcRect,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXLoadSurfaceFromSurface (
        LPDIRECT3DSURFACE9        pDestSurface,
        PALETTEENTRY*             pDestPalette,
        RECT*                     pDestRect,
        LPDIRECT3DSURFACE9        pSrcSurface,
        PALETTEENTRY*             pSrcPalette,
        RECT*                     pSrcRect,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey )

FUNCTION: HRESULT
    D3DXLoadSurfaceFromMemory (
        LPDIRECT3DSURFACE9        pDestSurface,
        PALETTEENTRY*             pDestPalette,
        RECT*                     pDestRect,
        LPCVOID                   pSrcMemory,
        D3DFORMAT                 SrcFormat,
        UINT                      SrcPitch,
        PALETTEENTRY*             pSrcPalette,
        RECT*                     pSrcRect,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey )

FUNCTION: HRESULT
    D3DXSaveSurfaceToFileA (
        LPCSTR                    pDestFile,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DSURFACE9        pSrcSurface,
        PALETTEENTRY*             pSrcPalette,
        RECT*                     pSrcRect )

FUNCTION: HRESULT
    D3DXSaveSurfaceToFileW (
        LPCWSTR                   pDestFile,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DSURFACE9        pSrcSurface,
        PALETTEENTRY*             pSrcPalette,
        RECT*                     pSrcRect )

ALIAS: D3DXSaveSurfaceToFile D3DXSaveSurfaceToFileW

FUNCTION: HRESULT
    D3DXSaveSurfaceToFileInMemory (
        LPD3DXBUFFER*             ppDestBuf,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DSURFACE9        pSrcSurface,
        PALETTEENTRY*             pSrcPalette,
        RECT*                     pSrcRect )

FUNCTION: HRESULT
    D3DXLoadVolumeFromFileA (
        LPDIRECT3DVOLUME9         pDestVolume,
        PALETTEENTRY*             pDestPalette,
        D3DBOX*                   pDestBox,
        LPCSTR                    pSrcFile,
        D3DBOX*                   pSrcBox,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXLoadVolumeFromFileW (
        LPDIRECT3DVOLUME9         pDestVolume,
        PALETTEENTRY*             pDestPalette,
        D3DBOX*                   pDestBox,
        LPCWSTR                   pSrcFile,
        D3DBOX*                   pSrcBox,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

ALIAS: D3DXLoadVolumeFromFile D3DXLoadVolumeFromFileW

FUNCTION: HRESULT
    D3DXLoadVolumeFromResourceA (
        LPDIRECT3DVOLUME9         pDestVolume,
        PALETTEENTRY*             pDestPalette,
        D3DBOX*                   pDestBox,
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        D3DBOX*                   pSrcBox,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXLoadVolumeFromResourceW (
        LPDIRECT3DVOLUME9         pDestVolume,
        PALETTEENTRY*             pDestPalette,
        D3DBOX*                   pDestBox,
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        D3DBOX*                   pSrcBox,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

ALIAS: D3DXLoadVolumeFromResource D3DXLoadVolumeFromResourceW

FUNCTION: HRESULT
    D3DXLoadVolumeFromFileInMemory (
        LPDIRECT3DVOLUME9         pDestVolume,
        PALETTEENTRY*             pDestPalette,
        D3DBOX*                   pDestBox,
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        D3DBOX*                   pSrcBox,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo )

FUNCTION: HRESULT
    D3DXLoadVolumeFromVolume (
        LPDIRECT3DVOLUME9         pDestVolume,
        PALETTEENTRY*             pDestPalette,
        D3DBOX*                   pDestBox,
        LPDIRECT3DVOLUME9         pSrcVolume,
        PALETTEENTRY*             pSrcPalette,
        D3DBOX*                   pSrcBox,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey )

FUNCTION: HRESULT
    D3DXLoadVolumeFromMemory (
        LPDIRECT3DVOLUME9         pDestVolume,
        PALETTEENTRY*             pDestPalette,
        D3DBOX*                   pDestBox,
        LPCVOID                   pSrcMemory,
        D3DFORMAT                 SrcFormat,
        UINT                      SrcRowPitch,
        UINT                      SrcSlicePitch,
        PALETTEENTRY*             pSrcPalette,
        D3DBOX*                   pSrcBox,
        DWORD                     Filter,
        D3DCOLOR                  ColorKey )

FUNCTION: HRESULT
    D3DXSaveVolumeToFileA (
        LPCSTR                    pDestFile,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DVOLUME9         pSrcVolume,
        PALETTEENTRY*             pSrcPalette,
        D3DBOX*                   pSrcBox )

FUNCTION: HRESULT
    D3DXSaveVolumeToFileW (
        LPCWSTR                   pDestFile,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DVOLUME9         pSrcVolume,
        PALETTEENTRY*             pSrcPalette,
        D3DBOX*                   pSrcBox )

ALIAS: D3DXSaveVolumeToFile D3DXSaveVolumeToFileW

FUNCTION: HRESULT
    D3DXSaveVolumeToFileInMemory (
        LPD3DXBUFFER*             ppDestBuf,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DVOLUME9         pSrcVolume,
        PALETTEENTRY*             pSrcPalette,
        D3DBOX*                   pSrcBox )

FUNCTION: HRESULT
    D3DXCheckTextureRequirements (
        LPDIRECT3DDEVICE9         pDevice,
        UINT*                     pWidth,
        UINT*                     pHeight,
        UINT*                     pNumMipLevels,
        DWORD                     Usage,
        D3DFORMAT*                pFormat,
        D3DPOOL                   Pool )

FUNCTION: HRESULT
    D3DXCheckCubeTextureRequirements (
        LPDIRECT3DDEVICE9         pDevice,
        UINT*                     pSize,
        UINT*                     pNumMipLevels,
        DWORD                     Usage,
        D3DFORMAT*                pFormat,
        D3DPOOL                   Pool )

FUNCTION: HRESULT
    D3DXCheckVolumeTextureRequirements (
        LPDIRECT3DDEVICE9         pDevice,
        UINT*                     pWidth,
        UINT*                     pHeight,
        UINT*                     pDepth,
        UINT*                     pNumMipLevels,
        DWORD                     Usage,
        D3DFORMAT*                pFormat,
        D3DPOOL                   Pool )

FUNCTION: HRESULT
    D3DXCreateTexture (
        LPDIRECT3DDEVICE9         pDevice,
        UINT                      Width,
        UINT                      Height,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        LPDIRECT3DTEXTURE9*       ppTexture )

FUNCTION: HRESULT
    D3DXCreateCubeTexture (
        LPDIRECT3DDEVICE9         pDevice,
        UINT                      Size,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

FUNCTION: HRESULT
    D3DXCreateVolumeTexture (
        LPDIRECT3DDEVICE9         pDevice,
        UINT                      Width,
        UINT                      Height,
        UINT                      Depth,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

FUNCTION: HRESULT
    D3DXCreateTextureFromFileA (
        LPDIRECT3DDEVICE9         pDevice,
        LPCSTR                    pSrcFile,
        LPDIRECT3DTEXTURE9*       ppTexture )

FUNCTION: HRESULT
    D3DXCreateTextureFromFileW (
        LPDIRECT3DDEVICE9         pDevice,
        LPCWSTR                   pSrcFile,
        LPDIRECT3DTEXTURE9*       ppTexture )

ALIAS: D3DXCreateTextureFromFile D3DXCreateTextureFromFileW

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromFileA (
        LPDIRECT3DDEVICE9         pDevice,
        LPCSTR                    pSrcFile,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromFileW (
        LPDIRECT3DDEVICE9         pDevice,
        LPCWSTR                   pSrcFile,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

ALIAS: D3DXCreateCubeTextureFromFile D3DXCreateCubeTextureFromFileW

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromFileA (
        LPDIRECT3DDEVICE9         pDevice,
        LPCSTR                    pSrcFile,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromFileW (
        LPDIRECT3DDEVICE9         pDevice,
        LPCWSTR                   pSrcFile,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

ALIAS: D3DXCreateVolumeTextureFromFile D3DXCreateVolumeTextureFromFileW

FUNCTION: HRESULT
    D3DXCreateTextureFromResourceA (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        LPDIRECT3DTEXTURE9*       ppTexture )

FUNCTION: HRESULT
    D3DXCreateTextureFromResourceW (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        LPDIRECT3DTEXTURE9*       ppTexture )

ALIAS: D3DXCreateTextureFromResource D3DXCreateTextureFromResourceW

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromResourceA (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromResourceW (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

ALIAS: D3DXCreateCubeTextureFromResource D3DXCreateCubeTextureFromResourceW

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromResourceA (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromResourceW (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

ALIAS: D3DXCreateVolumeTextureFromResource D3DXCreateVolumeTextureFromResourceW

FUNCTION: HRESULT
    D3DXCreateTextureFromFileExA (
        LPDIRECT3DDEVICE9         pDevice,
        LPCSTR                    pSrcFile,
        UINT                      Width,
        UINT                      Height,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DTEXTURE9*       ppTexture )

FUNCTION: HRESULT
    D3DXCreateTextureFromFileExW (
        LPDIRECT3DDEVICE9         pDevice,
        LPCWSTR                   pSrcFile,
        UINT                      Width,
        UINT                      Height,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DTEXTURE9*       ppTexture )

ALIAS: D3DXCreateTextureFromFileEx D3DXCreateTextureFromFileExW

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromFileExA (
        LPDIRECT3DDEVICE9         pDevice,
        LPCSTR                    pSrcFile,
        UINT                      Size,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromFileExW (
        LPDIRECT3DDEVICE9         pDevice,
        LPCWSTR                   pSrcFile,
        UINT                      Size,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

ALIAS: D3DXCreateCubeTextureFromFileEx D3DXCreateCubeTextureFromFileExW

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromFileExA (
        LPDIRECT3DDEVICE9         pDevice,
        LPCSTR                    pSrcFile,
        UINT                      Width,
        UINT                      Height,
        UINT                      Depth,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromFileExW (
        LPDIRECT3DDEVICE9         pDevice,
        LPCWSTR                   pSrcFile,
        UINT                      Width,
        UINT                      Height,
        UINT                      Depth,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

ALIAS: D3DXCreateVolumeTextureFromFileEx D3DXCreateVolumeTextureFromFileExW

FUNCTION: HRESULT
    D3DXCreateTextureFromResourceExA (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        UINT                      Width,
        UINT                      Height,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DTEXTURE9*       ppTexture )

FUNCTION: HRESULT
    D3DXCreateTextureFromResourceExW (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        UINT                      Width,
        UINT                      Height,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DTEXTURE9*       ppTexture )

ALIAS: D3DXCreateTextureFromResourceEx D3DXCreateTextureFromResourceExW

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromResourceExA (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        UINT                      Size,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromResourceExW (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        UINT                      Size,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

ALIAS: D3DXCreateCubeTextureFromResourceEx D3DXCreateCubeTextureFromResourceExW

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromResourceExA (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCSTR                    pSrcResource,
        UINT                      Width,
        UINT                      Height,
        UINT                      Depth,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromResourceExW (
        LPDIRECT3DDEVICE9         pDevice,
        HMODULE                   hSrcModule,
        LPCWSTR                   pSrcResource,
        UINT                      Width,
        UINT                      Height,
        UINT                      Depth,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

ALIAS: D3DXCreateVolumeTextureFromResourceEx D3DXCreateVolumeTextureFromResourceExW

FUNCTION: HRESULT
    D3DXCreateTextureFromFileInMemory (
        LPDIRECT3DDEVICE9         pDevice,
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        LPDIRECT3DTEXTURE9*       ppTexture )

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromFileInMemory (
        LPDIRECT3DDEVICE9         pDevice,
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromFileInMemory (
        LPDIRECT3DDEVICE9         pDevice,
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

FUNCTION: HRESULT
    D3DXCreateTextureFromFileInMemoryEx (
        LPDIRECT3DDEVICE9         pDevice,
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        UINT                      Width,
        UINT                      Height,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DTEXTURE9*       ppTexture )

FUNCTION: HRESULT
    D3DXCreateCubeTextureFromFileInMemoryEx (
        LPDIRECT3DDEVICE9         pDevice,
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        UINT                      Size,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DCUBETEXTURE9*   ppCubeTexture )

FUNCTION: HRESULT
    D3DXCreateVolumeTextureFromFileInMemoryEx (
        LPDIRECT3DDEVICE9         pDevice,
        LPCVOID                   pSrcData,
        UINT                      SrcDataSize,
        UINT                      Width,
        UINT                      Height,
        UINT                      Depth,
        UINT                      MipLevels,
        DWORD                     Usage,
        D3DFORMAT                 Format,
        D3DPOOL                   Pool,
        DWORD                     Filter,
        DWORD                     MipFilter,
        D3DCOLOR                  ColorKey,
        D3DXIMAGE_INFO*           pSrcInfo,
        PALETTEENTRY*             pPalette,
        LPDIRECT3DVOLUMETEXTURE9* ppVolumeTexture )

FUNCTION: HRESULT
    D3DXSaveTextureToFileA (
        LPCSTR                    pDestFile,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DBASETEXTURE9    pSrcTexture,
        PALETTEENTRY*             pSrcPalette )

FUNCTION: HRESULT
    D3DXSaveTextureToFileW (
        LPCWSTR                   pDestFile,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DBASETEXTURE9    pSrcTexture,
        PALETTEENTRY*             pSrcPalette )

ALIAS: D3DXSaveTextureToFile D3DXSaveTextureToFileW

FUNCTION: HRESULT
    D3DXSaveTextureToFileInMemory (
        LPD3DXBUFFER*             ppDestBuf,
        D3DXIMAGE_FILEFORMAT      DestFormat,
        LPDIRECT3DBASETEXTURE9    pSrcTexture,
        PALETTEENTRY*             pSrcPalette )

FUNCTION: HRESULT
    D3DXFilterTexture (
        LPDIRECT3DBASETEXTURE9    pBaseTexture,
        PALETTEENTRY*             pPalette,
        UINT                      SrcLevel,
        DWORD                     Filter )

ALIAS: D3DXFilterCubeTexture D3DXFilterTexture
ALIAS: D3DXFilterVolumeTexture D3DXFilterTexture

FUNCTION: HRESULT
    D3DXFillTexture (
        LPDIRECT3DTEXTURE9        pTexture,
        LPD3DXFILL2D              pFunction,
        LPVOID                    pData )

FUNCTION: HRESULT
    D3DXFillCubeTexture (
        LPDIRECT3DCUBETEXTURE9    pCubeTexture,
        LPD3DXFILL3D              pFunction,
        LPVOID                    pData )

FUNCTION: HRESULT
    D3DXFillVolumeTexture (
        LPDIRECT3DVOLUMETEXTURE9  pVolumeTexture,
        LPD3DXFILL3D              pFunction,
        LPVOID                    pData )

FUNCTION: HRESULT
    D3DXFillTextureTX (
        LPDIRECT3DTEXTURE9        pTexture,
        LPD3DXTEXTURESHADER       pTextureShader )

FUNCTION: HRESULT
    D3DXFillCubeTextureTX (
        LPDIRECT3DCUBETEXTURE9    pCubeTexture,
        LPD3DXTEXTURESHADER       pTextureShader )


FUNCTION: HRESULT
    D3DXFillVolumeTextureTX (
        LPDIRECT3DVOLUMETEXTURE9  pVolumeTexture,
        LPD3DXTEXTURESHADER       pTextureShader )

FUNCTION: HRESULT
    D3DXComputeNormalMap (
        LPDIRECT3DTEXTURE9        pTexture,
        LPDIRECT3DTEXTURE9        pSrcTexture,
        PALETTEENTRY*       pSrcPalette,
        DWORD                     Flags,
        DWORD                     Channel,
        FLOAT                     Amplitude )
