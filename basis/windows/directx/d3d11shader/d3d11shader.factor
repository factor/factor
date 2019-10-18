USING: alien.syntax alien.c-types classes.struct windows.types
windows.directx.d3d10shader windows.directx.d3d10
windows.directx.d3d11 windows.com windows.com.syntax
windows.directx.d3dcommon ;
IN: windows.directx.d3d11shader

LIBRARY: d3d11

CONSTANT: D3D11_SHVER_PIXEL_SHADER    0
CONSTANT: D3D11_SHVER_VERTEX_SHADER   1
CONSTANT: D3D11_SHVER_GEOMETRY_SHADER 2
CONSTANT: D3D11_SHVER_HULL_SHADER     3
CONSTANT: D3D11_SHVER_DOMAIN_SHADER   4
CONSTANT: D3D11_SHVER_COMPUTE_SHADER  5
TYPEDEF: int D3D11_SHADER_VERSION_TYPE

CONSTANT: D3D11_RETURN_TYPE_UNORM     1
CONSTANT: D3D11_RETURN_TYPE_SNORM     2
CONSTANT: D3D11_RETURN_TYPE_SINT      3
CONSTANT: D3D11_RETURN_TYPE_UINT      4
CONSTANT: D3D11_RETURN_TYPE_FLOAT     5
CONSTANT: D3D11_RETURN_TYPE_MIXED     6
CONSTANT: D3D11_RETURN_TYPE_DOUBLE    7
CONSTANT: D3D11_RETURN_TYPE_CONTINUED 8
TYPEDEF: int D3D11_RESOURCE_RETURN_TYPE

ENUM: D3D11_CBUFFER_TYPE
    D3D11_CT_CBUFFER
    D3D11_CT_TBUFFER
    D3D11_CT_INTERFACE_POINTERS
    D3D11_CT_RESOURCE_BIND_INFO ;
TYPEDEF: D3D11_CBUFFER_TYPE* LPD3D11_CBUFFER_TYPE

STRUCT: D3D11_SIGNATURE_PARAMETER_DESC
    { SemanticName    LPCSTR                          }
    { SemanticIndex   UINT                            }
    { Register        UINT                            }
    { SystemValueType D3D10_NAME                      }
    { ComponentType   D3D10_REGISTER_COMPONENT_TYPE   }
    { Mask            BYTE                            }
    { ReadWriteMask   BYTE                            }
    { Stream          UINT                            } ;

STRUCT: D3D11_SHADER_BUFFER_DESC
    { Name            LPCSTR                  }
    { Type            D3D11_CBUFFER_TYPE      }
    { Variables       UINT                    }
    { Size            UINT                    }
    { uFlags          UINT                    } ;

STRUCT: D3D11_SHADER_VARIABLE_DESC
    { Name            LPCSTR         }
    { StartOffset     UINT           }
    { Size            UINT           }
    { uFlags          UINT           }
    { DefaultValue    LPVOID         }
    { StartTexture    UINT           }
    { TextureSize     UINT           }
    { StartSampler    UINT           }
    { SamplerSize     UINT           } ;

STRUCT: D3D11_SHADER_TYPE_DESC
    { Class           D3D10_SHADER_VARIABLE_CLASS    }
    { Type            D3D10_SHADER_VARIABLE_TYPE     }
    { Rows            UINT                           }
    { Columns         UINT                           }
    { Elements        UINT                           }
    { Members         UINT                           }
    { Offset          UINT                           }
    { Name            LPCSTR                         } ;

CONSTANT: D3D11_TESSELLATOR_DOMAIN_UNDEFINED 0
CONSTANT: D3D11_TESSELLATOR_DOMAIN_ISOLINE   1
CONSTANT: D3D11_TESSELLATOR_DOMAIN_TRI       2
CONSTANT: D3D11_TESSELLATOR_DOMAIN_QUAD      3
TYPEDEF: int D3D11_TESSELLATOR_DOMAIN

CONSTANT: D3D11_TESSELLATOR_PARTITIONING_UNDEFINED       0
CONSTANT: D3D11_TESSELLATOR_PARTITIONING_INTEGER         1
CONSTANT: D3D11_TESSELLATOR_PARTITIONING_POW2            2
CONSTANT: D3D11_TESSELLATOR_PARTITIONING_FRACTIONAL_ODD  3
CONSTANT: D3D11_TESSELLATOR_PARTITIONING_FRACTIONAL_EVEN 4
TYPEDEF: int D3D11_TESSELLATOR_PARTITIONING

CONSTANT: D3D11_TESSELLATOR_OUTPUT_UNDEFINED    0
CONSTANT: D3D11_TESSELLATOR_OUTPUT_POINT        1
CONSTANT: D3D11_TESSELLATOR_OUTPUT_LINE         2
CONSTANT: D3D11_TESSELLATOR_OUTPUT_TRIANGLE_CW  3
CONSTANT: D3D11_TESSELLATOR_OUTPUT_TRIANGLE_CCW 4
TYPEDEF: int D3D11_TESSELLATOR_OUTPUT_PRIMITIVE

