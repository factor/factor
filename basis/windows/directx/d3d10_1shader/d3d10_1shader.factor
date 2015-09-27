USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx windows.directx.d3d10
windows.directx.d3d10shader windows.types ;
IN: windows.directx.d3d10_1shader

LIBRARY: d3d10_1

CONSTANT: D3D10_SHADER_DEBUG_REG_INPUT              0
CONSTANT: D3D10_SHADER_DEBUG_REG_OUTPUT             1
CONSTANT: D3D10_SHADER_DEBUG_REG_CBUFFER            2
CONSTANT: D3D10_SHADER_DEBUG_REG_TBUFFER            3
CONSTANT: D3D10_SHADER_DEBUG_REG_TEMP               4
CONSTANT: D3D10_SHADER_DEBUG_REG_TEMPARRAY          5
CONSTANT: D3D10_SHADER_DEBUG_REG_TEXTURE            6
CONSTANT: D3D10_SHADER_DEBUG_REG_SAMPLER            7
CONSTANT: D3D10_SHADER_DEBUG_REG_IMMEDIATECBUFFER   8
CONSTANT: D3D10_SHADER_DEBUG_REG_LITERAL            9
CONSTANT: D3D10_SHADER_DEBUG_REG_UNUSED             10
CONSTANT: D3D11_SHADER_DEBUG_REG_INTERFACE_POINTERS 11
CONSTANT: D3D10_SHADER_DEBUG_REG_FORCE_DWORD        0x7fffffff
TYPEDEF: int D3D10_SHADER_DEBUG_REGTYPE

CONSTANT: D3D10_SHADER_DEBUG_SCOPE_GLOBAL      0
CONSTANT: D3D10_SHADER_DEBUG_SCOPE_BLOCK       1
CONSTANT: D3D10_SHADER_DEBUG_SCOPE_FORLOOP     2
CONSTANT: D3D10_SHADER_DEBUG_SCOPE_STRUCT      3
CONSTANT: D3D10_SHADER_DEBUG_SCOPE_FUNC_PARAMS 4
CONSTANT: D3D10_SHADER_DEBUG_SCOPE_STATEBLOCK  5
CONSTANT: D3D10_SHADER_DEBUG_SCOPE_NAMESPACE   6
CONSTANT: D3D10_SHADER_DEBUG_SCOPE_ANNOTATION  7
CONSTANT: D3D10_SHADER_DEBUG_SCOPE_FORCE_DWORD 0x7fffffff
TYPEDEF: int D3D10_SHADER_DEBUG_SCOPETYPE

CONSTANT: D3D10_SHADER_DEBUG_VAR_VARIABLE    0
CONSTANT: D3D10_SHADER_DEBUG_VAR_FUNCTION    1
CONSTANT: D3D10_SHADER_DEBUG_VAR_FORCE_DWORD 0x7fffffff
TYPEDEF: int D3D10_SHADER_DEBUG_VARTYPE

STRUCT: D3D10_SHADER_DEBUG_TOKEN_INFO
    { File        UINT }
    { Line        UINT }
    { Column      UINT }
    { TokenLength UINT }
    { TokenId     UINT } ;

STRUCT: D3D10_SHADER_DEBUG_VAR_INFO
    { TokenId        UINT                       }
    { Type           D3D10_SHADER_VARIABLE_TYPE }
    { Register       UINT                       }
    { Component      UINT                       }
    { ScopeVar       UINT                       }
    { ScopeVarOffset UINT                       } ;

STRUCT: D3D10_SHADER_DEBUG_INPUT_INFO
    { Var                UINT                       }
    { InitialRegisterSet D3D10_SHADER_DEBUG_REGTYPE }
    { InitialBank        UINT                       }
    { InitialRegister    UINT                       }
    { InitialComponent   UINT                       }
    { InitialValue       UINT                       } ;

STRUCT: D3D10_SHADER_DEBUG_SCOPEVAR_INFO
    { TokenId           UINT                        }
    { VarType           D3D10_SHADER_DEBUG_VARTYPE  }
    { Class             D3D10_SHADER_VARIABLE_CLASS }
    { Rows              UINT                        }
    { Columns           UINT                        }
    { StructMemberScope UINT                        }
    { uArrayIndices     UINT                        }
    { ArrayElements     UINT                        }
    { ArrayStrides      UINT                        }
    { uVariables        UINT                        }
    { uFirstVariable    UINT                        } ;

