USING: alien.c-types alien.syntax ;
IN: windows.directx.dxgiformat

CONSTANT: DXGI_FORMAT_UNKNOWN 0
CONSTANT: DXGI_FORMAT_R32G32B32A32_TYPELESS 1
CONSTANT: DXGI_FORMAT_R32G32B32A32_FLOAT 2
CONSTANT: DXGI_FORMAT_R32G32B32A32_UINT 3
CONSTANT: DXGI_FORMAT_R32G32B32A32_SINT 4
CONSTANT: DXGI_FORMAT_R32G32B32_TYPELESS 5
CONSTANT: DXGI_FORMAT_R32G32B32_FLOAT 6
CONSTANT: DXGI_FORMAT_R32G32B32_UINT 7
CONSTANT: DXGI_FORMAT_R32G32B32_SINT 8
CONSTANT: DXGI_FORMAT_R16G16B16A16_TYPELESS 9
CONSTANT: DXGI_FORMAT_R16G16B16A16_FLOAT 10
CONSTANT: DXGI_FORMAT_R16G16B16A16_UNORM 11
CONSTANT: DXGI_FORMAT_R16G16B16A16_UINT 12
CONSTANT: DXGI_FORMAT_R16G16B16A16_SNORM 13
CONSTANT: DXGI_FORMAT_R16G16B16A16_SINT 14
CONSTANT: DXGI_FORMAT_R32G32_TYPELESS 15
CONSTANT: DXGI_FORMAT_R32G32_FLOAT 16
CONSTANT: DXGI_FORMAT_R32G32_UINT 17
CONSTANT: DXGI_FORMAT_R32G32_SINT 18
CONSTANT: DXGI_FORMAT_R32G8X24_TYPELESS 19
CONSTANT: DXGI_FORMAT_D32_FLOAT_S8X24_UINT 20
CONSTANT: DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS 21
CONSTANT: DXGI_FORMAT_X32_TYPELESS_G8X24_UINT 22
CONSTANT: DXGI_FORMAT_R10G10B10A2_TYPELESS 23
CONSTANT: DXGI_FORMAT_R10G10B10A2_UNORM 24
CONSTANT: DXGI_FORMAT_R10G10B10A2_UINT 25
CONSTANT: DXGI_FORMAT_R11G11B10_FLOAT 26
CONSTANT: DXGI_FORMAT_R8G8B8A8_TYPELESS 27
CONSTANT: DXGI_FORMAT_R8G8B8A8_UNORM 28
CONSTANT: DXGI_FORMAT_R8G8B8A8_UNORM_SRGB 29
CONSTANT: DXGI_FORMAT_R8G8B8A8_UINT 30
CONSTANT: DXGI_FORMAT_R8G8B8A8_SNORM 31
CONSTANT: DXGI_FORMAT_R8G8B8A8_SINT 32
CONSTANT: DXGI_FORMAT_R16G16_TYPELESS 33
CONSTANT: DXGI_FORMAT_R16G16_FLOAT 34
CONSTANT: DXGI_FORMAT_R16G16_UNORM 35
CONSTANT: DXGI_FORMAT_R16G16_UINT 36
CONSTANT: DXGI_FORMAT_R16G16_SNORM 37
CONSTANT: DXGI_FORMAT_R16G16_SINT 38
CONSTANT: DXGI_FORMAT_R32_TYPELESS 39
CONSTANT: DXGI_FORMAT_D32_FLOAT 40
CONSTANT: DXGI_FORMAT_R32_FLOAT 41
CONSTANT: DXGI_FORMAT_R32_UINT 42
CONSTANT: DXGI_FORMAT_R32_SINT 43
CONSTANT: DXGI_FORMAT_R24G8_TYPELESS 44
CONSTANT: DXGI_FORMAT_D24_UNORM_S8_UINT 45
CONSTANT: DXGI_FORMAT_R24_UNORM_X8_TYPELESS 46
CONSTANT: DXGI_FORMAT_X24_TYPELESS_G8_UINT 47
CONSTANT: DXGI_FORMAT_R8G8_TYPELESS 48
CONSTANT: DXGI_FORMAT_R8G8_UNORM 49
CONSTANT: DXGI_FORMAT_R8G8_UINT 50
CONSTANT: DXGI_FORMAT_R8G8_SNORM 51
CONSTANT: DXGI_FORMAT_R8G8_SINT 52
CONSTANT: DXGI_FORMAT_R16_TYPELESS 53
CONSTANT: DXGI_FORMAT_R16_FLOAT 54
CONSTANT: DXGI_FORMAT_D16_UNORM 55
CONSTANT: DXGI_FORMAT_R16_UNORM 56
CONSTANT: DXGI_FORMAT_R16_UINT 57
CONSTANT: DXGI_FORMAT_R16_SNORM 58
CONSTANT: DXGI_FORMAT_R16_SINT 59
CONSTANT: DXGI_FORMAT_R8_TYPELESS 60
CONSTANT: DXGI_FORMAT_R8_UNORM 61
CONSTANT: DXGI_FORMAT_R8_UINT 62
CONSTANT: DXGI_FORMAT_R8_SNORM 63
CONSTANT: DXGI_FORMAT_R8_SINT 64
CONSTANT: DXGI_FORMAT_A8_UNORM 65
CONSTANT: DXGI_FORMAT_R1_UNORM 66
CONSTANT: DXGI_FORMAT_R9G9B9E5_SHAREDEXP 67
CONSTANT: DXGI_FORMAT_R8G8_B8G8_UNORM 68
CONSTANT: DXGI_FORMAT_G8R8_G8B8_UNORM 69
CONSTANT: DXGI_FORMAT_BC1_TYPELESS 70
CONSTANT: DXGI_FORMAT_BC1_UNORM 71
CONSTANT: DXGI_FORMAT_BC1_UNORM_SRGB 72
CONSTANT: DXGI_FORMAT_BC2_TYPELESS 73
CONSTANT: DXGI_FORMAT_BC2_UNORM 74
CONSTANT: DXGI_FORMAT_BC2_UNORM_SRGB 75
CONSTANT: DXGI_FORMAT_BC3_TYPELESS 76
CONSTANT: DXGI_FORMAT_BC3_UNORM 77
CONSTANT: DXGI_FORMAT_BC3_UNORM_SRGB 78
CONSTANT: DXGI_FORMAT_BC4_TYPELESS 79
CONSTANT: DXGI_FORMAT_BC4_UNORM 80
CONSTANT: DXGI_FORMAT_BC4_SNORM 81
CONSTANT: DXGI_FORMAT_BC5_TYPELESS 82
CONSTANT: DXGI_FORMAT_BC5_UNORM 83
CONSTANT: DXGI_FORMAT_BC5_SNORM 84
CONSTANT: DXGI_FORMAT_B5G6R5_UNORM 85
CONSTANT: DXGI_FORMAT_B5G5R5A1_UNORM 86
CONSTANT: DXGI_FORMAT_B8G8R8A8_UNORM 87
CONSTANT: DXGI_FORMAT_B8G8R8X8_UNORM 88
CONSTANT: DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM 89
CONSTANT: DXGI_FORMAT_B8G8R8A8_TYPELESS 90
CONSTANT: DXGI_FORMAT_B8G8R8A8_UNORM_SRGB 91
CONSTANT: DXGI_FORMAT_B8G8R8X8_TYPELESS 92
CONSTANT: DXGI_FORMAT_B8G8R8X8_UNORM_SRGB 93
CONSTANT: DXGI_FORMAT_BC6H_TYPELESS 94
CONSTANT: DXGI_FORMAT_BC6H_UF16 95
CONSTANT: DXGI_FORMAT_BC6H_SF16 96
CONSTANT: DXGI_FORMAT_BC7_TYPELESS 97
CONSTANT: DXGI_FORMAT_BC7_UNORM 98
CONSTANT: DXGI_FORMAT_BC7_UNORM_SRGB 99
CONSTANT: DXGI_FORMAT_FORCE_UINT 0xffffffff
TYPEDEF: int DXGI_FORMAT
