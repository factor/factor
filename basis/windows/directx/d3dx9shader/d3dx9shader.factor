USING: alien.c-types alien.syntax classes.struct math
windows.com windows.com.syntax windows.directx
windows.directx.d3d9 windows.directx.d3dx9core
windows.directx.d3dx9math windows.types ;
IN: windows.directx.d3dx9shader

LIBRARY: d3dx9

: D3DXSHADER_DEBUG                          ( -- n ) 1 0 shift ; inline
: D3DXSHADER_SKIPVALIDATION                 ( -- n ) 1 1 shift ; inline
: D3DXSHADER_SKIPOPTIMIZATION               ( -- n ) 1 2 shift ; inline
: D3DXSHADER_PACKMATRIX_ROWMAJOR            ( -- n ) 1 3 shift ; inline
: D3DXSHADER_PACKMATRIX_COLUMNMAJOR         ( -- n ) 1 4 shift ; inline
: D3DXSHADER_PARTIALPRECISION               ( -- n ) 1 5 shift ; inline
: D3DXSHADER_FORCE_VS_SOFTWARE_NOOPT        ( -- n ) 1 6 shift ; inline
: D3DXSHADER_FORCE_PS_SOFTWARE_NOOPT        ( -- n ) 1 7 shift ; inline
: D3DXSHADER_NO_PRESHADER                   ( -- n ) 1 8 shift ; inline
: D3DXSHADER_AVOID_FLOW_CONTROL             ( -- n ) 1 9 shift ; inline
: D3DXSHADER_PREFER_FLOW_CONTROL            ( -- n ) 1 10 shift ; inline
: D3DXSHADER_ENABLE_BACKWARDS_COMPATIBILITY ( -- n ) 1 12 shift ; inline
: D3DXSHADER_IEEE_STRICTNESS                ( -- n ) 1 13 shift ; inline
: D3DXSHADER_USE_LEGACY_D3DX9_31_DLL        ( -- n ) 1 16 shift ; inline

: D3DXSHADER_OPTIMIZATION_LEVEL0            ( -- n ) 1 14 shift ; inline
: D3DXSHADER_OPTIMIZATION_LEVEL1            ( -- n ) 0 ; inline
: D3DXSHADER_OPTIMIZATION_LEVEL2            ( -- n ) 1 14 shift 1 15 shift bitor ; inline
: D3DXSHADER_OPTIMIZATION_LEVEL3            ( -- n ) 1 15 shift ; inline

: D3DXCONSTTABLE_LARGEADDRESSAWARE          ( -- n ) 1 17 shift ; inline

TYPEDEF: LPCSTR D3DXHANDLE
TYPEDEF: D3DXHANDLE* LPD3DXHANDLE

STRUCT: D3DXMACRO
    { Name       LPCSTR }
    { Definition LPCSTR } ;
TYPEDEF: D3DXMACRO* LPD3DXMACRO

STRUCT: D3DXSEMANTIC
    { Usage      UINT }
    { UsageIndex UINT } ;
TYPEDEF: D3DXSEMANTIC* LPD3DXSEMANTIC

ENUM: D3DXREGISTER_SET
    D3DXRS_BOOL
    D3DXRS_INT4
    D3DXRS_FLOAT4
    D3DXRS_SAMPLER ;
TYPEDEF: D3DXREGISTER_SET* LPD3DXREGISTER_SET

ENUM: D3DXPARAMETER_CLASS
    D3DXPC_SCALAR
    D3DXPC_VECTOR
    D3DXPC_MATRIX_ROWS
    D3DXPC_MATRIX_COLUMNS
    D3DXPC_OBJECT
    D3DXPC_STRUCT ;
TYPEDEF: D3DXPARAMETER_CLASS* LPD3DXPARAMETER_CLASS

