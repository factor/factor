USING: alien.syntax windows.directx windows.directx.d3d10misc
windows.directx.d3d10shader windows.directx.d3d11
windows.directx.d3dx11core windows.directx.d3dx11tex windows.types ;
IN: windows.directx.d3dx11async

LIBRARY: d3dx11

FUNCTION: HRESULT D3DX11CompileFromFileA ( LPCSTR pSrcFile, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )
FUNCTION: HRESULT D3DX11CompileFromFileW ( LPCWSTR pSrcFile, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )
ALIAS: D3DX11CompileFromFile D3DX11CompileFromFileW

FUNCTION: HRESULT D3DX11CompileFromResourceA ( HMODULE hSrcModule, LPCSTR pSrcResource, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )
FUNCTION: HRESULT D3DX11CompileFromResourceW ( HMODULE hSrcModule, LPCWSTR pSrcResource, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )
ALIAS: D3DX11CompileFromResource D3DX11CompileFromResourceW

FUNCTION: HRESULT D3DX11CompileFromMemory ( LPCSTR pSrcData, SIZE_T SrcDataLen, LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
    LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX11PreprocessShaderFromFileA ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX11PreprocessShaderFromFileW ( LPCWSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX11PreprocessShaderFromMemory ( LPCSTR pSrcData, SIZE_T SrcDataSize, LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX11PreprocessShaderFromResourceA ( HMODULE hModule, LPCSTR pResourceName, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX11PreprocessShaderFromResourceW ( HMODULE hModule, LPCWSTR pResourceName, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX11ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

ALIAS: D3DX11PreprocessShaderFromFile      D3DX11PreprocessShaderFromFileW
ALIAS: D3DX11PreprocessShaderFromResource  D3DX11PreprocessShaderFromResourceW

FUNCTION: HRESULT D3DX11CreateAsyncCompilerProcessor ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2,
        ID3D10Blob** ppCompiledShader, ID3D10Blob** ppErrorBuffer, ID3DX11DataProcessor** ppProcessor )

FUNCTION: HRESULT D3DX11CreateAsyncShaderPreprocessProcessor ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorBuffer, ID3DX11DataProcessor** ppProcessor )

FUNCTION: HRESULT D3DX11CreateAsyncFileLoaderW ( LPCWSTR pFileName, ID3DX11DataLoader** ppDataLoader )
FUNCTION: HRESULT D3DX11CreateAsyncFileLoaderA ( LPCSTR pFileName, ID3DX11DataLoader** ppDataLoader )
FUNCTION: HRESULT D3DX11CreateAsyncMemoryLoader ( LPCVOID pData, SIZE_T cbData, ID3DX11DataLoader** ppDataLoader )
FUNCTION: HRESULT D3DX11CreateAsyncResourceLoaderW ( HMODULE hSrcModule, LPCWSTR pSrcResource, ID3DX11DataLoader** ppDataLoader )
FUNCTION: HRESULT D3DX11CreateAsyncResourceLoaderA ( HMODULE hSrcModule, LPCSTR pSrcResource, ID3DX11DataLoader** ppDataLoader )

ALIAS: D3DX11CreateAsyncFileLoader D3DX11CreateAsyncFileLoaderW
ALIAS: D3DX11CreateAsyncResourceLoader D3DX11CreateAsyncResourceLoaderW

FUNCTION: HRESULT D3DX11CreateAsyncTextureProcessor ( ID3D11Device* pDevice, D3DX11_IMAGE_LOAD_INFO* pLoadInfo, ID3DX11DataProcessor** ppDataProcessor )
FUNCTION: HRESULT D3DX11CreateAsyncTextureInfoProcessor ( D3DX11_IMAGE_INFO* pImageInfo, ID3DX11DataProcessor** ppDataProcessor )
FUNCTION: HRESULT D3DX11CreateAsyncShaderResourceViewProcessor ( ID3D11Device* pDevice, D3DX11_IMAGE_LOAD_INFO* pLoadInfo, ID3DX11DataProcessor** ppDataProcessor )
