USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx.d3d10 windows.directx.d3d10misc
windows.types windows.directx ;
IN: windows.directx.d3d10shader

LIBRARY: d3d10

CONSTANT: D3D10_SHADER_DEBUG                          1
CONSTANT: D3D10_SHADER_SKIP_VALIDATION                2
CONSTANT: D3D10_SHADER_SKIP_OPTIMIZATION              4
CONSTANT: D3D10_SHADER_PACK_MATRIX_ROW_MAJOR          8
CONSTANT: D3D10_SHADER_PACK_MATRIX_COLUMN_MAJOR       16
CONSTANT: D3D10_SHADER_PARTIAL_PRECISION              32
CONSTANT: D3D10_SHADER_FORCE_VS_SOFTWARE_NO_OPT       64
CONSTANT: D3D10_SHADER_FORCE_PS_SOFTWARE_NO_OPT       128
CONSTANT: D3D10_SHADER_NO_PRESHADER                   256
CONSTANT: D3D10_SHADER_AVOID_FLOW_CONTROL             512
CONSTANT: D3D10_SHADER_PREFER_FLOW_CONTROL            1024
CONSTANT: D3D10_SHADER_ENABLE_STRICTNESS              2048
CONSTANT: D3D10_SHADER_ENABLE_BACKWARDS_COMPATIBILITY 4096
CONSTANT: D3D10_SHADER_IEEE_STRICTNESS                8192
CONSTANT: D3D10_SHADER_WARNINGS_ARE_ERRORS            262144

CONSTANT: D3D10_SHADER_OPTIMIZATION_LEVEL0 16384
CONSTANT: D3D10_SHADER_OPTIMIZATION_LEVEL1 0
CONSTANT: D3D10_SHADER_OPTIMIZATION_LEVEL2 49152
CONSTANT: D3D10_SHADER_OPTIMIZATION_LEVEL3 32768

STRUCT: D3D10_SHADER_MACRO
    { Name       LPCSTR }
    { Definition LPCSTR } ;
TYPEDEF: D3D10_SHADER_MACRO* LPD3D10_SHADER_MACRO

CONSTANT: D3D10_SVC_SCALAR            0
CONSTANT: D3D10_SVC_VECTOR            1
CONSTANT: D3D10_SVC_MATRIX_ROWS       2
CONSTANT: D3D10_SVC_MATRIX_COLUMNS    3
CONSTANT: D3D10_SVC_OBJECT            4
CONSTANT: D3D10_SVC_STRUCT            5
CONSTANT: D3D11_SVC_INTERFACE_CLASS   6
CONSTANT: D3D11_SVC_INTERFACE_POINTER 7
CONSTANT: D3D10_SVC_FORCE_DWORD       0x7fffffff
TYPEDEF: int D3D10_SHADER_VARIABLE_CLASS
TYPEDEF: D3D10_SHADER_VARIABLE_CLASS* LPD3D10_SHADER_VARIABLE_CLASS

CONSTANT: D3D10_SVF_USERPACKED        1
CONSTANT: D3D10_SVF_USED              2
CONSTANT: D3D11_SVF_INTERFACE_POINTER 4
CONSTANT: D3D10_SVF_FORCE_DWORD       0x7fffffff
TYPEDEF: int D3D10_SHADER_VARIABLE_FLAGS
TYPEDEF: D3D10_SHADER_VARIABLE_FLAGS* LPD3D10_SHADER_VARIABLE_FLAGS

