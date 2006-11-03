! Copyright (C) 2005 Alex Chapman.
! See http://factor.sf.net/license.txt for BSD license.

! This file is based on the gl.h that comes with xorg-x11 6.8.2

IN: opengl 
USING: alien kernel sequences words ;

windows? [
    "gl" "opengl32.dll" "stdcall" add-library
    "glu" "glu32.dll" "stdcall" add-library
] when

TYPEDEF: uint    GLenum
TYPEDEF: uchar   GLboolean
TYPEDEF: uint    GLbitfield
TYPEDEF: char    GLbyte
TYPEDEF: short   GLshort
TYPEDEF: int     GLint
TYPEDEF: int     GLsizei
TYPEDEF: uchar   GLubyte
TYPEDEF: ushort  GLushort
TYPEDEF: uint    GLuint
TYPEDEF: float   GLfloat
TYPEDEF: float   GLclampf
TYPEDEF: double  GLdouble
TYPEDEF: double  GLclampd
TYPEDEF: void*   GLvoid*

! Constants

! Boolean values
: GL_FALSE                          HEX: 0 ; inline
: GL_TRUE                           HEX: 1 ; inline

! Data types
: GL_BYTE                           HEX: 1400 ; inline
: GL_UNSIGNED_BYTE                  HEX: 1401 ; inline
: GL_SHORT                          HEX: 1402 ; inline
: GL_UNSIGNED_SHORT                 HEX: 1403 ; inline
: GL_INT                            HEX: 1404 ; inline
: GL_UNSIGNED_INT                   HEX: 1405 ; inline
: GL_FLOAT                          HEX: 1406 ; inline
: GL_2_BYTES                        HEX: 1407 ; inline
: GL_3_BYTES                        HEX: 1408 ; inline
: GL_4_BYTES                        HEX: 1409 ; inline
: GL_DOUBLE                         HEX: 140A ; inline

! Primitives
: GL_POINTS                         HEX: 0000 ; inline
: GL_LINES                          HEX: 0001 ; inline
: GL_LINE_LOOP                      HEX: 0002 ; inline
: GL_LINE_STRIP                     HEX: 0003 ; inline
: GL_TRIANGLES                      HEX: 0004 ; inline
: GL_TRIANGLE_STRIP                 HEX: 0005 ; inline
: GL_TRIANGLE_FAN                   HEX: 0006 ; inline
: GL_QUADS                          HEX: 0007 ; inline
: GL_QUAD_STRIP                     HEX: 0008 ; inline
: GL_POLYGON                        HEX: 0009 ; inline

! Vertex arrays
: GL_VERTEX_ARRAY                   HEX: 8074 ; inline
: GL_NORMAL_ARRAY                   HEX: 8075 ; inline
: GL_COLOR_ARRAY                    HEX: 8076 ; inline
: GL_INDEX_ARRAY                    HEX: 8077 ; inline
: GL_TEXTURE_COORD_ARRAY            HEX: 8078 ; inline
: GL_EDGE_FLAG_ARRAY                HEX: 8079 ; inline
: GL_VERTEX_ARRAY_SIZE              HEX: 807A ; inline
: GL_VERTEX_ARRAY_TYPE              HEX: 807B ; inline
: GL_VERTEX_ARRAY_STRIDE            HEX: 807C ; inline
: GL_NORMAL_ARRAY_TYPE              HEX: 807E ; inline
: GL_NORMAL_ARRAY_STRIDE            HEX: 807F ; inline
: GL_COLOR_ARRAY_SIZE               HEX: 8081 ; inline
: GL_COLOR_ARRAY_TYPE               HEX: 8082 ; inline
: GL_COLOR_ARRAY_STRIDE             HEX: 8083 ; inline
: GL_INDEX_ARRAY_TYPE               HEX: 8085 ; inline
: GL_INDEX_ARRAY_STRIDE             HEX: 8086 ; inline
: GL_TEXTURE_COORD_ARRAY_SIZE       HEX: 8088 ; inline
: GL_TEXTURE_COORD_ARRAY_TYPE       HEX: 8089 ; inline
: GL_TEXTURE_COORD_ARRAY_STRIDE     HEX: 808A ; inline
: GL_EDGE_FLAG_ARRAY_STRIDE         HEX: 808C ; inline
: GL_VERTEX_ARRAY_POINTER           HEX: 808E ; inline
: GL_NORMAL_ARRAY_POINTER           HEX: 808F ; inline
: GL_COLOR_ARRAY_POINTER            HEX: 8090 ; inline
: GL_INDEX_ARRAY_POINTER            HEX: 8091 ; inline
: GL_TEXTURE_COORD_ARRAY_POINTER    HEX: 8092 ; inline
: GL_EDGE_FLAG_ARRAY_POINTER        HEX: 8093 ; inline
: GL_V2F                            HEX: 2A20 ; inline
: GL_V3F                            HEX: 2A21 ; inline
: GL_C4UB_V2F                       HEX: 2A22 ; inline
: GL_C4UB_V3F                       HEX: 2A23 ; inline
: GL_C3F_V3F                        HEX: 2A24 ; inline
: GL_N3F_V3F                        HEX: 2A25 ; inline
: GL_C4F_N3F_V3F                    HEX: 2A26 ; inline
: GL_T2F_V3F                        HEX: 2A27 ; inline
: GL_T4F_V4F                        HEX: 2A28 ; inline
: GL_T2F_C4UB_V3F                   HEX: 2A29 ; inline
: GL_T2F_C3F_V3F                    HEX: 2A2A ; inline
: GL_T2F_N3F_V3F                    HEX: 2A2B ; inline
: GL_T2F_C4F_N3F_V3F                HEX: 2A2C ; inline
: GL_T4F_C4F_N3F_V4F                HEX: 2A2D ; inline

! Matrix mode
: GL_MATRIX_MODE                    HEX: 0BA0 ; inline
: GL_MODELVIEW                      HEX: 1700 ; inline
: GL_PROJECTION                     HEX: 1701 ; inline
: GL_TEXTURE                        HEX: 1702 ; inline

! Points
: GL_POINT_SMOOTH                   HEX: 0B10 ; inline
: GL_POINT_SIZE                     HEX: 0B11 ; inline
: GL_POINT_SIZE_GRANULARITY         HEX: 0B13 ; inline
: GL_POINT_SIZE_RANGE               HEX: 0B12 ; inline

! Lines
: GL_LINE_SMOOTH                    HEX: 0B20 ; inline
: GL_LINE_STIPPLE                   HEX: 0B24 ; inline
: GL_LINE_STIPPLE_PATTERN           HEX: 0B25 ; inline
: GL_LINE_STIPPLE_REPEAT            HEX: 0B26 ; inline
: GL_LINE_WIDTH                     HEX: 0B21 ; inline
: GL_LINE_WIDTH_GRANULARITY         HEX: 0B23 ; inline
: GL_LINE_WIDTH_RANGE               HEX: 0B22 ; inline

! Polygons
: GL_POINT                          HEX: 1B00 ; inline
: GL_LINE                           HEX: 1B01 ; inline
: GL_FILL                           HEX: 1B02 ; inline
: GL_CW                             HEX: 0900 ; inline
: GL_CCW                            HEX: 0901 ; inline
: GL_FRONT                          HEX: 0404 ; inline
: GL_BACK                           HEX: 0405 ; inline
: GL_POLYGON_MODE                   HEX: 0B40 ; inline
: GL_POLYGON_SMOOTH                 HEX: 0B41 ; inline
: GL_POLYGON_STIPPLE                HEX: 0B42 ; inline
: GL_EDGE_FLAG                      HEX: 0B43 ; inline
: GL_CULL_FACE                      HEX: 0B44 ; inline
: GL_CULL_FACE_MODE                 HEX: 0B45 ; inline
: GL_FRONT_FACE                     HEX: 0B46 ; inline
: GL_POLYGON_OFFSET_FACTOR          HEX: 8038 ; inline
: GL_POLYGON_OFFSET_UNITS           HEX: 2A00 ; inline
: GL_POLYGON_OFFSET_POINT           HEX: 2A01 ; inline
: GL_POLYGON_OFFSET_LINE            HEX: 2A02 ; inline
: GL_POLYGON_OFFSET_FILL            HEX: 8037 ; inline

! Display Lists
: GL_COMPILE                        HEX: 1300 ; inline
: GL_COMPILE_AND_EXECUTE            HEX: 1301 ; inline
: GL_LIST_BASE                      HEX: 0B32 ; inline
: GL_LIST_INDEX                     HEX: 0B33 ; inline
: GL_LIST_MODE                      HEX: 0B30 ; inline

! Depth buffer
: GL_NEVER                          HEX: 0200 ; inline
: GL_LESS                           HEX: 0201 ; inline
: GL_EQUAL                          HEX: 0202 ; inline
: GL_LEQUAL                         HEX: 0203 ; inline
: GL_GREATER                        HEX: 0204 ; inline
: GL_NOTEQUAL                       HEX: 0205 ; inline
: GL_GEQUAL                         HEX: 0206 ; inline
: GL_ALWAYS                         HEX: 0207 ; inline
: GL_DEPTH_TEST                     HEX: 0B71 ; inline
: GL_DEPTH_BITS                     HEX: 0D56 ; inline
: GL_DEPTH_CLEAR_VALUE              HEX: 0B73 ; inline
: GL_DEPTH_FUNC                     HEX: 0B74 ; inline
: GL_DEPTH_RANGE                    HEX: 0B70 ; inline
: GL_DEPTH_WRITEMASK                HEX: 0B72 ; inline
: GL_DEPTH_COMPONENT                HEX: 1902 ; inline

