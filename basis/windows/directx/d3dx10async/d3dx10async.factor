USING: alien.syntax windows.directx windows.directx.d3d10
windows.directx.d3d10misc windows.directx.d3d10shader
windows.directx.d3dx10core windows.types ;
IN: windows.directx.d3dx10async

LIBRARY: d3dx10

C-TYPE: ID3DX10ThreadPump
C-TYPE: ID3D10EffectPool
C-TYPE: D3DX10_IMAGE_LOAD_INFO
C-TYPE: D3DX10_IMAGE_INFO
C-TYPE: ID3D10Effect

FUNCTION: HRESULT D3DX10CompileFromFileA ( LPCSTR pSrcFile, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CompileFromFileW ( LPCWSTR pSrcFile, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

ALIAS: D3DX10CompileFromFile D3DX10CompileFromFileW

FUNCTION: HRESULT D3DX10CompileFromResourceA ( HMODULE hSrcModule, LPCSTR pSrcResource, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CompileFromResourceW ( HMODULE hSrcModule, LPCWSTR pSrcResource, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

ALIAS: D3DX10CompileFromResource D3DX10CompileFromResourceW

FUNCTION: HRESULT D3DX10CompileFromMemory ( LPCSTR pSrcData, SIZE_T SrcDataLen, LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
    LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectFromFileA ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice,
    ID3D10EffectPool* pEffectPool, ID3DX10ThreadPump* pPump, ID3D10Effect** ppEffect, ID3D10Blob** ppErrors, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectFromFileW ( LPCWSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice,
    ID3D10EffectPool* pEffectPool, ID3DX10ThreadPump* pPump, ID3D10Effect** ppEffect, ID3D10Blob** ppErrors, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectFromMemory ( LPCVOID pData, SIZE_T DataLength, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice,
    ID3D10EffectPool* pEffectPool, ID3DX10ThreadPump* pPump, ID3D10Effect** ppEffect, ID3D10Blob** ppErrors, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectFromResourceA ( HMODULE hModule, LPCSTR pResourceName, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice,
    ID3D10EffectPool* pEffectPool, ID3DX10ThreadPump* pPump, ID3D10Effect** ppEffect, ID3D10Blob** ppErrors, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectFromResourceW ( HMODULE hModule, LPCWSTR pResourceName, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice,
    ID3D10EffectPool* pEffectPool, ID3DX10ThreadPump* pPump, ID3D10Effect** ppEffect, ID3D10Blob** ppErrors, HRESULT* pHResult )

ALIAS: D3DX10CreateEffectFromFile          D3DX10CreateEffectFromFileW
ALIAS: D3DX10CreateEffectFromResource      D3DX10CreateEffectFromResourceW

FUNCTION: HRESULT D3DX10CreateEffectPoolFromFileA ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice, ID3DX10ThreadPump* pPump,
    ID3D10EffectPool** ppEffectPool, ID3D10Blob** ppErrors, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectPoolFromFileW ( LPCWSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice, ID3DX10ThreadPump* pPump,
    ID3D10EffectPool** ppEffectPool, ID3D10Blob** ppErrors, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectPoolFromMemory ( LPCVOID pData, SIZE_T DataLength, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice,
    ID3DX10ThreadPump* pPump, ID3D10EffectPool** ppEffectPool, ID3D10Blob** ppErrors, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectPoolFromResourceA ( HMODULE hModule, LPCSTR pResourceName, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice,
    ID3DX10ThreadPump* pPump, ID3D10EffectPool** ppEffectPool, ID3D10Blob** ppErrors, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10CreateEffectPoolFromResourceW ( HMODULE hModule, LPCWSTR pResourceName, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, LPCSTR pProfile, UINT HLSLFlags, UINT FXFlags, ID3D10Device* pDevice,
    ID3DX10ThreadPump* pPump, ID3D10EffectPool** ppEffectPool, ID3D10Blob** ppErrors, HRESULT* pHResult )

ALIAS: D3DX10CreateEffectPoolFromFile      D3DX10CreateEffectPoolFromFileW
ALIAS: D3DX10CreateEffectPoolFromResource  D3DX10CreateEffectPoolFromResourceW

FUNCTION: HRESULT D3DX10PreprocessShaderFromFileA ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10PreprocessShaderFromFileW ( LPCWSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10PreprocessShaderFromMemory ( LPCSTR pSrcData, SIZE_T SrcDataSize, LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10PreprocessShaderFromResourceA ( HMODULE hModule, LPCSTR pResourceName, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

FUNCTION: HRESULT D3DX10PreprocessShaderFromResourceW ( HMODULE hModule, LPCWSTR pResourceName, LPCWSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    LPD3D10INCLUDE pInclude, ID3DX10ThreadPump* pPump, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs, HRESULT* pHResult )

ALIAS: D3DX10PreprocessShaderFromFile      D3DX10PreprocessShaderFromFileW
ALIAS: D3DX10PreprocessShaderFromResource  D3DX10PreprocessShaderFromResourceW

FUNCTION: HRESULT D3DX10CreateAsyncCompilerProcessor ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags1, UINT Flags2,
        ID3D10Blob** ppCompiledShader, ID3D10Blob** ppErrorBuffer, ID3DX10DataProcessor** ppProcessor )

FUNCTION: HRESULT D3DX10CreateAsyncEffectCreateProcessor ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        LPCSTR pProfile, UINT Flags, UINT FXFlags, ID3D10Device* pDevice,
        ID3D10EffectPool* pPool, ID3D10Blob** ppErrorBuffer, ID3DX10DataProcessor** ppProcessor )

FUNCTION: HRESULT D3DX10CreateAsyncEffectPoolCreateProcessor ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        LPCSTR pProfile, UINT Flags, UINT FXFlags, ID3D10Device* pDevice,
        ID3D10Blob** ppErrorBuffer, ID3DX10DataProcessor** ppProcessor )

FUNCTION: HRESULT D3DX10CreateAsyncShaderPreprocessProcessor ( LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, LPD3D10INCLUDE pInclude,
        ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorBuffer, ID3DX10DataProcessor** ppProcessor )

FUNCTION: HRESULT D3DX10CreateAsyncFileLoaderW ( LPCWSTR pFileName, ID3DX10DataLoader** ppDataLoader )
FUNCTION: HRESULT D3DX10CreateAsyncFileLoaderA ( LPCSTR pFileName, ID3DX10DataLoader** ppDataLoader )
FUNCTION: HRESULT D3DX10CreateAsyncMemoryLoader ( LPCVOID pData, SIZE_T cbData, ID3DX10DataLoader** ppDataLoader )
FUNCTION: HRESULT D3DX10CreateAsyncResourceLoaderW ( HMODULE hSrcModule, LPCWSTR pSrcResource, ID3DX10DataLoader** ppDataLoader )
FUNCTION: HRESULT D3DX10CreateAsyncResourceLoaderA ( HMODULE hSrcModule, LPCSTR pSrcResource, ID3DX10DataLoader** ppDataLoader )

ALIAS: D3DX10CreateAsyncFileLoader D3DX10CreateAsyncFileLoaderW
ALIAS: D3DX10CreateAsyncResourceLoader D3DX10CreateAsyncResourceLoaderW

FUNCTION: HRESULT D3DX10CreateAsyncTextureProcessor ( ID3D10Device* pDevice, D3DX10_IMAGE_LOAD_INFO* pLoadInfo, ID3DX10DataProcessor** ppDataProcessor )
FUNCTION: HRESULT D3DX10CreateAsyncTextureInfoProcessor ( D3DX10_IMAGE_INFO* pImageInfo, ID3DX10DataProcessor** ppDataProcessor )
FUNCTION: HRESULT D3DX10CreateAsyncShaderResourceViewProcessor ( ID3D10Device* pDevice, D3DX10_IMAGE_LOAD_INFO* pLoadInfo, ID3DX10DataProcessor** ppDataProcessor )