CONSTANT: D3D10_SVT_VOID              0
CONSTANT: D3D10_SVT_BOOL              1
CONSTANT: D3D10_SVT_INT               2
CONSTANT: D3D10_SVT_FLOAT             3
CONSTANT: D3D10_SVT_STRING            4
CONSTANT: D3D10_SVT_TEXTURE           5
CONSTANT: D3D10_SVT_TEXTURE1D         6
CONSTANT: D3D10_SVT_TEXTURE2D         7
CONSTANT: D3D10_SVT_TEXTURE3D         8
CONSTANT: D3D10_SVT_TEXTURECUBE       9
CONSTANT: D3D10_SVT_SAMPLER           10
CONSTANT: D3D10_SVT_PIXELSHADER       15
CONSTANT: D3D10_SVT_VERTEXSHADER      16
CONSTANT: D3D10_SVT_UINT              19
CONSTANT: D3D10_SVT_UINT8             20
CONSTANT: D3D10_SVT_GEOMETRYSHADER    21
CONSTANT: D3D10_SVT_RASTERIZER        22
CONSTANT: D3D10_SVT_DEPTHSTENCIL      23
CONSTANT: D3D10_SVT_BLEND             24
CONSTANT: D3D10_SVT_BUFFER            25
CONSTANT: D3D10_SVT_CBUFFER           26
CONSTANT: D3D10_SVT_TBUFFER           27
CONSTANT: D3D10_SVT_TEXTURE1DARRAY    28
CONSTANT: D3D10_SVT_TEXTURE2DARRAY    29
CONSTANT: D3D10_SVT_RENDERTARGETVIEW  30
CONSTANT: D3D10_SVT_DEPTHSTENCILVIEW  31
CONSTANT: D3D10_SVT_TEXTURE2DMS       32
CONSTANT: D3D10_SVT_TEXTURE2DMSARRAY  33
CONSTANT: D3D10_SVT_TEXTURECUBEARRAY  34
CONSTANT: D3D11_SVT_HULLSHADER        35
CONSTANT: D3D11_SVT_DOMAINSHADER      36
CONSTANT: D3D11_SVT_INTERFACE_POINTER 37
CONSTANT: D3D11_SVT_COMPUTESHADER     38
CONSTANT: D3D11_SVT_DOUBLE            39
CONSTANT: D3D10_SVT_FORCE_DWORD       0x7ffffff
TYPEDEF: int D3D10_SHADER_VARIABLE_TYPE
TYPEDEF: D3D10_SHADER_VARIABLE_TYPE* LPD3D10_SHADER_VARIABLE_TYPE

CONSTANT: D3D10_SIF_USERPACKED          1
CONSTANT: D3D10_SIF_COMPARISON_SAMPLER  2
CONSTANT: D3D10_SIF_TEXTURE_COMPONENT_0 4
CONSTANT: D3D10_SIF_TEXTURE_COMPONENT_1 8
CONSTANT: D3D10_SIF_TEXTURE_COMPONENTS  12
CONSTANT: D3D10_SIF_FORCE_DWORD         0x7ffffff
TYPEDEF: int D3D10_SHADER_INPUT_FLAGS
TYPEDEF: D3D10_SHADER_INPUT_FLAGS* LPD3D10_SHADER_INPUT_FLAGS

CONSTANT: D3D10_SIT_CBUFFER                       0
CONSTANT: D3D10_SIT_TBUFFER                       1
CONSTANT: D3D10_SIT_TEXTURE                       2
CONSTANT: D3D10_SIT_SAMPLER                       3
CONSTANT: D3D11_SIT_UAV_RWTYPED                   4
CONSTANT: D3D11_SIT_STRUCTURED                    5
CONSTANT: D3D11_SIT_UAV_RWSTRUCTURED              6
CONSTANT: D3D11_SIT_BYTEADDRESS                   7
CONSTANT: D3D11_SIT_UAV_RWBYTEADDRESS             8
CONSTANT: D3D11_SIT_UAV_APPEND_STRUCTURED         9
CONSTANT: D3D11_SIT_UAV_CONSUME_STRUCTURED        10
CONSTANT: D3D11_SIT_UAV_RWSTRUCTURED_WITH_COUNTER 11
TYPEDEF: int D3D10_SHADER_INPUT_TYPE
TYPEDEF: D3D10_SHADER_INPUT_TYPE* LPD3D10_SHADER_INPUT_TYPE

