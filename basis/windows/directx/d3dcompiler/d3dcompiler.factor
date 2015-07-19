USING: alien.c-types alien.syntax windows.directx windows.ole32 windows.types ;
IN: windows.directx.d3dcompiler

LIBRARY: d3dcompiler

C-TYPE: D3D_SHADER_MACRO
C-TYPE: ID3DBlob
TYPEDEF: ID3DBlob* LPD3DBLOB
C-TYPE: ID3DInclude
TYPEDEF: ID3DInclude* LPD3DINCLUDE
C-TYPE: ID3D10Effect

FUNCTION: HRESULT D3DCompile (
    LPCVOID           pSrcData,
    SIZE_T            SrcDataSize,
    LPCSTR            pSourceName,
    D3D_SHADER_MACRO* pDefines,
    LPD3DINCLUDE      pInclude,
    LPCSTR            pEntrypoint,
    LPCSTR            pTarget,
    UINT              Flags1,
    UINT              Flags2,
    LPD3DBLOB*        ppCode,
    LPD3DBLOB*        ppErrorMsgs )

FUNCTION: HRESULT D3DPreprocess (
    LPCVOID           pSrcData,
    SIZE_T            SrcDataSize,
    LPCSTR            pSourceName,
    D3D_SHADER_MACRO* pDefines,
    LPD3DINCLUDE      pInclude,
    LPD3DBLOB*        ppCodeText,
    LPD3DBLOB*        ppErrorMsgs )

FUNCTION: HRESULT D3DGetDebugInfo (
    LPCVOID    pSrcData,
    SIZE_T     SrcDataSize,
    LPD3DBLOB* ppDebugInfo )

FUNCTION: HRESULT D3DReflect (
    LPCVOID    pSrcData,
    SIZE_T     SrcDataSize,
    REFIID     pInterface,
    void**     ppReflector )

CONSTANT: D3D_DISASM_ENABLE_COLOR_CODE            1
CONSTANT: D3D_DISASM_ENABLE_DEFAULT_VALUE_PRINTS  2
CONSTANT: D3D_DISASM_ENABLE_INSTRUCTION_NUMBERING 4
CONSTANT: D3D_DISASM_ENABLE_INSTRUCTION_CYCLE     8

FUNCTION: HRESULT D3DDisassemble (
    LPCVOID    pSrcData,
    SIZE_T     SrcDataSize,
    UINT       Flags,
    LPCSTR     szComments,
    LPD3DBLOB* ppDisassembly )

FUNCTION: HRESULT D3DDisassemble10Effect (
    ID3D10Effect* pEffect,
    UINT          Flags,
    LPD3DBLOB*    ppDisassembly )

FUNCTION: HRESULT D3DGetInputSignatureBlob (
    LPCVOID    pSrcData,
    SIZE_T     SrcDataSize,
    LPD3DBLOB* ppSignatureBlob )

FUNCTION: HRESULT D3DGetOutputSignatureBlob (
    LPCVOID    pSrcData,
    SIZE_T     SrcDataSize,
    LPD3DBLOB* ppSignatureBlob )

FUNCTION: HRESULT D3DGetInputAndOutputSignatureBlob (
    LPCVOID    pSrcData,
    SIZE_T     SrcDataSize,
    LPD3DBLOB* ppSignatureBlob )

CONSTANT: D3DCOMPILER_STRIP_REFLECTION_DATA 1
CONSTANT: D3DCOMPILER_STRIP_DEBUG_INFO      2
CONSTANT: D3DCOMPILER_STRIP_TEST_BLOBS      4
CONSTANT: D3DCOMPILER_STRIP_FORCE_DWORD     0x7fffffff
TYPEDEF: int D3DCOMPILER_STRIP_FLAGS

FUNCTION: HRESULT D3DStripShader (
    LPCVOID    pShaderBytecode,
    SIZE_T     BytecodeLength,
    UINT       uStripFlags,
    LPD3DBLOB* ppStrippedBlob )