ENUM: D3DXPARAMETER_TYPE
    D3DXPT_VOID
    D3DXPT_BOOL
    D3DXPT_INT
    D3DXPT_FLOAT
    D3DXPT_STRING
    D3DXPT_TEXTURE
    D3DXPT_TEXTURE1D
    D3DXPT_TEXTURE2D
    D3DXPT_TEXTURE3D
    D3DXPT_TEXTURECUBE
    D3DXPT_SAMPLER
    D3DXPT_SAMPLER1D
    D3DXPT_SAMPLER2D
    D3DXPT_SAMPLER3D
    D3DXPT_SAMPLERCUBE
    D3DXPT_PIXELSHADER
    D3DXPT_VERTEXSHADER
    D3DXPT_PIXELFRAGMENT
    D3DXPT_VERTEXFRAGMENT
    D3DXPT_UNSUPPORTED ;
TYPEDEF: D3DXPARAMETER_TYPE* LPD3DXPARAMETER_TYPE

STRUCT: D3DXCONSTANTTABLE_DESC
    { Creator   LPCSTR }
    { Version   DWORD  }
    { Constants UINT   } ;
TYPEDEF: D3DXCONSTANTTABLE_DESC* LPD3DXCONSTANTTABLE_DESC

STRUCT: D3DXCONSTANT_DESC
    { Name          LPCSTR              }
    { RegisterSet   D3DXREGISTER_SET    }
    { RegisterIndex UINT                }
    { RegisterCount UINT                }
    { Class         D3DXPARAMETER_CLASS }
    { Type          D3DXPARAMETER_TYPE  }
    { Rows          UINT                }
    { Columns       UINT                }
    { Elements      UINT                }
    { StructMembers UINT                }
    { Bytes         UINT                }
    { DefaultValue  LPCVOID             } ;
TYPEDEF: D3DXCONSTANT_DESC* LPD3DXCONSTANT_DESC

C-TYPE: ID3DXConstantTable
TYPEDEF: ID3DXConstantTable* LPD3DXCONSTANTTABLE

COM-INTERFACE: ID3DXConstantTable IUnknown {AB3C758F-093E-4356-B762-4DB18F1B3A01}
    LPVOID GetBufferPointer ( )
    DWORD GetBufferSize ( )
    HRESULT GetDesc ( D3DXCONSTANTTABLE_DESC* pDesc )
    HRESULT GetConstantDesc ( D3DXHANDLE hConstant, D3DXCONSTANT_DESC* pConstantDesc, UINT* pCount )
    UINT GetSamplerIndex ( D3DXHANDLE hConstant )
    D3DXHANDLE GetConstant ( D3DXHANDLE hConstant, UINT Index )
    D3DXHANDLE GetConstantByName ( D3DXHANDLE hConstant, LPCSTR pName )
    D3DXHANDLE GetConstantElement ( D3DXHANDLE hConstant, UINT Index )
    HRESULT SetDefaults ( LPDIRECT3DDEVICE9 pDevice )
    HRESULT SetValue ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, LPCVOID pData, UINT Bytes )
    HRESULT SetBool ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, BOOL b )
    HRESULT SetBoolArray ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, BOOL* pb, UINT Count )
    HRESULT SetInt ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, INT n )
    HRESULT SetIntArray ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, INT* pn, UINT Count )
    HRESULT SetFloat ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, FLOAT f )
    HRESULT SetFloatArray ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, FLOAT* pf, UINT Count )
    HRESULT SetVector ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, D3DXVECTOR4* pVector )
    HRESULT SetVectorArray ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, D3DXVECTOR4* pVector, UINT Count )
    HRESULT SetMatrix ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, D3DXMATRIX* pMatrix )
    HRESULT SetMatrixArray ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, D3DXMATRIX* pMatrix, UINT Count )
    HRESULT SetMatrixPointerArray ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, D3DXMATRIX** ppMatrix, UINT Count )
    HRESULT SetMatrixTranspose ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, D3DXMATRIX* pMatrix )
    HRESULT SetMatrixTransposeArray ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, D3DXMATRIX* pMatrix, UINT Count )
    HRESULT SetMatrixTransposePointerArray ( LPDIRECT3DDEVICE9 pDevice, D3DXHANDLE hConstant, D3DXMATRIX** ppMatrix, UINT Count ) ;

