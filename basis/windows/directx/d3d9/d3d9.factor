USING: alien.syntax windows.types alien.c-types windows.directx.d3d9types
windows.com.syntax windows.com windows.directx windows.directx.d3d9caps
windows.ole32 windows.kernel32 ;
IN: windows.directx.d3d9

LIBRARY: d3d9

CONSTANT: DIRECT3D_VERSION         0x0900

CONSTANT: D3D_SDK_VERSION   32
CONSTANT: D3D9b_SDK_VERSION 31

C-TYPE: IDirect3D9

FUNCTION: IDirect3D9* Direct3DCreate9 ( UINT SDKVersion )

FUNCTION: int D3DPERF_BeginEvent ( D3DCOLOR col, LPCWSTR wszName )
FUNCTION: int D3DPERF_EndEvent ( )
FUNCTION: void D3DPERF_SetMarker ( D3DCOLOR col, LPCWSTR wszName )
FUNCTION: void D3DPERF_SetRegion ( D3DCOLOR col, LPCWSTR wszName )
FUNCTION: BOOL D3DPERF_QueryRepeatFrame ( )

FUNCTION: void D3DPERF_SetOptions ( DWORD dwOptions )
FUNCTION: DWORD D3DPERF_GetStatus ( )

C-TYPE: IDirect3DDevice9

COM-INTERFACE: IDirect3D9 IUnknown {81BDCBCA-64D4-426d-AE8D-AD0147F4275C}
    HRESULT RegisterSoftwareDevice ( void* pInitializeFunction )
    UINT GetAdapterCount ( )
    HRESULT GetAdapterIdentifier ( UINT Adapter, DWORD Flags, D3DADAPTER_IDENTIFIER9* pIdentifier )
    UINT GetAdapterModeCount ( UINT Adapter, D3DFORMAT Format )
    HRESULT EnumAdapterModes ( UINT Adapter, D3DFORMAT Format, UINT Mode, D3DDISPLAYMODE* pMode )
    HRESULT GetAdapterDisplayMode ( UINT Adapter, D3DDISPLAYMODE* pMode )
    HRESULT CheckDeviceType ( UINT Adapter, D3DDEVTYPE DevType, D3DFORMAT AdapterFormat, D3DFORMAT BackBufferFormat, BOOL bWindowed )
    HRESULT CheckDeviceFormat ( UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT AdapterFormat, DWORD Usage, D3DRESOURCETYPE RType, D3DFORMAT CheckFormat )
    HRESULT CheckDeviceMultiSampleType ( UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT SurfaceFormat, BOOL Windowed, D3DMULTISAMPLE_TYPE MultiSampleType, DWORD* pQualityLevels )
    HRESULT CheckDepthStencilMatch ( UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT AdapterFormat, D3DFORMAT RenderTargetFormat, D3DFORMAT DepthStencilFormat )
    HRESULT CheckDeviceFormatConversion ( UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT SourceFormat, D3DFORMAT TargetFormat )
    HRESULT GetDeviceCaps ( UINT Adapter, D3DDEVTYPE DeviceType, D3DCAPS9* pCaps )
    HMONITOR GetAdapterMonitor ( UINT Adapter )
    HRESULT CreateDevice ( UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow, DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters, IDirect3DDevice9** ppReturnedDeviceInterface ) ;

TYPEDEF: IDirect3D9* LPDIRECT3D9
TYPEDEF: IDirect3D9* PDIRECT3D9

C-TYPE: IDirect3DSurface9
C-TYPE: RGNDATA
C-TYPE: IDirect3DBaseTexture9
C-TYPE: PALETTEENTRY
C-TYPE: IDirect3DVertexBuffer9
C-TYPE: IDirect3DVertexDeclaration9
C-TYPE: IDirect3DVertexShader9
C-TYPE: IDirect3DIndexBuffer9
C-TYPE: IDirect3DPixelShader9
C-TYPE: IDirect3DSwapChain9
C-TYPE: IDirect3DTexture9
C-TYPE: IDirect3DVolumeTexture9
C-TYPE: IDirect3DCubeTexture9
C-TYPE: IDirect3DStateBlock9
C-TYPE: IDirect3DQuery9
C-TYPE: IDirect3DVolume9
C-TYPE: IDirect3D9Ex
C-TYPE: IDirect3DDevice9Ex
C-TYPE: IDirect3DAuthenticatedChannel9
C-TYPE: IDirect3DCryptoSession9