CONSTANT: D3D10_CBF_USERPACKED  1
CONSTANT: D3D10_CBF_FORCE_DWORD 0x7fffffff
TYPEDEF: int D3D10_SHADER_CBUFFER_FLAGS
TYPEDEF: D3D10_SHADER_CBUFFER_FLAGS* LPD3D10_SHADER_CBUFFER_FLAGS

CONSTANT: D3D10_CT_CBUFFER 0
CONSTANT: D3D10_CT_TBUFFER 1
TYPEDEF: int D3D10_CBUFFER_TYPE
TYPEDEF: D3D10_CBUFFER_TYPE* LPD3D10_CBUFFER_TYPE

CONSTANT: D3D10_NAME_UNDEFINED                     0
CONSTANT: D3D10_NAME_POSITION                      1
CONSTANT: D3D10_NAME_CLIP_DISTANCE                 2
CONSTANT: D3D10_NAME_CULL_DISTANCE                 3
CONSTANT: D3D10_NAME_RENDER_TARGET_ARRAY_INDEX     4
CONSTANT: D3D10_NAME_VIEWPORT_ARRAY_INDEX          5
CONSTANT: D3D10_NAME_VERTEX_ID                     6
CONSTANT: D3D10_NAME_PRIMITIVE_ID                  7
CONSTANT: D3D10_NAME_INSTANCE_ID                   8
CONSTANT: D3D10_NAME_IS_FRONT_FACE                 9
CONSTANT: D3D10_NAME_SAMPLE_INDEX                  10
CONSTANT: D3D11_NAME_FINAL_QUAD_EDGE_TESSFACTOR    11
CONSTANT: D3D11_NAME_FINAL_QUAD_INSIDE_TESSFACTOR  12
CONSTANT: D3D11_NAME_FINAL_TRI_EDGE_TESSFACTOR     13
CONSTANT: D3D11_NAME_FINAL_TRI_INSIDE_TESSFACTOR   14
CONSTANT: D3D11_NAME_FINAL_LINE_DETAIL_TESSFACTOR  15
CONSTANT: D3D11_NAME_FINAL_LINE_DENSITY_TESSFACTOR 16
CONSTANT: D3D10_NAME_TARGET                        64
CONSTANT: D3D10_NAME_DEPTH                         65
CONSTANT: D3D10_NAME_COVERAGE                      66
CONSTANT: D3D11_NAME_DEPTH_GREATER_EQUAL           67
CONSTANT: D3D11_NAME_DEPTH_LESS_EQUAL              68
TYPEDEF: int D3D10_NAME

CONSTANT: D3D10_RETURN_TYPE_UNORM 1
CONSTANT: D3D10_RETURN_TYPE_SNORM 2
CONSTANT: D3D10_RETURN_TYPE_SINT  3
CONSTANT: D3D10_RETURN_TYPE_UINT  4
CONSTANT: D3D10_RETURN_TYPE_FLOAT 5
CONSTANT: D3D10_RETURN_TYPE_MIXED 6
TYPEDEF: int D3D10_RESOURCE_RETURN_TYPE

CONSTANT: D3D10_REGISTER_COMPONENT_UNKNOWN 0
CONSTANT: D3D10_REGISTER_COMPONENT_UINT32  1
CONSTANT: D3D10_REGISTER_COMPONENT_SINT32  2
CONSTANT: D3D10_REGISTER_COMPONENT_FLOAT32 3
TYPEDEF: int D3D10_REGISTER_COMPONENT_TYPE

CONSTANT: D3D10_INCLUDE_LOCAL       0
CONSTANT: D3D10_INCLUDE_SYSTEM      1
CONSTANT: D3D10_INCLUDE_FORCE_DWORD 0x7fffffff
TYPEDEF: int D3D10_INCLUDE_TYPE
TYPEDEF: D3D10_INCLUDE_TYPE* LPD3D10_INCLUDE_TYPE

