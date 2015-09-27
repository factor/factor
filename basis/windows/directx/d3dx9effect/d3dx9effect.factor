USING: alien.syntax classes.struct math windows.com
windows.com.syntax windows.directx windows.directx.d3d9
windows.directx.d3d9types windows.directx.d3dx9core
windows.directx.d3dx9math windows.directx.d3dx9shader
windows.types ;
IN: windows.directx.d3dx9effect

LIBRARY: d3dx9

CONSTANT: D3DXFX_DONOTSAVESTATE         1
CONSTANT: D3DXFX_DONOTSAVESHADERSTATE   2
CONSTANT: D3DXFX_DONOTSAVESAMPLERSTATE  4

: D3DXFX_NOT_CLONEABLE     ( -- n ) 1 11 shift ; inline
: D3DXFX_LARGEADDRESSAWARE ( -- n ) 1 17 shift ; inline

CONSTANT: D3DX_PARAMETER_SHARED       1
CONSTANT: D3DX_PARAMETER_LITERAL      2
CONSTANT: D3DX_PARAMETER_ANNOTATION   4

STRUCT: D3DXEFFECT_DESC
    { Creator    LPCSTR }
    { Parameters UINT   }
    { Techniques UINT   }
    { Functions  UINT   } ;

STRUCT: D3DXPARAMETER_DESC
    { Name          LPCSTR              }
    { Semantic      LPCSTR              }
    { Class         D3DXPARAMETER_CLASS }
    { Type          D3DXPARAMETER_TYPE  }
    { Rows          UINT                }
    { Columns       UINT                }
    { Elements      UINT                }
    { Annotations   UINT                }
    { StructMembers UINT                }
    { Flags         DWORD               }
    { Bytes         UINT                } ;

STRUCT: D3DXTECHNIQUE_DESC
    { Name        LPCSTR }
    { Passes      UINT   }
    { Annotations UINT   }  ;

STRUCT: D3DXPASS_DESC
    { Name                  LPCSTR }
    { Annotations           UINT   }
    { pVertexShaderFunction DWORD* }
    { pPixelShaderFunction  DWORD* } ;

STRUCT: D3DXFUNCTION_DESC
    { Name        LPCSTR }
    { Annotations UINT   } ;

C-TYPE: ID3DXEffectPool
TYPEDEF: ID3DXEffectPool* LPD3DXEFFECTPOOL

COM-INTERFACE: ID3DXEffectPool IUnknown {9537AB04-3250-412e-8213-FCD2F8677933} ;

C-TYPE: ID3DXBaseEffect
TYPEDEF: ID3DXBaseEffect* LPD3DXBASEEFFECT

