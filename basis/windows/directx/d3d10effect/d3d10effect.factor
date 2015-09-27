USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx windows.directx.d3d10
windows.directx.d3d10misc windows.directx.d3d10shader windows.types ;
IN: windows.directx.d3d10effect

LIBRARY: d3d10

CONSTANT: D3D10_DST_SO_BUFFERS             1
CONSTANT: D3D10_DST_OM_RENDER_TARGETS      2
CONSTANT: D3D10_DST_OM_DEPTH_STENCIL_STATE 3
CONSTANT: D3D10_DST_OM_BLEND_STATE         4
CONSTANT: D3D10_DST_VS                     5
CONSTANT: D3D10_DST_VS_SAMPLERS            6
CONSTANT: D3D10_DST_VS_SHADER_RESOURCES    7
CONSTANT: D3D10_DST_VS_CONSTANT_BUFFERS    8
CONSTANT: D3D10_DST_GS                     9
CONSTANT: D3D10_DST_GS_SAMPLERS            10
CONSTANT: D3D10_DST_GS_SHADER_RESOURCES    11
CONSTANT: D3D10_DST_GS_CONSTANT_BUFFERS    12
CONSTANT: D3D10_DST_PS                     13
CONSTANT: D3D10_DST_PS_SAMPLERS            14
CONSTANT: D3D10_DST_PS_SHADER_RESOURCES    15
CONSTANT: D3D10_DST_PS_CONSTANT_BUFFERS    16
CONSTANT: D3D10_DST_IA_VERTEX_BUFFERS      17
CONSTANT: D3D10_DST_IA_INDEX_BUFFER        18
CONSTANT: D3D10_DST_IA_INPUT_LAYOUT        19
CONSTANT: D3D10_DST_IA_PRIMITIVE_TOPOLOGY  20
CONSTANT: D3D10_DST_RS_VIEWPORTS           21
CONSTANT: D3D10_DST_RS_SCISSOR_RECTS       22
CONSTANT: D3D10_DST_RS_RASTERIZER_STATE    23
CONSTANT: D3D10_DST_PREDICATION            24
TYPEDEF: int D3D10_DEVICE_STATE_TYPES

STRUCT: D3D10_STATE_BLOCK_MASK
    { VS                  BYTE    }
    { VSSamplers          BYTE[2] }
    { VSShaderResources   BYTE[8] }
    { VSConstantBuffers   BYTE[2] }
    { GS                  BYTE    }
    { GSSamplers          BYTE[2] }
    { GSShaderResources   BYTE[8] }
    { GSConstantBuffers   BYTE[2] }
    { PS                  BYTE    }
    { PSSamplers          BYTE[2] }
    { PSShaderResources   BYTE[8] }
    { PSConstantBuffers   BYTE[2] }
    { IAVertexBuffers     BYTE[2] }
    { IAIndexBuffer       BYTE    }
    { IAInputLayout       BYTE    }
    { IAPrimitiveTopology BYTE    }
    { OMRenderTargets     BYTE    }
    { OMDepthStencilState BYTE    }
    { OMBlendState        BYTE    }
    { RSViewports         BYTE    }
    { RSScissorRects      BYTE    }
    { RSRasterizerState   BYTE    }
    { SOBuffers           BYTE    }
    { Predication         BYTE    } ;

COM-INTERFACE: ID3D10StateBlock IUnknown {0803425A-57F5-4dd6-9465-A87570834A08}
    HRESULT Capture ( )
    HRESULT Apply ( )
    HRESULT ReleaseAllDeviceObjects ( )
    HRESULT GetDevice ( ID3D10Device** ppDevice ) ;
TYPEDEF: ID3D10StateBlock* LPD3D10STATEBLOCK