! Lighting
: GL_LIGHTING                       HEX: 0B50 ; inline
: GL_LIGHT0                         HEX: 4000 ; inline
: GL_LIGHT1                         HEX: 4001 ; inline
: GL_LIGHT2                         HEX: 4002 ; inline
: GL_LIGHT3                         HEX: 4003 ; inline
: GL_LIGHT4                         HEX: 4004 ; inline
: GL_LIGHT5                         HEX: 4005 ; inline
: GL_LIGHT6                         HEX: 4006 ; inline
: GL_LIGHT7                         HEX: 4007 ; inline
: GL_SPOT_EXPONENT                  HEX: 1205 ; inline
: GL_SPOT_CUTOFF                    HEX: 1206 ; inline
: GL_CONSTANT_ATTENUATION           HEX: 1207 ; inline
: GL_LINEAR_ATTENUATION             HEX: 1208 ; inline
: GL_QUADRATIC_ATTENUATION          HEX: 1209 ; inline
: GL_AMBIENT                        HEX: 1200 ; inline
: GL_DIFFUSE                        HEX: 1201 ; inline
: GL_SPECULAR                       HEX: 1202 ; inline
: GL_SHININESS                      HEX: 1601 ; inline
: GL_EMISSION                       HEX: 1600 ; inline
: GL_POSITION                       HEX: 1203 ; inline
: GL_SPOT_DIRECTION                 HEX: 1204 ; inline
: GL_AMBIENT_AND_DIFFUSE            HEX: 1602 ; inline
: GL_COLOR_INDEXES                  HEX: 1603 ; inline
: GL_LIGHT_MODEL_TWO_SIDE           HEX: 0B52 ; inline
: GL_LIGHT_MODEL_LOCAL_VIEWER       HEX: 0B51 ; inline
: GL_LIGHT_MODEL_AMBIENT            HEX: 0B53 ; inline
: GL_FRONT_AND_BACK                 HEX: 0408 ; inline
: GL_SHADE_MODEL                    HEX: 0B54 ; inline
: GL_FLAT                           HEX: 1D00 ; inline
: GL_SMOOTH                         HEX: 1D01 ; inline
: GL_COLOR_MATERIAL                 HEX: 0B57 ; inline
: GL_COLOR_MATERIAL_FACE            HEX: 0B55 ; inline
: GL_COLOR_MATERIAL_PARAMETER       HEX: 0B56 ; inline
: GL_NORMALIZE                      HEX: 0BA1 ; inline

! User clipping planes
: GL_CLIP_PLANE0                    HEX: 3000 ; inline
: GL_CLIP_PLANE1                    HEX: 3001 ; inline
: GL_CLIP_PLANE2                    HEX: 3002 ; inline
: GL_CLIP_PLANE3                    HEX: 3003 ; inline
: GL_CLIP_PLANE4                    HEX: 3004 ; inline
: GL_CLIP_PLANE5                    HEX: 3005 ; inline

! Accumulation buffer
: GL_ACCUM_RED_BITS                 HEX: 0D58 ; inline
: GL_ACCUM_GREEN_BITS               HEX: 0D59 ; inline
: GL_ACCUM_BLUE_BITS                HEX: 0D5A ; inline
: GL_ACCUM_ALPHA_BITS               HEX: 0D5B ; inline
: GL_ACCUM_CLEAR_VALUE              HEX: 0B80 ; inline
: GL_ACCUM                          HEX: 0100 ; inline
: GL_ADD                            HEX: 0104 ; inline
: GL_LOAD                           HEX: 0101 ; inline
: GL_MULT                           HEX: 0103 ; inline
: GL_RETURN                         HEX: 0102 ; inline

! Alpha testing
: GL_ALPHA_TEST                     HEX: 0BC0 ; inline
: GL_ALPHA_TEST_REF                 HEX: 0BC2 ; inline
: GL_ALPHA_TEST_FUNC                HEX: 0BC1 ; inline

! Blending
: GL_BLEND                          HEX: 0BE2 ; inline
: GL_BLEND_SRC                      HEX: 0BE1 ; inline
: GL_BLEND_DST                      HEX: 0BE0 ; inline
: GL_ZERO                           HEX: 0 ;  inline
: GL_ONE                            HEX: 1 ;  inline
: GL_SRC_COLOR                      HEX: 0300 ; inline
: GL_ONE_MINUS_SRC_COLOR            HEX: 0301 ; inline
: GL_SRC_ALPHA                      HEX: 0302 ; inline
: GL_ONE_MINUS_SRC_ALPHA            HEX: 0303 ; inline
: GL_DST_ALPHA                      HEX: 0304 ; inline
: GL_ONE_MINUS_DST_ALPHA            HEX: 0305 ; inline
: GL_DST_COLOR                      HEX: 0306 ; inline
: GL_ONE_MINUS_DST_COLOR            HEX: 0307 ; inline
: GL_SRC_ALPHA_SATURATE             HEX: 0308 ; inline

! Render Mode
: GL_FEEDBACK                       HEX: 1C01 ; inline
: GL_RENDER                         HEX: 1C00 ; inline
: GL_SELECT                         HEX: 1C02 ; inline

! Feedback
: GL_2D                             HEX: 0600 ; inline
: GL_3D                             HEX: 0601 ; inline
: GL_3D_COLOR                       HEX: 0602 ; inline
: GL_3D_COLOR_TEXTURE               HEX: 0603 ; inline
: GL_4D_COLOR_TEXTURE               HEX: 0604 ; inline
: GL_POINT_TOKEN                    HEX: 0701 ; inline
: GL_LINE_TOKEN                     HEX: 0702 ; inline
: GL_LINE_RESET_TOKEN               HEX: 0707 ; inline
: GL_POLYGON_TOKEN                  HEX: 0703 ; inline
: GL_BITMAP_TOKEN                   HEX: 0704 ; inline
: GL_DRAW_PIXEL_TOKEN               HEX: 0705 ; inline
: GL_COPY_PIXEL_TOKEN               HEX: 0706 ; inline
: GL_PASS_THROUGH_TOKEN             HEX: 0700 ; inline
: GL_FEEDBACK_BUFFER_POINTER        HEX: 0DF0 ; inline
: GL_FEEDBACK_BUFFER_SIZE           HEX: 0DF1 ; inline
: GL_FEEDBACK_BUFFER_TYPE           HEX: 0DF2 ; inline

! Selection
: GL_SELECTION_BUFFER_POINTER       HEX: 0DF3 ; inline
: GL_SELECTION_BUFFER_SIZE          HEX: 0DF4 ; inline

! Fog
: GL_FOG                            HEX: 0B60 ; inline
: GL_FOG_MODE                       HEX: 0B65 ; inline
: GL_FOG_DENSITY                    HEX: 0B62 ; inline
: GL_FOG_COLOR                      HEX: 0B66 ; inline
: GL_FOG_INDEX                      HEX: 0B61 ; inline
: GL_FOG_START                      HEX: 0B63 ; inline
: GL_FOG_END                        HEX: 0B64 ; inline
: GL_LINEAR                         HEX: 2601 ; inline
: GL_EXP                            HEX: 0800 ; inline
: GL_EXP2                           HEX: 0801 ; inline

! Logic Ops
: GL_LOGIC_OP                       HEX: 0BF1 ; inline
: GL_INDEX_LOGIC_OP                 HEX: 0BF1 ; inline
: GL_COLOR_LOGIC_OP                 HEX: 0BF2 ; inline
: GL_LOGIC_OP_MODE                  HEX: 0BF0 ; inline
: GL_CLEAR                          HEX: 1500 ; inline
: GL_SET                            HEX: 150F ; inline
: GL_COPY                           HEX: 1503 ; inline
: GL_COPY_INVERTED                  HEX: 150C ; inline
: GL_NOOP                           HEX: 1505 ; inline
: GL_INVERT                         HEX: 150A ; inline
: GL_AND                            HEX: 1501 ; inline
: GL_NAND                           HEX: 150E ; inline
: GL_OR                             HEX: 1507 ; inline
: GL_NOR                            HEX: 1508 ; inline
: GL_XOR                            HEX: 1506 ; inline
: GL_EQUIV                          HEX: 1509 ; inline
: GL_AND_REVERSE                    HEX: 1502 ; inline
: GL_AND_INVERTED                   HEX: 1504 ; inline
: GL_OR_REVERSE                     HEX: 150B ; inline
: GL_OR_INVERTED                    HEX: 150D ; inline

! Stencil
: GL_STENCIL_TEST                   HEX: 0B90 ; inline
: GL_STENCIL_WRITEMASK              HEX: 0B98 ; inline
: GL_STENCIL_BITS                   HEX: 0D57 ; inline
: GL_STENCIL_FUNC                   HEX: 0B92 ; inline
: GL_STENCIL_VALUE_MASK             HEX: 0B93 ; inline
: GL_STENCIL_REF                    HEX: 0B97 ; inline
: GL_STENCIL_FAIL                   HEX: 0B94 ; inline
: GL_STENCIL_PASS_DEPTH_PASS        HEX: 0B96 ; inline
: GL_STENCIL_PASS_DEPTH_FAIL        HEX: 0B95 ; inline
: GL_STENCIL_CLEAR_VALUE            HEX: 0B91 ; inline
: GL_STENCIL_INDEX                  HEX: 1901 ; inline
: GL_KEEP                           HEX: 1E00 ; inline
: GL_REPLACE                        HEX: 1E01 ; inline
: GL_INCR                           HEX: 1E02 ; inline
: GL_DECR                           HEX: 1E03 ; inline

! Buffers, Pixel Drawing/Reading
: GL_NONE                           HEX:    0 ; inline
: GL_LEFT                           HEX: 0406 ; inline
: GL_RIGHT                          HEX: 0407 ; inline
! defined elsewhere
! GL_FRONT                          HEX: 0404
! GL_BACK                           HEX: 0405
! GL_FRONT_AND_BACK                 HEX: 0408
: GL_FRONT_LEFT                     HEX: 0400 ; inline
: GL_FRONT_RIGHT                    HEX: 0401 ; inline
: GL_BACK_LEFT                      HEX: 0402 ; inline
: GL_BACK_RIGHT                     HEX: 0403 ; inline
: GL_AUX0                           HEX: 0409 ; inline
: GL_AUX1                           HEX: 040A ; inline
: GL_AUX2                           HEX: 040B ; inline
: GL_AUX3                           HEX: 040C ; inline
: GL_COLOR_INDEX                    HEX: 1900 ; inline
: GL_RED                            HEX: 1903 ; inline
: GL_GREEN                          HEX: 1904 ; inline
: GL_BLUE                           HEX: 1905 ; inline
: GL_ALPHA                          HEX: 1906 ; inline
: GL_LUMINANCE                      HEX: 1909 ; inline
: GL_LUMINANCE_ALPHA                HEX: 190A ; inline
: GL_ALPHA_BITS                     HEX: 0D55 ; inline
: GL_RED_BITS                       HEX: 0D52 ; inline
: GL_GREEN_BITS                     HEX: 0D53 ; inline
: GL_BLUE_BITS                      HEX: 0D54 ; inline
: GL_INDEX_BITS                     HEX: 0D51 ; inline
: GL_SUBPIXEL_BITS                  HEX: 0D50 ; inline
: GL_AUX_BUFFERS                    HEX: 0C00 ; inline
: GL_READ_BUFFER                    HEX: 0C02 ; inline
: GL_DRAW_BUFFER                    HEX: 0C01 ; inline
: GL_DOUBLEBUFFER                   HEX: 0C32 ; inline
: GL_STEREO                         HEX: 0C33 ; inline
: GL_BITMAP                         HEX: 1A00 ; inline
: GL_COLOR                          HEX: 1800 ; inline
: GL_DEPTH                          HEX: 1801 ; inline
: GL_STENCIL                        HEX: 1802 ; inline
: GL_DITHER                         HEX: 0BD0 ; inline
: GL_RGB                            HEX: 1907 ; inline
: GL_RGBA                           HEX: 1908 ; inline

