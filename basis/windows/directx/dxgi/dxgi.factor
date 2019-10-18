USING: alien.c-types alien.syntax classes.struct windows.com windows.com.syntax
windows.directx.dxgiformat windows.directx.dxgitype windows.kernel32
windows.ole32 windows.types windows.directx ;
IN: windows.directx.dxgi

LIBRARY: dxgi

CONSTANT: DXGI_CPU_ACCESS_NONE 0
CONSTANT: DXGI_CPU_ACCESS_DYNAMIC 1
CONSTANT: DXGI_CPU_ACCESS_READ_WRITE 2
CONSTANT: DXGI_CPU_ACCESS_SCRATCH 3
CONSTANT: DXGI_CPU_ACCESS_FIELD 15
CONSTANT: DXGI_USAGE_SHADER_INPUT 16
CONSTANT: DXGI_USAGE_RENDER_TARGET_OUTPUT 32
CONSTANT: DXGI_USAGE_BACK_BUFFER 64
CONSTANT: DXGI_USAGE_SHARED 128
CONSTANT: DXGI_USAGE_READ_ONLY 256
CONSTANT: DXGI_USAGE_DISCARD_ON_PRESENT 512
CONSTANT: DXGI_USAGE_UNORDERED_ACCESS 1024
TYPEDEF: UINT DXGI_USAGE

STRUCT: DXGI_FRAME_STATISTICS
{ PresentCount UINT }
{ PresentRefreshCount UINT }
{ SyncRefreshCount UINT }
{ SyncQPCTime LARGE_INTEGER }
{ SyncGPUTime LARGE_INTEGER } ;

STRUCT: DXGI_MAPPED_RECT
{ Pitch INT }
{ pBits BYTE* } ;

STRUCT: DXGI_ADAPTER_DESC
{ Description WCHAR[128] }
{ VendorId UINT }
{ DeviceId UINT }
{ SubSysId UINT }
{ Revision UINT }
{ DedicatedVideoMemory SIZE_T }
{ DedicatedSystemMemory SIZE_T }
{ SharedSystemMemory SIZE_T }
{ AdapterLuid LUID } ;

STRUCT: DXGI_OUTPUT_DESC
{ DeviceName WCHAR[32] }
{ DesktopCoordinates RECT }
{ AttachedToDesktop BOOL }
{ Rotation DXGI_MODE_ROTATION }
{ Monitor HMONITOR } ;

STRUCT: DXGI_SHARED_RESOURCE
{ Handle HANDLE } ;

CONSTANT: DXGI_RESOURCE_PRIORITY_MINIMUM 0x28000000
CONSTANT: DXGI_RESOURCE_PRIORITY_LOW 0x50000000
CONSTANT: DXGI_RESOURCE_PRIORITY_NORMAL 0x78000000
CONSTANT: DXGI_RESOURCE_PRIORITY_HIGH 0xa0000000
CONSTANT: DXGI_RESOURCE_PRIORITY_MAXIMUM 0xc8000000

CONSTANT: DXGI_RESIDENCY_FULLY_RESIDENT 1
CONSTANT: DXGI_RESIDENCY_RESIDENT_IN_SHARED_MEMORY 2
CONSTANT: DXGI_RESIDENCY_EVICTED_TO_DISK 3
TYPEDEF: int DXGI_RESIDENCY

STRUCT: DXGI_SURFACE_DESC
{ Width UINT }
{ Height UINT }
{ Format DXGI_FORMAT }
{ SampleDesc DXGI_SAMPLE_DESC } ;

CONSTANT: DXGI_SWAP_EFFECT_DISCARD 0
CONSTANT: DXGI_SWAP_EFFECT_SEQUENTIAL 1
TYPEDEF: int DXGI_SWAP_EFFECT

CONSTANT: DXGI_SWAP_CHAIN_FLAG_NONPREROTATED 1
CONSTANT: DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH 2
CONSTANT: DXGI_SWAP_CHAIN_FLAG_GDI_COMPATIBLE 4
TYPEDEF: int DXGI_SWAP_CHAIN_FLAG

STRUCT: DXGI_SWAP_CHAIN_DESC
{ BufferDesc DXGI_MODE_DESC }
{ SampleDesc DXGI_SAMPLE_DESC }
{ BufferUsage DXGI_USAGE }
{ BufferCount UINT }
{ OutputWindow HWND }
{ Windowed BOOL }
{ SwapEffect DXGI_SWAP_EFFECT }
{ Flags UINT } ;