FUNCTION: HRESULT D3D10StateBlockMaskUnion ( D3D10_STATE_BLOCK_MASK* pA, D3D10_STATE_BLOCK_MASK* pB, D3D10_STATE_BLOCK_MASK* pResult )
FUNCTION: HRESULT D3D10StateBlockMaskIntersect ( D3D10_STATE_BLOCK_MASK* pA, D3D10_STATE_BLOCK_MASK* pB, D3D10_STATE_BLOCK_MASK* pResult )
FUNCTION: HRESULT D3D10StateBlockMaskDifference ( D3D10_STATE_BLOCK_MASK* pA, D3D10_STATE_BLOCK_MASK* pB, D3D10_STATE_BLOCK_MASK* pResult )
FUNCTION: HRESULT D3D10StateBlockMaskEnableCapture ( D3D10_STATE_BLOCK_MASK* pMask, D3D10_DEVICE_STATE_TYPES StateType, UINT RangeStart, UINT RangeLength )
FUNCTION: HRESULT D3D10StateBlockMaskDisableCapture ( D3D10_STATE_BLOCK_MASK* pMask, D3D10_DEVICE_STATE_TYPES StateType, UINT RangeStart, UINT RangeLength )
FUNCTION: HRESULT D3D10StateBlockMaskEnableAll ( D3D10_STATE_BLOCK_MASK* pMask )
FUNCTION: HRESULT D3D10StateBlockMaskDisableAll ( D3D10_STATE_BLOCK_MASK* pMask )
FUNCTION: BOOL    D3D10StateBlockMaskGetSetting ( D3D10_STATE_BLOCK_MASK* pMask, D3D10_DEVICE_STATE_TYPES StateType, UINT Entry )

FUNCTION: HRESULT D3D10CreateStateBlock ( ID3D10Device* pDevice, D3D10_STATE_BLOCK_MASK* pStateBlockMask, ID3D10StateBlock** ppStateBlock )

CONSTANT: D3D10_EFFECT_COMPILE_CHILD_EFFECT             1
CONSTANT: D3D10_EFFECT_COMPILE_ALLOW_SLOW_OPS           2
CONSTANT: D3D10_EFFECT_SINGLE_THREADED                  8

CONSTANT: D3D10_EFFECT_VARIABLE_POOLED                  1
CONSTANT: D3D10_EFFECT_VARIABLE_ANNOTATION              2
CONSTANT: D3D10_EFFECT_VARIABLE_EXPLICIT_BIND_POINT     4

STRUCT: D3D10_EFFECT_TYPE_DESC
    { TypeName        LPCSTR                      }
    { Class           D3D10_SHADER_VARIABLE_CLASS }
    { Type            D3D10_SHADER_VARIABLE_TYPE  }
    { Elements        UINT                        }
    { Members         UINT                        }
    { Rows            UINT                        }
    { Columns         UINT                        }
    { PackedSize      UINT                        }
    { UnpackedSize    UINT                        }
    { Stride          UINT                        } ;

COM-INTERFACE: ID3D10EffectType f {4E9E1DDC-CD9D-4772-A837-00180B9B88FD}
    BOOL IsValid ( )
    HRESULT GetDesc ( D3D10_EFFECT_TYPE_DESC* pDesc )
    ID3D10EffectType* GetMemberTypeByIndex ( UINT Index )
    ID3D10EffectType* GetMemberTypeByName ( LPCSTR Name )
    ID3D10EffectType* GetMemberTypeBySemantic ( LPCSTR Semantic )
    LPCSTR GetMemberName ( UINT Index )
    LPCSTR GetMemberSemantic ( UINT Index ) ;
TYPEDEF: ID3D10EffectType* LPD3D10EFFECTTYPE

STRUCT: D3D10_EFFECT_VARIABLE_DESC
    { Name                 LPCSTR }
    { Semantic             LPCSTR }
    { Flags                UINT   }
    { Annotations          UINT   }
    { BufferOffset         UINT   }
    { ExplicitBindPoint    UINT   } ;

C-TYPE: ID3D10EffectConstantBuffer
C-TYPE: ID3D10EffectScalarVariable
C-TYPE: ID3D10EffectVectorVariable
C-TYPE: ID3D10EffectMatrixVariable
C-TYPE: ID3D10EffectStringVariable
C-TYPE: ID3D10EffectShaderResourceVariable
C-TYPE: ID3D10EffectRenderTargetViewVariable
C-TYPE: ID3D10EffectDepthStencilViewVariable
C-TYPE: ID3D10EffectShaderVariable
C-TYPE: ID3D10EffectBlendVariable
C-TYPE: ID3D10EffectDepthStencilVariable
C-TYPE: ID3D10EffectRasterizerVariable
C-TYPE: ID3D10EffectSamplerVariable