! Implementation limits
: GL_MAX_LIST_NESTING               HEX: 0B31 ; inline
: GL_MAX_ATTRIB_STACK_DEPTH         HEX: 0D35 ; inline
: GL_MAX_MODELVIEW_STACK_DEPTH      HEX: 0D36 ; inline
: GL_MAX_NAME_STACK_DEPTH           HEX: 0D37 ; inline
: GL_MAX_PROJECTION_STACK_DEPTH     HEX: 0D38 ; inline
: GL_MAX_TEXTURE_STACK_DEPTH        HEX: 0D39 ; inline
: GL_MAX_EVAL_ORDER                 HEX: 0D30 ; inline
: GL_MAX_LIGHTS                     HEX: 0D31 ; inline
: GL_MAX_CLIP_PLANES                HEX: 0D32 ; inline
: GL_MAX_TEXTURE_SIZE               HEX: 0D33 ; inline
: GL_MAX_PIXEL_MAP_TABLE            HEX: 0D34 ; inline
: GL_MAX_VIEWPORT_DIMS              HEX: 0D3A ; inline
: GL_MAX_CLIENT_ATTRIB_STACK_DEPTH  HEX: 0D3B ; inline

! Gets
: GL_ATTRIB_STACK_DEPTH             HEX: 0BB0 ; inline
: GL_CLIENT_ATTRIB_STACK_DEPTH      HEX: 0BB1 ; inline
: GL_COLOR_CLEAR_VALUE              HEX: 0C22 ; inline
: GL_COLOR_WRITEMASK                HEX: 0C23 ; inline
: GL_CURRENT_INDEX                  HEX: 0B01 ; inline
: GL_CURRENT_COLOR                  HEX: 0B00 ; inline
: GL_CURRENT_NORMAL                 HEX: 0B02 ; inline
: GL_CURRENT_RASTER_COLOR           HEX: 0B04 ; inline
: GL_CURRENT_RASTER_DISTANCE        HEX: 0B09 ; inline
: GL_CURRENT_RASTER_INDEX           HEX: 0B05 ; inline
: GL_CURRENT_RASTER_POSITION        HEX: 0B07 ; inline
: GL_CURRENT_RASTER_TEXTURE_COORDS  HEX: 0B06 ; inline
: GL_CURRENT_RASTER_POSITION_VALID  HEX: 0B08 ; inline
: GL_CURRENT_TEXTURE_COORDS         HEX: 0B03 ; inline
: GL_INDEX_CLEAR_VALUE              HEX: 0C20 ; inline
: GL_INDEX_MODE                     HEX: 0C30 ; inline
: GL_INDEX_WRITEMASK                HEX: 0C21 ; inline
: GL_MODELVIEW_MATRIX               HEX: 0BA6 ; inline
: GL_MODELVIEW_STACK_DEPTH          HEX: 0BA3 ; inline
: GL_NAME_STACK_DEPTH               HEX: 0D70 ; inline
: GL_PROJECTION_MATRIX              HEX: 0BA7 ; inline
: GL_PROJECTION_STACK_DEPTH         HEX: 0BA4 ; inline
: GL_RENDER_MODE                    HEX: 0C40 ; inline
: GL_RGBA_MODE                      HEX: 0C31 ; inline
: GL_TEXTURE_MATRIX                 HEX: 0BA8 ; inline
: GL_TEXTURE_STACK_DEPTH            HEX: 0BA5 ; inline
: GL_VIEWPORT                       HEX: 0BA2 ; inline

! Evaluators inline
: GL_AUTO_NORMAL                    HEX: 0D80 ; inline
: GL_MAP1_COLOR_4                   HEX: 0D90 ; inline
: GL_MAP1_INDEX                     HEX: 0D91 ; inline
: GL_MAP1_NORMAL                    HEX: 0D92 ; inline
: GL_MAP1_TEXTURE_COORD_1           HEX: 0D93 ; inline
: GL_MAP1_TEXTURE_COORD_2           HEX: 0D94 ; inline
: GL_MAP1_TEXTURE_COORD_3           HEX: 0D95 ; inline
: GL_MAP1_TEXTURE_COORD_4           HEX: 0D96 ; inline
: GL_MAP1_VERTEX_3                  HEX: 0D97 ; inline
: GL_MAP1_VERTEX_4                  HEX: 0D98 ; inline
: GL_MAP2_COLOR_4                   HEX: 0DB0 ; inline
: GL_MAP2_INDEX                     HEX: 0DB1 ; inline
: GL_MAP2_NORMAL                    HEX: 0DB2 ; inline
: GL_MAP2_TEXTURE_COORD_1           HEX: 0DB3 ; inline
: GL_MAP2_TEXTURE_COORD_2           HEX: 0DB4 ; inline
: GL_MAP2_TEXTURE_COORD_3           HEX: 0DB5 ; inline
: GL_MAP2_TEXTURE_COORD_4           HEX: 0DB6 ; inline
: GL_MAP2_VERTEX_3                  HEX: 0DB7 ; inline
: GL_MAP2_VERTEX_4                  HEX: 0DB8 ; inline
: GL_MAP1_GRID_DOMAIN               HEX: 0DD0 ; inline
: GL_MAP1_GRID_SEGMENTS             HEX: 0DD1 ; inline
: GL_MAP2_GRID_DOMAIN               HEX: 0DD2 ; inline
: GL_MAP2_GRID_SEGMENTS             HEX: 0DD3 ; inline
: GL_COEFF                          HEX: 0A00 ; inline
: GL_DOMAIN                         HEX: 0A02 ; inline
: GL_ORDER                          HEX: 0A01 ; inline

! Hints inline
: GL_FOG_HINT                       HEX: 0C54 ; inline
: GL_LINE_SMOOTH_HINT               HEX: 0C52 ; inline
: GL_PERSPECTIVE_CORRECTION_HINT    HEX: 0C50 ; inline
: GL_POINT_SMOOTH_HINT              HEX: 0C51 ; inline
: GL_POLYGON_SMOOTH_HINT            HEX: 0C53 ; inline
: GL_DONT_CARE                      HEX: 1100 ; inline
: GL_FASTEST                        HEX: 1101 ; inline
: GL_NICEST                         HEX: 1102 ; inline

! Scissor box inline
: GL_SCISSOR_TEST                   HEX: 0C11 ; inline
: GL_SCISSOR_BOX                    HEX: 0C10 ; inline

! Pixel Mode / Transfer inline
: GL_MAP_COLOR                      HEX: 0D10 ; inline
: GL_MAP_STENCIL                    HEX: 0D11 ; inline
: GL_INDEX_SHIFT                    HEX: 0D12 ; inline
: GL_INDEX_OFFSET                   HEX: 0D13 ; inline
: GL_RED_SCALE                      HEX: 0D14 ; inline
: GL_RED_BIAS                       HEX: 0D15 ; inline
: GL_GREEN_SCALE                    HEX: 0D18 ; inline
: GL_GREEN_BIAS                     HEX: 0D19 ; inline
: GL_BLUE_SCALE                     HEX: 0D1A ; inline
: GL_BLUE_BIAS                      HEX: 0D1B ; inline
: GL_ALPHA_SCALE                    HEX: 0D1C ; inline
: GL_ALPHA_BIAS                     HEX: 0D1D ; inline
: GL_DEPTH_SCALE                    HEX: 0D1E ; inline
: GL_DEPTH_BIAS                     HEX: 0D1F ; inline
: GL_PIXEL_MAP_S_TO_S_SIZE          HEX: 0CB1 ; inline
: GL_PIXEL_MAP_I_TO_I_SIZE          HEX: 0CB0 ; inline
: GL_PIXEL_MAP_I_TO_R_SIZE          HEX: 0CB2 ; inline
: GL_PIXEL_MAP_I_TO_G_SIZE          HEX: 0CB3 ; inline
: GL_PIXEL_MAP_I_TO_B_SIZE          HEX: 0CB4 ; inline
: GL_PIXEL_MAP_I_TO_A_SIZE          HEX: 0CB5 ; inline
: GL_PIXEL_MAP_R_TO_R_SIZE          HEX: 0CB6 ; inline
: GL_PIXEL_MAP_G_TO_G_SIZE          HEX: 0CB7 ; inline
: GL_PIXEL_MAP_B_TO_B_SIZE          HEX: 0CB8 ; inline
: GL_PIXEL_MAP_A_TO_A_SIZE          HEX: 0CB9 ; inline
: GL_PIXEL_MAP_S_TO_S               HEX: 0C71 ; inline
: GL_PIXEL_MAP_I_TO_I               HEX: 0C70 ; inline
: GL_PIXEL_MAP_I_TO_R               HEX: 0C72 ; inline
: GL_PIXEL_MAP_I_TO_G               HEX: 0C73 ; inline
: GL_PIXEL_MAP_I_TO_B               HEX: 0C74 ; inline
: GL_PIXEL_MAP_I_TO_A               HEX: 0C75 ; inline
: GL_PIXEL_MAP_R_TO_R               HEX: 0C76 ; inline
: GL_PIXEL_MAP_G_TO_G               HEX: 0C77 ; inline
: GL_PIXEL_MAP_B_TO_B               HEX: 0C78 ; inline
: GL_PIXEL_MAP_A_TO_A               HEX: 0C79 ; inline
: GL_PACK_ALIGNMENT                 HEX: 0D05 ; inline
: GL_PACK_LSB_FIRST                 HEX: 0D01 ; inline
: GL_PACK_ROW_LENGTH                HEX: 0D02 ; inline
: GL_PACK_SKIP_PIXELS               HEX: 0D04 ; inline
: GL_PACK_SKIP_ROWS                 HEX: 0D03 ; inline
: GL_PACK_SWAP_BYTES                HEX: 0D00 ; inline
: GL_UNPACK_ALIGNMENT               HEX: 0CF5 ; inline
: GL_UNPACK_LSB_FIRST               HEX: 0CF1 ; inline
: GL_UNPACK_ROW_LENGTH              HEX: 0CF2 ; inline
: GL_UNPACK_SKIP_PIXELS             HEX: 0CF4 ; inline
: GL_UNPACK_SKIP_ROWS               HEX: 0CF3 ; inline
: GL_UNPACK_SWAP_BYTES              HEX: 0CF0 ; inline
: GL_ZOOM_X                         HEX: 0D16 ; inline
: GL_ZOOM_Y                         HEX: 0D17 ; inline