C-TYPE: ID3DXTextureShader
TYPEDEF: ID3DXTextureShader* LPD3DXTEXTURESHADER

COM-INTERFACE: ID3DXTextureShader IUnknown {3E3D67F8-AA7A-405d-A857-BA01D4758426}
    HRESULT GetFunction ( LPD3DXBUFFER* ppFunction )
    HRESULT GetConstantBuffer ( LPD3DXBUFFER* ppConstantBuffer )
    HRESULT GetDesc ( D3DXCONSTANTTABLE_DESC* pDesc )
    HRESULT GetConstantDesc ( D3DXHANDLE hConstant, D3DXCONSTANT_DESC* pConstantDesc, UINT* pCount )
    D3DXHANDLE GetConstant ( D3DXHANDLE hConstant, UINT Index )
    D3DXHANDLE GetConstantByName ( D3DXHANDLE hConstant, LPCSTR pName )
    D3DXHANDLE GetConstantElement ( D3DXHANDLE hConstant, UINT Index )
    HRESULT SetDefaults ( )
    HRESULT SetValue ( D3DXHANDLE hConstant, LPCVOID pData, UINT Bytes )
    HRESULT SetBool ( D3DXHANDLE hConstant, BOOL b )
    HRESULT SetBoolArray ( D3DXHANDLE hConstant, BOOL* pb, UINT Count )
    HRESULT SetInt ( D3DXHANDLE hConstant, INT n )
    HRESULT SetIntArray ( D3DXHANDLE hConstant, INT* pn, UINT Count )
    HRESULT SetFloat ( D3DXHANDLE hConstant, FLOAT f )
    HRESULT SetFloatArray ( D3DXHANDLE hConstant, FLOAT* pf, UINT Count )
    HRESULT SetVector ( D3DXHANDLE hConstant, D3DXVECTOR4* pVector )
    HRESULT SetVectorArray ( D3DXHANDLE hConstant, D3DXVECTOR4* pVector, UINT Count )
    HRESULT SetMatrix ( D3DXHANDLE hConstant, D3DXMATRIX* pMatrix )
    HRESULT SetMatrixArray ( D3DXHANDLE hConstant, D3DXMATRIX* pMatrix, UINT Count )
    HRESULT SetMatrixPointerArray ( D3DXHANDLE hConstant, D3DXMATRIX** ppMatrix, UINT Count )
    HRESULT SetMatrixTranspose ( D3DXHANDLE hConstant, D3DXMATRIX* pMatrix )
    HRESULT SetMatrixTransposeArray ( D3DXHANDLE hConstant, D3DXMATRIX* pMatrix, UINT Count )
    HRESULT SetMatrixTransposePointerArray ( D3DXHANDLE hConstant, D3DXMATRIX** ppMatrix, UINT Count ) ;

ENUM: D3DXINCLUDE_TYPE
    D3DXINC_LOCAL
    D3DXINC_SYSTEM ;
TYPEDEF: D3DXINCLUDE_TYPE* LPD3DXINCLUDE_TYPE

C-TYPE: ID3DXInclude
TYPEDEF: ID3DXInclude* LPD3DXINCLUDE

COM-INTERFACE: ID3DXInclude f {00000000-0000-0000-0000-000000000000}
    HRESULT Open ( D3DXINCLUDE_TYPE IncludeType, LPCSTR pFileName, LPCVOID pParentData, LPCVOID* ppData, UINT* pBytes )
    HRESULT Close ( LPCVOID pData ) ;

FUNCTION: HRESULT
    D3DXAssembleShaderFromFileA (
        LPCSTR                          pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs )

FUNCTION: HRESULT
    D3DXAssembleShaderFromFileW (
        LPCWSTR                         pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs )

ALIAS: D3DXAssembleShaderFromFile D3DXAssembleShaderFromFileW

