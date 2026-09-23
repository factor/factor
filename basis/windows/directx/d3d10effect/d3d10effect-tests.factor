USING: alien.c-types classes.struct tools.test windows.directx.d3d10effect ;
IN: windows.directx.d3d10effect.tests

{ 76 3 24 45 } [
    D3D10_STATE_BLOCK_MASK heap-size
    "VSShaderResources" D3D10_STATE_BLOCK_MASK offset-of
    "GSShaderResources" D3D10_STATE_BLOCK_MASK offset-of
    "PSShaderResources" D3D10_STATE_BLOCK_MASK offset-of
] unit-test