COM-INTERFACE: ID3D10Include f {C530AD7D-9B16-4395-A979-BA2ECFF83ADD}
    HRESULT Open ( D3D10_INCLUDE_TYPE IncludeType, LPCSTR pFileName, LPCVOID pParentData, LPCVOID* ppData, UINT* pBytes )
    HRESULT Close ( LPCVOID pData ) ;
TYPEDEF: ID3D10Include* LPD3D10INCLUDE

STRUCT: D3D10_SHADER_DESC
    { Version                     UINT                     }
    { Creator                     LPCSTR                   }
    { Flags                       UINT                     }
    { ConstantBuffers             UINT                     }
    { BoundResources              UINT                     }
    { InputParameters             UINT                     }
    { OutputParameters            UINT                     }
    { InstructionCount            UINT                     }
    { TempRegisterCount           UINT                     }
    { TempArrayCount              UINT                     }
    { DefCount                    UINT                     }
    { DclCount                    UINT                     }
    { TextureNormalInstructions   UINT                     }
    { TextureLoadInstructions     UINT                     }
    { TextureCompInstructions     UINT                     }
    { TextureBiasInstructions     UINT                     }
    { TextureGradientInstructions UINT                     }
    { FloatInstructionCount       UINT                     }
    { IntInstructionCount         UINT                     }
    { UintInstructionCount        UINT                     }
    { StaticFlowControlCount      UINT                     }
    { DynamicFlowControlCount     UINT                     }
    { MacroInstructionCount       UINT                     }
    { ArrayInstructionCount       UINT                     }
    { CutInstructionCount         UINT                     }
    { EmitInstructionCount        UINT                     }
    { GSOutputTopology            D3D10_PRIMITIVE_TOPOLOGY }
    { GSMaxOutputVertexCount      UINT                     } ;

STRUCT: D3D10_SHADER_BUFFER_DESC
    { Name      LPCSTR             }
    { Type      D3D10_CBUFFER_TYPE }
    { Variables UINT               }
    { Size      UINT               }
    { uFlags    UINT               } ;

STRUCT: D3D10_SHADER_VARIABLE_DESC
    { Name         LPCSTR }
    { StartOffset  UINT   }
    { Size         UINT   }
    { uFlags       UINT   }
    { DefaultValue LPVOID } ;

STRUCT: D3D10_SHADER_TYPE_DESC
    { Class    D3D10_SHADER_VARIABLE_CLASS }
    { Type     D3D10_SHADER_VARIABLE_TYPE  }
    { Rows     UINT                        }
    { Columns  UINT                        }
    { Elements UINT                        }
    { Members  UINT                        }
    { Offset   UINT                        } ;

STRUCT: D3D10_SHADER_INPUT_BIND_DESC
    { Name       LPCSTR                     }
    { Type       D3D10_SHADER_INPUT_TYPE    }
    { BindPoint  UINT                       }
    { BindCount  UINT                       }
    { uFlags     UINT                       }
    { ReturnType D3D10_RESOURCE_RETURN_TYPE }
    { Dimension  D3D10_SRV_DIMENSION        }
    { NumSamples UINT                       } ;

STRUCT: D3D10_SIGNATURE_PARAMETER_DESC
    { SemanticName    LPCSTR                        }
    { SemanticIndex   UINT                          }
    { Register        UINT                          }
    { SystemValueType D3D10_NAME                    }
    { ComponentType   D3D10_REGISTER_COMPONENT_TYPE }
    { Mask            BYTE                          }
    { ReadWriteMask   BYTE                          } ;

COM-INTERFACE: ID3D10ShaderReflectionType f {C530AD7D-9B16-4395-A979-BA2ECFF83ADD}
    HRESULT GetDesc ( D3D10_SHADER_TYPE_DESC* pDesc )
    ID3D10ShaderReflectionType* GetMemberTypeByIndex ( UINT Index )
    ID3D10ShaderReflectionType* GetMemberTypeByName ( LPCSTR Name )
    LPCSTR GetMemberTypeName ( UINT Index ) ;