COM-INTERFACE: IDirect3DDevice9 IUnknown {D0223B96-BF7A-43fd-92BD-A43B0D82B9EB}
    HRESULT TestCooperativeLevel ( )
    UINT GetAvailableTextureMem ( )
    HRESULT EvictManagedResources ( )
    HRESULT GetDirect3D ( IDirect3D9** ppD3D9 )
    HRESULT GetDeviceCaps ( D3DCAPS9* pCaps )
    HRESULT GetDisplayMode ( UINT iSwapChain, D3DDISPLAYMODE* pMode )
    HRESULT GetCreationParameters ( D3DDEVICE_CREATION_PARAMETERS *pParameters )
    HRESULT SetCursorProperties ( UINT XHotSpot, UINT YHotSpot, IDirect3DSurface9* pCursorBitmap )
    void SetCursorPosition ( int X, int Y, DWORD Flags )
    BOOL ShowCursor ( BOOL bShow )
    HRESULT CreateAdditionalSwapChain ( D3DPRESENT_PARAMETERS* pPresentationParameters, IDirect3DSwapChain9** pSwapChain )
    HRESULT GetSwapChain ( UINT iSwapChain, IDirect3DSwapChain9** pSwapChain )
    UINT GetNumberOfSwapChains ( )
    HRESULT Reset ( D3DPRESENT_PARAMETERS* pPresentationParameters )
    HRESULT Present ( RECT* pSourceRect, RECT* pDestRect, HWND hDestWindowOverride, RGNDATA* pDirtyRegion )
    HRESULT GetBackBuffer ( UINT iSwapChain, UINT iBackBuffer, D3DBACKBUFFER_TYPE Type, IDirect3DSurface9** ppBackBuffer )
    HRESULT GetRasterStatus ( UINT iSwapChain, D3DRASTER_STATUS* pRasterStatus )
    HRESULT SetDialogBoxMode ( BOOL bEnableDialogs )
    void SetGammaRamp ( UINT iSwapChain, DWORD Flags, D3DGAMMARAMP* pRamp )
    void GetGammaRamp ( UINT iSwapChain, D3DGAMMARAMP* pRamp )
    HRESULT CreateTexture ( UINT Width, UINT Height, UINT Levels, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DTexture9** ppTexture, HANDLE* pSharedHandle )
    HRESULT CreateVolumeTexture ( UINT Width, UINT Height, UINT Depth, UINT Levels, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DVolumeTexture9** ppVolumeTexture, HANDLE* pSharedHandle )
    HRESULT CreateCubeTexture ( UINT EdgeLength, UINT Levels, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DCubeTexture9** ppCubeTexture, HANDLE* pSharedHandle )
    HRESULT CreateVertexBuffer ( UINT Length, DWORD Usage, DWORD FVF, D3DPOOL Pool, IDirect3DVertexBuffer9** ppVertexBuffer, HANDLE* pSharedHandle )
    HRESULT CreateIndexBuffer ( UINT Length, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DIndexBuffer9** ppIndexBuffer, HANDLE* pSharedHandle )
    HRESULT CreateRenderTarget ( UINT Width, UINT Height, D3DFORMAT Format, D3DMULTISAMPLE_TYPE MultiSample, DWORD MultisampleQuality, BOOL Lockable, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle )
    HRESULT CreateDepthStencilSurface ( UINT Width, UINT Height, D3DFORMAT Format, D3DMULTISAMPLE_TYPE MultiSample, DWORD MultisampleQuality, BOOL Discard, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle )
    HRESULT UpdateSurface ( IDirect3DSurface9* pSourceSurface, RECT* pSourceRect, IDirect3DSurface9* pDestinationSurface, POINT* pDestPoint )
    HRESULT UpdateTexture ( IDirect3DBaseTexture9* pSourceTexture, IDirect3DBaseTexture9* pDestinationTexture )
    HRESULT GetRenderTargetData ( IDirect3DSurface9* pRenderTarget, IDirect3DSurface9* pDestSurface )
    HRESULT GetFrontBufferData ( UINT iSwapChain, IDirect3DSurface9* pDestSurface )
    HRESULT StretchRect ( IDirect3DSurface9* pSourceSurface, RECT* pSourceRect, IDirect3DSurface9* pDestSurface, RECT* pDestRect, D3DTEXTUREFILTERTYPE Filter )
    HRESULT ColorFill ( IDirect3DSurface9* pSurface, RECT* pRect, D3DCOLOR color )
    HRESULT CreateOffscreenPlainSurface ( UINT Width, UINT Height, D3DFORMAT Format, D3DPOOL Pool, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle )
    HRESULT SetRenderTarget ( DWORD RenderTargetIndex, IDirect3DSurface9* pRenderTarget )
    HRESULT GetRenderTarget ( DWORD RenderTargetIndex, IDirect3DSurface9** ppRenderTarget )
    HRESULT SetDepthStencilSurface ( IDirect3DSurface9* pNewZStencil )
    HRESULT GetDepthStencilSurface ( IDirect3DSurface9** ppZStencilSurface )
    HRESULT BeginScene ( )
    HRESULT EndScene ( )
    HRESULT Clear ( DWORD Count, D3DRECT* pRects, DWORD Flags, D3DCOLOR Color, float Z, DWORD Stencil )
    HRESULT SetTransform ( D3DTRANSFORMSTATETYPE State, D3DMATRIX* pMatrix )
    HRESULT GetTransform ( D3DTRANSFORMSTATETYPE State, D3DMATRIX* pMatrix )
    HRESULT MultiplyTransform ( D3DTRANSFORMSTATETYPE State, D3DMATRIX* pMatrix )
    HRESULT SetViewport ( D3DVIEWPORT9* pViewport )
    HRESULT GetViewport ( D3DVIEWPORT9* pViewport )
    HRESULT SetMaterial ( D3DMATERIAL9* pMaterial )
    HRESULT GetMaterial ( D3DMATERIAL9* pMaterial )
    HRESULT SetLight ( DWORD Index, D3DLIGHT9* l )
    HRESULT GetLight ( DWORD Index, D3DLIGHT9* l )
    HRESULT LightEnable ( DWORD Index, BOOL Enable )
    HRESULT GetLightEnable ( DWORD Index, BOOL* pEnable )
    HRESULT SetClipPlane ( DWORD Index, float* pPlane )
    HRESULT GetClipPlane ( DWORD Index, float* pPlane )
    HRESULT SetRenderState ( D3DRENDERSTATETYPE State, DWORD Value )
    HRESULT GetRenderState ( D3DRENDERSTATETYPE State, DWORD* pValue )
    HRESULT CreateStateBlock ( D3DSTATEBLOCKTYPE Type, IDirect3DStateBlock9** ppSB )
    HRESULT BeginStateBlock ( )
    HRESULT EndStateBlock ( IDirect3DStateBlock9** ppSB )
    HRESULT SetClipStatus ( D3DCLIPSTATUS9* pClipStatus )
    HRESULT GetClipStatus ( D3DCLIPSTATUS9* pClipStatus )
    HRESULT GetTexture ( DWORD Stage, IDirect3DBaseTexture9** ppTexture )
    HRESULT SetTexture ( DWORD Stage, IDirect3DBaseTexture9* pTexture )
    HRESULT GetTextureStageState ( DWORD Stage, D3DTEXTURESTAGESTATETYPE Type, DWORD* pValue )
    HRESULT SetTextureStageState ( DWORD Stage, D3DTEXTURESTAGESTATETYPE Type, DWORD Value )
    HRESULT GetSamplerState ( DWORD Sampler, D3DSAMPLERSTATETYPE Type, DWORD* pValue )
    HRESULT SetSamplerState ( DWORD Sampler, D3DSAMPLERSTATETYPE Type, DWORD Value )
    HRESULT ValidateDevice ( DWORD* pNumPasses )
    HRESULT SetPaletteEntries ( UINT PaletteNumber, PALETTEENTRY* pEntries )
    HRESULT GetPaletteEntries ( UINT PaletteNumber, PALETTEENTRY* pEntries )
    HRESULT SetCurrentTexturePalette ( UINT PaletteNumber )
    HRESULT GetCurrentTexturePalette ( UINT *PaletteNumber )
    HRESULT SetScissorRect ( RECT* pRect )
    HRESULT GetScissorRect ( RECT* pRect )
    HRESULT SetSoftwareVertexProcessing ( BOOL bSoftware )
    BOOL GetSoftwareVertexProcessing ( )
    HRESULT SetNPatchMode ( float nSegments )
    float GetNPatchMode ( )
    HRESULT DrawPrimitive ( D3DPRIMITIVETYPE PrimitiveType, UINT StartVertex, UINT PrimitiveCount )
    HRESULT DrawIndexedPrimitive ( D3DPRIMITIVETYPE x, INT BaseVertexIndex, UINT MinVertexIndex, UINT NumVertices, UINT startIndex, UINT primCount )
    HRESULT DrawPrimitiveUP ( D3DPRIMITIVETYPE PrimitiveType, UINT PrimitiveCount, void* pVertexStreamZeroData, UINT VertexStreamZeroStride )
    HRESULT DrawIndexedPrimitiveUP ( D3DPRIMITIVETYPE PrimitiveType, UINT MinVertexIndex, UINT NumVertices, UINT PrimitiveCount, void* pIndexData, D3DFORMAT IndexDataFormat, void* pVertexStreamZeroData, UINT VertexStreamZeroStride )
    HRESULT ProcessVertices ( UINT SrcStartIndex, UINT DestIndex, UINT VertexCount, IDirect3DVertexBuffer9* pDestBuffer, IDirect3DVertexDeclaration9* pVertexDecl, DWORD Flags )
    HRESULT CreateVertexDeclaration ( D3DVERTEXELEMENT9* pVertexElements, IDirect3DVertexDeclaration9** ppDecl )
    HRESULT SetVertexDeclaration ( IDirect3DVertexDeclaration9* pDecl )
    HRESULT GetVertexDeclaration ( IDirect3DVertexDeclaration9** ppDecl )
    HRESULT SetFVF ( DWORD FVF )
    HRESULT GetFVF ( DWORD* pFVF )
    HRESULT CreateVertexShader ( DWORD* pFunction, IDirect3DVertexShader9** ppShader )
    HRESULT SetVertexShader ( IDirect3DVertexShader9* pShader )
    HRESULT GetVertexShader ( IDirect3DVertexShader9** ppShader )
    HRESULT SetVertexShaderConstantF ( UINT StartRegister, float* pConstantData, UINT Vector4fCount )
    HRESULT GetVertexShaderConstantF ( UINT StartRegister, float* pConstantData, UINT Vector4fCount )
    HRESULT SetVertexShaderConstantI ( UINT StartRegister, int* pConstantData, UINT Vector4iCount )
    HRESULT GetVertexShaderConstantI ( UINT StartRegister, int* pConstantData, UINT Vector4iCount )
    HRESULT SetVertexShaderConstantB ( UINT StartRegister, BOOL* pConstantData, UINT BoolCount )
    HRESULT GetVertexShaderConstantB ( UINT StartRegister, BOOL* pConstantData, UINT BoolCount )
    HRESULT SetStreamSource ( UINT StreamNumber, IDirect3DVertexBuffer9* pStreamData, UINT OffsetInBytes, UINT Stride )
    HRESULT GetStreamSource ( UINT StreamNumber, IDirect3DVertexBuffer9** ppStreamData, UINT* pOffsetInBytes, UINT* pStride )
    HRESULT SetStreamSourceFreq ( UINT StreamNumber, UINT Setting )
    HRESULT GetStreamSourceFreq ( UINT StreamNumber, UINT* pSetting )
    HRESULT SetIndices ( IDirect3DIndexBuffer9* pIndexData )
    HRESULT GetIndices ( IDirect3DIndexBuffer9** ppIndexData )
    HRESULT CreatePixelShader ( DWORD* pFunction, IDirect3DPixelShader9** ppShader )
    HRESULT SetPixelShader ( IDirect3DPixelShader9* pShader )
    HRESULT GetPixelShader ( IDirect3DPixelShader9** ppShader )
    HRESULT SetPixelShaderConstantF ( UINT StartRegister, float* pConstantData, UINT Vector4fCount )
    HRESULT GetPixelShaderConstantF ( UINT StartRegister, float* pConstantData, UINT Vector4fCount )
    HRESULT SetPixelShaderConstantI ( UINT StartRegister, int* pConstantData, UINT Vector4iCount )
    HRESULT GetPixelShaderConstantI ( UINT StartRegister, int* pConstantData, UINT Vector4iCount )
    HRESULT SetPixelShaderConstantB ( UINT StartRegister, BOOL* pConstantData, UINT BoolCount )
    HRESULT GetPixelShaderConstantB ( UINT StartRegister, BOOL* pConstantData, UINT BoolCount )
    HRESULT DrawRectPatch ( UINT Handle, float* pNumSegs, D3DRECTPATCH_INFO* pRectPatchInfo )
    HRESULT DrawTriPatch ( UINT Handle, float* pNumSegs, D3DTRIPATCH_INFO* pTriPatchInfo )
    HRESULT DeletePatch ( UINT Handle )
    HRESULT CreateQuery ( D3DQUERYTYPE Type, IDirect3DQuery9** ppQuery ) ;