! Texture mapping inline
: GL_TEXTURE_ENV                    HEX: 2300 ; inline
: GL_TEXTURE_ENV_MODE               HEX: 2200 ; inline
: GL_TEXTURE_1D                     HEX: 0DE0 ; inline
: GL_TEXTURE_2D                     HEX: 0DE1 ; inline
: GL_TEXTURE_WRAP_S                 HEX: 2802 ; inline
: GL_TEXTURE_WRAP_T                 HEX: 2803 ; inline
: GL_TEXTURE_MAG_FILTER             HEX: 2800 ; inline
: GL_TEXTURE_MIN_FILTER             HEX: 2801 ; inline
: GL_TEXTURE_ENV_COLOR              HEX: 2201 ; inline
: GL_TEXTURE_GEN_S                  HEX: 0C60 ; inline
: GL_TEXTURE_GEN_T                  HEX: 0C61 ; inline
: GL_TEXTURE_GEN_MODE               HEX: 2500 ; inline
: GL_TEXTURE_BORDER_COLOR           HEX: 1004 ; inline
: GL_TEXTURE_WIDTH                  HEX: 1000 ; inline
: GL_TEXTURE_HEIGHT                 HEX: 1001 ; inline
: GL_TEXTURE_BORDER                 HEX: 1005 ; inline
: GL_TEXTURE_COMPONENTS             HEX: 1003 ; inline
: GL_TEXTURE_RED_SIZE               HEX: 805C ; inline
: GL_TEXTURE_GREEN_SIZE             HEX: 805D ; inline
: GL_TEXTURE_BLUE_SIZE              HEX: 805E ; inline
: GL_TEXTURE_ALPHA_SIZE             HEX: 805F ; inline
: GL_TEXTURE_LUMINANCE_SIZE         HEX: 8060 ; inline
: GL_TEXTURE_INTENSITY_SIZE         HEX: 8061 ; inline
: GL_NEAREST_MIPMAP_NEAREST         HEX: 2700 ; inline
: GL_NEAREST_MIPMAP_LINEAR          HEX: 2702 ; inline
: GL_LINEAR_MIPMAP_NEAREST          HEX: 2701 ; inline
: GL_LINEAR_MIPMAP_LINEAR           HEX: 2703 ; inline
: GL_OBJECT_LINEAR                  HEX: 2401 ; inline
: GL_OBJECT_PLANE                   HEX: 2501 ; inline
: GL_EYE_LINEAR                     HEX: 2400 ; inline
: GL_EYE_PLANE                      HEX: 2502 ; inline
: GL_SPHERE_MAP                     HEX: 2402 ; inline
: GL_DECAL                          HEX: 2101 ; inline
: GL_MODULATE                       HEX: 2100 ; inline
: GL_NEAREST                        HEX: 2600 ; inline
: GL_REPEAT                         HEX: 2901 ; inline
: GL_CLAMP                          HEX: 2900 ; inline
: GL_S                              HEX: 2000 ; inline
: GL_T                              HEX: 2001 ; inline
: GL_R                              HEX: 2002 ; inline
: GL_Q                              HEX: 2003 ; inline
: GL_TEXTURE_GEN_R                  HEX: 0C62 ; inline
: GL_TEXTURE_GEN_Q                  HEX: 0C63 ; inline

! Utility inline
: GL_VENDOR                         HEX: 1F00 ; inline
: GL_RENDERER                       HEX: 1F01 ; inline
: GL_VERSION                        HEX: 1F02 ; inline
: GL_EXTENSIONS                     HEX: 1F03 ; inline

! Errors inline
: GL_NO_ERROR                       HEX:    0 ; inline
: GL_INVALID_VALUE                  HEX: 0501 ; inline
: GL_INVALID_ENUM                   HEX: 0500 ; inline
: GL_INVALID_OPERATION              HEX: 0502 ; inline
: GL_STACK_OVERFLOW                 HEX: 0503 ; inline
: GL_STACK_UNDERFLOW                HEX: 0504 ; inline
: GL_OUT_OF_MEMORY                  HEX: 0505 ; inline

! glPush/PopAttrib bits
: GL_CURRENT_BIT                    HEX: 00000001 ; inline
: GL_POINT_BIT                      HEX: 00000002 ; inline
: GL_LINE_BIT                       HEX: 00000004 ; inline
: GL_POLYGON_BIT                    HEX: 00000008 ; inline
: GL_POLYGON_STIPPLE_BIT            HEX: 00000010 ; inline
: GL_PIXEL_MODE_BIT                 HEX: 00000020 ; inline
: GL_LIGHTING_BIT                   HEX: 00000040 ; inline
: GL_FOG_BIT                        HEX: 00000080 ; inline
: GL_DEPTH_BUFFER_BIT               HEX: 00000100 ; inline
: GL_ACCUM_BUFFER_BIT               HEX: 00000200 ; inline
: GL_STENCIL_BUFFER_BIT             HEX: 00000400 ; inline
: GL_VIEWPORT_BIT                   HEX: 00000800 ; inline
: GL_TRANSFORM_BIT                  HEX: 00001000 ; inline
: GL_ENABLE_BIT                     HEX: 00002000 ; inline
: GL_COLOR_BUFFER_BIT               HEX: 00004000 ; inline
: GL_HINT_BIT                       HEX: 00008000 ; inline
: GL_EVAL_BIT                       HEX: 00010000 ; inline
: GL_LIST_BIT                       HEX: 00020000 ; inline
: GL_TEXTURE_BIT                    HEX: 00040000 ; inline
: GL_SCISSOR_BIT                    HEX: 00080000 ; inline
: GL_ALL_ATTRIB_BITS                HEX: 000FFFFF ; inline

! OpenGL 1.1
: GL_PROXY_TEXTURE_1D               HEX: 8063 ; inline
: GL_PROXY_TEXTURE_2D               HEX: 8064 ; inline
: GL_TEXTURE_PRIORITY               HEX: 8066 ; inline
: GL_TEXTURE_RESIDENT               HEX: 8067 ; inline
: GL_TEXTURE_BINDING_1D             HEX: 8068 ; inline
: GL_TEXTURE_BINDING_2D             HEX: 8069 ; inline
: GL_TEXTURE_INTERNAL_FORMAT        HEX: 1003 ; inline
: GL_ALPHA4                         HEX: 803B ; inline
: GL_ALPHA8                         HEX: 803C ; inline
: GL_ALPHA12                        HEX: 803D ; inline
: GL_ALPHA16                        HEX: 803E ; inline
: GL_LUMINANCE4                     HEX: 803F ; inline
: GL_LUMINANCE8                     HEX: 8040 ; inline
: GL_LUMINANCE12                    HEX: 8041 ; inline
: GL_LUMINANCE16                    HEX: 8042 ; inline
: GL_LUMINANCE4_ALPHA4              HEX: 8043 ; inline
: GL_LUMINANCE6_ALPHA2              HEX: 8044 ; inline
: GL_LUMINANCE8_ALPHA8              HEX: 8045 ; inline
: GL_LUMINANCE12_ALPHA4             HEX: 8046 ; inline
: GL_LUMINANCE12_ALPHA12            HEX: 8047 ; inline
: GL_LUMINANCE16_ALPHA16            HEX: 8048 ; inline
: GL_INTENSITY                      HEX: 8049 ; inline
: GL_INTENSITY4                     HEX: 804A ; inline
: GL_INTENSITY8                     HEX: 804B ; inline
: GL_INTENSITY12                    HEX: 804C ; inline
: GL_INTENSITY16                    HEX: 804D ; inline
: GL_R3_G3_B2                       HEX: 2A10 ; inline
: GL_RGB4                           HEX: 804F ; inline
: GL_RGB5                           HEX: 8050 ; inline
: GL_RGB8                           HEX: 8051 ; inline
: GL_RGB10                          HEX: 8052 ; inline
: GL_RGB12                          HEX: 8053 ; inline
: GL_RGB16                          HEX: 8054 ; inline
: GL_RGBA2                          HEX: 8055 ; inline
: GL_RGBA4                          HEX: 8056 ; inline
: GL_RGB5_A1                        HEX: 8057 ; inline
: GL_RGBA8                          HEX: 8058 ; inline
: GL_RGB10_A2                       HEX: 8059 ; inline
: GL_RGBA12                         HEX: 805A ; inline
: GL_RGBA16                         HEX: 805B ; inline
: GL_CLIENT_PIXEL_STORE_BIT         HEX: 00000001 ; inline
: GL_CLIENT_VERTEX_ARRAY_BIT        HEX: 00000002 ; inline
: GL_ALL_CLIENT_ATTRIB_BITS         HEX: FFFFFFFF ; inline
: GL_CLIENT_ALL_ATTRIB_BITS         HEX: FFFFFFFF ; inline

LIBRARY: gl

! Miscellaneous

FUNCTION: void glClearIndex ( GLfloat c ) ;
FUNCTION: void glClearColor ( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha ) ;
FUNCTION: void glClear ( GLbitfield mask ) ;
FUNCTION: void glIndexMask ( GLuint mask ) ;
FUNCTION: void glColorMask ( GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha ) ;
FUNCTION: void glAlphaFunc ( GLenum func, GLclampf ref ) ;
FUNCTION: void glBlendFunc ( GLenum sfactor, GLenum dfactor ) ;
FUNCTION: void glLogicOp ( GLenum opcode ) ;
FUNCTION: void glCullFace ( GLenum mode ) ;
FUNCTION: void glFrontFace ( GLenum mode ) ;
FUNCTION: void glPointSize ( GLfloat size ) ;
FUNCTION: void glLineWidth ( GLfloat width ) ;
FUNCTION: void glLineStipple ( GLint factor, GLushort pattern ) ;
FUNCTION: void glPolygonMode ( GLenum face, GLenum mode ) ;
FUNCTION: void glPolygonOffset ( GLfloat factor, GLfloat units ) ;
FUNCTION: void glPolygonStipple ( GLubyte* mask ) ;
FUNCTION: void glGetPolygonStipple ( GLubyte* mask ) ;
FUNCTION: void glEdgeFlag ( GLboolean flag ) ;
FUNCTION: void glEdgeFlagv ( GLboolean* flag ) ;
FUNCTION: void glScissor ( GLint x, GLint y, GLsizei width, GLsizei height ) ;
FUNCTION: void glClipPlane ( GLenum plane, GLdouble* equation ) ;
FUNCTION: void glGetClipPlane ( GLenum plane, GLdouble* equation ) ;
FUNCTION: void glDrawBuffer ( GLenum mode ) ;
FUNCTION: void glReadBuffer ( GLenum mode ) ;
FUNCTION: void glEnable ( GLenum cap ) ;
FUNCTION: void glDisable ( GLenum cap ) ;
FUNCTION: GLboolean glIsEnabled ( GLenum cap ) ;
 
