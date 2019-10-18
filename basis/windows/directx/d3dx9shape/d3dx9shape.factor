USING: alien.c-types alien.syntax windows.directx
windows.directx.d3d9 windows.directx.d3dx9core
windows.directx.d3dx9mesh windows.types ;
IN: windows.directx.d3dx9shape

LIBRARY: d3dx9

TYPEDEF: void* LPGLYPHMETRICSFLOAT

FUNCTION: HRESULT
    D3DXCreatePolygon (
        LPDIRECT3DDEVICE9   pDevice,
        FLOAT               Length,
        UINT                Sides,
        LPD3DXMESH*         ppMesh,
        LPD3DXBUFFER*       ppAdjacency )

FUNCTION: HRESULT
    D3DXCreateBox (
        LPDIRECT3DDEVICE9   pDevice,
        FLOAT               Width,
        FLOAT               Height,
        FLOAT               Depth,
        LPD3DXMESH*         ppMesh,
        LPD3DXBUFFER*       ppAdjacency )

FUNCTION: HRESULT
    D3DXCreateCylinder (
        LPDIRECT3DDEVICE9   pDevice,
        FLOAT               Radius1,
        FLOAT               Radius2,
        FLOAT               Length,
        UINT                Slices,
        UINT                Stacks,
        LPD3DXMESH*         ppMesh,
        LPD3DXBUFFER*       ppAdjacency )

FUNCTION: HRESULT
    D3DXCreateSphere (
        LPDIRECT3DDEVICE9  pDevice,
        FLOAT              Radius,
        UINT               Slices,
        UINT               Stacks,
        LPD3DXMESH*        ppMesh,
        LPD3DXBUFFER*      ppAdjacency )

FUNCTION: HRESULT
    D3DXCreateTorus (
        LPDIRECT3DDEVICE9   pDevice,
        FLOAT               InnerRadius,
        FLOAT               OuterRadius,
        UINT                Sides,
        UINT                Rings,
        LPD3DXMESH*         ppMesh,
        LPD3DXBUFFER*       ppAdjacency )

FUNCTION: HRESULT
    D3DXCreateTeapot (
        LPDIRECT3DDEVICE9   pDevice,
        LPD3DXMESH*         ppMesh,
        LPD3DXBUFFER*       ppAdjacency )

FUNCTION: HRESULT
    D3DXCreateTextA (
        LPDIRECT3DDEVICE9   pDevice,
        HDC                 hDC,
        LPCSTR              pText,
        FLOAT               Deviation,
        FLOAT               Extrusion,
        LPD3DXMESH*         ppMesh,
        LPD3DXBUFFER*       ppAdjacency,
        LPGLYPHMETRICSFLOAT pGlyphMetrics )

FUNCTION: HRESULT
    D3DXCreateTextW (
        LPDIRECT3DDEVICE9   pDevice,
        HDC                 hDC,
        LPCWSTR             pText,
        FLOAT               Deviation,
        FLOAT               Extrusion,
        LPD3DXMESH*         ppMesh,
        LPD3DXBUFFER*       ppAdjacency,
        LPGLYPHMETRICSFLOAT pGlyphMetrics )

ALIAS: D3DXCreateText D3DXCreateTextW