COM-INTERFACE: ID3DXBaseEffect IUnknown {017C18AC-103F-4417-8C51-6BF6EF1E56BE}
    HRESULT GetDesc ( D3DXEFFECT_DESC* pDesc )
    HRESULT GetParameterDesc ( D3DXHANDLE hParameter, D3DXPARAMETER_DESC* pDesc )
    HRESULT GetTechniqueDesc ( D3DXHANDLE hTechnique, D3DXTECHNIQUE_DESC* pDesc )
    HRESULT GetPassDesc ( D3DXHANDLE hPass, D3DXPASS_DESC* pDesc )
    HRESULT GetFunctionDesc ( D3DXHANDLE hShader, D3DXFUNCTION_DESC* pDesc )
    D3DXHANDLE GetParameter ( D3DXHANDLE hParameter, UINT Index )
    D3DXHANDLE GetParameterByName ( D3DXHANDLE hParameter, LPCSTR pName )
    D3DXHANDLE GetParameterBySemantic ( D3DXHANDLE hParameter, LPCSTR pSemantic )
    D3DXHANDLE GetParameterElement ( D3DXHANDLE hParameter, UINT Index )
    D3DXHANDLE GetTechnique ( UINT Index )
    D3DXHANDLE GetTechniqueByName ( LPCSTR pName )
    D3DXHANDLE GetPass ( D3DXHANDLE hTechnique, UINT Index )
    D3DXHANDLE GetPassByName ( D3DXHANDLE hTechnique, LPCSTR pName )
    D3DXHANDLE GetFunction ( UINT Index )
    D3DXHANDLE GetFunctionByName ( LPCSTR pName )
    D3DXHANDLE GetAnnotation ( D3DXHANDLE hObject, UINT Index )
    D3DXHANDLE GetAnnotationByName ( D3DXHANDLE hObject, LPCSTR pName )
    HRESULT SetValue ( D3DXHANDLE hParameter, LPCVOID pData, UINT Bytes )
    HRESULT GetValue ( D3DXHANDLE hParameter, LPVOID pData, UINT Bytes )
    HRESULT SetBool ( D3DXHANDLE hParameter, BOOL b )
    HRESULT GetBool ( D3DXHANDLE hParameter, BOOL* pb )
    HRESULT SetBoolArray ( D3DXHANDLE hParameter, BOOL* pb, UINT Count )
    HRESULT GetBoolArray ( D3DXHANDLE hParameter, BOOL* pb, UINT Count )
    HRESULT SetInt ( D3DXHANDLE hParameter, INT n )
    HRESULT GetInt ( D3DXHANDLE hParameter, INT* pn )
    HRESULT SetIntArray ( D3DXHANDLE hParameter, INT* pn, UINT Count )
    HRESULT GetIntArray ( D3DXHANDLE hParameter, INT* pn, UINT Count )
    HRESULT SetFloat ( D3DXHANDLE hParameter, FLOAT f )
    HRESULT GetFloat ( D3DXHANDLE hParameter, FLOAT* pf )
    HRESULT SetFloatArray ( D3DXHANDLE hParameter, FLOAT* pf, UINT Count )
    HRESULT GetFloatArray ( D3DXHANDLE hParameter, FLOAT* pf, UINT Count )
    HRESULT SetVector ( D3DXHANDLE hParameter, D3DXVECTOR4* pVector )
    HRESULT GetVector ( D3DXHANDLE hParameter, D3DXVECTOR4* pVector )
    HRESULT SetVectorArray ( D3DXHANDLE hParameter, D3DXVECTOR4* pVector, UINT Count )
    HRESULT GetVectorArray ( D3DXHANDLE hParameter, D3DXVECTOR4* pVector, UINT Count )
    HRESULT SetMatrix ( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix )
    HRESULT GetMatrix ( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix )
    HRESULT SetMatrixArray ( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix, UINT Count )
    HRESULT GetMatrixArray ( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix, UINT Count )
    HRESULT SetMatrixPointerArray ( D3DXHANDLE hParameter, D3DXMATRIX** ppMatrix, UINT Count )
    HRESULT GetMatrixPointerArray ( D3DXHANDLE hParameter, D3DXMATRIX** ppMatrix, UINT Count )
    HRESULT SetMatrixTranspose ( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix )
    HRESULT GetMatrixTranspose ( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix )
    HRESULT SetMatrixTransposeArray ( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix, UINT Count )
    HRESULT GetMatrixTransposeArray ( D3DXHANDLE hParameter, D3DXMATRIX* pMatrix, UINT Count )
    HRESULT SetMatrixTransposePointerArray ( D3DXHANDLE hParameter, D3DXMATRIX** ppMatrix, UINT Count )
    HRESULT GetMatrixTransposePointerArray ( D3DXHANDLE hParameter, D3DXMATRIX** ppMatrix, UINT Count )
    HRESULT SetString ( D3DXHANDLE hParameter, LPCSTR pString )
    HRESULT GetString ( D3DXHANDLE hParameter, LPCSTR* ppString )
    HRESULT SetTexture ( D3DXHANDLE hParameter, LPDIRECT3DBASETEXTURE9 pTexture )
    HRESULT GetTexture ( D3DXHANDLE hParameter, LPDIRECT3DBASETEXTURE9* ppTexture )
    HRESULT GetPixelShader ( D3DXHANDLE hParameter, LPDIRECT3DPIXELSHADER9* ppPShader )
    HRESULT GetVertexShader ( D3DXHANDLE hParameter, LPDIRECT3DVERTEXSHADER9* ppVShader )
    HRESULT SetArrayRange ( D3DXHANDLE hParameter, UINT uStart, UINT uEnd ) ;

C-TYPE: ID3DXEffectStateManager
TYPEDEF: ID3DXEffectStateManager* LPD3DXEFFECTSTATEMANAGER