COM-INTERFACE: ID3D10EffectVariable f {AE897105-00E6-45bf-BB8E-281DD6DB8E1B}
    BOOL IsValid ( )
    ID3D10EffectType* GetType ( )
    HRESULT GetDesc ( D3D10_EFFECT_VARIABLE_DESC* pDesc )
    ID3D10EffectVariable* GetAnnotationByIndex ( UINT Index )
    ID3D10EffectVariable* GetAnnotationByName ( LPCSTR Name )
    ID3D10EffectVariable* GetMemberByIndex ( UINT Index )
    ID3D10EffectVariable* GetMemberByName ( LPCSTR Name )
    ID3D10EffectVariable* GetMemberBySemantic ( LPCSTR Semantic )
    ID3D10EffectVariable* GetElement ( UINT Index )
    ID3D10EffectConstantBuffer* GetParentConstantBuffer ( )
    ID3D10EffectScalarVariable* AsScalar ( )
    ID3D10EffectVectorVariable* AsVector ( )
    ID3D10EffectMatrixVariable* AsMatrix ( )
    ID3D10EffectStringVariable* AsString ( )
    ID3D10EffectShaderResourceVariable* AsShaderResource ( )
    ID3D10EffectRenderTargetViewVariable* AsRenderTargetView ( )
    ID3D10EffectDepthStencilViewVariable* AsDepthStencilView ( )
    ID3D10EffectConstantBuffer* AsConstantBuffer ( )
    ID3D10EffectShaderVariable* AsShader ( )
    ID3D10EffectBlendVariable* AsBlend ( )
    ID3D10EffectDepthStencilVariable* AsDepthStencil ( )
    ID3D10EffectRasterizerVariable* AsRasterizer ( )
    ID3D10EffectSamplerVariable* AsSampler ( )
    HRESULT SetRawValue ( void* pData, UINT Offset, UINT Count )
    HRESULT GetRawValue ( void* pData, UINT Offset, UINT Count ) ;
TYPEDEF: ID3D10EffectVariable* LPD3D10EFFECTVARIABLE

COM-INTERFACE: ID3D10EffectScalarVariable ID3D10EffectVariable {00E48F7B-D2C8-49e8-A86C-022DEE53431F}
    HRESULT SetFloat ( float Value )
    HRESULT GetFloat ( float* pValue )
    HRESULT SetFloatArray ( float* pData, UINT Offset, UINT Count )
    HRESULT GetFloatArray ( float* pData, UINT Offset, UINT Count )
    HRESULT SetInt ( int Value )
    HRESULT GetInt ( int* pValue )
    HRESULT SetIntArray ( int* pData, UINT Offset, UINT Count )
    HRESULT GetIntArray ( int* pData, UINT Offset, UINT Count )
    HRESULT SetBool ( BOOL Value )
    HRESULT GetBool ( BOOL* pValue )
    HRESULT SetBoolArray ( BOOL* pData, UINT Offset, UINT Count )
    HRESULT GetBoolArray ( BOOL* pData, UINT Offset, UINT Count ) ;
TYPEDEF: ID3D10EffectScalarVariable* LPD3D10EFFECTSCALARVARIABLE

COM-INTERFACE: ID3D10EffectVectorVariable ID3D10EffectVariable {62B98C44-1F82-4c67-BCD0-72CF8F217E81}
    HRESULT SetBoolVector ( BOOL* pData )
    HRESULT SetIntVector  ( int* pData )
    HRESULT SetFloatVector ( float* pData )
    HRESULT GetBoolVector ( BOOL* pData )
    HRESULT GetIntVector  ( int* pData )
    HRESULT GetFloatVector ( float *pData )
    HRESULT SetBoolVectorArray ( BOOL* pData, UINT Offset, UINT Count )
    HRESULT SetIntVectorArray  ( int* pData, UINT Offset, UINT Count )
    HRESULT SetFloatVectorArray ( float* pData, UINT Offset, UINT Count )
    HRESULT GetBoolVectorArray ( BOOL* pData, UINT Offset, UINT Count )
    HRESULT GetIntVectorArray  ( int* pData, UINT Offset, UINT Count )
    HRESULT GetFloatVectorArray ( float* pData, UINT Offset, UINT Count ) ;
TYPEDEF: ID3D10EffectVectorVariable* LPD3D10EFFECTVECTORVARIABLE