TYPEDEF: IDirect3DDevice9* LPDIRECT3DDEVICE9
TYPEDEF: IDirect3DDevice9* PDIRECT3DDEVICE9

COM-INTERFACE: IDirect3DStateBlock9 IUnknown {B07C4FE5-310D-4ba8-A23C-4F0F206F218B}
    HRESULT GetDevice ( IDirect3DDevice9** ppDevice )
    HRESULT Capture ( )
    HRESULT Apply ( ) ;

COM-INTERFACE: IDirect3DSwapChain9 IUnknown {794950F2-ADFC-458a-905E-10A10B0B503B}
    HRESULT Present ( RECT* pSourceRect, RECT* pDestRect, HWND hDestWindowOverride, RGNDATA* pDirtyRegion, DWORD dwFlags )
    HRESULT GetFrontBufferData ( IDirect3DSurface9* pDestSurface )
    HRESULT GetBackBuffer ( UINT iBackBuffer, D3DBACKBUFFER_TYPE Type, IDirect3DSurface9** ppBackBuffer )
    HRESULT GetRasterStatus ( D3DRASTER_STATUS* pRasterStatus )
    HRESULT GetDisplayMode ( D3DDISPLAYMODE* pMode )
    HRESULT GetDevice ( IDirect3DDevice9** ppDevice )
    HRESULT GetPresentParameters ( D3DPRESENT_PARAMETERS* pPresentationParameters ) ;