STRUCT: D3D11_SHADER_DESC
    { Version                     UINT                               }
    { Creator                     LPCSTR                             }
    { Flags                       UINT                               }
    { ConstantBuffers             UINT                               }
    { BoundResources              UINT                               }
    { InputParameters             UINT                               }
    { OutputParameters            UINT                               }
    { InstructionCount            UINT                               }
    { TempRegisterCount           UINT                               }
    { TempArrayCount              UINT                               }
    { DefCount                    UINT                               }
    { DclCount                    UINT                               }
    { TextureNormalInstructions   UINT                               }
    { TextureLoadInstructions     UINT                               }
    { TextureCompInstructions     UINT                               }
    { TextureBiasInstructions     UINT                               }
    { TextureGradientInstructions UINT                               }
    { FloatInstructionCount       UINT                               }
    { IntInstructionCount         UINT                               }
    { UintInstructionCount        UINT                               }
    { StaticFlowControlCount      UINT                               }
    { DynamicFlowControlCount     UINT                               }
    { MacroInstructionCount       UINT                               }
    { ArrayInstructionCount       UINT                               }
    { CutInstructionCount         UINT                               }
    { EmitInstructionCount        UINT                               }
    { GSOutputTopology            D3D10_PRIMITIVE_TOPOLOGY           }
    { GSMaxOutputVertexCount      UINT                               }
    { InputPrimitive              D3D11_PRIMITIVE                    }
    { PatchConstantParameters     UINT                               }
    { cGSInstanceCount            UINT                               }
    { cControlPoints              UINT                               }
    { HSOutputPrimitive           D3D11_TESSELLATOR_OUTPUT_PRIMITIVE }
    { HSPartitioning              D3D11_TESSELLATOR_PARTITIONING     }
    { TessellatorDomain           D3D11_TESSELLATOR_DOMAIN           }
    { cBarrierInstructions        UINT                               }
    { cInterlockedInstructions    UINT                               }
    { cTextureStoreInstructions   UINT                               } ;

STRUCT: D3D11_SHADER_INPUT_BIND_DESC
    { Name                        LPCSTR                        }
    { Type                        D3D10_SHADER_INPUT_TYPE       }
    { BindPoint                   UINT                          }
    { BindCount                   UINT                          }
    { uFlags                      UINT                          }
    { ReturnType                  D3D11_RESOURCE_RETURN_TYPE    }
    { Dimension                   D3D10_SRV_DIMENSION           }
    { NumSamples                  UINT                          } ;

COM-INTERFACE: ID3D11ShaderReflectionType f {6E6FFA6A-9BAE-4613-A51E-91652D508C21}
    HRESULT GetDesc ( D3D11_SHADER_TYPE_DESC* pDesc )
    ID3D11ShaderReflectionType* GetMemberTypeByIndex ( UINT Index )
    ID3D11ShaderReflectionType* GetMemberTypeByName ( LPCSTR Name )
    LPCSTR GetMemberTypeName ( UINT Index )
    HRESULT IsEqual ( ID3D11ShaderReflectionType* pType )
    ID3D11ShaderReflectionType* GetSubType ( )
    ID3D11ShaderReflectionType* GetBaseClass ( )
    UINT GetNumInterfaces ( )
    ID3D11ShaderReflectionType* GetInterfaceByIndex ( UINT uIndex )
    HRESULT IsOfType ( ID3D11ShaderReflectionType* pType )
    HRESULT ImplementsInterface ( ID3D11ShaderReflectionType* pBase ) ;

C-TYPE: ID3D11ShaderReflectionType
C-TYPE: ID3D11ShaderReflectionConstantBuffer

COM-INTERFACE: ID3D11ShaderReflectionVariable f {51F23923-F3E5-4BD1-91CB-606177D8DB4C}
    HRESULT GetDesc ( D3D11_SHADER_VARIABLE_DESC* pDesc )
    ID3D11ShaderReflectionType* GetType ( )
    ID3D11ShaderReflectionConstantBuffer* GetBuffer ( )
    UINT GetInterfaceSlot ( UINT uArrayIndex ) ;

COM-INTERFACE: ID3D11ShaderReflectionConstantBuffer f {EB62D63D-93DD-4318-8AE8-C6F83AD371B8}
    HRESULT GetDesc ( D3D11_SHADER_BUFFER_DESC* pDesc )
    ID3D11ShaderReflectionVariable* GetVariableByIndex ( UINT Index )
    ID3D11ShaderReflectionVariable* GetVariableByName ( LPCSTR Name ) ;

COM-INTERFACE: ID3D11ShaderReflection IUnknown {17F27486-A342-4D10-8842-AB0874E7F670}
    HRESULT GetDesc ( D3D11_SHADER_DESC* pDesc )
    ID3D11ShaderReflectionConstantBuffer* GetConstantBufferByIndex ( UINT Index )
    ID3D11ShaderReflectionConstantBuffer* GetConstantBufferByName ( LPCSTR Name )
    HRESULT GetResourceBindingDesc ( UINT ResourceIndex, D3D11_SHADER_INPUT_BIND_DESC* pDesc )
    HRESULT GetInputParameterDesc ( UINT ParameterIndex, D3D11_SIGNATURE_PARAMETER_DESC* pDesc )
    HRESULT GetOutputParameterDesc ( UINT ParameterIndex, D3D11_SIGNATURE_PARAMETER_DESC* pDesc )
    HRESULT GetPatchConstantParameterDesc ( UINT ParameterIndex, D3D11_SIGNATURE_PARAMETER_DESC* pDesc )
    ID3D11ShaderReflectionVariable* GetVariableByName ( LPCSTR Name )
    HRESULT GetResourceBindingDescByName ( LPCSTR Name, D3D11_SHADER_INPUT_BIND_DESC* pDesc )
    UINT GetMovInstructionCount ( )
    UINT GetMovcInstructionCount ( )
    UINT GetConversionInstructionCount ( )
    UINT GetBitwiseInstructionCount ( )
    D3D10_PRIMITIVE GetGSInputPrimitive ( )
    BOOL IsSampleFrequencyShader ( )
    UINT GetNumInterfaceSlots ( )
    HRESULT GetMinFeatureLevel ( D3D_FEATURE_LEVEL* pLevel ) ;