FUNCTION: void glEnableClientState ( GLenum cap ) ;
FUNCTION: void glDisableClientState ( GLenum cap ) ;
FUNCTION: void glGetBooleanv ( GLenum pname, GLboolean* params ) ;
FUNCTION: void glGetDoublev ( GLenum pname, GLdouble* params ) ;
FUNCTION: void glGetFloatv ( GLenum pname, GLfloat* params ) ;
FUNCTION: void glGetIntegerv ( GLenum pname, GLint* params ) ;

FUNCTION: void glPushAttrib ( GLbitfield mask ) ;
FUNCTION: void glPopAttrib ( ) ;

FUNCTION: void glPushClientAttrib ( GLbitfield mask ) ;
FUNCTION: void glPopClientAttrib ( ) ;

FUNCTION: GLint glRenderMode ( GLenum mode ) ;
FUNCTION: GLenum glGetError ( ) ;
FUNCTION: GLubyte* glGetString ( GLenum name ) ;
FUNCTION: void glFinish ( ) ;
FUNCTION: void glFlush ( ) ;
FUNCTION: void glHint ( GLenum target, GLenum mode ) ;

FUNCTION: void glClearDepth ( GLclampd depth ) ;
FUNCTION: void glDepthFunc ( GLenum func ) ;
FUNCTION: void glDepthMask ( GLboolean flag ) ;
FUNCTION: void glDepthRange ( GLclampd near_val, GLclampd far_val ) ;

FUNCTION: void glClearAccum ( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha ) ;
FUNCTION: void glAccum ( GLenum op, GLfloat value ) ;

FUNCTION: void glMatrixMode ( GLenum mode ) ;
FUNCTION: void glOrtho ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, 
                         GLdouble near_val, GLdouble far_val ) ;
FUNCTION: void glFrustum ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, 
                           GLdouble near_val, GLdouble far_val ) ;
FUNCTION: void glViewport ( GLint x, GLint y, GLsizei width, GLsizei height ) ;
FUNCTION: void glPushMatrix ( ) ;
FUNCTION: void glPopMatrix ( ) ;
FUNCTION: void glLoadIdentity ( ) ;
FUNCTION: void glLoadMatrixd ( GLdouble* m ) ;
FUNCTION: void glLoadMatrixf ( GLfloat* m ) ;
FUNCTION: void glMultMatrixd ( GLdouble* m ) ;
FUNCTION: void glMultMatrixf ( GLfloat* m ) ;
FUNCTION: void glRotated ( GLdouble angle, GLdouble x, GLdouble y, GLdouble z ) ;
FUNCTION: void glRotatef ( GLfloat angle, GLfloat x, GLfloat y, GLfloat z ) ;
FUNCTION: void glScaled ( GLdouble x, GLdouble y, GLdouble z ) ;
FUNCTION: void glScalef ( GLfloat x, GLfloat y, GLfloat z ) ;
FUNCTION: void glTranslated ( GLdouble x, GLdouble y, GLdouble z ) ;
FUNCTION: void glTranslatef ( GLfloat x, GLfloat y, GLfloat z ) ;


FUNCTION: GLboolean glIsList ( GLuint list ) ;
FUNCTION: void glDeleteLists ( GLuint list, GLsizei range ) ;
FUNCTION: GLuint glGenLists ( GLsizei range ) ;
FUNCTION: void glNewList ( GLuint list, GLenum mode ) ;
FUNCTION: void glEndList ( ) ;
FUNCTION: void glCallList ( GLuint list ) ;
FUNCTION: void glCallLists ( GLsizei n, GLenum type, GLvoid* lists ) ;
FUNCTION: void glListBase ( GLuint base ) ;

FUNCTION: void glBegin ( GLenum mode ) ;
FUNCTION: void glEnd ( ) ;

FUNCTION: void glVertex2d ( GLdouble x, GLdouble y ) ;
FUNCTION: void glVertex2f ( GLfloat x, GLfloat y ) ;
FUNCTION: void glVertex2i ( GLint x, GLint y ) ;
FUNCTION: void glVertex2s ( GLshort x, GLshort y ) ;

FUNCTION: void glVertex3d ( GLdouble x, GLdouble y, GLdouble z ) ;
FUNCTION: void glVertex3f ( GLfloat x, GLfloat y, GLfloat z ) ;
FUNCTION: void glVertex3i ( GLint x, GLint y, GLint z ) ;
FUNCTION: void glVertex3s ( GLshort x, GLshort y, GLshort z ) ;

FUNCTION: void glVertex4d ( GLdouble x, GLdouble y, GLdouble z, GLdouble w ) ;
FUNCTION: void glVertex4f ( GLfloat x, GLfloat y, GLfloat z, GLfloat w ) ;
FUNCTION: void glVertex4i ( GLint x, GLint y, GLint z, GLint w ) ;
FUNCTION: void glVertex4s ( GLshort x, GLshort y, GLshort z, GLshort w ) ;

FUNCTION: void glVertex2dv ( GLdouble* v ) ;
FUNCTION: void glVertex2fv ( GLfloat* v ) ;
FUNCTION: void glVertex2iv ( GLint* v ) ;
FUNCTION: void glVertex2sv ( GLshort* v ) ;

FUNCTION: void glVertex3dv ( GLdouble* v ) ;
FUNCTION: void glVertex3fv ( GLfloat* v ) ;
FUNCTION: void glVertex3iv ( GLint* v ) ;
FUNCTION: void glVertex3sv ( GLshort* v ) ;

FUNCTION: void glVertex4dv ( GLdouble* v ) ;
FUNCTION: void glVertex4fv ( GLfloat* v ) ;
FUNCTION: void glVertex4iv ( GLint* v ) ;
FUNCTION: void glVertex4sv ( GLshort* v ) ;

FUNCTION: void glNormal3b ( GLbyte nx, GLbyte ny, GLbyte nz ) ;
FUNCTION: void glNormal3d ( GLdouble nx, GLdouble ny, GLdouble nz ) ;
FUNCTION: void glNormal3f ( GLfloat nx, GLfloat ny, GLfloat nz ) ;
FUNCTION: void glNormal3i ( GLint nx, GLint ny, GLint nz ) ;
FUNCTION: void glNormal3s ( GLshort nx, GLshort ny, GLshort nz ) ;

FUNCTION: void glNormal3bv ( GLbyte* v ) ;
FUNCTION: void glNormal3dv ( GLdouble* v ) ;
FUNCTION: void glNormal3fv ( GLfloat* v ) ;
FUNCTION: void glNormal3iv ( GLint* v ) ;
FUNCTION: void glNormal3sv ( GLshort* v ) ;

FUNCTION: void glIndexd ( GLdouble c ) ;
FUNCTION: void glIndexf ( GLfloat c ) ;
FUNCTION: void glIndexi ( GLint c ) ;
FUNCTION: void glIndexs ( GLshort c ) ;
FUNCTION: void glIndexub ( GLubyte c ) ;

FUNCTION: void glIndexdv ( GLdouble* c ) ;
FUNCTION: void glIndexfv ( GLfloat* c ) ;
FUNCTION: void glIndexiv ( GLint* c ) ;
FUNCTION: void glIndexsv ( GLshort* c ) ;
FUNCTION: void glIndexubv ( GLubyte* c ) ;

FUNCTION: void glColor3b ( GLbyte red, GLbyte green, GLbyte blue ) ;
FUNCTION: void glColor3d ( GLdouble red, GLdouble green, GLdouble blue ) ;
FUNCTION: void glColor3f ( GLfloat red, GLfloat green, GLfloat blue ) ;
FUNCTION: void glColor3i ( GLint red, GLint green, GLint blue ) ;
FUNCTION: void glColor3s ( GLshort red, GLshort green, GLshort blue ) ;
FUNCTION: void glColor3ub ( GLubyte red, GLubyte green, GLubyte blue ) ;
FUNCTION: void glColor3ui ( GLuint red, GLuint green, GLuint blue ) ;
FUNCTION: void glColor3us ( GLushort red, GLushort green, GLushort blue ) ;

FUNCTION: void glColor4b ( GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha ) ;
FUNCTION: void glColor4d ( GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha ) ;
FUNCTION: void glColor4f ( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha ) ;
FUNCTION: void glColor4i ( GLint red, GLint green, GLint blue, GLint alpha ) ;
FUNCTION: void glColor4s ( GLshort red, GLshort green, GLshort blue, GLshort alpha ) ;
FUNCTION: void glColor4ub ( GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha ) ;
FUNCTION: void glColor4ui ( GLuint red, GLuint green, GLuint blue, GLuint alpha ) ;
FUNCTION: void glColor4us ( GLushort red, GLushort green, GLushort blue, GLushort alpha ) ;

FUNCTION: void glColor3bv ( GLbyte* v ) ;
FUNCTION: void glColor3dv ( GLdouble* v ) ;
FUNCTION: void glColor3fv ( GLfloat* v ) ;
FUNCTION: void glColor3iv ( GLint* v ) ;
FUNCTION: void glColor3sv ( GLshort* v ) ;
FUNCTION: void glColor3ubv ( GLubyte* v ) ;
FUNCTION: void glColor3uiv ( GLuint* v ) ;
FUNCTION: void glColor3usv ( GLushort* v ) ;

FUNCTION: void glColor4bv ( GLbyte* v ) ;
FUNCTION: void glColor4dv ( GLdouble* v ) ;
FUNCTION: void glColor4fv ( GLfloat* v ) ;
FUNCTION: void glColor4iv ( GLint* v ) ;
FUNCTION: void glColor4sv ( GLshort* v ) ;
FUNCTION: void glColor4ubv ( GLubyte* v ) ;
FUNCTION: void glColor4uiv ( GLuint* v ) ;
FUNCTION: void glColor4usv ( GLushort* v ) ;


FUNCTION: void glTexCoord1d ( GLdouble s ) ;
FUNCTION: void glTexCoord1f ( GLfloat s ) ;
FUNCTION: void glTexCoord1i ( GLint s ) ;
FUNCTION: void glTexCoord1s ( GLshort s ) ;

FUNCTION: void glTexCoord2d ( GLdouble s, GLdouble t ) ;
FUNCTION: void glTexCoord2f ( GLfloat s, GLfloat t ) ;
FUNCTION: void glTexCoord2i ( GLint s, GLint t ) ;
FUNCTION: void glTexCoord2s ( GLshort s, GLshort t ) ;

FUNCTION: void glTexCoord3d ( GLdouble s, GLdouble t, GLdouble r ) ;
FUNCTION: void glTexCoord3f ( GLfloat s, GLfloat t, GLfloat r ) ;
FUNCTION: void glTexCoord3i ( GLint s, GLint t, GLint r ) ;
FUNCTION: void glTexCoord3s ( GLshort s, GLshort t, GLshort r ) ;