TYPEDEF: IDirect3DSwapChain9* LPDIRECT3DSWAPCHAIN9
TYPEDEF: IDirect3DSwapChain9* PDIRECT3DSWAPCHAIN9

COM-INTERFACE: IDirect3DResource9 IUnknown {05EEC05D-8F7D-4362-B999-D1BAF357C704}
    HRESULT GetDevice ( IDirect3DDevice9** ppDevice )
    HRESULT SetPrivateData ( REFGUID refguid, void* pData, DWORD SizeOfData, DWORD Flags )
    HRESULT GetPrivateData ( REFGUID refguid, void* pData, DWORD* pSizeOfData )
    HRESULT FreePrivateData ( REFGUID refguid )
    DWORD SetPriority ( DWORD PriorityNew )
    DWORD GetPriority ( )
    void PreLoad ( )
    D3DRESOURCETYPE GetType ( ) ;

TYPEDEF: IDirect3DResource9* LPDIRECT3DRESOURCE9
TYPEDEF: IDirect3DResource9* PDIRECT3DRESOURCE9

COM-INTERFACE: IDirect3DVertexDeclaration9 IUnknown {DD13C59C-36FA-4098-A8FB-C7ED39DC8546}
    HRESULT GetDevice ( IDirect3DDevice9** ppDevice )
    HRESULT GetDeclaration ( D3DVERTEXELEMENT9* pElement, UINT* pNumElements ) ;

TYPEDEF: IDirect3DVertexDeclaration9* LPDIRECT3DVERTEXDECLARATION9
TYPEDEF: IDirect3DVertexDeclaration9* PDIRECT3DVERTEXDECLARATION9

COM-INTERFACE: IDirect3DVertexShader9 IUnknown {EFC5557E-6265-4613-8A94-43857889EB36}
    HRESULT GetDevice ( IDirect3DDevice9** ppDevice )
    HRESULT GetFunction ( void* x, UINT* pSizeOfData ) ;

TYPEDEF: IDirect3DVertexShader9* LPDIRECT3DVERTEXSHADER9
TYPEDEF: IDirect3DVertexShader9* PDIRECT3DVERTEXSHADER9

COM-INTERFACE: IDirect3DPixelShader9 IUnknown {6D3BDBDC-5B02-4415-B852-CE5E8BCCB289}
    HRESULT GetDevice ( IDirect3DDevice9** ppDevice )
    HRESULT GetFunction ( void* x, UINT* pSizeOfData ) ;