COM-INTERFACE: ID3D10EffectMatrixVariable ID3D10EffectVariable {50666C24-B82F-4eed-A172-5B6E7E8522E0}
    HRESULT SetMatrix ( float* pData )
    HRESULT GetMatrix ( float* pData )
    HRESULT SetMatrixArray ( float* pData, UINT Offset, UINT Count )
    HRESULT GetMatrixArray ( float* pData, UINT Offset, UINT Count )
    HRESULT SetMatrixTranspose ( float* pData )
    HRESULT GetMatrixTranspose ( float* pData )
    HRESULT SetMatrixTransposeArray ( float* pData, UINT Offset, UINT Count )
    HRESULT GetMatrixTransposeArray ( float* pData, UINT Offset, UINT Count ) ;
TYPEDEF: ID3D10EffectMatrixVariable* LPD3D10EFFECTMATRIXVARIABLE


COM-INTERFACE: ID3D10EffectStringVariable ID3D10EffectVariable {71417501-8DF9-4e0a-A78A-255F9756BAFF}
    HRESULT GetString ( LPCSTR* ppString )
    HRESULT GetStringArray ( LPCSTR* ppStrings, UINT Offset, UINT Count ) ;
TYPEDEF: ID3D10EffectStringVariable* LPD3D10EFFECTSTRINGVARIABLE

COM-INTERFACE: ID3D10EffectShaderResourceVariable ID3D10EffectVariable {C0A7157B-D872-4b1d-8073-EFC2ACD4B1FC}
    HRESULT SetResource ( ID3D10ShaderResourceView* pResource )
    HRESULT GetResource ( ID3D10ShaderResourceView** ppResource )
    HRESULT SetResourceArray ( ID3D10ShaderResourceView** ppResources, UINT Offset, UINT Count )
    HRESULT GetResourceArray ( ID3D10ShaderResourceView** ppResources, UINT Offset, UINT Count ) ;
TYPEDEF: ID3D10EffectShaderResourceVariable* LPD3D10EFFECTSHADERRESOURCEVARIABLE

COM-INTERFACE: ID3D10EffectRenderTargetViewVariable ID3D10EffectVariable {28CA0CC3-C2C9-40bb-B57F-67B737122B17}
    HRESULT SetRenderTarget ( ID3D10RenderTargetView* pResource )
    HRESULT GetRenderTarget ( ID3D10RenderTargetView** ppResource )
    HRESULT SetRenderTargetArray ( ID3D10RenderTargetView** ppResources, UINT Offset, UINT Count )
    HRESULT GetRenderTargetArray ( ID3D10RenderTargetView** ppResources, UINT Offset, UINT Count ) ;
TYPEDEF: ID3D10EffectRenderTargetViewVariable* LPD3D10EFFECTRENDERTARGETVIEWVARIABLE

COM-INTERFACE: ID3D10EffectDepthStencilViewVariable ID3D10EffectVariable {3E02C918-CC79-4985-B622-2D92AD701623}
    HRESULT SetDepthStencil ( ID3D10DepthStencilView* pResource )
    HRESULT GetDepthStencil ( ID3D10DepthStencilView** ppResource )
    HRESULT SetDepthStencilArray ( ID3D10DepthStencilView** ppResources, UINT Offset, UINT Count )
    HRESULT GetDepthStencilArray ( ID3D10DepthStencilView** ppResources, UINT Offset, UINT Count ) ;
TYPEDEF: ID3D10EffectDepthStencilViewVariable* LPD3D10EFFECTDEPTHSTENCILVIEWVARIABLE

COM-INTERFACE: ID3D10EffectConstantBuffer ID3D10EffectVariable {56648F4D-CC8B-4444-A5AD-B5A3D76E91B3}
    HRESULT SetConstantBuffer ( ID3D10Buffer* pConstantBuffer )
    HRESULT GetConstantBuffer ( ID3D10Buffer** ppConstantBuffer )
    HRESULT SetTextureBuffer ( ID3D10ShaderResourceView* pTextureBuffer )
    HRESULT GetTextureBuffer ( ID3D10ShaderResourceView** ppTextureBuffer ) ;
TYPEDEF: ID3D10EffectConstantBuffer* LPD3D10EFFECTCONSTANTBUFFER

