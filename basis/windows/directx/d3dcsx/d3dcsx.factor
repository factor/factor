USING: alien.c-types alien.syntax classes.struct windows.com windows.com.syntax
windows.directx windows.directx.d3d11 windows.types ;
IN: windows.directx.d3dcsx

LIBRARY: d3dcsx

CONSTANT: D3DX11_SCAN_DATA_TYPE_FLOAT 1
CONSTANT: D3DX11_SCAN_DATA_TYPE_INT   2
CONSTANT: D3DX11_SCAN_DATA_TYPE_UINT  3
TYPEDEF: int D3DX11_SCAN_DATA_TYPE

CONSTANT: D3DX11_SCAN_OPCODE_ADD 1
CONSTANT: D3DX11_SCAN_OPCODE_MIN 2
CONSTANT: D3DX11_SCAN_OPCODE_MAX 3
CONSTANT: D3DX11_SCAN_OPCODE_MUL 4
CONSTANT: D3DX11_SCAN_OPCODE_AND 5
CONSTANT: D3DX11_SCAN_OPCODE_OR  6
CONSTANT: D3DX11_SCAN_OPCODE_XOR 7
TYPEDEF: int D3DX11_SCAN_OPCODE

CONSTANT: D3DX11_SCAN_DIRECTION_FORWARD  1
CONSTANT: D3DX11_SCAN_DIRECTION_BACKWARD 2
TYPEDEF: int D3DX11_SCAN_DIRECTION

COM-INTERFACE: ID3DX11Scan IUnknown {5089b68f-e71d-4d38-be8e-f363b95a9405}
    HRESULT SetScanDirection ( D3DX11_SCAN_DIRECTION Direction )
    HRESULT Scan ( D3DX11_SCAN_DATA_TYPE ElementType, D3DX11_SCAN_OPCODE OpCode, UINT ElementScanSize, ID3D11UnorderedAccessView* pSrc, ID3D11UnorderedAccessView* pDst )
    HRESULT Multiscan ( D3DX11_SCAN_DATA_TYPE ElementType, D3DX11_SCAN_OPCODE OpCode, UINT ElementScanSize, UINT ElementScanPitch, UINT ScanCount, ID3D11UnorderedAccessView* pSrc, ID3D11UnorderedAccessView* pDst ) ;

FUNCTION: HRESULT D3DX11CreateScan ( ID3D11DeviceContext* pDeviceContext, UINT MaxElementScanSize, UINT MaxScanCount, ID3DX11Scan** ppScan )

COM-INTERFACE: ID3DX11SegmentedScan IUnknown {a915128c-d954-4c79-bfe1-64db923194d6}
    HRESULT SetScanDirection ( D3DX11_SCAN_DIRECTION Direction )
    HRESULT SegScan ( D3DX11_SCAN_DATA_TYPE ElementType, D3DX11_SCAN_OPCODE OpCode, UINT ElementScanSize, ID3D11UnorderedAccessView* pSrc, ID3D11UnorderedAccessView* pSrcElementFlags, ID3D11UnorderedAccessView* pDst ) ;

FUNCTION: HRESULT D3DX11CreateSegmentedScan ( ID3D11DeviceContext* pDeviceContext, UINT MaxElementScanSize, ID3DX11SegmentedScan** ppScan )

CONSTANT: D3DX11_FFT_MAX_PRECOMPUTE_BUFFERS 4
CONSTANT: D3DX11_FFT_MAX_TEMP_BUFFERS       4
CONSTANT: D3DX11_FFT_MAX_DIMENSIONS         32