COM-INTERFACE: IDXGIObject IUnknown {aec22fb8-76f3-4639-9be0-28eb43a67a2e}
HRESULT SetPrivateData ( REFGUID Name, UINT DataSize, void* pData )
HRESULT SetPrivateDataInterface ( REFGUID Name, IUnknown* pUnknown )
HRESULT GetPrivateData ( REFGUID Name, UINT* pDataSize, void* pData )
HRESULT GetParent ( REFIID riid, void** ppParent ) ;

COM-INTERFACE: IDXGIDeviceSubObject IDXGIObject {3d3e0379-f9de-4d58-bb6c-18d62992f1a6}
HRESULT GetDevice ( REFIID riid, void** ppDevice ) ;

COM-INTERFACE: IDXGIResource IDXGIDeviceSubObject {035f3ab4-482e-4e50-b41f-8a7f8bd8960b}
HRESULT GetSharedHandle ( HANDLE* pSharedHandle )
HRESULT GetUsage ( DXGI_USAGE* pUsage )
HRESULT SetEvictionPriority ( UINT EvictionPriority )
HRESULT GetEvictionPriority ( UINT* pEvictionPriority ) ;

COM-INTERFACE: IDXGIKeyedMutex IDXGIDeviceSubObject {9d8e1289-d7b3-465f-8126-250e349af85d}
HRESULT AcquireSync ( UINT64 Key, DWORD dwMilliseconds )
HRESULT ReleaseSync ( UINT64 Key ) ;

CONSTANT: DXGI_MAP_READ 1
CONSTANT: DXGI_MAP_WRITE 2
CONSTANT: DXGI_MAP_DISCARD 4

COM-INTERFACE: IDXGISurface IDXGIDeviceSubObject {cafcb56c-6ac3-4889-bf47-9e23bbd260ec}
HRESULT GetDesc ( DXGI_SURFACE_DESC* pDesc )
HRESULT Map ( DXGI_MAPPED_RECT* pLockedRect, UINT MapFlags )
HRESULT Unmap ( ) ;

COM-INTERFACE: IDXGISurface1 IDXGISurface {4AE63092-6327-4c1b-80AE-BFE12EA32B86}
HRESULT GetDC ( BOOL Discard, HDC* phdc )
HRESULT ReleaseDC ( RECT* pDirtyRect ) ;

C-TYPE: IDXGIOutput
COM-INTERFACE: IDXGIAdapter IDXGIObject {2411e7e1-12ac-4ccf-bd14-9798e8534dc0}
HRESULT EnumOutputs ( UINT Output, IDXGIOutput** ppOutput )
HRESULT GetDesc ( DXGI_ADAPTER_DESC* pDesc )
HRESULT CheckInterfaceSupport ( REFGUID InterfaceName, LARGE_INTEGER* pUMDVersion ) ;

CONSTANT: DXGI_ENUM_MODES_INTERLACED 1
CONSTANT: DXGI_ENUM_MODES_SCALING 2

COM-INTERFACE: IDXGIOutput IDXGIObject {ae02eedb-c735-4690-8d52-5a8dc20213aa}
HRESULT GetDesc ( DXGI_OUTPUT_DESC* pDesc )
HRESULT GetDisplayModeList ( DXGI_FORMAT EnumFormat, UINT Flags, UINT* pNumModes, DXGI_MODE_DESC* pDesc )
HRESULT FindClosestMatchingMode ( DXGI_MODE_DESC* pModeToMatch, DXGI_MODE_DESC* pClosestMatch, IUnknown* pConcernedDevice )
HRESULT WaitForVBlank ( )
HRESULT TakeOwnership ( IUnknown* pDevice, BOOL Exclusive )
void ReleaseOwnership ( )
HRESULT GetGammaControlCapabilities ( DXGI_GAMMA_CONTROL_CAPABILITIES* pGammaCaps )
HRESULT SetGammaControl ( DXGI_GAMMA_CONTROL* pArray )
HRESULT GetGammaControl ( DXGI_GAMMA_CONTROL* pArray )
HRESULT SetDisplaySurface ( IDXGISurface* pScanoutSurface )
HRESULT GetDisplaySurfaceData ( IDXGISurface* pDestination )
HRESULT GetFrameStatistics ( DXGI_FRAME_STATISTICS* pStats ) ;

CONSTANT: DXGI_MAX_SWAP_CHAIN_BUFFERS 16
CONSTANT: DXGI_PRESENT_TEST 1
CONSTANT: DXGI_PRESENT_DO_NOT_SEQUENCE 2
CONSTANT: DXGI_PRESENT_RESTART 4

