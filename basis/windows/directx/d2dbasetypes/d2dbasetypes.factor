USING: alien.syntax classes.struct windows.types ;
IN: windows.directx.d2dbasetypes

STRUCT: D3DCOLORVALUE
    { r FLOAT }
    { g FLOAT }
    { b FLOAT }
    { a FLOAT } ;

STRUCT: D2D_POINT_2U
    { x UINT32 }
    { y UINT32 } ;

STRUCT: D2D_POINT_2F
    { x FLOAT }
    { y FLOAT } ;

STRUCT: D2D_RECT_F
    { left   FLOAT }
    { top    FLOAT }
    { right  FLOAT }
    { bottom FLOAT } ;

STRUCT: D2D_RECT_U
    { left   UINT32 }
    { top    UINT32 }
    { right  UINT32 }
    { bottom UINT32 } ;

STRUCT: D2D_SIZE_F
    { width  FLOAT }
    { height FLOAT } ;

STRUCT: D2D_SIZE_U
    { width  UINT32 }
    { height UINT32 } ;

TYPEDEF: D3DCOLORVALUE D2D_COLOR_F

STRUCT: D2D_MATRIX_3X2_F
    { _11 FLOAT }
    { _12 FLOAT }
    { _21 FLOAT }
    { _22 FLOAT }
    { _31 FLOAT }
    { _32 FLOAT } ;
