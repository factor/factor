USING: alien.c-types alien.syntax windows.com windows.com.syntax
windows.directx windows.directx.d3d10 windows.directx.dxgi
windows.types ;
IN: windows.directx.d3d10misc

LIBRARY: d3d10

C-TYPE: ID3D10Blob
TYPEDEF: ID3D10Blob* LPD3D10BLOB

COM-INTERFACE: ID3D10Blob IUnknown {8BA5FB08-5195-40e2-AC58-0D989C3A0102}
    LPVOID GetBufferPointer ( )
    SIZE_T GetBufferSize ( ) ;

CONSTANT: D3D10_DRIVER_TYPE_HARDWARE  0
CONSTANT: D3D10_DRIVER_TYPE_REFERENCE 1
CONSTANT: D3D10_DRIVER_TYPE_NULL      2
CONSTANT: D3D10_DRIVER_TYPE_SOFTWARE  3
CONSTANT: D3D10_DRIVER_TYPE_WARP      5
TYPEDEF: int D3D10_DRIVER_TYPE

FUNCTION: HRESULT D3D10CreateDevice (
    IDXGIAdapter*     pAdapter,
    D3D10_DRIVER_TYPE DriverType,
    HMODULE           Software,
    UINT              Flags,
    UINT              SDKVersion,
    ID3D10Device**    ppDevice )

FUNCTION: HRESULT D3D10CreateDeviceAndSwapChain (
    IDXGIAdapter*         pAdapter,
    D3D10_DRIVER_TYPE     DriverType,
    HMODULE               Software,
    UINT                  Flags,
    UINT                  SDKVersion,
    DXGI_SWAP_CHAIN_DESC* pSwapChainDesc,
    IDXGISwapChain**      ppSwapChain,
    ID3D10Device**        ppDevice )

FUNCTION: HRESULT D3D10CreateBlob ( SIZE_T NumBytes, LPD3D10BLOB* ppBuffer )