STRUCT: D3D10_SHADER_DEBUG_SCOPE_INFO
    { ScopeType    D3D10_SHADER_DEBUG_SCOPETYPE }
    { Name         UINT                         }
    { uNameLen     UINT                         }
    { uVariables   UINT                         }
    { VariableData UINT                         } ;

STRUCT: D3D10_SHADER_DEBUG_OUTPUTVAR
    { Var           UINT  }
    { uValueMin     UINT  }
    { uValueMax     UINT  }
    { iValueMin     INT   }
    { iValueMax     INT   }
    { fValueMin     FLOAT }
    { fValueMax     FLOAT }
    { bNaNPossible  BOOL  }
    { bInfPossible  BOOL  } ;

STRUCT: D3D10_SHADER_DEBUG_OUTPUTREG_INFO
    { OutputRegisterSet D3D10_SHADER_DEBUG_REGTYPE      }
    { OutputReg         UINT                            }
    { TempArrayReg      UINT                            }
    { OutputComponents  UINT[4]                         }
    { OutputVars        D3D10_SHADER_DEBUG_OUTPUTVAR[4] }
    { IndexReg          UINT                            }
    { IndexComp         UINT                            } ;

STRUCT: D3D10_SHADER_DEBUG_INST_INFO
    { Id               UINT                                 }
    { Opcode           UINT                                 }
    { uOutputs         UINT                                 }
    { pOutputs         D3D10_SHADER_DEBUG_OUTPUTREG_INFO[2] }
    { TokenId          UINT                                 }
    { NestingLevel     UINT                                 }
    { Scopes           UINT                                 }
    { ScopeInfo        UINT                                 }
    { AccessedVars     UINT                                 }
    { AccessedVarsInfo UINT                                 } ;

STRUCT: D3D10_SHADER_DEBUG_FILE_INFO
    { FileName    UINT }
    { FileNameLen UINT }
    { FileData    UINT }
    { FileLen     UINT } ;

STRUCT: D3D10_SHADER_DEBUG_INFO
    { Size              UINT }
    { Creator           UINT }
    { EntrypointName    UINT }
    { ShaderTarget      UINT }
    { CompileFlags      UINT }
    { Files             UINT }
    { FileInfo          UINT }
    { Instructions      UINT }
    { InstructionInfo   UINT }
    { Variables         UINT }
    { VariableInfo      UINT }
    { InputVariables    UINT }
    { InputVariableInfo UINT }
    { Tokens            UINT }
    { TokenInfo         UINT }
    { Scopes            UINT }
    { ScopeInfo         UINT }
    { ScopeVariables    UINT }
    { ScopeVariableInfo UINT }
    { UintOffset        UINT }
    { StringOffset      UINT } ;

C-TYPE: ID3D10ShaderReflection1
TYPEDEF: ID3D10ShaderReflection1* LPD3D10SHADERREFLECTION1

COM-INTERFACE: ID3D10ShaderReflection1 IUnknown {C3457783-A846-47CE-9520-CEA6F66E7447}
    HRESULT GetDesc ( D3D10_SHADER_DESC* pDesc )
    ID3D10ShaderReflectionConstantBuffer* GetConstantBufferByIndex ( UINT Index )
    ID3D10ShaderReflectionConstantBuffer* GetConstantBufferByName ( LPCSTR Name )
    HRESULT GetResourceBindingDesc ( UINT ResourceIndex, D3D10_SHADER_INPUT_BIND_DESC* pDesc )
    HRESULT GetInputParameterDesc ( UINT ParameterIndex, D3D10_SIGNATURE_PARAMETER_DESC* pDesc )
    HRESULT GetOutputParameterDesc ( UINT ParameterIndex, D3D10_SIGNATURE_PARAMETER_DESC* pDesc )
    ID3D10ShaderReflectionVariable* GetVariableByName ( LPCSTR Name )
    HRESULT GetResourceBindingDescByName ( LPCSTR Name, D3D10_SHADER_INPUT_BIND_DESC* pDesc )
    HRESULT GetMovInstructionCount ( UINT* pCount )
    HRESULT GetMovcInstructionCount ( UINT* pCount )
    HRESULT GetConversionInstructionCount ( UINT* pCount )
    HRESULT GetBitwiseInstructionCount ( UINT* pCount )
    HRESULT GetGSInputPrimitive ( D3D10_PRIMITIVE* pPrim )
    HRESULT IsLevel9Shader ( BOOL* pbLevel9Shader )
    HRESULT IsSampleFrequencyShader ( BOOL* pbSampleFrequency ) ;