TYPEDEF: IDirect3DPixelShader9* LPDIRECT3DPIXELSHADER9
TYPEDEF: IDirect3DPixelShader9* PDIRECT3DPIXELSHADER9

COM-INTERFACE: IDirect3DBaseTexture9 IDirect3DResource9 {580CA87E-1D3C-4d54-991D-B7D3E3C298CE}
    DWORD SetLOD ( DWORD LODNew )
    DWORD GetLOD ( )
    DWORD GetLevelCount ( )
    HRESULT SetAutoGenFilterType ( D3DTEXTUREFILTERTYPE FilterType )
    D3DTEXTUREFILTERTYPE GetAutoGenFilterType ( )
    void GenerateMipSubLevels ( ) ;

TYPEDEF: IDirect3DBaseTexture9* LPDIRECT3DBASETEXTURE9
TYPEDEF: IDirect3DBaseTexture9* PDIRECT3DBASETEXTURE9

COM-INTERFACE: IDirect3DTexture9 IDirect3DBaseTexture9 {85C31227-3DE5-4f00-9B3A-F11AC38C18B5}
    HRESULT GetLevelDesc ( UINT Level, D3DSURFACE_DESC* pDesc )
    HRESULT GetSurfaceLevel ( UINT Level, IDirect3DSurface9** ppSurfaceLevel )
    HRESULT LockRect ( UINT Level, D3DLOCKED_RECT* pLockedRect, RECT* pRect, DWORD Flags )
    HRESULT UnlockRect ( UINT Level ) ;

TYPEDEF: IDirect3DTexture9* LPDIRECT3DTEXTURE9
TYPEDEF: IDirect3DTexture9* PDIRECT3DTEXTURE9

COM-INTERFACE: IDirect3DVolumeTexture9 IDirect3DBaseTexture9 {2518526C-E789-4111-A7B9-47EF328D13E6}
    HRESULT GetLevelDesc ( UINT Level, D3DVOLUME_DESC* pDesc )
    HRESULT GetVolumeLevel ( UINT Level, IDirect3DVolume9** ppVolumeLevel )
    HRESULT LockBox ( UINT Level, D3DLOCKED_BOX* pLockedVolume, D3DBOX* pBox, DWORD Flags )
    HRESULT UnlockBox ( UINT Level )
    HRESULT AddDirtyBox ( D3DBOX* pDirtyBox ) ;

TYPEDEF: IDirect3DVolumeTexture9* LPDIRECT3DVOLUMETEXTURE9
TYPEDEF: IDirect3DVolumeTexture9* PDIRECT3DVOLUMETEXTURE9

COM-INTERFACE: IDirect3DCubeTexture9 IDirect3DBaseTexture9 {FFF32F81-D953-473a-9223-93D652ABA93F}
    HRESULT GetLevelDesc ( UINT Level, D3DSURFACE_DESC* pDesc )
    HRESULT GetCubeMapSurface ( D3DCUBEMAP_FACES FaceType, UINT Level, IDirect3DSurface9** ppCubeMapSurface )
    HRESULT LockRect ( D3DCUBEMAP_FACES FaceType, UINT Level, D3DLOCKED_RECT* pLockedRect, RECT* pRect, DWORD Flags )
    HRESULT UnlockRect ( D3DCUBEMAP_FACES FaceType, UINT Level )
    HRESULT AddDirtyRect ( D3DCUBEMAP_FACES FaceType, RECT* pDirtyRect ) ;

TYPEDEF: IDirect3DCubeTexture9* LPDIRECT3DCUBETEXTURE9
TYPEDEF: IDirect3DCubeTexture9* PDIRECT3DCUBETEXTURE9

COM-INTERFACE: IDirect3DVertexBuffer9 IDirect3DResource9 {B64BB1B5-FD70-4df6-BF91-19D0A12455E3}
    HRESULT Lock ( UINT OffsetToLock, UINT SizeToLock, void** ppbData, DWORD Flags )
    HRESULT Unlock ( )
    HRESULT GetDesc ( D3DVERTEXBUFFER_DESC* pDesc ) ;

TYPEDEF: IDirect3DVertexBuffer9* LPDIRECT3DVERTEXBUFFER9
TYPEDEF: IDirect3DVertexBuffer9* PDIRECT3DVERTEXBUFFER9

COM-INTERFACE: IDirect3DIndexBuffer9 IDirect3DResource9 {7C9DD65E-D3F7-4529-ACEE-785830ACDE35}
    HRESULT Lock ( UINT OffsetToLock, UINT SizeToLock, void** ppbData, DWORD Flags )
    HRESULT Unlock ( )
    HRESULT GetDesc ( D3DINDEXBUFFER_DESC* pDesc ) ;

TYPEDEF: IDirect3DIndexBuffer9* LPDIRECT3DINDEXBUFFER9
TYPEDEF: IDirect3DIndexBuffer9* PDIRECT3DINDEXBUFFER9

COM-INTERFACE: IDirect3DSurface9 IDirect3DResource9 {0CFBAF3A-9FF6-429a-99B3-A2796AF8B89B}
    HRESULT GetContainer ( REFIID riid, void** ppContainer )
    HRESULT GetDesc ( D3DSURFACE_DESC* pDesc )
    HRESULT LockRect ( D3DLOCKED_RECT* pLockedRect, RECT* pRect, DWORD Flags )
    HRESULT UnlockRect ( )
    HRESULT GetDC ( HDC* phdc )
    HRESULT ReleaseDC ( HDC hdc ) ;

