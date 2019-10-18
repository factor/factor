USING: alien.syntax classes.struct windows.types ;
IN: windows.directx.d3dx10math

STRUCT: D3DVECTOR
    { x FLOAT }
    { y FLOAT }
    { z FLOAT } ;

STRUCT: D3DMATRIX
    { m FLOAT[4][4] } ;

STRUCT: D3DXFLOAT16
    { value WORD } ;

TYPEDEF: D3DMATRIX D3DXMATRIX

STRUCT: D3DXVECTOR2
    { x FLOAT }
    { y FLOAT } ;

STRUCT: D3DXVECTOR2_16F
    { x D3DXFLOAT16 }
    { y D3DXFLOAT16 } ;

TYPEDEF: D3DVECTOR D3DXVECTOR3

STRUCT: D3DXVECTOR3_16F
    { x D3DXFLOAT16 }
    { y D3DXFLOAT16 }
    { z D3DXFLOAT16 } ;

STRUCT: D3DXVECTOR4
    { x FLOAT }
    { y FLOAT }
    { z FLOAT }
    { w FLOAT } ;

STRUCT: D3DXVECTOR4_16F
    { x D3DXFLOAT16 }
    { y D3DXFLOAT16 }
    { z D3DXFLOAT16 }
    { w D3DXFLOAT16 } ;

STRUCT: D3DXQUATERNION
    { x FLOAT }
    { y FLOAT }
    { z FLOAT }
    { w FLOAT } ;

STRUCT: D3DXPLANE
    { a FLOAT }
    { b FLOAT }
    { c FLOAT }
    { d FLOAT } ;

STRUCT: D3DXCOLOR
    { r FLOAT }
    { g FLOAT }
    { b FLOAT }
    { a FLOAT } ;