COM-INTERFACE: ID3DXEffectStateManager IUnknown {79AAB587-6DBC-4fa7-82DE-37FA1781C5CE}
    HRESULT SetTransform ( D3DTRANSFORMSTATETYPE State, D3DMATRIX* pMatrix )
    HRESULT SetMaterial ( D3DMATERIAL9* pMaterial )
    HRESULT SetLight ( DWORD Index, D3DLIGHT9* pLight )
    HRESULT LightEnable ( DWORD Index, BOOL Enable )
    HRESULT SetRenderState ( D3DRENDERSTATETYPE State, DWORD Value )
    HRESULT SetTexture ( DWORD Stage, LPDIRECT3DBASETEXTURE9 pTexture )
    HRESULT SetTextureStageState ( DWORD Stage, D3DTEXTURESTAGESTATETYPE Type, DWORD Value )
    HRESULT SetSamplerState ( DWORD Sampler, D3DSAMPLERSTATETYPE Type, DWORD Value )
    HRESULT SetNPatchMode ( FLOAT NumSegments )
    HRESULT SetFVF ( DWORD FVF )
    HRESULT SetVertexShader ( LPDIRECT3DVERTEXSHADER9 pShader )
    HRESULT SetVertexShaderConstantF ( UINT RegisterIndex, FLOAT* pConstantData, UINT RegisterCount )
    HRESULT SetVertexShaderConstantI ( UINT RegisterIndex, INT* pConstantData, UINT RegisterCount )
    HRESULT SetVertexShaderConstantB ( UINT RegisterIndex, BOOL* pConstantData, UINT RegisterCount )
    HRESULT SetPixelShader ( LPDIRECT3DPIXELSHADER9 pShader )
    HRESULT SetPixelShaderConstantF ( UINT RegisterIndex, FLOAT* pConstantData, UINT RegisterCount )
    HRESULT SetPixelShaderConstantI ( UINT RegisterIndex, INT* pConstantData, UINT RegisterCount )
    HRESULT SetPixelShaderConstantB ( UINT RegisterIndex, BOOL* pConstantData, UINT RegisterCount ) ;

C-TYPE: ID3DXEffect
TYPEDEF: ID3DXEffect* LPD3DXEFFECT

COM-INTERFACE: ID3DXEffect ID3DXBaseEffect {F6CEB4B3-4E4C-40dd-B883-8D8DE5EA0CD5}
    HRESULT GetPool ( LPD3DXEFFECTPOOL* ppPool )
    HRESULT SetTechnique ( D3DXHANDLE hTechnique )
    D3DXHANDLE GetCurrentTechnique ( )
    HRESULT ValidateTechnique ( D3DXHANDLE hTechnique )
    HRESULT FindNextValidTechnique ( D3DXHANDLE hTechnique, D3DXHANDLE* pTechnique )
    BOOL IsParameterUsed ( D3DXHANDLE hParameter, D3DXHANDLE hTechnique )
    HRESULT Begin ( UINT* pPasses, DWORD Flags )
    HRESULT BeginPass ( UINT Pass )
    HRESULT CommitChanges ( )
    HRESULT EndPass ( )
    HRESULT End ( )
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT OnLostDevice ( )
    HRESULT OnResetDevice ( )
    HRESULT SetStateManager ( LPD3DXEFFECTSTATEMANAGER pManager )
    HRESULT GetStateManager ( LPD3DXEFFECTSTATEMANAGER* ppManager )
    HRESULT BeginParameterBlock ( )
    D3DXHANDLE EndParameterBlock ( )
    HRESULT ApplyParameterBlock ( D3DXHANDLE hParameterBlock )
    HRESULT DeleteParameterBlock ( D3DXHANDLE hParameterBlock )
    HRESULT CloneEffect ( LPDIRECT3DDEVICE9 pDevice, LPD3DXEFFECT* ppEffect )
    HRESULT SetRawValue ( D3DXHANDLE hParameter, LPCVOID pData, UINT ByteOffset, UINT Bytes ) ;

C-TYPE: ID3DXEffectCompiler
TYPEDEF: ID3DXEffectCompiler* LPD3DXEFFECTCOMPILER

COM-INTERFACE: ID3DXEffectCompiler ID3DXBaseEffect {51B8A949-1A31-47e6-BEA0-4B30DB53F1E0}
    HRESULT SetLiteral ( D3DXHANDLE hParameter, BOOL Literal )
    HRESULT GetLiteral ( D3DXHANDLE hParameter, BOOL* pLiteral )
    HRESULT CompileEffect ( DWORD Flags, LPD3DXBUFFER* ppEffect, LPD3DXBUFFER* ppErrorMsgs )
    HRESULT CompileShader ( D3DXHANDLE hFunction, LPCSTR pTarget, DWORD Flags,
                            LPD3DXBUFFER* ppShader, LPD3DXBUFFER* ppErrorMsgs,
                            LPD3DXCONSTANTTABLE* ppConstantTable ) ;

FUNCTION: HRESULT
    D3DXCreateEffectPool ( LPD3DXEFFECTPOOL* ppPool )