TYPEDEF: IDirect3DSurface9* LPDIRECT3DSURFACE9
TYPEDEF: IDirect3DSurface9* PDIRECT3DSURFACE9

COM-INTERFACE: IDirect3DVolume9 IUnknown {24F416E6-1F67-4aa7-B88E-D33F6F3128A1}
    HRESULT GetDevice ( IDirect3DDevice9** ppDevice )
    HRESULT SetPrivateData ( REFGUID refguid, void* pData, DWORD SizeOfData, DWORD Flags )
    HRESULT GetPrivateData ( REFGUID refguid, void* pData, DWORD* pSizeOfData )
    HRESULT FreePrivateData ( REFGUID refguid )
    HRESULT GetContainer ( REFIID riid, void** ppContainer )
    HRESULT GetDesc ( D3DVOLUME_DESC *pDesc )
    HRESULT LockBox ( D3DLOCKED_BOX* pLockedVolume, D3DBOX* pBox, DWORD Flags )
    HRESULT UnlockBox ( ) ;

TYPEDEF: IDirect3DVolume9* LPDIRECT3DVOLUME9
TYPEDEF: IDirect3DVolume9* PDIRECT3DVOLUME9

COM-INTERFACE: IDirect3DQuery9 IUnknown {d9771460-a695-4f26-bbd3-27b840b541cc}
    HRESULT GetDevice ( IDirect3DDevice9** ppDevice )
    D3DQUERYTYPE GetType ( )
    DWORD GetDataSize ( )
    HRESULT Issue ( DWORD dwIssueFlags )
    HRESULT GetData ( void* pData, DWORD dwSize, DWORD dwGetDataFlags ) ;

TYPEDEF: IDirect3DQuery9* LPDIRECT3DQUERY9
TYPEDEF: IDirect3DQuery9* PDIRECT3DQUERY9

CONSTANT: D3DSPD_IUNKNOWN                         0x00000001

CONSTANT: D3DCREATE_FPU_PRESERVE                  0x00000002
CONSTANT: D3DCREATE_MULTITHREADED                 0x00000004

CONSTANT: D3DCREATE_PUREDEVICE                    0x00000010
CONSTANT: D3DCREATE_SOFTWARE_VERTEXPROCESSING     0x00000020
CONSTANT: D3DCREATE_HARDWARE_VERTEXPROCESSING     0x00000040
CONSTANT: D3DCREATE_MIXED_VERTEXPROCESSING        0x00000080

CONSTANT: D3DCREATE_DISABLE_DRIVER_MANAGEMENT     0x00000100
CONSTANT: D3DCREATE_ADAPTERGROUP_DEVICE           0x00000200
CONSTANT: D3DCREATE_DISABLE_DRIVER_MANAGEMENT_EX  0x00000400

CONSTANT: D3DCREATE_NOWINDOWCHANGES               0x00000800

CONSTANT: D3DCREATE_DISABLE_PSGP_THREADING        0x00002000
CONSTANT: D3DCREATE_ENABLE_PRESENTSTATS           0x00004000
CONSTANT: D3DCREATE_DISABLE_PRINTSCREEN           0x00008000
CONSTANT: D3DCREATE_SCREENSAVER                   0x10000000

CONSTANT: D3DADAPTER_DEFAULT                     0
CONSTANT: D3DENUM_WHQL_LEVEL                     2
CONSTANT: D3DENUM_NO_DRIVERVERSION               4
CONSTANT: D3DPRESENT_BACK_BUFFERS_MAX            3
CONSTANT: D3DPRESENT_BACK_BUFFERS_MAX_EX         30

CONSTANT: D3DSGR_NO_CALIBRATION                  0x00000000
CONSTANT: D3DSGR_CALIBRATE                       0x00000001

CONSTANT: D3DCURSOR_IMMEDIATE_UPDATE             0x00000001

CONSTANT: D3DPRESENT_DONOTWAIT                   0x00000001
CONSTANT: D3DPRESENT_LINEAR_CONTENT              0x00000002

CONSTANT: D3DPRESENT_DONOTFLIP                   0x00000004
CONSTANT: D3DPRESENT_FLIPRESTART                 0x00000008
CONSTANT: D3DPRESENT_VIDEO_RESTRICT_TO_MONITOR   0x00000010
CONSTANT: D3DPRESENT_UPDATEOVERLAYONLY           0x00000020
CONSTANT: D3DPRESENT_HIDEOVERLAY                 0x00000040
CONSTANT: D3DPRESENT_UPDATECOLORKEY              0x00000080
CONSTANT: D3DPRESENT_FORCEIMMEDIATE              0x00000100

: D3D_OK ( -- n ) S_OK ; inline