FUNCTION: void glTexCoord4d ( GLdouble s, GLdouble t, GLdouble r, GLdouble q ) ;
FUNCTION: void glTexCoord4f ( GLfloat s, GLfloat t, GLfloat r, GLfloat q ) ;
FUNCTION: void glTexCoord4i ( GLint s, GLint t, GLint r, GLint q ) ;
FUNCTION: void glTexCoord4s ( GLshort s, GLshort t, GLshort r, GLshort q ) ;

FUNCTION: void glTexCoord1dv ( GLdouble* v ) ;
FUNCTION: void glTexCoord1fv ( GLfloat* v ) ;
FUNCTION: void glTexCoord1iv ( GLint* v ) ;
FUNCTION: void glTexCoord1sv ( GLshort* v ) ;

FUNCTION: void glTexCoord2dv ( GLdouble* v ) ;
FUNCTION: void glTexCoord2fv ( GLfloat* v ) ;
FUNCTION: void glTexCoord2iv ( GLint* v ) ;
FUNCTION: void glTexCoord2sv ( GLshort* v ) ;

FUNCTION: void glTexCoord3dv ( GLdouble* v ) ;
FUNCTION: void glTexCoord3fv ( GLfloat* v ) ;
FUNCTION: void glTexCoord3iv ( GLint* v ) ;
FUNCTION: void glTexCoord3sv ( GLshort* v ) ;

FUNCTION: void glTexCoord4dv ( GLdouble* v ) ;
FUNCTION: void glTexCoord4fv ( GLfloat* v ) ;
FUNCTION: void glTexCoord4iv ( GLint* v ) ;
FUNCTION: void glTexCoord4sv ( GLshort* v ) ;

FUNCTION: void glRasterPos2d ( GLdouble x, GLdouble y ) ;
FUNCTION: void glRasterPos2f ( GLfloat x, GLfloat y ) ;
FUNCTION: void glRasterPos2i ( GLint x, GLint y ) ;
FUNCTION: void glRasterPos2s ( GLshort x, GLshort y ) ;

FUNCTION: void glRasterPos3d ( GLdouble x, GLdouble y, GLdouble z ) ;
FUNCTION: void glRasterPos3f ( GLfloat x, GLfloat y, GLfloat z ) ;
FUNCTION: void glRasterPos3i ( GLint x, GLint y, GLint z ) ;
FUNCTION: void glRasterPos3s ( GLshort x, GLshort y, GLshort z ) ;

FUNCTION: void glRasterPos4d ( GLdouble x, GLdouble y, GLdouble z, GLdouble w ) ;
FUNCTION: void glRasterPos4f ( GLfloat x, GLfloat y, GLfloat z, GLfloat w ) ;
FUNCTION: void glRasterPos4i ( GLint x, GLint y, GLint z, GLint w ) ;
FUNCTION: void glRasterPos4s ( GLshort x, GLshort y, GLshort z, GLshort w ) ;

FUNCTION: void glRasterPos2dv ( GLdouble* v ) ;
FUNCTION: void glRasterPos2fv ( GLfloat* v ) ;
FUNCTION: void glRasterPos2iv ( GLint* v ) ;
FUNCTION: void glRasterPos2sv ( GLshort* v ) ;

FUNCTION: void glRasterPos3dv ( GLdouble* v ) ;
FUNCTION: void glRasterPos3fv ( GLfloat* v ) ;
FUNCTION: void glRasterPos3iv ( GLint* v ) ;
FUNCTION: void glRasterPos3sv ( GLshort* v ) ;

FUNCTION: void glRasterPos4dv ( GLdouble* v ) ;
FUNCTION: void glRasterPos4fv ( GLfloat* v ) ;
FUNCTION: void glRasterPos4iv ( GLint* v ) ;
FUNCTION: void glRasterPos4sv ( GLshort* v ) ;


FUNCTION: void glRectd ( GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2 ) ;
FUNCTION: void glRectf ( GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2 ) ;
FUNCTION: void glRecti ( GLint x1, GLint y1, GLint x2, GLint y2 ) ;
FUNCTION: void glRects ( GLshort x1, GLshort y1, GLshort x2, GLshort y2 ) ;

FUNCTION: void glRectdv ( GLdouble* v1, GLdouble* v2 ) ;
FUNCTION: void glRectfv ( GLfloat* v1, GLfloat* v2 ) ;
FUNCTION: void glRectiv ( GLint* v1, GLint* v2 ) ;
FUNCTION: void glRectsv ( GLshort* v1, GLshort* v2 ) ;


! Vertex Arrays (1.1)

FUNCTION: void glVertexPointer ( GLint size, GLenum type, GLsizei stride, GLvoid* ptr ) ;
FUNCTION: void glNormalPointer ( GLenum type, GLsizei stride, GLvoid* ptr ) ;
FUNCTION: void glColorPointer ( GLint size, GLenum type, GLsizei stride, GLvoid* ptr ) ;
FUNCTION: void glIndexPointer ( GLenum type, GLsizei stride, GLvoid* ptr ) ;
FUNCTION: void glTexCoordPointer ( GLint size, GLenum type, GLsizei stride, GLvoid* ptr ) ;
FUNCTION: void glEdgeFlagPointer ( GLsizei stride, GLvoid* ptr ) ;

! [09:39] (slava) NULL <void*>
! [09:39] (slava) then keep that object
! [09:39] (slava) when you want to get the value stored there, *void*
! [09:39] (slava) which returns an alien
FUNCTION: void glGetPointerv ( GLenum pname, GLvoid** params ) ;

FUNCTION: void glArrayElement ( GLint i ) ;
FUNCTION: void glDrawArrays ( GLenum mode, GLint first, GLsizei count ) ;
FUNCTION: void glDrawElements ( GLenum mode, GLsizei count, GLenum type, GLvoid* indices ) ;
FUNCTION: void glInterleavedArrays ( GLenum format, GLsizei stride, GLvoid* pointer ) ;

! Lighting

FUNCTION: void glShadeModel ( GLenum mode ) ;

FUNCTION: void glLightf ( GLenum light, GLenum pname, GLfloat param ) ;
FUNCTION: void glLighti ( GLenum light, GLenum pname, GLint param ) ;
FUNCTION: void glLightfv ( GLenum light, GLenum pname, GLfloat* params ) ;
FUNCTION: void glLightiv ( GLenum light, GLenum pname, GLint* params ) ;
FUNCTION: void glGetLightfv ( GLenum light, GLenum pname, GLfloat* params ) ;
FUNCTION: void glGetLightiv ( GLenum light, GLenum pname, GLint* params ) ;

FUNCTION: void glLightModelf ( GLenum pname, GLfloat param ) ;
FUNCTION: void glLightModeli ( GLenum pname, GLint param ) ;
FUNCTION: void glLightModelfv ( GLenum pname, GLfloat* params ) ;
FUNCTION: void glLightModeliv ( GLenum pname, GLint* params ) ;

FUNCTION: void glMaterialf ( GLenum face, GLenum pname, GLfloat param ) ;
FUNCTION: void glMateriali ( GLenum face, GLenum pname, GLint param ) ;
FUNCTION: void glMaterialfv ( GLenum face, GLenum pname, GLfloat* params ) ;
FUNCTION: void glMaterialiv ( GLenum face, GLenum pname, GLint* params ) ;

FUNCTION: void glGetMaterialfv ( GLenum face, GLenum pname, GLfloat* params ) ;
FUNCTION: void glGetMaterialiv ( GLenum face, GLenum pname, GLint* params ) ;

FUNCTION: void glColorMaterial ( GLenum face, GLenum mode ) ;


! Raster functions

FUNCTION: void glPixelZoom ( GLfloat xfactor, GLfloat yfactor ) ;

FUNCTION: void glPixelStoref ( GLenum pname, GLfloat param ) ;
FUNCTION: void glPixelStorei ( GLenum pname, GLint param ) ;

FUNCTION: void glPixelTransferf ( GLenum pname, GLfloat param ) ;
FUNCTION: void glPixelTransferi ( GLenum pname, GLint param ) ;

FUNCTION: void glPixelMapfv ( GLenum map, GLsizei mapsize, GLfloat* values ) ;
FUNCTION: void glPixelMapuiv ( GLenum map, GLsizei mapsize, GLuint* values ) ;
FUNCTION: void glPixelMapusv ( GLenum map, GLsizei mapsize, GLushort* values ) ;

FUNCTION: void glGetPixelMapfv ( GLenum map, GLfloat* values ) ;
FUNCTION: void glGetPixelMapuiv ( GLenum map, GLuint* values ) ;
FUNCTION: void glGetPixelMapusv ( GLenum map, GLushort* values ) ;

FUNCTION: void glBitmap ( GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, 
                          GLfloat xmove, GLfloat ymove, GLubyte* bitmap ) ;

FUNCTION: void glReadPixels ( GLint x, GLint y, GLsizei width, GLsizei height, 
                              GLenum format, GLenum type, GLvoid* pixels ) ;

FUNCTION: void glDrawPixels ( GLsizei width, GLsizei height, GLenum format, 
                              GLenum type, GLvoid* pixels ) ;
FUNCTION: void glCopyPixels ( GLint x, GLint y, GLsizei width, GLsizei height, GLenum type ) ;

! Stenciling
FUNCTION: void glStencilFunc ( GLenum func, GLint ref, GLuint mask ) ;
FUNCTION: void glStencilMask ( GLuint mask ) ;
FUNCTION: void glStencilOp ( GLenum fail, GLenum zfail, GLenum zpass ) ;
FUNCTION: void glClearStencil ( GLint s ) ;


! Texture mapping

FUNCTION: void glTexGend ( GLenum coord, GLenum pname, GLdouble param ) ;
FUNCTION: void glTexGenf ( GLenum coord, GLenum pname, GLfloat param ) ;
FUNCTION: void glTexGeni ( GLenum coord, GLenum pname, GLint param ) ;

FUNCTION: void glTexGendv ( GLenum coord, GLenum pname, GLdouble* params ) ;
FUNCTION: void glTexGenfv ( GLenum coord, GLenum pname, GLfloat* params ) ;
FUNCTION: void glTexGeniv ( GLenum coord, GLenum pname, GLint* params ) ;

FUNCTION: void glGetTexGendv ( GLenum coord, GLenum pname, GLdouble* params ) ;
FUNCTION: void glGetTexGenfv ( GLenum coord, GLenum pname, GLfloat* params ) ;
FUNCTION: void glGetTexGeniv ( GLenum coord, GLenum pname, GLint* params ) ;

FUNCTION: void glTexEnvf ( GLenum target, GLenum pname, GLfloat param ) ;
FUNCTION: void glTexEnvi ( GLenum target, GLenum pname, GLint param ) ;
FUNCTION: void glTexEnvfv ( GLenum target, GLenum pname, GLfloat* params ) ;
FUNCTION: void glTexEnviv ( GLenum target, GLenum pname, GLint* params ) ;