COM-INTERFACE: ID3DX11FFT IUnknown {b3f7a938-4c93-4310-a675-b30d6de50553}
    HRESULT SetForwardScale ( FLOAT ForwardScale )
    FLOAT GetForwardScale ( )
    HRESULT SetInverseScale ( FLOAT InverseScale )
    FLOAT GetInverseScale ( )
    HRESULT AttachBuffersAndPrecompute ( UINT NumTempBuffers, ID3D11UnorderedAccessView** ppTempBuffers, UINT NumPrecomputeBuffers, ID3D11UnorderedAccessView** ppPrecomputeBufferSizes )
    HRESULT ForwardTransform ( ID3D11UnorderedAccessView* pInputBuffer, ID3D11UnorderedAccessView** ppOutputBuffer )
    HRESULT InverseTransform ( ID3D11UnorderedAccessView* pInputBuffer, ID3D11UnorderedAccessView** ppOutputBuffer ) ;

ENUM: D3DX11_FFT_DATA_TYPE
    D3DX11_FFT_DATA_TYPE_REAL
    D3DX11_FFT_DATA_TYPE_COMPLEX ;

CONSTANT: D3DX11_FFT_DIM_MASK_1D 1
CONSTANT: D3DX11_FFT_DIM_MASK_2D 3
CONSTANT: D3DX11_FFT_DIM_MASK_3D 7
TYPEDEF: int D3DX11_FFT_DIM_MASK

STRUCT: D3DX11_FFT_DESC
    { NumDimensions  UINT                            }
    { ElementLengths UINT[D3DX11_FFT_MAX_DIMENSIONS] }
    { DimensionMask  UINT                            }
    { Type           D3DX11_FFT_DATA_TYPE            } ;

STRUCT: D3DX11_FFT_BUFFER_INFO
    { NumTempBufferSize          UINT                                    }
    { TempBufferFloatSizes       UINT[D3DX11_FFT_MAX_TEMP_BUFFERS]       }
    { NumPrecomputeBufferSizes   UINT                                    }
    { PrecomputeBufferFloatSizes UINT[D3DX11_FFT_MAX_PRECOMPUTE_BUFFERS] } ;

CONSTANT: D3DX11_FFT_CREATE_FLAG_NO_PRECOMPUTE_BUFFERS 1
TYPEDEF: int D3DX11_FFT_CREATE_FLAG

FUNCTION: HRESULT D3DX11CreateFFT ( ID3D11DeviceContext* pDeviceContext, D3DX11_FFT_DESC* pDesc, UINT Flags, D3DX11_FFT_BUFFER_INFO* pBufferInfo, ID3DX11FFT** ppFFT )
FUNCTION: HRESULT D3DX11CreateFFT1DReal ( ID3D11DeviceContext* pDeviceContext, UINT X, UINT Flags, D3DX11_FFT_BUFFER_INFO* pBufferInfo, ID3DX11FFT** ppFFT )
FUNCTION: HRESULT D3DX11CreateFFT1DComplex ( ID3D11DeviceContext* pDeviceContext, UINT X, UINT Flags, D3DX11_FFT_BUFFER_INFO* pBufferInfo, ID3DX11FFT** ppFFT )
FUNCTION: HRESULT D3DX11CreateFFT2DReal ( ID3D11DeviceContext* pDeviceContext, UINT X, UINT Y, UINT Flags, D3DX11_FFT_BUFFER_INFO* pBufferInfo, ID3DX11FFT** ppFFT )
FUNCTION: HRESULT D3DX11CreateFFT2DComplex ( ID3D11DeviceContext* pDeviceContext, UINT X, UINT Y, UINT Flags, D3DX11_FFT_BUFFER_INFO* pBufferInfo, ID3DX11FFT** ppFFT )
FUNCTION: HRESULT D3DX11CreateFFT3DReal ( ID3D11DeviceContext* pDeviceContext, UINT X, UINT Y, UINT Z, UINT Flags, D3DX11_FFT_BUFFER_INFO* pBufferInfo, ID3DX11FFT** ppFFT )
FUNCTION: HRESULT D3DX11CreateFFT3DComplex ( ID3D11DeviceContext* pDeviceContext, UINT X, UINT Y, UINT Z, UINT Flags, D3DX11_FFT_BUFFER_INFO* pBufferInfo, ID3DX11FFT** ppFFT )