COM-INTERFACE: IDXGISwapChain IDXGIDeviceSubObject {310d36a0-d2e7-4c0a-aa04-6a9d23b8886a}
HRESULT Present ( UINT SyncInterval, UINT Flags )
HRESULT GetBuffer ( UINT Buffer, REFIID riid, void** ppSurface )
HRESULT SetFullscreenState ( BOOL Fullscreen, IDXGIOutput* pTarget )
HRESULT GetFullscreenState ( BOOL* pFullscreen, IDXGIOutput** ppTarget )
HRESULT GetDesc ( DXGI_SWAP_CHAIN_DESC* pDesc )
HRESULT ResizeBuffers ( UINT BufferCount, UINT Width, UINT Height, DXGI_FORMAT NewFormat, UINT SwapChainFlags )
HRESULT ResizeTarget ( DXGI_MODE_DESC* pNewTargetParameters )
HRESULT GetContainingOutput ( IDXGIOutput** ppOutput )
HRESULT GetFrameStatistics ( DXGI_FRAME_STATISTICS* pStats )
HRESULT GetLastPresentCount ( UINT* pLastPresentCount ) ;

CONSTANT: DXGI_MWA_NO_WINDOW_CHANGES 1
CONSTANT: DXGI_MWA_NO_ALT_ENTER 2
CONSTANT: DXGI_MWA_NO_PRINT_SCREEN 4
CONSTANT: DXGI_MWA_VALID 7

COM-INTERFACE: IDXGIFactory IDXGIObject {7b7166ec-21c7-44ae-b21a-c9ae321ae369}
HRESULT EnumAdapters ( UINT Adapter, IDXGIAdapter** ppAdapter )
HRESULT MakeWindowAssociation ( HWND WindowHandle, UINT Flags )
HRESULT GetWindowAssociation ( HWND* pWindowHandle )
HRESULT CreateSwapChain ( IUnknown* pDevice, DXGI_SWAP_CHAIN_DESC* pDesc, IDXGISwapChain** ppSwapChain )
HRESULT CreateSoftwareAdapter ( HMODULE Module, IDXGIAdapter** ppAdapter ) ;

FUNCTION: HRESULT CreateDXGIFactory ( REFIID riid, void** ppFactory )
FUNCTION: HRESULT CreateDXGIFactory1 ( REFIID riid, void** ppFactory )

COM-INTERFACE: IDXGIDevice IDXGIObject {54ec77fa-1377-44e6-8c32-88fd5f44c84c}
HRESULT GetAdapter ( IDXGIAdapter** pAdapter )
HRESULT CreateSurface ( DXGI_SURFACE_DESC* pDesc, UINT NumSurfaces, DXGI_USAGE Usage, DXGI_SHARED_RESOURCE* pSharedResource, IDXGISurface** ppSurface )
HRESULT QueryResourceResidency ( IUnknown** ppResources, DXGI_RESIDENCY* pResidencyStatus, UINT NumResources )
HRESULT SetGPUThreadPriority ( INT Priority )
HRESULT GetGPUThreadPriority ( INT* pPriority ) ;

CONSTANT: DXGI_ADAPTER_FLAG_NONE 0
CONSTANT: DXGI_ADAPTER_FLAG_REMOTE 1
CONSTANT: DXGI_ADAPTER_FLAG_FORCE_DWORD 0xffffffff
TYPEDEF: int DXGI_ADAPTER_FLAG

STRUCT: DXGI_ADAPTER_DESC1
{ Description WCHAR[128] }
{ VendorId UINT }
{ DeviceId UINT }
{ SubSysId UINT }
{ Revision UINT }
{ DedicatedVideoMemory SIZE_T }
{ DedicatedSystemMemory SIZE_T }
{ SharedSystemMemory SIZE_T }
{ AdapterLuid LUID }
{ Flags UINT } ;

STRUCT: DXGI_DISPLAY_COLOR_SPACE
{ PrimaryCoordinates FLOAT[8][2] }
{ WhitePoints FLOAT[16][2] } ;

COM-INTERFACE: IDXGIAdapter1 IDXGIAdapter {29038f61-3839-4626-91fd-086879011a05}
HRESULT GetDesc1 ( DXGI_ADAPTER_DESC1* pDesc ) ;

COM-INTERFACE: IDXGIFactory1 IDXGIFactory {770aae78-f26f-4dba-a829-253c83d1b387}
HRESULT EnumAdapters1 ( UINT Adapter, IDXGIAdapter1** ppAdapter )
BOOL IsCurrent ( ) ;

COM-INTERFACE: IDXGIDevice1 IDXGIDevice {77db970f-6276-48ba-ba28-070143b4392c}
HRESULT SetMaximumFrameLatency ( UINT MaxLatency )
HRESULT GetMaximumFrameLatency ( UINT* pMaxLatency ) ;