COM-INTERFACE: ID3D10ShaderReflectionVariable f {1BF63C95-2650-405d-99C1-3636BD1DA0A1}
    HRESULT GetDesc ( D3D10_SHADER_VARIABLE_DESC* pDesc )
    ID3D10ShaderReflectionType* GetType ( ) ;

COM-INTERFACE: ID3D10ShaderReflectionConstantBuffer f {66C66A94-DDDD-4b62-A66A-F0DA33C2B4D0}
    HRESULT GetDesc ( D3D10_SHADER_BUFFER_DESC* pDesc )
    ID3D10ShaderReflectionVariable* GetVariableByIndex ( UINT Index )
    ID3D10ShaderReflectionVariable* GetVariableByName ( LPCSTR Name ) ;

COM-INTERFACE: ID3D10ShaderReflection IUnknown {D40E20B6-F8F7-42ad-AB20-4BAF8F15DFAA}
    HRESULT GetDesc ( D3D10_SHADER_DESC* pDesc )
    ID3D10ShaderReflectionConstantBuffer* GetConstantBufferByIndex ( UINT Index )
    ID3D10ShaderReflectionConstantBuffer* GetConstantBufferByName ( LPCSTR Name )
    HRESULT GetResourceBindingDesc ( UINT ResourceIndex, D3D10_SHADER_INPUT_BIND_DESC* pDesc )
    HRESULT GetInputParameterDesc ( UINT ParameterIndex, D3D10_SIGNATURE_PARAMETER_DESC* pDesc )
    HRESULT GetOutputParameterDesc ( UINT ParameterIndex, D3D10_SIGNATURE_PARAMETER_DESC* pDesc ) ;

FUNCTION: HRESULT D3D10CompileShader ( LPCSTR pSrcData, SIZE_T SrcDataLen, LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include* pInclude, LPCSTR pFunctionName, LPCSTR pProfile, UINT Flags, ID3D10Blob** ppShader, ID3D10Blob** ppErrorMsgs )
FUNCTION: HRESULT D3D10DisassembleShader ( void* pShader, SIZE_T BytecodeLength, BOOL EnableColorCode, LPCSTR pComments, ID3D10Blob** ppDisassembly )
FUNCTION: LPCSTR D3D10GetPixelShaderProfile ( ID3D10Device* pDevice )
FUNCTION: LPCSTR D3D10GetVertexShaderProfile ( ID3D10Device* pDevice )
FUNCTION: LPCSTR D3D10GetGeometryShaderProfile ( ID3D10Device* pDevice )
FUNCTION: HRESULT D3D10ReflectShader ( void* pShaderBytecode, SIZE_T BytecodeLength, ID3D10ShaderReflection** ppReflector )
FUNCTION: HRESULT D3D10PreprocessShader ( LPCSTR pSrcData, SIZE_T SrcDataSize, LPCSTR pFileName, D3D10_SHADER_MACRO* pDefines, ID3D10Include* pInclude, ID3D10Blob** ppShaderText, ID3D10Blob** ppErrorMsgs )
FUNCTION: HRESULT D3D10GetInputSignatureBlob ( void* pShaderBytecode, SIZE_T BytecodeLength, ID3D10Blob** ppSignatureBlob )
FUNCTION: HRESULT D3D10GetOutputSignatureBlob ( void* pShaderBytecode, SIZE_T BytecodeLength, ID3D10Blob** ppSignatureBlob )
FUNCTION: HRESULT D3D10GetInputAndOutputSignatureBlob ( void* pShaderBytecode, SIZE_T BytecodeLength, ID3D10Blob** ppSignatureBlob )
FUNCTION: HRESULT D3D10GetShaderDebugInfo ( void* pShaderBytecode, SIZE_T BytecodeLength, ID3D10Blob** ppDebugInfo )
