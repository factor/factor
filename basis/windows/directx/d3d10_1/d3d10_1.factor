USING: alien.c-types alien.syntax classes.struct
windows.com.syntax windows.directx windows.directx.d3d10
windows.directx.d3d10misc windows.directx.dxgi
windows.directx.dxgiformat windows.types ;
IN: windows.directx.d3d10_1

LIBRARY: d3d10_1

CONSTANT: D3D10_1_DEFAULT_SAMPLE_MASK                             0xffffffff
CONSTANT: D3D10_1_FLOAT16_FUSED_TOLERANCE_IN_ULP                  0.6
CONSTANT: D3D10_1_FLOAT32_TO_INTEGER_TOLERANCE_IN_ULP             0.6
CONSTANT: D3D10_1_GS_INPUT_REGISTER_COUNT                         32
CONSTANT: D3D10_1_IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT             32
CONSTANT: D3D10_1_IA_VERTEX_INPUT_STRUCTURE_ELEMENTS_COMPONENTS   128
CONSTANT: D3D10_1_IA_VERTEX_INPUT_STRUCTURE_ELEMENT_COUNT         32
CONSTANT: D3D10_1_PS_OUTPUT_MASK_REGISTER_COMPONENTS              1
CONSTANT: D3D10_1_PS_OUTPUT_MASK_REGISTER_COMPONENT_BIT_COUNT     32
CONSTANT: D3D10_1_PS_OUTPUT_MASK_REGISTER_COUNT                   1
CONSTANT: D3D10_1_SHADER_MAJOR_VERSION                            4
CONSTANT: D3D10_1_SHADER_MINOR_VERSION                            1
CONSTANT: D3D10_1_SO_BUFFER_MAX_STRIDE_IN_BYTES                   2048
CONSTANT: D3D10_1_SO_BUFFER_MAX_WRITE_WINDOW_IN_BYTES             256
CONSTANT: D3D10_1_SO_BUFFER_SLOT_COUNT                            4
CONSTANT: D3D10_1_SO_MULTIPLE_BUFFER_ELEMENTS_PER_BUFFER          1
CONSTANT: D3D10_1_SO_SINGLE_BUFFER_COMPONENT_LIMIT                64
CONSTANT: D3D10_1_STANDARD_VERTEX_ELEMENT_COUNT                   32
CONSTANT: D3D10_1_SUBPIXEL_FRACTIONAL_BIT_COUNT                   8
CONSTANT: D3D10_1_VS_INPUT_REGISTER_COUNT                         32
CONSTANT: D3D10_1_VS_OUTPUT_REGISTER_COUNT                        32

CONSTANT: D3D10_FEATURE_LEVEL_10_0    0xa000
CONSTANT: D3D10_FEATURE_LEVEL_10_1    0xa100
CONSTANT: D3D10_FEATURE_LEVEL_9_1     0x9100
CONSTANT: D3D10_FEATURE_LEVEL_9_2     0x9200
CONSTANT: D3D10_FEATURE_LEVEL_9_3     0x9300
TYPEDEF: int D3D10_FEATURE_LEVEL1

STRUCT: D3D10_RENDER_TARGET_BLEND_DESC1
    { BlendEnable           BOOL           }
    { SrcBlend              D3D10_BLEND    }
    { DestBlend             D3D10_BLEND    }
    { BlendOp               D3D10_BLEND_OP }
    { SrcBlendAlpha         D3D10_BLEND    }
    { DestBlendAlpha        D3D10_BLEND    }
    { BlendOpAlpha          D3D10_BLEND_OP }
    { RenderTargetWriteMask BYTE           } ;

STRUCT: D3D10_BLEND_DESC1
    { AlphaToCoverageEnable  BOOL                               }
    { IndependentBlendEnable BOOL                               }
    { RenderTarget           D3D10_RENDER_TARGET_BLEND_DESC1[8] } ;

COM-INTERFACE: ID3D10BlendState1 ID3D10BlendState {EDAD8D99-8A35-4d6d-8566-2EA276CDE161}
    void GetDesc1 ( D3D10_BLEND_DESC1* pDesc ) ;