STRUCT: D3D10_EFFECT_SHADER_DESC
    { pInputSignature           BYTE*  }
    { IsInline                  BOOL   }
    { pBytecode                 BYTE*  }
    { BytecodeLength            UINT   }
    { SODecl                    LPCSTR }
    { NumInputSignatureEntries  UINT   }
    { NumOutputSignatureEntries UINT   } ;

COM-INTERFACE: ID3D10EffectShaderVariable ID3D10EffectVariable {80849279-C799-4797-8C33-0407A07D9E06}
    HRESULT GetShaderDesc ( UINT ShaderIndex, D3D10_EFFECT_SHADER_DESC* pDesc )
    HRESULT GetVertexShader ( UINT ShaderIndex, ID3D10VertexShader** ppVS )
    HRESULT GetGeometryShader ( UINT ShaderIndex, ID3D10GeometryShader** ppGS )
    HRESULT GetPixelShader ( UINT ShaderIndex, ID3D10PixelShader** ppPS )
    HRESULT GetInputSignatureElementDesc ( UINT ShaderIndex, UINT Element, D3D10_SIGNATURE_PARAMETER_DESC* pDesc )
    HRESULT GetOutputSignatureElementDesc ( UINT ShaderIndex, UINT Element, D3D10_SIGNATURE_PARAMETER_DESC* pDesc ) ;
TYPEDEF: ID3D10EffectShaderVariable* LPD3D10EFFECTSHADERVARIABLE

COM-INTERFACE: ID3D10EffectBlendVariable ID3D10EffectVariable {1FCD2294-DF6D-4eae-86B3-0E9160CFB07B}
    HRESULT GetBlendState ( UINT Index, ID3D10BlendState** ppBlendState )
    HRESULT GetBackingStore ( UINT Index, D3D10_BLEND_DESC* pBlendDesc ) ;
TYPEDEF: ID3D10EffectBlendVariable* LPD3D10EFFECTBLENDVARIABLE

COM-INTERFACE: ID3D10EffectDepthStencilVariable ID3D10EffectVariable {AF482368-330A-46a5-9A5C-01C71AF24C8D}
    HRESULT GetDepthStencilState ( UINT Index, ID3D10DepthStencilState** ppDepthStencilState )
    HRESULT GetBackingStore ( UINT Index, D3D10_DEPTH_STENCIL_DESC* pDepthStencilDesc ) ;
TYPEDEF: ID3D10EffectDepthStencilVariable* LPD3D10EFFECTDEPTHSTENCILVARIABLE

COM-INTERFACE: ID3D10EffectRasterizerVariable ID3D10EffectVariable {21AF9F0E-4D94-4ea9-9785-2CB76B8C0B34}
    HRESULT GetRasterizerState ( UINT Index, ID3D10RasterizerState** ppRasterizerState )
    HRESULT GetBackingStore ( UINT Index, D3D10_RASTERIZER_DESC* pRasterizerDesc ) ;
TYPEDEF: ID3D10EffectRasterizerVariable* LPD3D10EFFECTRASTERIZERVARIABLE

COM-INTERFACE: ID3D10EffectSamplerVariable ID3D10EffectVariable {6530D5C7-07E9-4271-A418-E7CE4BD1E480}
    HRESULT GetSampler ( UINT Index, ID3D10SamplerState** ppSampler )
    HRESULT GetBackingStore ( UINT Index, D3D10_SAMPLER_DESC* pSamplerDesc ) ;
TYPEDEF: ID3D10EffectSamplerVariable* LPD3D10EFFECTSAMPLERVARIABLE

STRUCT: D3D10_PASS_DESC
    { Name                 LPCSTR   }
    { Annotations          UINT     }
    { pIAInputSignature    BYTE*    }
    { IAInputSignatureSize SIZE_T   }
    { StencilRef           UINT     }
    { SampleMask           UINT     }
    { BlendFactor          FLOAT[4] } ;

STRUCT: D3D10_PASS_SHADER_DESC
    { pShaderVariable                    ID3D10EffectShaderVariable* }
    { ShaderIndex                        UINT                        } ;