CONSTANT: D3DERR_WRONGTEXTUREFORMAT               0x88760818
CONSTANT: D3DERR_UNSUPPORTEDCOLOROPERATION        0x88760819
CONSTANT: D3DERR_UNSUPPORTEDCOLORARG              0x8876081A
CONSTANT: D3DERR_UNSUPPORTEDALPHAOPERATION        0x8876081B
CONSTANT: D3DERR_UNSUPPORTEDALPHAARG              0x8876081C
CONSTANT: D3DERR_TOOMANYOPERATIONS                0x8876081D
CONSTANT: D3DERR_CONFLICTINGTEXTUREFILTER         0x8876081E
CONSTANT: D3DERR_UNSUPPORTEDFACTORVALUE           0x8876081F
CONSTANT: D3DERR_CONFLICTINGRENDERSTATE           0x88760820
CONSTANT: D3DERR_UNSUPPORTEDTEXTUREFILTER         0x88760821
CONSTANT: D3DERR_CONFLICTINGTEXTUREPALETTE        0x88760825
CONSTANT: D3DERR_DRIVERINTERNALERROR              0x88760826
CONSTANT: D3DERR_NOTFOUND                         0x88760866
CONSTANT: D3DERR_MOREDATA                         0x88760867
CONSTANT: D3DERR_DEVICELOST                       0x88760868
CONSTANT: D3DERR_DEVICENOTRESET                   0x88760869
CONSTANT: D3DERR_NOTAVAILABLE                     0x8876086A
CONSTANT: D3DERR_OUTOFVIDEOMEMORY                 0x8876017C
CONSTANT: D3DERR_INVALIDDEVICE                    0x8876086B
CONSTANT: D3DERR_INVALIDCALL                      0x8876086C
CONSTANT: D3DERR_DRIVERINVALIDCALL                0x8876086D
CONSTANT: D3DERR_WASSTILLDRAWING                  0x8876021C
CONSTANT: D3DOK_NOAUTOGEN                         0x0876086F
CONSTANT: D3DERR_DEVICEREMOVED                    0x88760870
CONSTANT: S_NOT_RESIDENT                          0x08760875
CONSTANT: S_RESIDENT_IN_SHARED_MEMORY             0x08760876
CONSTANT: S_PRESENT_MODE_CHANGED                  0x08760877
CONSTANT: S_PRESENT_OCCLUDED                      0x08760878
CONSTANT: D3DERR_DEVICEHUNG                       0x88760874
CONSTANT: D3DERR_UNSUPPORTEDOVERLAY               0x8876087C
CONSTANT: D3DERR_UNSUPPORTEDOVERLAYFORMAT         0x8876087D
CONSTANT: D3DERR_CANNOTPROTECTCONTENT             0x8876087E
CONSTANT: D3DERR_UNSUPPORTEDCRYPTO                0x8876087F
CONSTANT: D3DERR_PRESENT_STATISTICS_DISJOINT      0x88760884

FUNCTION: HRESULT Direct3DCreate9Ex ( UINT SDKVersion, IDirect3D9Ex** out )

COM-INTERFACE: IDirect3D9Ex IDirect3D9 {02177241-69FC-400C-8FF1-93A44DF6861D}
    UINT GetAdapterModeCountEx ( UINT Adapter, D3DDISPLAYMODEFILTER* pFilter )
    HRESULT EnumAdapterModesEx ( UINT Adapter, D3DDISPLAYMODEFILTER* pFilter, UINT Mode, D3DDISPLAYMODEEX* pMode )
    HRESULT GetAdapterDisplayModeEx ( UINT Adapter, D3DDISPLAYMODEEX* pMode, D3DDISPLAYROTATION* pRotation )
    HRESULT CreateDeviceEx ( UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow, DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters, D3DDISPLAYMODEEX* pFullscreenDisplayMode, IDirect3DDevice9Ex** ppReturnedDeviceInterface )
    HRESULT GetAdapterLUID ( UINT Adapter, LUID* pLUID ) ;

TYPEDEF: IDirect3D9Ex* LPDIRECT3D9EX
TYPEDEF: IDirect3D9Ex* PDIRECT3D9EX

COM-INTERFACE: IDirect3DDevice9Ex IDirect3DDevice9 {B18B10CE-2649-405a-870F-95F777D4313A}
    HRESULT SetConvolutionMonoKernel ( UINT width, UINT height, float* rows, float* columns )
    HRESULT ComposeRects ( IDirect3DSurface9* pSrc, IDirect3DSurface9* pDst, IDirect3DVertexBuffer9* pSrcRectDescs, UINT NumRects, IDirect3DVertexBuffer9* pDstRectDescs, D3DCOMPOSERECTSOP Operation, int Xoffset, int Yoffset )
    HRESULT PresentEx ( RECT* pSourceRect, RECT* pDestRect, HWND hDestWindowOverride, RGNDATA* pDirtyRegion, DWORD dwFlags )
    HRESULT GetGPUThreadPriority ( INT* pPriority )
    HRESULT SetGPUThreadPriority ( INT Priority )
    HRESULT WaitForVBlank ( UINT iSwapChain )
    HRESULT CheckResourceResidency ( IDirect3DResource9** pResourceArray, UINT32 NumResources )
    HRESULT SetMaximumFrameLatency ( UINT MaxLatency )
    HRESULT GetMaximumFrameLatency ( UINT* pMaxLatency )
    HRESULT CheckDeviceState ( HWND hDestinationWindow )
    HRESULT CreateRenderTargetEx ( UINT Width, UINT Height, D3DFORMAT Format, D3DMULTISAMPLE_TYPE MultiSample, DWORD MultisampleQuality, BOOL Lockable, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle, DWORD Usage )
    HRESULT CreateOffscreenPlainSurfaceEx ( UINT Width, UINT Height, D3DFORMAT Format, D3DPOOL Pool, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle, DWORD Usage )
    HRESULT CreateDepthStencilSurfaceEx ( UINT Width, UINT Height, D3DFORMAT Format, D3DMULTISAMPLE_TYPE MultiSample, DWORD MultisampleQuality, BOOL Discard, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle, DWORD Usage )
    HRESULT ResetEx ( D3DPRESENT_PARAMETERS* pPresentationParameters, D3DDISPLAYMODEEX *pFullscreenDisplayMode )
    HRESULT GetDisplayModeEx ( UINT iSwapChain, D3DDISPLAYMODEEX* pMode, D3DDISPLAYROTATION* pRotation ) ;