FUNCTION: HRESULT
    D3DXAssembleShaderFromResourceA (
        HMODULE                         hSrcModule,
        LPCSTR                          pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs )

FUNCTION: HRESULT
    D3DXAssembleShaderFromResourceW (
        HMODULE                         hSrcModule,
        LPCWSTR                         pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs )

ALIAS: D3DXAssembleShaderFromResource D3DXAssembleShaderFromResourceW

FUNCTION: HRESULT
    D3DXAssembleShader (
        LPCSTR                          pSrcData,
        UINT                            SrcDataLen,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs )

FUNCTION: HRESULT
    D3DXCompileShaderFromFileA (
        LPCSTR                          pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pFunctionName,
        LPCSTR                          pProfile,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs,
        LPD3DXCONSTANTTABLE*            ppConstantTable )

FUNCTION: HRESULT
    D3DXCompileShaderFromFileW (
        LPCWSTR                         pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pFunctionName,
        LPCSTR                          pProfile,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs,
        LPD3DXCONSTANTTABLE*            ppConstantTable )

ALIAS: D3DXCompileShaderFromFile D3DXCompileShaderFromFileW

FUNCTION: HRESULT
    D3DXCompileShaderFromResourceA (
        HMODULE                         hSrcModule,
        LPCSTR                          pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pFunctionName,
        LPCSTR                          pProfile,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs,
        LPD3DXCONSTANTTABLE*            ppConstantTable )

FUNCTION: HRESULT
    D3DXCompileShaderFromResourceW (
        HMODULE                         hSrcModule,
        LPCWSTR                         pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pFunctionName,
        LPCSTR                          pProfile,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs,
        LPD3DXCONSTANTTABLE*            ppConstantTable )

ALIAS: D3DXCompileShaderFromResource D3DXCompileShaderFromResourceW

FUNCTION: HRESULT
    D3DXCompileShader (
        LPCSTR                          pSrcData,
        UINT                            SrcDataLen,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pFunctionName,
        LPCSTR                          pProfile,
        DWORD                           Flags,
        LPD3DXBUFFER*                   ppShader,
        LPD3DXBUFFER*                   ppErrorMsgs,
        LPD3DXCONSTANTTABLE*            ppConstantTable )

FUNCTION: HRESULT
    D3DXDisassembleShader (
        DWORD*                          pShader,
        BOOL                            EnableColorCode,
        LPCSTR                          pComments,
        LPD3DXBUFFER*                   ppDisassembly )

FUNCTION: LPCSTR
    D3DXGetPixelShaderProfile (
        LPDIRECT3DDEVICE9               pDevice )

FUNCTION: LPCSTR
    D3DXGetVertexShaderProfile (
        LPDIRECT3DDEVICE9               pDevice )

FUNCTION: HRESULT
    D3DXFindShaderComment (
        DWORD*                          pFunction,
        DWORD                           FourCC,
        LPCVOID*                        ppData,
        UINT*                           pSizeInBytes )

FUNCTION: UINT
    D3DXGetShaderSize (
        DWORD*                    pFunction )

FUNCTION: DWORD
    D3DXGetShaderVersion (
        DWORD*                    pFunction )

FUNCTION: HRESULT
    D3DXGetShaderInputSemantics (
        DWORD*                          pFunction,
        D3DXSEMANTIC*                   pSemantics,
        UINT*                           pCount )

FUNCTION: HRESULT
    D3DXGetShaderOutputSemantics (
        DWORD*                          pFunction,
        D3DXSEMANTIC*                   pSemantics,
        UINT*                           pCount )

FUNCTION: HRESULT
    D3DXGetShaderSamplers (
        DWORD*                          pFunction,
        LPCSTR*                         pSamplers,
        UINT*                           pCount )

FUNCTION: HRESULT
    D3DXGetShaderConstantTable (
        DWORD*                          pFunction,
        LPD3DXCONSTANTTABLE*            ppConstantTable )

