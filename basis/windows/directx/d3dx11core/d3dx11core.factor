USING: alien.syntax windows.directx windows.types windows.com.syntax
alien.c-types windows.com windows.directx.d3d11 ;
IN: windows.directx.d3dx11core

LIBRARY: d3dx11

FUNCTION: HRESULT D3DX11CheckVersion ( UINT D3DSdkVersion, UINT D3DX11SdkVersion )

COM-INTERFACE: ID3DX11DataLoader f {00000000-0000-0000-0000-000000000000}
    HRESULT Load ( )
    HRESULT Decompress ( void** ppData, SIZE_T* pcBytes )
    HRESULT Destroy ( ) ;

COM-INTERFACE: ID3DX11DataProcessor f {00000000-0000-0000-0000-000000000000}
    HRESULT Process ( void* pData, SIZE_T cBytes )
    HRESULT CreateDeviceObject ( void** ppDataObject )
    HRESULT Destroy ( ) ;

COM-INTERFACE: ID3DX11ThreadPump IUnknown {C93FECFA-6967-478a-ABBC-402D90621FCB}
    HRESULT AddWorkItem ( ID3DX11DataLoader* pDataLoader, ID3DX11DataProcessor* pDataProcessor, HRESULT* pHResult, void** ppDeviceObject )
    UINT GetWorkItemCount ( )
    HRESULT WaitForAllItems ( )
    HRESULT ProcessDeviceWorkItems ( UINT iWorkItemCount )
    HRESULT PurgeAllItems ( )
    HRESULT GetQueueStatus ( UINT* pIoQueue, UINT* pProcessQueue, UINT* pDeviceQueue ) ;

FUNCTION: HRESULT D3DX11CreateThreadPump ( UINT cIoThreads, UINT cProcThreads, ID3DX11ThreadPump** ppThreadPump )
FUNCTION: HRESULT D3DX11UnsetAllDeviceObjects ( ID3D11DeviceContext* pContext )

CONSTANT: D3DERR_INVALIDCALL     0x8876086C
CONSTANT: D3DERR_WASSTILLDRAWING 0x8876021C