TYPEDEF: IDirect3DDevice9Ex* LPDIRECT3DDEVICE9EX
TYPEDEF: IDirect3DDevice9Ex* PDIRECT3DDEVICE9EX

COM-INTERFACE: IDirect3DSwapChain9Ex IDirect3DSwapChain9 {91886CAF-1C3D-4d2e-A0AB-3E4C7D8D3303}
    HRESULT GetLastPresentCount ( UINT* pLastPresentCount )
    HRESULT GetPresentStats ( D3DPRESENTSTATS* pPresentationStatistics )
    HRESULT GetDisplayModeEx ( D3DDISPLAYMODEEX* pMode, D3DDISPLAYROTATION* pRotation ) ;

TYPEDEF: IDirect3DSwapChain9Ex* LPDIRECT3DSWAPCHAIN9EX
TYPEDEF: IDirect3DSwapChain9Ex* PDIRECT3DSWAPCHAIN9EX

COM-INTERFACE: IDirect3D9ExOverlayExtension IUnknown {187aeb13-aaf5-4c59-876d-e059088c0df8}
    HRESULT CheckDeviceOverlayType ( UINT Adapter, D3DDEVTYPE DevType, UINT OverlayWidth, UINT OverlayHeight, D3DFORMAT OverlayFormat, D3DDISPLAYMODEEX* pDisplayMode, D3DDISPLAYROTATION DisplayRotation, D3DOVERLAYCAPS* pOverlayCaps ) ;

TYPEDEF: IDirect3D9ExOverlayExtension* LPDIRECT3D9EXOVERLAYEXTENSION
TYPEDEF: IDirect3D9ExOverlayExtension* PDIRECT3D9EXOVERLAYEXTENSION

COM-INTERFACE: IDirect3DDevice9Video IUnknown {26DC4561-A1EE-4ae7-96DA-118A36C0EC95}
    HRESULT GetContentProtectionCaps ( GUID* pCryptoType, GUID* pDecodeProfile, D3DCONTENTPROTECTIONCAPS* pCaps )
    HRESULT CreateAuthenticatedChannel ( D3DAUTHENTICATEDCHANNELTYPE ChannelType, IDirect3DAuthenticatedChannel9** ppAuthenticatedChannel, HANDLE* pChannelHandle )
    HRESULT CreateCryptoSession ( GUID* pCryptoType, GUID* pDecodeProfile, IDirect3DCryptoSession9** ppCryptoSession, HANDLE* pCryptoHandle ) ;

TYPEDEF: IDirect3DDevice9Video* LPDIRECT3DDEVICE9VIDEO
TYPEDEF: IDirect3DDevice9Video* PDIRECT3DDEVICE9VIDEO

COM-INTERFACE: IDirect3DAuthenticatedChannel9 IUnknown {FF24BEEE-DA21-4beb-98B5-D2F899F98AF9}
    HRESULT GetCertificateSize ( UINT* pCertificateSize )
    HRESULT GetCertificate ( UINT CertifacteSize, BYTE* ppCertificate )
    HRESULT NegotiateKeyExchange ( UINT DataSize, VOID* pData )
    HRESULT Query ( UINT InputSize, VOID* pInput, UINT OutputSize, VOID* pOutput )
    HRESULT Configure ( UINT InputSize, VOID* pInput, D3DAUTHENTICATEDCHANNEL_CONFIGURE_OUTPUT* pOutput ) ;

TYPEDEF: IDirect3DAuthenticatedChannel9* LPDIRECT3DAUTHENTICATEDCHANNEL9
TYPEDEF: IDirect3DAuthenticatedChannel9* PDIRECT3DAUTHENTICATEDCHANNEL9

COM-INTERFACE: IDirect3DCryptoSession9 IUnknown {FA0AB799-7A9C-48ca-8C5B-237E71A54434}
    HRESULT GetCertificateSize ( UINT* pCertificateSize )
    HRESULT GetCertificate ( UINT CertifacteSize, BYTE* ppCertificate )
    HRESULT NegotiateKeyExchange ( UINT DataSize, VOID* pData )
    HRESULT EncryptionBlt ( IDirect3DSurface9* pSrcSurface, IDirect3DSurface9* pDstSurface, UINT DstSurfaceSize, VOID* pIV )
    HRESULT DecryptionBlt ( IDirect3DSurface9* pSrcSurface, IDirect3DSurface9* pDstSurface, UINT SrcSurfaceSize, D3DENCRYPTED_BLOCK_INFO* pEncryptedBlockInfo, VOID* pContentKey, VOID* pIV )
    HRESULT GetSurfacePitch ( IDirect3DSurface9* pSrcSurface, UINT* pSurfacePitch )
    HRESULT StartSessionKeyRefresh ( VOID* pRandomNumber, UINT RandomNumberSize )
    HRESULT FinishSessionKeyRefresh ( )
    HRESULT GetEncryptionBltKey ( VOID* pReadbackKey, UINT KeySize ) ;

TYPEDEF: IDirect3DCryptoSession9* LPDIRECT3DCRYPTOSESSION9
TYPEDEF: IDirect3DCryptoSession9* PDIRECT3DCRYPTOSESSION9