FUNCTION: void glGetTexEnvfv ( GLenum target, GLenum pname, GLfloat* params ) ;
FUNCTION: void glGetTexEnviv ( GLenum target, GLenum pname, GLint* params ) ;

FUNCTION: void glTexParameterf ( GLenum target, GLenum pname, GLfloat param ) ;
FUNCTION: void glTexParameteri ( GLenum target, GLenum pname, GLint param ) ;

FUNCTION: void glTexParameterfv ( GLenum target, GLenum pname, GLfloat* params ) ;
FUNCTION: void glTexParameteriv ( GLenum target, GLenum pname, GLint* params ) ;

FUNCTION: void glGetTexParameterfv ( GLenum target, GLenum pname, GLfloat* params ) ;
FUNCTION: void glGetTexParameteriv ( GLenum target, GLenum pname, GLint* params ) ;

FUNCTION: void glGetTexLevelParameterfv ( GLenum target, GLint level, 
                                          GLenum pname, GLfloat* params ) ;
FUNCTION: void glGetTexLevelParameteriv ( GLenum target, GLint level,
                                          GLenum pname, GLint* params ) ;

FUNCTION: void glTexImage1D ( GLenum target, GLint level, GLint internalFormat, GLsizei width,
                              GLint border, GLenum format, GLenum type, GLvoid* pixels ) ;

FUNCTION: void glTexImage2D ( GLenum target, GLint level, GLint internalFormat, 
                              GLsizei width, GLsizei height, GLint border, 
			      GLenum format, GLenum type, GLvoid* pixels ) ;

FUNCTION: void glGetTexImage ( GLenum target, GLint level, GLenum format, 
                               GLenum type, GLvoid* pixels ) ;


! 1.1 functions

FUNCTION: void glGenTextures ( GLsizei n, GLuint* textures ) ;

FUNCTION: void glDeleteTextures ( GLsizei n, GLuint* textures ) ;

FUNCTION: void glBindTexture ( GLenum target, GLuint texture ) ;

FUNCTION: void glPrioritizeTextures ( GLsizei n, GLuint* textures, GLclampf* priorities ) ;

FUNCTION: GLboolean glAreTexturesResident ( GLsizei n, GLuint* textures, GLboolean* residences ) ;

FUNCTION: GLboolean glIsTexture ( GLuint texture ) ;

FUNCTION: void glTexSubImage1D ( GLenum target, GLint level, GLint xoffset, GLsizei width,
                                 GLenum format, GLenum type, GLvoid* pixels ) ;

FUNCTION: void glTexSubImage2D ( GLenum target, GLint level, GLint xoffset, GLint yoffset,
                                 GLsizei width, GLsizei height, GLenum format, 
				 GLenum type, GLvoid* pixels ) ;

FUNCTION: void glCopyTexImage1D ( GLenum target, GLint level, GLenum internalformat, 
                                  GLint x, GLint y, GLsizei width, GLint border ) ;

FUNCTION: void glCopyTexImage2D ( GLenum target, GLint level, GLenum internalformat, 
                                  GLint x, GLint y,
				  GLsizei width, GLsizei height, GLint border ) ;

FUNCTION: void glCopyTexSubImage1D ( GLenum target, GLint level, GLint xoffset, 
                                     GLint x, GLint y, GLsizei width ) ;

FUNCTION: void glCopyTexSubImage2D ( GLenum target, GLint level, GLint xoffset, GLint yoffset,
                                     GLint x, GLint y, GLsizei width, GLsizei height ) ;


! Evaluators

FUNCTION: void glMap1d ( GLenum target, GLdouble u1, GLdouble u2,
                         GLint stride, GLint order, GLdouble* points ) ;
FUNCTION: void glMap1f ( GLenum target, GLfloat u1, GLfloat u2,
                         GLint stride, GLint order, GLfloat* points ) ;

FUNCTION: void glMap2d ( GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder,
                         GLdouble v1, GLdouble v2, GLint vstride, GLint vorder,
			 GLdouble* points ) ;
FUNCTION: void glMap2f ( GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder,
                         GLfloat v1, GLfloat v2, GLint vstride, GLint vorder,
			 GLfloat* points ) ;

FUNCTION: void glGetMapdv ( GLenum target, GLenum query, GLdouble* v ) ;
FUNCTION: void glGetMapfv ( GLenum target, GLenum query, GLfloat* v ) ;
FUNCTION: void glGetMapiv ( GLenum target, GLenum query, GLint* v ) ;

FUNCTION: void glEvalCoord1d ( GLdouble u ) ;
FUNCTION: void glEvalCoord1f ( GLfloat u ) ;

FUNCTION: void glEvalCoord1dv ( GLdouble* u ) ;
FUNCTION: void glEvalCoord1fv ( GLfloat* u ) ;

FUNCTION: void glEvalCoord2d ( GLdouble u, GLdouble v ) ;
FUNCTION: void glEvalCoord2f ( GLfloat u, GLfloat v ) ;

FUNCTION: void glEvalCoord2dv ( GLdouble* u ) ;
FUNCTION: void glEvalCoord2fv ( GLfloat* u ) ;

FUNCTION: void glMapGrid1d ( GLint un, GLdouble u1, GLdouble u2 ) ;
FUNCTION: void glMapGrid1f ( GLint un, GLfloat u1, GLfloat u2 ) ;

FUNCTION: void glMapGrid2d ( GLint un, GLdouble u1, GLdouble u2,
                             GLint vn, GLdouble v1, GLdouble v2 ) ;
FUNCTION: void glMapGrid2f ( GLint un, GLfloat u1, GLfloat u2,
                             GLint vn, GLfloat v1, GLfloat v2 ) ;

FUNCTION: void glEvalPoint1 ( GLint i ) ;
FUNCTION: void glEvalPoint2 ( GLint i, GLint j ) ;

FUNCTION: void glEvalMesh1 ( GLenum mode, GLint i1, GLint i2 ) ;
FUNCTION: void glEvalMesh2 ( GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2 ) ;


! Fog

FUNCTION: void glFogf ( GLenum pname, GLfloat param ) ;
FUNCTION: void glFogi ( GLenum pname, GLint param ) ;
FUNCTION: void glFogfv ( GLenum pname, GLfloat* params ) ;
FUNCTION: void glFogiv ( GLenum pname, GLint* params ) ;


! Selection and Feedback

FUNCTION: void glFeedbackBuffer ( GLsizei size, GLenum type, GLfloat* buffer ) ;

FUNCTION: void glPassThrough ( GLfloat token ) ;
FUNCTION: void glSelectBuffer ( GLsizei size, GLuint* buffer ) ;
FUNCTION: void glInitNames ( ) ;
FUNCTION: void glLoadName ( GLuint name ) ;
FUNCTION: void glPushName ( GLuint name ) ;
FUNCTION: void glPopName ( ) ;


! OpenGL 1.2

: GL_PACK_SKIP_IMAGES               HEX: 806B ; inline
: GL_PACK_IMAGE_HEIGHT              HEX: 806C ; inline
: GL_UNPACK_SKIP_IMAGES             HEX: 806D ; inline
: GL_UNPACK_IMAGE_HEIGHT            HEX: 806E ; inline
: GL_TEXTURE_3D                     HEX: 806F ; inline
: GL_PROXY_TEXTURE_3D               HEX: 8070 ; inline
: GL_TEXTURE_DEPTH                  HEX: 8071 ; inline
: GL_TEXTURE_WRAP_R                 HEX: 8072 ; inline
: GL_MAX_3D_TEXTURE_SIZE            HEX: 8073 ; inline
: GL_BGR                            HEX: 80E0 ; inline
: GL_BGRA                           HEX: 80E1 ; inline
: GL_UNSIGNED_BYTE_3_3_2            HEX: 8032 ; inline
: GL_UNSIGNED_BYTE_2_3_3_REV        HEX: 8362 ; inline
: GL_UNSIGNED_SHORT_5_6_5           HEX: 8363 ; inline
: GL_UNSIGNED_SHORT_5_6_5_REV       HEX: 8364 ; inline
: GL_UNSIGNED_SHORT_4_4_4_4         HEX: 8033 ; inline
: GL_UNSIGNED_SHORT_4_4_4_4_REV     HEX: 8365 ; inline
: GL_UNSIGNED_SHORT_5_5_5_1         HEX: 8034 ; inline
: GL_UNSIGNED_SHORT_1_5_5_5_REV     HEX: 8366 ; inline
: GL_UNSIGNED_INT_8_8_8_8           HEX: 8035 ; inline
: GL_UNSIGNED_INT_8_8_8_8_REV       HEX: 8367 ; inline
: GL_UNSIGNED_INT_10_10_10_2        HEX: 8036 ; inline
: GL_UNSIGNED_INT_2_10_10_10_REV    HEX: 8368 ; inline
: GL_RESCALE_NORMAL                 HEX: 803A ; inline
: GL_LIGHT_MODEL_COLOR_CONTROL      HEX: 81F8 ; inline
: GL_SINGLE_COLOR                   HEX: 81F9 ; inline
: GL_SEPARATE_SPECULAR_COLOR        HEX: 81FA ; inline
: GL_CLAMP_TO_EDGE                  HEX: 812F ; inline
: GL_TEXTURE_MIN_LOD                HEX: 813A ; inline
: GL_TEXTURE_MAX_LOD                HEX: 813B ; inline
: GL_TEXTURE_BASE_LEVEL             HEX: 813C ; inline
: GL_TEXTURE_MAX_LEVEL              HEX: 813D ; inline
: GL_MAX_ELEMENTS_VERTICES          HEX: 80E8 ; inline
: GL_MAX_ELEMENTS_INDICES           HEX: 80E9 ; inline
: GL_ALIASED_POINT_SIZE_RANGE       HEX: 846D ; inline
: GL_ALIASED_LINE_WIDTH_RANGE       HEX: 846E ; inline


FUNCTION: void glDrawRangeElements ( GLenum mode, GLuint start, GLuint end,
                                     GLsizei count, GLenum type, GLvoid* indices ) ;

FUNCTION: void glTexImage3D ( GLenum target, GLint level, GLint internalFormat,
                              GLsizei width, GLsizei height, GLsizei depth, GLint border,
			      GLenum format, GLenum type, GLvoid* pixels ) ;

FUNCTION: void glTexSubImage3D ( GLenum target, GLint level, GLint xoffset, GLint yoffset,
                                 GLint zoffset, GLsizei width, GLsizei height, GLsizei depth,
				 GLenum format, GLenum type, GLvoid* pixels ) ;

FUNCTION: void glCopyTexSubImage3D ( GLenum target, GLint level,
                                     GLint xoffset, GLint yoffset, GLint zoffset,
				     GLint x, GLint y, GLsizei width, GLsizei height ) ;
! windows? [
!     { glDrawRangeElements glTexImage3D glTexSubImage3D glCopyTexSubImage3D } [ forget ] each
! ] unless