STRUCT: D3D10_TEXCUBE_ARRAY_SRV1
    { MostDetailedMip  UINT }
    { MipLevels        UINT }
    { First2DArrayFace UINT }
    { NumCubes         UINT } ;

CONSTANT: D3D10_1_SRV_DIMENSION_UNKNOWN           0
CONSTANT: D3D10_1_SRV_DIMENSION_BUFFER            1
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURE1D         2
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURE1DARRAY    3
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURE2D         4
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURE2DARRAY    5
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURE2DMS       6
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURE2DMSARRAY  7
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURE3D         8
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURECUBE       9
CONSTANT: D3D10_1_SRV_DIMENSION_TEXTURECUBEARRAY  10
TYPEDEF: int D3D10_SRV_DIMENSION1

UNION-STRUCT: D3D10_SHADER_RESOURCE_VIEW_DESC1_UNION
    { Buffer           D3D10_BUFFER_SRV         }
    { Texture1D        D3D10_TEX1D_SRV          }
    { Texture1DArray   D3D10_TEX1D_ARRAY_SRV    }
    { Texture2D        D3D10_TEX2D_SRV          }
    { Texture2DArray   D3D10_TEX2D_ARRAY_SRV    }
    { Texture2DMS      D3D10_TEX2DMS_SRV        }
    { Texture2DMSArray D3D10_TEX2DMS_ARRAY_SRV  }
    { Texture3D        D3D10_TEX3D_SRV          }
    { TextureCube      D3D10_TEXCUBE_SRV        }
    { TextureCubeArray D3D10_TEXCUBE_ARRAY_SRV1 } ;
STRUCT: D3D10_SHADER_RESOURCE_VIEW_DESC1
    { Format        DXGI_FORMAT                            }
    { ViewDimension D3D10_SRV_DIMENSION1                   }
    { View          D3D10_SHADER_RESOURCE_VIEW_DESC1_UNION } ;

COM-INTERFACE: ID3D10ShaderResourceView1 ID3D10ShaderResourceView {9B7E4C87-342C-4106-A19F-4F2704F689F0}
    void GetDesc1 ( D3D10_SHADER_RESOURCE_VIEW_DESC1* pDesc ) ;

CONSTANT: D3D10_STANDARD_MULTISAMPLE_PATTERN  0xffffffff
CONSTANT: D3D10_CENTER_MULTISAMPLE_PATTERN    0xfffffffe
TYPEDEF: int D3D10_STANDARD_MULTISAMPLE_QUALITY_LEVELS

COM-INTERFACE: ID3D10Device1 ID3D10Device {9B7E4C8F-342C-4106-A19F-4F2704F689F0}
    HRESULT CreateShaderResourceView1 (
        ID3D10Resource*                   pResource,
        D3D10_SHADER_RESOURCE_VIEW_DESC1* pDesc,
        ID3D10ShaderResourceView1**       ppSRView )
    HRESULT CreateBlendState1 (
        D3D10_BLEND_DESC1*  pBlendStateDesc,
        ID3D10BlendState1** ppBlendState )
    D3D10_FEATURE_LEVEL1 GetFeatureLevel ( ) ;

CONSTANT: D3D10_1_SDK_VERSION 0x20

FUNCTION: HRESULT D3D10CreateDevice1 (
    IDXGIAdapter*        pAdapter,
    D3D10_DRIVER_TYPE    DriverType,
    HMODULE              Software,
    UINT                 Flags,
    D3D10_FEATURE_LEVEL1 HardwareLevel,
    UINT                 SDKVersion,
    ID3D10Device1**      ppDevice )

FUNCTION: HRESULT D3D10CreateDeviceAndSwapChain1 (
    IDXGIAdapter*         pAdapter,
    D3D10_DRIVER_TYPE     DriverType,
    HMODULE               Software,
    UINT                  Flags,
    D3D10_FEATURE_LEVEL1  HardwareLevel,
    UINT                  SDKVersion,
    DXGI_SWAP_CHAIN_DESC* pSwapChainDesc,
    IDXGISwapChain**      ppSwapChain,
    ID3D10Device1**       ppDevice )