COM-INTERFACE: ID3D10EffectPass f {5CFBEB89-1A06-46e0-B282-E3F9BFA36A54}
    BOOL IsValid ( )
    HRESULT GetDesc ( D3D10_PASS_DESC* pDesc )
    HRESULT GetVertexShaderDesc ( D3D10_PASS_SHADER_DESC* pDesc )
    HRESULT GetGeometryShaderDesc ( D3D10_PASS_SHADER_DESC* pDesc )
    HRESULT GetPixelShaderDesc ( D3D10_PASS_SHADER_DESC* pDesc )
    ID3D10EffectVariable* GetAnnotationByIndex ( UINT Index )
    ID3D10EffectVariable* GetAnnotationByName ( LPCSTR Name )
    HRESULT Apply ( UINT Flags )
    HRESULT ComputeStateBlockMask ( D3D10_STATE_BLOCK_MASK* pStateBlockMask ) ;
TYPEDEF: ID3D10EffectPass* LPD3D10EFFECTPASS

STRUCT: D3D10_TECHNIQUE_DESC
    { Name           LPCSTR }
    { Passes         UINT   }
    { Annotations    UINT   } ;

COM-INTERFACE: ID3D10EffectTechnique f {DB122CE8-D1C9-4292-B237-24ED3DE8B175}
    BOOL IsValid ( )
    HRESULT GetDesc ( D3D10_TECHNIQUE_DESC* pDesc )
    ID3D10EffectVariable* GetAnnotationByIndex ( UINT Index )
    ID3D10EffectVariable* GetAnnotationByName ( LPCSTR Name )
    ID3D10EffectPass* GetPassByIndex ( UINT Index )
    ID3D10EffectPass* GetPassByName ( LPCSTR Name )
    HRESULT ComputeStateBlockMask ( D3D10_STATE_BLOCK_MASK* pStateBlockMask ) ;
TYPEDEF: ID3D10EffectTechnique* LPD3D10EFFECTTECHNIQUE

STRUCT: D3D10_EFFECT_DESC
    { IsChildEffect            BOOL }
    { ConstantBuffers          UINT }
    { SharedConstantBuffers    UINT }
    { GlobalVariables          UINT }
    { SharedGlobalVariables    UINT }
    { Techniques               UINT } ;

COM-INTERFACE: ID3D10Effect IUnknown {51B0CA8B-EC0B-4519-870D-8EE1CB5017C7}
    BOOL IsValid ( )
    BOOL IsPool ( )
    HRESULT GetDevice ( ID3D10Device** ppDevice )
    HRESULT GetDesc ( D3D10_EFFECT_DESC* pDesc )
    ID3D10EffectConstantBuffer* GetConstantBufferByIndex ( UINT Index )
    ID3D10EffectConstantBuffer* GetConstantBufferByName ( LPCSTR Name )
    ID3D10EffectVariable* GetVariableByIndex ( UINT Index )
    ID3D10EffectVariable* GetVariableByName ( LPCSTR Name )
    ID3D10EffectVariable* GetVariableBySemantic ( LPCSTR Semantic )
    ID3D10EffectTechnique* GetTechniqueByIndex ( UINT Index )
    ID3D10EffectTechnique* GetTechniqueByName ( LPCSTR Name )
    HRESULT Optimize ( )
    BOOL IsOptimized ( ) ;
TYPEDEF: ID3D10Effect* LPD3D10EFFECT

COM-INTERFACE: ID3D10EffectPool IUnknown {9537AB04-3250-412e-8213-FCD2F8677933}
    ID3D10Effect* AsEffect ( ) ;
TYPEDEF: ID3D10EffectPool* LPD3D10EFFECTPOOL

FUNCTION: HRESULT D3D10CompileEffectFromMemory ( void* pData, SIZE_T DataLength, LPCSTR pSrcFileName, D3D10_SHADER_MACRO* pDefines,
    ID3D10Include* pInclude, UINT HLSLFlags, UINT FXFlags,
    ID3D10Blob** ppCompiledEffect, ID3D10Blob** ppErrors )

FUNCTION: HRESULT D3D10CreateEffectFromMemory ( void* pData, SIZE_T DataLength, UINT FXFlags, ID3D10Device* pDevice,
    ID3D10EffectPool* pEffectPool, ID3D10Effect** ppEffect )

FUNCTION: HRESULT D3D10CreateEffectPoolFromMemory ( void* pData, SIZE_T DataLength, UINT FXFlags, ID3D10Device* pDevice,
    ID3D10EffectPool** ppEffectPool )

FUNCTION: HRESULT D3D10DisassembleEffect ( ID3D10Effect* pEffect, BOOL EnableColorCode, ID3D10Blob** ppDisassembly )