! TODO: the rest. looks fiddly

! OpenGL 1.3

: GL_ACTIVE_TEXTURE                 HEX: 84E0 ; inline
: GL_CLIENT_ACTIVE_TEXTURE          HEX: 84E1 ; inline
: GL_MAX_TEXTURE_UNITS              HEX: 84E2 ; inline
: GL_TEXTURE0                       HEX: 84C0 ; inline
: GL_TEXTURE1                       HEX: 84C1 ; inline
: GL_TEXTURE2                       HEX: 84C2 ; inline
: GL_TEXTURE3                       HEX: 84C3 ; inline
: GL_TEXTURE4                       HEX: 84C4 ; inline
: GL_TEXTURE5                       HEX: 84C5 ; inline
: GL_TEXTURE6                       HEX: 84C6 ; inline
: GL_TEXTURE7                       HEX: 84C7 ; inline
: GL_TEXTURE8                       HEX: 84C8 ; inline
: GL_TEXTURE9                       HEX: 84C9 ; inline
: GL_TEXTURE10                      HEX: 84CA ; inline
: GL_TEXTURE11                      HEX: 84CB ; inline
: GL_TEXTURE12                      HEX: 84CC ; inline
: GL_TEXTURE13                      HEX: 84CD ; inline
: GL_TEXTURE14                      HEX: 84CE ; inline
: GL_TEXTURE15                      HEX: 84CF ; inline
: GL_TEXTURE16                      HEX: 84D0 ; inline
: GL_TEXTURE17                      HEX: 84D1 ; inline
: GL_TEXTURE18                      HEX: 84D2 ; inline
: GL_TEXTURE19                      HEX: 84D3 ; inline
: GL_TEXTURE20                      HEX: 84D4 ; inline
: GL_TEXTURE21                      HEX: 84D5 ; inline
: GL_TEXTURE22                      HEX: 84D6 ; inline
: GL_TEXTURE23                      HEX: 84D7 ; inline
: GL_TEXTURE24                      HEX: 84D8 ; inline
: GL_TEXTURE25                      HEX: 84D9 ; inline
: GL_TEXTURE26                      HEX: 84DA ; inline
: GL_TEXTURE27                      HEX: 84DB ; inline
: GL_TEXTURE28                      HEX: 84DC ; inline
: GL_TEXTURE29                      HEX: 84DD ; inline
: GL_TEXTURE30                      HEX: 84DE ; inline
: GL_TEXTURE31                      HEX: 84DF ; inline
: GL_NORMAL_MAP                     HEX: 8511 ; inline
: GL_REFLECTION_MAP                 HEX: 8512 ; inline
: GL_TEXTURE_CUBE_MAP               HEX: 8513 ; inline
: GL_TEXTURE_BINDING_CUBE_MAP       HEX: 8514 ; inline
: GL_TEXTURE_CUBE_MAP_POSITIVE_X    HEX: 8515 ; inline
: GL_TEXTURE_CUBE_MAP_NEGATIVE_X    HEX: 8516 ; inline
: GL_TEXTURE_CUBE_MAP_POSITIVE_Y    HEX: 8517 ; inline
: GL_TEXTURE_CUBE_MAP_NEGATIVE_Y    HEX: 8518 ; inline
: GL_TEXTURE_CUBE_MAP_POSITIVE_Z    HEX: 8519 ; inline
: GL_TEXTURE_CUBE_MAP_NEGATIVE_Z    HEX: 851A ; inline
: GL_PROXY_TEXTURE_CUBE_MAP         HEX: 851B ; inline
: GL_MAX_CUBE_MAP_TEXTURE_SIZE      HEX: 851C ; inline
: GL_COMBINE                        HEX: 8570 ; inline
: GL_COMBINE_RGB                    HEX: 8571 ; inline
: GL_COMBINE_ALPHA                  HEX: 8572 ; inline
: GL_RGB_SCALE                      HEX: 8573 ; inline
: GL_ADD_SIGNED                     HEX: 8574 ; inline
: GL_INTERPOLATE                    HEX: 8575 ; inline
: GL_CONSTANT                       HEX: 8576 ; inline
: GL_PRIMARY_COLOR                  HEX: 8577 ; inline
: GL_PREVIOUS                       HEX: 8578 ; inline
: GL_SOURCE0_RGB                    HEX: 8580 ; inline
: GL_SOURCE1_RGB                    HEX: 8581 ; inline
: GL_SOURCE2_RGB                    HEX: 8582 ; inline
: GL_SOURCE0_ALPHA                  HEX: 8588 ; inline
: GL_SOURCE1_ALPHA                  HEX: 8589 ; inline
: GL_SOURCE2_ALPHA                  HEX: 858A ; inline
: GL_OPERAND0_RGB                   HEX: 8590 ; inline
: GL_OPERAND1_RGB                   HEX: 8591 ; inline
: GL_OPERAND2_RGB                   HEX: 8592 ; inline
: GL_OPERAND0_ALPHA                 HEX: 8598 ; inline
: GL_OPERAND1_ALPHA                 HEX: 8599 ; inline
: GL_OPERAND2_ALPHA                 HEX: 859A ; inline
: GL_SUBTRACT                       HEX: 84E7 ; inline
: GL_TRANSPOSE_MODELVIEW_MATRIX     HEX: 84E3 ; inline
: GL_TRANSPOSE_PROJECTION_MATRIX    HEX: 84E4 ; inline
: GL_TRANSPOSE_TEXTURE_MATRIX       HEX: 84E5 ; inline
: GL_TRANSPOSE_COLOR_MATRIX         HEX: 84E6 ; inline
: GL_COMPRESSED_ALPHA               HEX: 84E9 ; inline
: GL_COMPRESSED_LUMINANCE           HEX: 84EA ; inline
: GL_COMPRESSED_LUMINANCE_ALPHA     HEX: 84EB ; inline
: GL_COMPRESSED_INTENSITY           HEX: 84EC ; inline
: GL_COMPRESSED_RGB                 HEX: 84ED ; inline
: GL_COMPRESSED_RGBA                HEX: 84EE ; inline
: GL_TEXTURE_COMPRESSION_HINT       HEX: 84EF ; inline
: GL_TEXTURE_COMPRESSED_IMAGE_SIZE  HEX: 86A0 ; inline
: GL_TEXTURE_COMPRESSED             HEX: 86A1 ; inline
: GL_NUM_COMPRESSED_TEXTURE_FORMATS HEX: 86A2 ; inline
: GL_COMPRESSED_TEXTURE_FORMATS     HEX: 86A3 ; inline
: GL_DOT3_RGB                       HEX: 86AE ; inline
: GL_DOT3_RGBA                      HEX: 86AF ; inline
: GL_CLAMP_TO_BORDER                HEX: 812D ; inline
: GL_MULTISAMPLE                    HEX: 809D ; inline
: GL_SAMPLE_ALPHA_TO_COVERAGE       HEX: 809E ; inline
: GL_SAMPLE_ALPHA_TO_ONE            HEX: 809F ; inline
: GL_SAMPLE_COVERAGE                HEX: 80A0 ; inline
: GL_SAMPLE_BUFFERS                 HEX: 80A8 ; inline
: GL_SAMPLES                        HEX: 80A9 ; inline
: GL_SAMPLE_COVERAGE_VALUE          HEX: 80AA ; inline
: GL_SAMPLE_COVERAGE_INVERT         HEX: 80AB ; inline
: GL_MULTISAMPLE_BIT                HEX: 20000000 ; inline


! OpenGL 1.4

: GL_POINT_SIZE_MIN                 HEX: 8126 ; inline
: GL_POINT_SIZE_MAX                 HEX: 8127 ; inline
: GL_POINT_FADE_THRESHOLD_SIZE      HEX: 8128 ; inline
: GL_POINT_DISTANCE_ATTENUATION     HEX: 8129 ; inline
: GL_FOG_COORDINATE_SOURCE          HEX: 8450 ; inline
: GL_FOG_COORDINATE                 HEX: 8451 ; inline
: GL_FRAGMENT_DEPTH                 HEX: 8452 ; inline
: GL_CURRENT_FOG_COORDINATE         HEX: 8453 ; inline
: GL_FOG_COORDINATE_ARRAY_TYPE      HEX: 8454 ; inline
: GL_FOG_COORDINATE_ARRAY_STRIDE    HEX: 8455 ; inline
: GL_FOG_COORDINATE_ARRAY_POINTER   HEX: 8456 ; inline
: GL_FOG_COORDINATE_ARRAY           HEX: 8457 ; inline
: GL_COLOR_SUM                      HEX: 8458 ; inline
: GL_CURRENT_SECONDARY_COLOR        HEX: 8459 ; inline
: GL_SECONDARY_COLOR_ARRAY_SIZE     HEX: 845A ; inline
: GL_SECONDARY_COLOR_ARRAY_TYPE     HEX: 845B ; inline
: GL_SECONDARY_COLOR_ARRAY_STRIDE   HEX: 845C ; inline
: GL_SECONDARY_COLOR_ARRAY_POINTER  HEX: 845D ; inline
: GL_SECONDARY_COLOR_ARRAY          HEX: 845E ; inline
: GL_INCR_WRAP                      HEX: 8507 ; inline
: GL_DECR_WRAP                      HEX: 8508 ; inline
: GL_MAX_TEXTURE_LOD_BIAS           HEX: 84FD ; inline
: GL_TEXTURE_FILTER_CONTROL         HEX: 8500 ; inline
: GL_TEXTURE_LOD_BIAS               HEX: 8501 ; inline
: GL_GENERATE_MIPMAP                HEX: 8191 ; inline
: GL_GENERATE_MIPMAP_HINT           HEX: 8192 ; inline
: GL_BLEND_DST_RGB                  HEX: 80C8 ; inline
: GL_BLEND_SRC_RGB                  HEX: 80C9 ; inline
: GL_BLEND_DST_ALPHA                HEX: 80CA ; inline
: GL_BLEND_SRC_ALPHA                HEX: 80CB ; inline
: GL_MIRRORED_REPEAT                HEX: 8370 ; inline
: GL_DEPTH_COMPONENT16              HEX: 81A5 ; inline
: GL_DEPTH_COMPONENT24              HEX: 81A6 ; inline
: GL_DEPTH_COMPONENT32              HEX: 81A7 ; inline
: GL_TEXTURE_DEPTH_SIZE             HEX: 884A ; inline
: GL_DEPTH_TEXTURE_MODE             HEX: 884B ; inline
: GL_TEXTURE_COMPARE_MODE           HEX: 884C ; inline
: GL_TEXTURE_COMPARE_FUNC           HEX: 884D ; inline
: GL_COMPARE_R_TO_TEXTURE           HEX: 884E ; inline