FUNCTION: HRESULT
    D3DXCreateEffectFromFileA (
        LPDIRECT3DDEVICE9               pDevice,
        LPCSTR                          pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

FUNCTION: HRESULT
    D3DXCreateEffectFromFileW (
        LPDIRECT3DDEVICE9               pDevice,
        LPCWSTR                         pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

ALIAS: D3DXCreateEffectFromFile D3DXCreateEffectFromFileW

FUNCTION: HRESULT
    D3DXCreateEffectFromResourceA (
        LPDIRECT3DDEVICE9               pDevice,
        HMODULE                         hSrcModule,
        LPCSTR                          pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

FUNCTION: HRESULT
    D3DXCreateEffectFromResourceW (
        LPDIRECT3DDEVICE9               pDevice,
        HMODULE                         hSrcModule,
        LPCWSTR                         pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

ALIAS: D3DXCreateEffectFromResource D3DXCreateEffectFromResourceW

FUNCTION: HRESULT
    D3DXCreateEffect (
        LPDIRECT3DDEVICE9               pDevice,
        LPCVOID                         pSrcData,
        UINT                            SrcDataLen,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

FUNCTION: HRESULT
    D3DXCreateEffectFromFileExA (
        LPDIRECT3DDEVICE9               pDevice,
        LPCSTR                          pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pSkipConstants,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

FUNCTION: HRESULT
    D3DXCreateEffectFromFileExW (
        LPDIRECT3DDEVICE9               pDevice,
        LPCWSTR                         pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pSkipConstants,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

ALIAS: D3DXCreateEffectFromFileEx D3DXCreateEffectFromFileExW

FUNCTION: HRESULT
    D3DXCreateEffectFromResourceExA (
        LPDIRECT3DDEVICE9               pDevice,
        HMODULE                         hSrcModule,
        LPCSTR                          pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pSkipConstants,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

FUNCTION: HRESULT
    D3DXCreateEffectFromResourceExW (
        LPDIRECT3DDEVICE9               pDevice,
        HMODULE                         hSrcModule,
        LPCWSTR                         pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pSkipConstants,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

ALIAS: D3DXCreateEffectFromResourceEx D3DXCreateEffectFromResourceExW

FUNCTION: HRESULT
    D3DXCreateEffectEx (
        LPDIRECT3DDEVICE9               pDevice,
        LPCVOID                         pSrcData,
        UINT                            SrcDataLen,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        LPCSTR                          pSkipConstants,
        DWORD                           Flags,
        LPD3DXEFFECTPOOL                pPool,
        LPD3DXEFFECT*                   ppEffect,
        LPD3DXBUFFER*                   ppCompilationErrors )

FUNCTION: HRESULT
    D3DXCreateEffectCompilerFromFileA (
        LPCSTR                          pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTCOMPILER*           ppCompiler,
        LPD3DXBUFFER*                   ppParseErrors )

FUNCTION: HRESULT
    D3DXCreateEffectCompilerFromFileW (
        LPCWSTR                         pSrcFile,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTCOMPILER*           ppCompiler,
        LPD3DXBUFFER*                   ppParseErrors )

ALIAS: D3DXCreateEffectCompilerFromFile D3DXCreateEffectCompilerFromFileW

FUNCTION: HRESULT
    D3DXCreateEffectCompilerFromResourceA (
        HMODULE                         hSrcModule,
        LPCSTR                          pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTCOMPILER*           ppCompiler,
        LPD3DXBUFFER*                   ppParseErrors )

FUNCTION: HRESULT
    D3DXCreateEffectCompilerFromResourceW (
        HMODULE                         hSrcModule,
        LPCWSTR                         pSrcResource,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTCOMPILER*           ppCompiler,
        LPD3DXBUFFER*                   ppParseErrors )

ALIAS: D3DXCreateEffectCompilerFromResource D3DXCreateEffectCompilerFromResourceW

FUNCTION: HRESULT
    D3DXCreateEffectCompiler (
        LPCSTR                          pSrcData,
        UINT                            SrcDataLen,
        D3DXMACRO*                      pDefines,
        LPD3DXINCLUDE                   pInclude,
        DWORD                           Flags,
        LPD3DXEFFECTCOMPILER*           ppCompiler,
        LPD3DXBUFFER*                   ppParseErrors )

FUNCTION: HRESULT
    D3DXDisassembleEffect (
        LPD3DXEFFECT pEffect,
        BOOL EnableColorCode,
        LPD3DXBUFFER* ppDisassembly )