FUNCTION: HRESULT
    D3DXGetShaderConstantTableEx (
        DWORD*                          pFunction,
        DWORD                           Flags,
        LPD3DXCONSTANTTABLE*            ppConstantTable )

FUNCTION: HRESULT
    D3DXCreateTextureShader (
        DWORD*                          pFunction,
        LPD3DXTEXTURESHADER*            ppTextureShader )

FUNCTION: HRESULT
    D3DXPreprocessShaderFromFileA (
        LPCSTR                       pSrcFile,
        D3DXMACRO*                   pDefines,
        LPD3DXINCLUDE                pInclude,
        LPD3DXBUFFER*                ppShaderText,
        LPD3DXBUFFER*                ppErrorMsgs )

FUNCTION: HRESULT
    D3DXPreprocessShaderFromFileW (
        LPCWSTR                      pSrcFile,
        D3DXMACRO*                   pDefines,
        LPD3DXINCLUDE                pInclude,
        LPD3DXBUFFER*                ppShaderText,
        LPD3DXBUFFER*                ppErrorMsgs )

ALIAS: D3DXPreprocessShaderFromFile D3DXPreprocessShaderFromFileW

FUNCTION: HRESULT
    D3DXPreprocessShaderFromResourceA (
        HMODULE                      hSrcModule,
        LPCSTR                       pSrcResource,
        D3DXMACRO*                   pDefines,
        LPD3DXINCLUDE                pInclude,
        LPD3DXBUFFER*                ppShaderText,
        LPD3DXBUFFER*                ppErrorMsgs )

FUNCTION: HRESULT
    D3DXPreprocessShaderFromResourceW (
        HMODULE                      hSrcModule,
        LPCWSTR                      pSrcResource,
        D3DXMACRO*                   pDefines,
        LPD3DXINCLUDE                pInclude,
        LPD3DXBUFFER*                ppShaderText,
        LPD3DXBUFFER*                ppErrorMsgs )

ALIAS: D3DXPreprocessShaderFromResource D3DXPreprocessShaderFromResourceW

FUNCTION: HRESULT
    D3DXPreprocessShader (
        LPCSTR                       pSrcData,
        UINT                         SrcDataSize,
        D3DXMACRO*                   pDefines,
        LPD3DXINCLUDE                pInclude,
        LPD3DXBUFFER*                ppShaderText,
        LPD3DXBUFFER*                ppErrorMsgs )

STRUCT: D3DXSHADER_CONSTANTTABLE
    { Size         DWORD }
    { Creator      DWORD }
    { Version      DWORD }
    { Constants    DWORD }
    { ConstantInfo DWORD }
    { Flags        DWORD }
    { Target       DWORD } ;
TYPEDEF: D3DXSHADER_CONSTANTTABLE* LPD3DXSHADER_CONSTANTTABLE

STRUCT: D3DXSHADER_CONSTANTINFO
    { Name           DWORD }
    { RegisterSet    WORD  }
    { RegisterIndex  WORD  }
    { RegisterCount  WORD  }
    { Reserved       WORD  }
    { TypeInfo       DWORD }
    { DefaultValue   DWORD } ;
TYPEDEF: D3DXSHADER_CONSTANTINFO* LPD3DXSHADER_CONSTANTINFO

STRUCT: D3DXSHADER_TYPEINFO
    { Class            WORD  }
    { Type             WORD  }
    { Rows             WORD  }
    { Columns          WORD  }
    { Elements         WORD  }
    { StructMembers    WORD  }
    { StructMemberInfo DWORD } ;
TYPEDEF: D3DXSHADER_TYPEINFO* LPD3DXSHADER_TYPEINFO

STRUCT: D3DXSHADER_STRUCTMEMBERINFO
    { Name     DWORD }
    { TypeInfo DWORD } ;
TYPEDEF: D3DXSHADER_STRUCTMEMBERINFO* LPD3DXSHADER_STRUCTMEMBERINFO
