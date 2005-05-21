! Copyright (C) 2005 Alex Chapman.
! See http://factor.sf.net/license.txt for BSD license.

! This file is based on the gl.h that comes with xorg-x11 6.8.2

IN: gl 
USING: alien gl-internals ;

ALIAS: uint   GLenum
ALIAS: uchar  GLboolean
ALIAS: uint   GLbitfield
ALIAS: char   GLbyte
ALIAS: short  GLshort
ALIAS: int    GLint
ALIAS: int    GLsizei
ALIAS: uchar  GLubyte
ALIAS: ushort GLushort
ALIAS: uint   GLuint
ALIAS: float  GLfloat
ALIAS: float  GLclampf
ALIAS: double GLdouble
ALIAS: double GLclampd
ALIAS: void*  GLvoid*

! Constants

! Boolean values
: GL_FALSE                          HEX: 0 ;
: GL_TRUE                           HEX: 1 ;

! Data types
: GL_BYTE                           HEX: 1400 ;
: GL_UNSIGNED_BYTE                  HEX: 1401 ;
: GL_SHORT                          HEX: 1402 ;
: GL_UNSIGNED_SHORT                 HEX: 1403 ;
: GL_INT                            HEX: 1404 ;
: GL_UNSIGNED_INT                   HEX: 1405 ;
: GL_FLOAT                          HEX: 1406 ;
: GL_2_BYTES                        HEX: 1407 ;
: GL_3_BYTES                        HEX: 1408 ;
: GL_4_BYTES                        HEX: 1409 ;
: GL_DOUBLE                         HEX: 140A ;

! Primitives
: GL_POINTS                         HEX: 0000 ;
: GL_LINES                          HEX: 0001 ;
: GL_LINE_LOOP                      HEX: 0002 ;
: GL_LINE_STRIP                     HEX: 0003 ;
: GL_TRIANGLES                      HEX: 0004 ;
: GL_TRIANGLE_STRIP                 HEX: 0005 ;
: GL_TRIANGLE_FAN                   HEX: 0006 ;
: GL_QUADS                          HEX: 0007 ;
: GL_QUAD_STRIP                     HEX: 0008 ;
: GL_POLYGON                        HEX: 0009 ;

! Vertex arrays
: GL_VERTEX_ARRAY                   HEX: 8074 ;
: GL_NORMAL_ARRAY                   HEX: 8075 ;
: GL_COLOR_ARRAY                    HEX: 8076 ;
: GL_INDEX_ARRAY                    HEX: 8077 ;
: GL_TEXTURE_COORD_ARRAY            HEX: 8078 ;
: GL_EDGE_FLAG_ARRAY                HEX: 8079 ;
: GL_VERTEX_ARRAY_SIZE              HEX: 807A ;
: GL_VERTEX_ARRAY_TYPE              HEX: 807B ;
: GL_VERTEX_ARRAY_STRIDE            HEX: 807C ;
: GL_NORMAL_ARRAY_TYPE              HEX: 807E ;
: GL_NORMAL_ARRAY_STRIDE            HEX: 807F ;
: GL_COLOR_ARRAY_SIZE               HEX: 8081 ;
: GL_COLOR_ARRAY_TYPE               HEX: 8082 ;
: GL_COLOR_ARRAY_STRIDE             HEX: 8083 ;
: GL_INDEX_ARRAY_TYPE               HEX: 8085 ;
: GL_INDEX_ARRAY_STRIDE             HEX: 8086 ;
: GL_TEXTURE_COORD_ARRAY_SIZE       HEX: 8088 ;
: GL_TEXTURE_COORD_ARRAY_TYPE       HEX: 8089 ;
: GL_TEXTURE_COORD_ARRAY_STRIDE     HEX: 808A ;
: GL_EDGE_FLAG_ARRAY_STRIDE         HEX: 808C ;
: GL_VERTEX_ARRAY_POINTER           HEX: 808E ;
: GL_NORMAL_ARRAY_POINTER           HEX: 808F ;
: GL_COLOR_ARRAY_POINTER            HEX: 8090 ;
: GL_INDEX_ARRAY_POINTER            HEX: 8091 ;
: GL_TEXTURE_COORD_ARRAY_POINTER    HEX: 8092 ;
: GL_EDGE_FLAG_ARRAY_POINTER        HEX: 8093 ;
: GL_V2F                            HEX: 2A20 ;
: GL_V3F                            HEX: 2A21 ;
: GL_C4UB_V2F                       HEX: 2A22 ;
: GL_C4UB_V3F                       HEX: 2A23 ;
: GL_C3F_V3F                        HEX: 2A24 ;
: GL_N3F_V3F                        HEX: 2A25 ;
: GL_C4F_N3F_V3F                    HEX: 2A26 ;
: GL_T2F_V3F                        HEX: 2A27 ;
: GL_T4F_V4F                        HEX: 2A28 ;
: GL_T2F_C4UB_V3F                   HEX: 2A29 ;
: GL_T2F_C3F_V3F                    HEX: 2A2A ;
: GL_T2F_N3F_V3F                    HEX: 2A2B ;
: GL_T2F_C4F_N3F_V3F                HEX: 2A2C ;
: GL_T4F_C4F_N3F_V4F                HEX: 2A2D ;

! Matrix mode
: GL_MATRIX_MODE                    HEX: 0BA0 ;
: GL_MODELVIEW                      HEX: 1700 ;
: GL_PROJECTION                     HEX: 1701 ;
: GL_TEXTURE                        HEX: 1702 ;

! Points
: GL_POINT_SMOOTH                   HEX: 0B10 ;
: GL_POINT_SIZE                     HEX: 0B11 ;
: GL_POINT_SIZE_GRANULARITY         HEX: 0B13 ;
: GL_POINT_SIZE_RANGE               HEX: 0B12 ;

! Lines
: GL_LINE_SMOOTH                    HEX: 0B20 ;
: GL_LINE_STIPPLE                   HEX: 0B24 ;
: GL_LINE_STIPPLE_PATTERN           HEX: 0B25 ;
: GL_LINE_STIPPLE_REPEAT            HEX: 0B26 ;
: GL_LINE_WIDTH                     HEX: 0B21 ;
: GL_LINE_WIDTH_GRANULARITY         HEX: 0B23 ;
: GL_LINE_WIDTH_RANGE               HEX: 0B22 ;

! Polygons
: GL_POINT                          HEX: 1B00 ;
: GL_LINE                           HEX: 1B01 ;
: GL_FILL                           HEX: 1B02 ;
: GL_CW                             HEX: 0900 ;
: GL_CCW                            HEX: 0901 ;
: GL_FRONT                          HEX: 0404 ;
: GL_BACK                           HEX: 0405 ;
: GL_POLYGON_MODE                   HEX: 0B40 ;
: GL_POLYGON_SMOOTH                 HEX: 0B41 ;
: GL_POLYGON_STIPPLE                HEX: 0B42 ;
: GL_EDGE_FLAG                      HEX: 0B43 ;
: GL_CULL_FACE                      HEX: 0B44 ;
: GL_CULL_FACE_MODE                 HEX: 0B45 ;
: GL_FRONT_FACE                     HEX: 0B46 ;
: GL_POLYGON_OFFSET_FACTOR          HEX: 8038 ;
: GL_POLYGON_OFFSET_UNITS           HEX: 2A00 ;
: GL_POLYGON_OFFSET_POINT           HEX: 2A01 ;
: GL_POLYGON_OFFSET_LINE            HEX: 2A02 ;
: GL_POLYGON_OFFSET_FILL            HEX: 8037 ;

! Display Lists
: GL_COMPILE                        HEX: 1300 ;
: GL_COMPILE_AND_EXECUTE            HEX: 1301 ;
: GL_LIST_BASE                      HEX: 0B32 ;
: GL_LIST_INDEX                     HEX: 0B33 ;
: GL_LIST_MODE                      HEX: 0B30 ;

! Depth buffer
: GL_NEVER                          HEX: 0200 ;
: GL_LESS                           HEX: 0201 ;
: GL_EQUAL                          HEX: 0202 ;
: GL_LEQUAL                         HEX: 0203 ;
: GL_GREATER                        HEX: 0204 ;
: GL_NOTEQUAL                       HEX: 0205 ;
: GL_GEQUAL                         HEX: 0206 ;
: GL_ALWAYS                         HEX: 0207 ;
: GL_DEPTH_TEST                     HEX: 0B71 ;
: GL_DEPTH_BITS                     HEX: 0D56 ;
: GL_DEPTH_CLEAR_VALUE              HEX: 0B73 ;
: GL_DEPTH_FUNC                     HEX: 0B74 ;
: GL_DEPTH_RANGE                    HEX: 0B70 ;
: GL_DEPTH_WRITEMASK                HEX: 0B72 ;
: GL_DEPTH_COMPONENT                HEX: 1902 ;

! Lighting
: GL_LIGHTING                       HEX: 0B50 ;
: GL_LIGHT0                         HEX: 4000 ;
: GL_LIGHT1                         HEX: 4001 ;
: GL_LIGHT2                         HEX: 4002 ;
: GL_LIGHT3                         HEX: 4003 ;
: GL_LIGHT4                         HEX: 4004 ;
: GL_LIGHT5                         HEX: 4005 ;
: GL_LIGHT6                         HEX: 4006 ;
: GL_LIGHT7                         HEX: 4007 ;
: GL_SPOT_EXPONENT                  HEX: 1205 ;
: GL_SPOT_CUTOFF                    HEX: 1206 ;
: GL_CONSTANT_ATTENUATION           HEX: 1207 ;
: GL_LINEAR_ATTENUATION             HEX: 1208 ;
: GL_QUADRATIC_ATTENUATION          HEX: 1209 ;
: GL_AMBIENT                        HEX: 1200 ;
: GL_DIFFUSE                        HEX: 1201 ;
: GL_SPECULAR                       HEX: 1202 ;
: GL_SHININESS                      HEX: 1601 ;
: GL_EMISSION                       HEX: 1600 ;
: GL_POSITION                       HEX: 1203 ;
: GL_SPOT_DIRECTION                 HEX: 1204 ;
: GL_AMBIENT_AND_DIFFUSE            HEX: 1602 ;
: GL_COLOR_INDEXES                  HEX: 1603 ;
: GL_LIGHT_MODEL_TWO_SIDE           HEX: 0B52 ;
: GL_LIGHT_MODEL_LOCAL_VIEWER       HEX: 0B51 ;
: GL_LIGHT_MODEL_AMBIENT            HEX: 0B53 ;
: GL_FRONT_AND_BACK                 HEX: 0408 ;
: GL_SHADE_MODEL                    HEX: 0B54 ;
: GL_FLAT                           HEX: 1D00 ;
: GL_SMOOTH                         HEX: 1D01 ;
: GL_COLOR_MATERIAL                 HEX: 0B57 ;
: GL_COLOR_MATERIAL_FACE            HEX: 0B55 ;
: GL_COLOR_MATERIAL_PARAMETER       HEX: 0B56 ;
: GL_NORMALIZE                      HEX: 0BA1 ;

! User clipping planes
: GL_CLIP_PLANE0                    HEX: 3000 ;
: GL_CLIP_PLANE1                    HEX: 3001 ;
: GL_CLIP_PLANE2                    HEX: 3002 ;
: GL_CLIP_PLANE3                    HEX: 3003 ;
: GL_CLIP_PLANE4                    HEX: 3004 ;
: GL_CLIP_PLANE5                    HEX: 3005 ;

! Accumulation buffer
: GL_ACCUM_RED_BITS                 HEX: 0D58 ;
: GL_ACCUM_GREEN_BITS               HEX: 0D59 ;
: GL_ACCUM_BLUE_BITS                HEX: 0D5A ;
: GL_ACCUM_ALPHA_BITS               HEX: 0D5B ;
: GL_ACCUM_CLEAR_VALUE              HEX: 0B80 ;
: GL_ACCUM                          HEX: 0100 ;
: GL_ADD                            HEX: 0104 ;
: GL_LOAD                           HEX: 0101 ;
: GL_MULT                           HEX: 0103 ;
: GL_RETURN                         HEX: 0102 ;

! Alpha testing
: GL_ALPHA_TEST                     HEX: 0BC0 ;
: GL_ALPHA_TEST_REF                 HEX: 0BC2 ;
: GL_ALPHA_TEST_FUNC                HEX: 0BC1 ;

! Blending
: GL_BLEND                          HEX: 0BE2 ;
: GL_BLEND_SRC                      HEX: 0BE1 ;
: GL_BLEND_DST                      HEX: 0BE0 ;
: GL_ZERO                           HEX: 0 ;
: GL_ONE                            HEX: 1 ;
: GL_SRC_COLOR                      HEX: 0300 ;
: GL_ONE_MINUS_SRC_COLOR            HEX: 0301 ;
: GL_SRC_ALPHA                      HEX: 0302 ;
: GL_ONE_MINUS_SRC_ALPHA            HEX: 0303 ;
: GL_DST_ALPHA                      HEX: 0304 ;
: GL_ONE_MINUS_DST_ALPHA            HEX: 0305 ;
: GL_DST_COLOR                      HEX: 0306 ;
: GL_ONE_MINUS_DST_COLOR            HEX: 0307 ;
: GL_SRC_ALPHA_SATURATE             HEX: 0308 ;

! Render Mode
: GL_FEEDBACK                       HEX: 1C01 ;
: GL_RENDER                         HEX: 1C00 ;
: GL_SELECT                         HEX: 1C02 ;

! Feedback
: GL_2D                             HEX: 0600 ;
: GL_3D                             HEX: 0601 ;
: GL_3D_COLOR                       HEX: 0602 ;
: GL_3D_COLOR_TEXTURE               HEX: 0603 ;
: GL_4D_COLOR_TEXTURE               HEX: 0604 ;
: GL_POINT_TOKEN                    HEX: 0701 ;
: GL_LINE_TOKEN                     HEX: 0702 ;
: GL_LINE_RESET_TOKEN               HEX: 0707 ;
: GL_POLYGON_TOKEN                  HEX: 0703 ;
: GL_BITMAP_TOKEN                   HEX: 0704 ;
: GL_DRAW_PIXEL_TOKEN               HEX: 0705 ;
: GL_COPY_PIXEL_TOKEN               HEX: 0706 ;
: GL_PASS_THROUGH_TOKEN             HEX: 0700 ;
: GL_FEEDBACK_BUFFER_POINTER        HEX: 0DF0 ;
: GL_FEEDBACK_BUFFER_SIZE           HEX: 0DF1 ;
: GL_FEEDBACK_BUFFER_TYPE           HEX: 0DF2 ;

! Selection
: GL_SELECTION_BUFFER_POINTER       HEX: 0DF3 ;
: GL_SELECTION_BUFFER_SIZE          HEX: 0DF4 ;

! Fog
: GL_FOG                            HEX: 0B60 ;
: GL_FOG_MODE                       HEX: 0B65 ;
: GL_FOG_DENSITY                    HEX: 0B62 ;
: GL_FOG_COLOR                      HEX: 0B66 ;
: GL_FOG_INDEX                      HEX: 0B61 ;
: GL_FOG_START                      HEX: 0B63 ;
: GL_FOG_END                        HEX: 0B64 ;
: GL_LINEAR                         HEX: 2601 ;
: GL_EXP                            HEX: 0800 ;
: GL_EXP2                           HEX: 0801 ;

! Logic Ops
: GL_LOGIC_OP                       HEX: 0BF1 ;
: GL_INDEX_LOGIC_OP                 HEX: 0BF1 ;
: GL_COLOR_LOGIC_OP                 HEX: 0BF2 ;
: GL_LOGIC_OP_MODE                  HEX: 0BF0 ;
: GL_CLEAR                          HEX: 1500 ;
: GL_SET                            HEX: 150F ;
: GL_COPY                           HEX: 1503 ;
: GL_COPY_INVERTED                  HEX: 150C ;
: GL_NOOP                           HEX: 1505 ;
: GL_INVERT                         HEX: 150A ;
: GL_AND                            HEX: 1501 ;
: GL_NAND                           HEX: 150E ;
: GL_OR                             HEX: 1507 ;
: GL_NOR                            HEX: 1508 ;
: GL_XOR                            HEX: 1506 ;
: GL_EQUIV                          HEX: 1509 ;
: GL_AND_REVERSE                    HEX: 1502 ;
: GL_AND_INVERTED                   HEX: 1504 ;
: GL_OR_REVERSE                     HEX: 150B ;
: GL_OR_INVERTED                    HEX: 150D ;

! Stencil
: GL_STENCIL_TEST                   HEX: 0B90 ;
: GL_STENCIL_WRITEMASK              HEX: 0B98 ;
: GL_STENCIL_BITS                   HEX: 0D57 ;
: GL_STENCIL_FUNC                   HEX: 0B92 ;
: GL_STENCIL_VALUE_MASK             HEX: 0B93 ;
: GL_STENCIL_REF                    HEX: 0B97 ;
: GL_STENCIL_FAIL                   HEX: 0B94 ;
: GL_STENCIL_PASS_DEPTH_PASS        HEX: 0B96 ;
: GL_STENCIL_PASS_DEPTH_FAIL        HEX: 0B95 ;
: GL_STENCIL_CLEAR_VALUE            HEX: 0B91 ;
: GL_STENCIL_INDEX                  HEX: 1901 ;
: GL_KEEP                           HEX: 1E00 ;
: GL_REPLACE                        HEX: 1E01 ;
: GL_INCR                           HEX: 1E02 ;
: GL_DECR                           HEX: 1E03 ;

! Buffers, Pixel Drawing/Reading
: GL_NONE                           HEX:    0 ;
: GL_LEFT                           HEX: 0406 ;
: GL_RIGHT                          HEX: 0407 ;
! defined elsewhere
! GL_FRONT                          HEX: 0404
! GL_BACK                           HEX: 0405
! GL_FRONT_AND_BACK                 HEX: 0408
: GL_FRONT_LEFT                     HEX: 0400 ;
: GL_FRONT_RIGHT                    HEX: 0401 ;
: GL_BACK_LEFT                      HEX: 0402 ;
: GL_BACK_RIGHT                     HEX: 0403 ;
: GL_AUX0                           HEX: 0409 ;
: GL_AUX1                           HEX: 040A ;
: GL_AUX2                           HEX: 040B ;
: GL_AUX3                           HEX: 040C ;
: GL_COLOR_INDEX                    HEX: 1900 ;
: GL_RED                            HEX: 1903 ;
: GL_GREEN                          HEX: 1904 ;
: GL_BLUE                           HEX: 1905 ;
: GL_ALPHA                          HEX: 1906 ;
: GL_LUMINANCE                      HEX: 1909 ;
: GL_LUMINANCE_ALPHA                HEX: 190A ;
: GL_ALPHA_BITS                     HEX: 0D55 ;
: GL_RED_BITS                       HEX: 0D52 ;
: GL_GREEN_BITS                     HEX: 0D53 ;
: GL_BLUE_BITS                      HEX: 0D54 ;
: GL_INDEX_BITS                     HEX: 0D51 ;
: GL_SUBPIXEL_BITS                  HEX: 0D50 ;
: GL_AUX_BUFFERS                    HEX: 0C00 ;
: GL_READ_BUFFER                    HEX: 0C02 ;
: GL_DRAW_BUFFER                    HEX: 0C01 ;
: GL_DOUBLEBUFFER                   HEX: 0C32 ;
: GL_STEREO                         HEX: 0C33 ;
: GL_BITMAP                         HEX: 1A00 ;
: GL_COLOR                          HEX: 1800 ;
: GL_DEPTH                          HEX: 1801 ;
: GL_STENCIL                        HEX: 1802 ;
: GL_DITHER                         HEX: 0BD0 ;
: GL_RGB                            HEX: 1907 ;
: GL_RGBA                           HEX: 1908 ;

! Implementation limits
: GL_MAX_LIST_NESTING               HEX: 0B31 ;
: GL_MAX_ATTRIB_STACK_DEPTH         HEX: 0D35 ;
: GL_MAX_MODELVIEW_STACK_DEPTH      HEX: 0D36 ;
: GL_MAX_NAME_STACK_DEPTH           HEX: 0D37 ;
: GL_MAX_PROJECTION_STACK_DEPTH     HEX: 0D38 ;
: GL_MAX_TEXTURE_STACK_DEPTH        HEX: 0D39 ;
: GL_MAX_EVAL_ORDER                 HEX: 0D30 ;
: GL_MAX_LIGHTS                     HEX: 0D31 ;
: GL_MAX_CLIP_PLANES                HEX: 0D32 ;
: GL_MAX_TEXTURE_SIZE               HEX: 0D33 ;
: GL_MAX_PIXEL_MAP_TABLE            HEX: 0D34 ;
: GL_MAX_VIEWPORT_DIMS              HEX: 0D3A ;
: GL_MAX_CLIENT_ATTRIB_STACK_DEPTH  HEX: 0D3B ;

! Gets
: GL_ATTRIB_STACK_DEPTH             HEX: 0BB0 ;
: GL_CLIENT_ATTRIB_STACK_DEPTH      HEX: 0BB1 ;
: GL_COLOR_CLEAR_VALUE              HEX: 0C22 ;
: GL_COLOR_WRITEMASK                HEX: 0C23 ;
: GL_CURRENT_INDEX                  HEX: 0B01 ;
: GL_CURRENT_COLOR                  HEX: 0B00 ;
: GL_CURRENT_NORMAL                 HEX: 0B02 ;
: GL_CURRENT_RASTER_COLOR           HEX: 0B04 ;
: GL_CURRENT_RASTER_DISTANCE        HEX: 0B09 ;
: GL_CURRENT_RASTER_INDEX           HEX: 0B05 ;
: GL_CURRENT_RASTER_POSITION        HEX: 0B07 ;
: GL_CURRENT_RASTER_TEXTURE_COORDS  HEX: 0B06 ;
: GL_CURRENT_RASTER_POSITION_VALID  HEX: 0B08 ;
: GL_CURRENT_TEXTURE_COORDS         HEX: 0B03 ;
: GL_INDEX_CLEAR_VALUE              HEX: 0C20 ;
: GL_INDEX_MODE                     HEX: 0C30 ;
: GL_INDEX_WRITEMASK                HEX: 0C21 ;
: GL_MODELVIEW_MATRIX               HEX: 0BA6 ;
: GL_MODELVIEW_STACK_DEPTH          HEX: 0BA3 ;
: GL_NAME_STACK_DEPTH               HEX: 0D70 ;
: GL_PROJECTION_MATRIX              HEX: 0BA7 ;
: GL_PROJECTION_STACK_DEPTH         HEX: 0BA4 ;
: GL_RENDER_MODE                    HEX: 0C40 ;
: GL_RGBA_MODE                      HEX: 0C31 ;
: GL_TEXTURE_MATRIX                 HEX: 0BA8 ;
: GL_TEXTURE_STACK_DEPTH            HEX: 0BA5 ;
: GL_VIEWPORT                       HEX: 0BA2 ;

! Evaluators
: GL_AUTO_NORMAL                    HEX: 0D80 ;
: GL_MAP1_COLOR_4                   HEX: 0D90 ;
: GL_MAP1_INDEX                     HEX: 0D91 ;
: GL_MAP1_NORMAL                    HEX: 0D92 ;
: GL_MAP1_TEXTURE_COORD_1           HEX: 0D93 ;
: GL_MAP1_TEXTURE_COORD_2           HEX: 0D94 ;
: GL_MAP1_TEXTURE_COORD_3           HEX: 0D95 ;
: GL_MAP1_TEXTURE_COORD_4           HEX: 0D96 ;
: GL_MAP1_VERTEX_3                  HEX: 0D97 ;
: GL_MAP1_VERTEX_4                  HEX: 0D98 ;
: GL_MAP2_COLOR_4                   HEX: 0DB0 ;
: GL_MAP2_INDEX                     HEX: 0DB1 ;
: GL_MAP2_NORMAL                    HEX: 0DB2 ;
: GL_MAP2_TEXTURE_COORD_1           HEX: 0DB3 ;
: GL_MAP2_TEXTURE_COORD_2           HEX: 0DB4 ;
: GL_MAP2_TEXTURE_COORD_3           HEX: 0DB5 ;
: GL_MAP2_TEXTURE_COORD_4           HEX: 0DB6 ;
: GL_MAP2_VERTEX_3                  HEX: 0DB7 ;
: GL_MAP2_VERTEX_4                  HEX: 0DB8 ;
: GL_MAP1_GRID_DOMAIN               HEX: 0DD0 ;
: GL_MAP1_GRID_SEGMENTS             HEX: 0DD1 ;
: GL_MAP2_GRID_DOMAIN               HEX: 0DD2 ;
: GL_MAP2_GRID_SEGMENTS             HEX: 0DD3 ;
: GL_COEFF                          HEX: 0A00 ;
: GL_DOMAIN                         HEX: 0A02 ;
: GL_ORDER                          HEX: 0A01 ;

! Hints
: GL_FOG_HINT                       HEX: 0C54 ;
: GL_LINE_SMOOTH_HINT               HEX: 0C52 ;
: GL_PERSPECTIVE_CORRECTION_HINT    HEX: 0C50 ;
: GL_POINT_SMOOTH_HINT              HEX: 0C51 ;
: GL_POLYGON_SMOOTH_HINT            HEX: 0C53 ;
: GL_DONT_CARE                      HEX: 1100 ;
: GL_FASTEST                        HEX: 1101 ;
: GL_NICEST                         HEX: 1102 ;

! Scissor box
: GL_SCISSOR_TEST                   HEX: 0C11 ;
: GL_SCISSOR_BOX                    HEX: 0C10 ;

! Pixel Mode / Transfer
: GL_MAP_COLOR                      HEX: 0D10 ;
: GL_MAP_STENCIL                    HEX: 0D11 ;
: GL_INDEX_SHIFT                    HEX: 0D12 ;
: GL_INDEX_OFFSET                   HEX: 0D13 ;
: GL_RED_SCALE                      HEX: 0D14 ;
: GL_RED_BIAS                       HEX: 0D15 ;
: GL_GREEN_SCALE                    HEX: 0D18 ;
: GL_GREEN_BIAS                     HEX: 0D19 ;
: GL_BLUE_SCALE                     HEX: 0D1A ;
: GL_BLUE_BIAS                      HEX: 0D1B ;
: GL_ALPHA_SCALE                    HEX: 0D1C ;
: GL_ALPHA_BIAS                     HEX: 0D1D ;
: GL_DEPTH_SCALE                    HEX: 0D1E ;
: GL_DEPTH_BIAS                     HEX: 0D1F ;
: GL_PIXEL_MAP_S_TO_S_SIZE          HEX: 0CB1 ;
: GL_PIXEL_MAP_I_TO_I_SIZE          HEX: 0CB0 ;
: GL_PIXEL_MAP_I_TO_R_SIZE          HEX: 0CB2 ;
: GL_PIXEL_MAP_I_TO_G_SIZE          HEX: 0CB3 ;
: GL_PIXEL_MAP_I_TO_B_SIZE          HEX: 0CB4 ;
: GL_PIXEL_MAP_I_TO_A_SIZE          HEX: 0CB5 ;
: GL_PIXEL_MAP_R_TO_R_SIZE          HEX: 0CB6 ;
: GL_PIXEL_MAP_G_TO_G_SIZE          HEX: 0CB7 ;
: GL_PIXEL_MAP_B_TO_B_SIZE          HEX: 0CB8 ;
: GL_PIXEL_MAP_A_TO_A_SIZE          HEX: 0CB9 ;
: GL_PIXEL_MAP_S_TO_S               HEX: 0C71 ;
: GL_PIXEL_MAP_I_TO_I               HEX: 0C70 ;
: GL_PIXEL_MAP_I_TO_R               HEX: 0C72 ;
: GL_PIXEL_MAP_I_TO_G               HEX: 0C73 ;
: GL_PIXEL_MAP_I_TO_B               HEX: 0C74 ;
: GL_PIXEL_MAP_I_TO_A               HEX: 0C75 ;
: GL_PIXEL_MAP_R_TO_R               HEX: 0C76 ;
: GL_PIXEL_MAP_G_TO_G               HEX: 0C77 ;
: GL_PIXEL_MAP_B_TO_B               HEX: 0C78 ;
: GL_PIXEL_MAP_A_TO_A               HEX: 0C79 ;
: GL_PACK_ALIGNMENT                 HEX: 0D05 ;
: GL_PACK_LSB_FIRST                 HEX: 0D01 ;
: GL_PACK_ROW_LENGTH                HEX: 0D02 ;
: GL_PACK_SKIP_PIXELS               HEX: 0D04 ;
: GL_PACK_SKIP_ROWS                 HEX: 0D03 ;
: GL_PACK_SWAP_BYTES                HEX: 0D00 ;
: GL_UNPACK_ALIGNMENT               HEX: 0CF5 ;
: GL_UNPACK_LSB_FIRST               HEX: 0CF1 ;
: GL_UNPACK_ROW_LENGTH              HEX: 0CF2 ;
: GL_UNPACK_SKIP_PIXELS             HEX: 0CF4 ;
: GL_UNPACK_SKIP_ROWS               HEX: 0CF3 ;
: GL_UNPACK_SWAP_BYTES              HEX: 0CF0 ;
: GL_ZOOM_X                         HEX: 0D16 ;
: GL_ZOOM_Y                         HEX: 0D17 ;

! Texture mapping
: GL_TEXTURE_ENV                    HEX: 2300 ;
: GL_TEXTURE_ENV_MODE               HEX: 2200 ;
: GL_TEXTURE_1D                     HEX: 0DE0 ;
: GL_TEXTURE_2D                     HEX: 0DE1 ;
: GL_TEXTURE_WRAP_S                 HEX: 2802 ;
: GL_TEXTURE_WRAP_T                 HEX: 2803 ;
: GL_TEXTURE_MAG_FILTER             HEX: 2800 ;
: GL_TEXTURE_MIN_FILTER             HEX: 2801 ;
: GL_TEXTURE_ENV_COLOR              HEX: 2201 ;
: GL_TEXTURE_GEN_S                  HEX: 0C60 ;
: GL_TEXTURE_GEN_T                  HEX: 0C61 ;
: GL_TEXTURE_GEN_MODE               HEX: 2500 ;
: GL_TEXTURE_BORDER_COLOR           HEX: 1004 ;
: GL_TEXTURE_WIDTH                  HEX: 1000 ;
: GL_TEXTURE_HEIGHT                 HEX: 1001 ;
: GL_TEXTURE_BORDER                 HEX: 1005 ;
: GL_TEXTURE_COMPONENTS             HEX: 1003 ;
: GL_TEXTURE_RED_SIZE               HEX: 805C ;
: GL_TEXTURE_GREEN_SIZE             HEX: 805D ;
: GL_TEXTURE_BLUE_SIZE              HEX: 805E ;
: GL_TEXTURE_ALPHA_SIZE             HEX: 805F ;
: GL_TEXTURE_LUMINANCE_SIZE         HEX: 8060 ;
: GL_TEXTURE_INTENSITY_SIZE         HEX: 8061 ;
: GL_NEAREST_MIPMAP_NEAREST         HEX: 2700 ;
: GL_NEAREST_MIPMAP_LINEAR          HEX: 2702 ;
: GL_LINEAR_MIPMAP_NEAREST          HEX: 2701 ;
: GL_LINEAR_MIPMAP_LINEAR           HEX: 2703 ;
: GL_OBJECT_LINEAR                  HEX: 2401 ;
: GL_OBJECT_PLANE                   HEX: 2501 ;
: GL_EYE_LINEAR                     HEX: 2400 ;
: GL_EYE_PLANE                      HEX: 2502 ;
: GL_SPHERE_MAP                     HEX: 2402 ;
: GL_DECAL                          HEX: 2101 ;
: GL_MODULATE                       HEX: 2100 ;
: GL_NEAREST                        HEX: 2600 ;
: GL_REPEAT                         HEX: 2901 ;
: GL_CLAMP                          HEX: 2900 ;
: GL_S                              HEX: 2000 ;
: GL_T                              HEX: 2001 ;
: GL_R                              HEX: 2002 ;
: GL_Q                              HEX: 2003 ;
: GL_TEXTURE_GEN_R                  HEX: 0C62 ;
: GL_TEXTURE_GEN_Q                  HEX: 0C63 ;

! Utility
: GL_VENDOR                         HEX: 1F00 ;
: GL_RENDERER                       HEX: 1F01 ;
: GL_VERSION                        HEX: 1F02 ;
: GL_EXTENSIONS                     HEX: 1F03 ;

! Errors
: GL_NO_ERROR                       HEX:    0 ;
: GL_INVALID_VALUE                  HEX: 0501 ;
: GL_INVALID_ENUM                   HEX: 0500 ;
: GL_INVALID_OPERATION              HEX: 0502 ;
: GL_STACK_OVERFLOW                 HEX: 0503 ;
: GL_STACK_UNDERFLOW                HEX: 0504 ;
: GL_OUT_OF_MEMORY                  HEX: 0505 ;

! glPush/PopAttrib bits
: GL_CURRENT_BIT                    HEX: 00000001 ;
: GL_POINT_BIT                      HEX: 00000002 ;
: GL_LINE_BIT                       HEX: 00000004 ;
: GL_POLYGON_BIT                    HEX: 00000008 ;
: GL_POLYGON_STIPPLE_BIT            HEX: 00000010 ;
: GL_PIXEL_MODE_BIT                 HEX: 00000020 ;
: GL_LIGHTING_BIT                   HEX: 00000040 ;
: GL_FOG_BIT                        HEX: 00000080 ;
: GL_DEPTH_BUFFER_BIT               HEX: 00000100 ;
: GL_ACCUM_BUFFER_BIT               HEX: 00000200 ;
: GL_STENCIL_BUFFER_BIT             HEX: 00000400 ;
: GL_VIEWPORT_BIT                   HEX: 00000800 ;
: GL_TRANSFORM_BIT                  HEX: 00001000 ;
: GL_ENABLE_BIT                     HEX: 00002000 ;
: GL_COLOR_BUFFER_BIT               HEX: 00004000 ;
: GL_HINT_BIT                       HEX: 00008000 ;
: GL_EVAL_BIT                       HEX: 00010000 ;
: GL_LIST_BIT                       HEX: 00020000 ;
: GL_TEXTURE_BIT                    HEX: 00040000 ;
: GL_SCISSOR_BIT                    HEX: 00080000 ;
: GL_ALL_ATTRIB_BITS                HEX: 000FFFFF ;

! OpenGL 1.1
: GL_PROXY_TEXTURE_1D               HEX: 8063 ;
: GL_PROXY_TEXTURE_2D               HEX: 8064 ;
: GL_TEXTURE_PRIORITY               HEX: 8066 ;
: GL_TEXTURE_RESIDENT               HEX: 8067 ;
: GL_TEXTURE_BINDING_1D             HEX: 8068 ;
: GL_TEXTURE_BINDING_2D             HEX: 8069 ;
: GL_TEXTURE_INTERNAL_FORMAT        HEX: 1003 ;
: GL_ALPHA4                         HEX: 803B ;
: GL_ALPHA8                         HEX: 803C ;
: GL_ALPHA12                        HEX: 803D ;
: GL_ALPHA16                        HEX: 803E ;
: GL_LUMINANCE4                     HEX: 803F ;
: GL_LUMINANCE8                     HEX: 8040 ;
: GL_LUMINANCE12                    HEX: 8041 ;
: GL_LUMINANCE16                    HEX: 8042 ;
: GL_LUMINANCE4_ALPHA4              HEX: 8043 ;
: GL_LUMINANCE6_ALPHA2              HEX: 8044 ;
: GL_LUMINANCE8_ALPHA8              HEX: 8045 ;
: GL_LUMINANCE12_ALPHA4             HEX: 8046 ;
: GL_LUMINANCE12_ALPHA12            HEX: 8047 ;
: GL_LUMINANCE16_ALPHA16            HEX: 8048 ;
: GL_INTENSITY                      HEX: 8049 ;
: GL_INTENSITY4                     HEX: 804A ;
: GL_INTENSITY8                     HEX: 804B ;
: GL_INTENSITY12                    HEX: 804C ;
: GL_INTENSITY16                    HEX: 804D ;
: GL_R3_G3_B2                       HEX: 2A10 ;
: GL_RGB4                           HEX: 804F ;
: GL_RGB5                           HEX: 8050 ;
: GL_RGB8                           HEX: 8051 ;
: GL_RGB10                          HEX: 8052 ;
: GL_RGB12                          HEX: 8053 ;
: GL_RGB16                          HEX: 8054 ;
: GL_RGBA2                          HEX: 8055 ;
: GL_RGBA4                          HEX: 8056 ;
: GL_RGB5_A1                        HEX: 8057 ;
: GL_RGBA8                          HEX: 8058 ;
: GL_RGB10_A2                       HEX: 8059 ;
: GL_RGBA12                         HEX: 805A ;
: GL_RGBA16                         HEX: 805B ;
: GL_CLIENT_PIXEL_STORE_BIT         HEX: 00000001 ;
: GL_CLIENT_VERTEX_ARRAY_BIT        HEX: 00000002 ;
: GL_ALL_CLIENT_ATTRIB_BITS         HEX: FFFFFFFF ;
: GL_CLIENT_ALL_ATTRIB_BITS         HEX: FFFFFFFF ;

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
! FUNCTION: void glPolygonStipple ( const GLubyte* mask ) ;
! FUNCTION: void glGetPolygonStipple ( GLubyte* mask ) ;
FUNCTION: void glEdgeFlag ( GLboolean flag ) ;
! FUNCTION: void glEdgeFlagv ( const GLboolean* flag ) ;
FUNCTION: void glScissor ( GLint x, GLint y, GLsizei width, GLsizei height ) ;
! FUNCTION: void glClipPlane ( GLenum plane, const GLdouble* equation ) ;
! FUNCTION: void glGetClipPlane ( GLenum plane, GLdouble* equation ) ;
FUNCTION: void glDrawBuffer ( GLenum mode ) ;
FUNCTION: void glReadBuffer ( GLenum mode ) ;
FUNCTION: void glEnable ( GLenum cap ) ;
FUNCTION: void glDisable ( GLenum cap ) ;
FUNCTION: GLboolean glIsEnabled ( GLenum cap ) ;
 
FUNCTION: void glEnableClientState ( GLenum cap ) ;
FUNCTION: void glDisableClientState ( GLenum cap ) ;
! FUNCTION: void glGetBooleanv (- GLenum pname, GLboolean* params -) ;
! FUNCTION: void glGetDoublev (- GLenum pname, GLdouble* params -) ;
! FUNCTION: void glGetFloatv (- GLenum pname, GLfloat* params -) ;
! FUNCTION: void glGetIntegerv (- GLenum pname, GLint* params -) ;

FUNCTION: void glPushAttrib ( GLbitfield mask ) ;
FUNCTION: void glPopAttrib ( ) ;

FUNCTION: void glPushClientAttrib ( GLbitfield mask ) ;
FUNCTION: void glPopClientAttrib ( ) ;

FUNCTION: GLint glRenderMode ( GLenum mode ) ;
FUNCTION: GLenum glGetError ( ) ;
! FUNCTION: const GLubyte* glGetString ( GLenum name ) ;
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
FUNCTION: void glOrtho ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble near_val, GLdouble far_val ) ;
FUNCTION: void glFrustum ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble near_val, GLdouble far_val ) ;
FUNCTION: void glViewport ( GLint x, GLint y, GLsizei width, GLsizei height ) ;
FUNCTION: void glPushMatrix ( ) ;
FUNCTION: void glPopMatrix ( ) ;
FUNCTION: void glLoadIdentity ( ) ;
! FUNCTION: void glLoadMatrixd ( const GLdouble *m ) ;
! FUNCTION: void glLoadMatrixf ( const GLfloat *m ) ;
! FUNCTION: void glMultMatrixd ( const GLdouble *m ) ;
! FUNCTION: void glMultMatrixf ( const GLfloat *m ) ;
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
! FUNCTION: void glCallLists ( GLsizei n, GLenum type, const GLvoid *lists ) ;
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

! FUNCTION: void glVertex2dv ( const GLdouble *v ) ;
! FUNCTION: void glVertex2fv ( const GLfloat *v ) ;
! FUNCTION: void glVertex2iv ( const GLint *v ) ;
! FUNCTION: void glVertex2sv ( const GLshort *v ) ;
! 
! FUNCTION: void glVertex3dv ( const GLdouble *v ) ;
! FUNCTION: void glVertex3fv ( const GLfloat *v ) ;
! FUNCTION: void glVertex3iv ( const GLint *v ) ;
! FUNCTION: void glVertex3sv ( const GLshort *v ) ;
! 
! FUNCTION: void glVertex4dv ( const GLdouble *v ) ;
! FUNCTION: void glVertex4fv ( const GLfloat *v ) ;
! FUNCTION: void glVertex4iv ( const GLint *v ) ;
! FUNCTION: void glVertex4sv ( const GLshort *v ) ;

FUNCTION: void glNormal3b ( GLbyte nx, GLbyte ny, GLbyte nz ) ;
FUNCTION: void glNormal3d ( GLdouble nx, GLdouble ny, GLdouble nz ) ;
FUNCTION: void glNormal3f ( GLfloat nx, GLfloat ny, GLfloat nz ) ;
FUNCTION: void glNormal3i ( GLint nx, GLint ny, GLint nz ) ;
FUNCTION: void glNormal3s ( GLshort nx, GLshort ny, GLshort nz ) ;

! FUNCTION: void glNormal3bv ( const GLbyte *v ) ;
! FUNCTION: void glNormal3dv ( const GLdouble *v ) ;
! FUNCTION: void glNormal3fv ( const GLfloat *v ) ;
! FUNCTION: void glNormal3iv ( const GLint *v ) ;
! FUNCTION: void glNormal3sv ( const GLshort *v ) ;

FUNCTION: void glIndexd ( GLdouble c ) ;
FUNCTION: void glIndexf ( GLfloat c ) ;
FUNCTION: void glIndexi ( GLint c ) ;
FUNCTION: void glIndexs ( GLshort c ) ;
FUNCTION: void glIndexub ( GLubyte c ) ;

! FUNCTION: void glIndexdv ( const GLdouble *c ) ;
! FUNCTION: void glIndexfv ( const GLfloat *c ) ;
! FUNCTION: void glIndexiv ( const GLint *c ) ;
! FUNCTION: void glIndexsv ( const GLshort *c ) ;
! FUNCTION: void glIndexubv ( const GLubyte *c ) ;

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

! FUNCTION: void glColor3bv ( const GLbyte *v ) ;
! FUNCTION: void glColor3dv ( const GLdouble *v ) ;
! FUNCTION: void glColor3fv ( const GLfloat *v ) ;
! FUNCTION: void glColor3iv ( const GLint *v ) ;
! FUNCTION: void glColor3sv ( const GLshort *v ) ;
! FUNCTION: void glColor3ubv ( const GLubyte *v ) ;
! FUNCTION: void glColor3uiv ( const GLuint *v ) ;
! FUNCTION: void glColor3usv ( const GLushort *v ) ;

! FUNCTION: void glColor4bv ( const GLbyte *v ) ;
! FUNCTION: void glColor4dv ( const GLdouble *v ) ;
! FUNCTION: void glColor4fv ( const GLfloat *v ) ;
! FUNCTION: void glColor4iv ( const GLint *v ) ;
! FUNCTION: void glColor4sv ( const GLshort *v ) ;
! FUNCTION: void glColor4ubv ( const GLubyte *v ) ;
! FUNCTION: void glColor4uiv ( const GLuint *v ) ;
! FUNCTION: void glColor4usv ( const GLushort *v ) ;


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

! FUNCTION: void glTexCoord1dv ( const GLdouble *v ) ;
! FUNCTION: void glTexCoord1fv ( const GLfloat *v ) ;
! FUNCTION: void glTexCoord1iv ( const GLint *v ) ;
! FUNCTION: void glTexCoord1sv ( const GLshort *v ) ;
! 
! FUNCTION: void glTexCoord2dv ( const GLdouble *v ) ;
! FUNCTION: void glTexCoord2fv ( const GLfloat *v ) ;
! FUNCTION: void glTexCoord2iv ( const GLint *v ) ;
! FUNCTION: void glTexCoord2sv ( const GLshort *v ) ;
! 
! FUNCTION: void glTexCoord3dv ( const GLdouble *v ) ;
! FUNCTION: void glTexCoord3fv ( const GLfloat *v ) ;
! FUNCTION: void glTexCoord3iv ( const GLint *v ) ;
! FUNCTION: void glTexCoord3sv ( const GLshort *v ) ;
! 
! FUNCTION: void glTexCoord4dv ( const GLdouble *v ) ;
! FUNCTION: void glTexCoord4fv ( const GLfloat *v ) ;
! FUNCTION: void glTexCoord4iv ( const GLint *v ) ;
! FUNCTION: void glTexCoord4sv ( const GLshort *v ) ;

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

! FUNCTION: void glRasterPos2dv ( const GLdouble *v ) ;
! FUNCTION: void glRasterPos2fv ( const GLfloat *v ) ;
! FUNCTION: void glRasterPos2iv ( const GLint *v ) ;
! FUNCTION: void glRasterPos2sv ( const GLshort *v ) ;
! 
! FUNCTION: void glRasterPos3dv ( const GLdouble *v ) ;
! FUNCTION: void glRasterPos3fv ( const GLfloat *v ) ;
! FUNCTION: void glRasterPos3iv ( const GLint *v ) ;
! FUNCTION: void glRasterPos3sv ( const GLshort *v ) ;
! 
! FUNCTION: void glRasterPos4dv ( const GLdouble *v ) ;
! FUNCTION: void glRasterPos4fv ( const GLfloat *v ) ;
! FUNCTION: void glRasterPos4iv ( const GLint *v ) ;
! FUNCTION: void glRasterPos4sv ( const GLshort *v ) ;


FUNCTION: void glRectd ( GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2 ) ;
FUNCTION: void glRectf ( GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2 ) ;
FUNCTION: void glRecti ( GLint x1, GLint y1, GLint x2, GLint y2 ) ;
FUNCTION: void glRects ( GLshort x1, GLshort y1, GLshort x2, GLshort y2 ) ;

! FUNCTION: void glRectdv ( const GLdouble *v1, const GLdouble *v2 ) ;
! FUNCTION: void glRectfv ( const GLfloat *v1, const GLfloat *v2 ) ;
! FUNCTION: void glRectiv ( const GLint *v1, const GLint *v2 ) ;
! FUNCTION: void glRectsv ( const GLshort *v1, const GLshort *v2 ) ;


! Vertex Arrays (1.1)

! FUNCTION: void glVertexPointer ( GLint size, GLenum type, GLsizei stride, const GLvoid* ptr );
! FUNCTION: void glNormalPointer ( GLenum type, GLsizei stride, const GLvoid* ptr ) ;
! FUNCTION: void glColorPointer ( GLint size, GLenum type, GLsizei stride, const GLvoid* ptr );
! FUNCTION: void glIndexPointer ( GLenum type, GLsizei stride, const GLvoid* ptr ) ;
! FUNCTION: void glTexCoordPointer ( GLint size, GLenum type, GLsizei stride, const GLvoid* ptr );
! FUNCTION: void glEdgeFlagPointer ( GLsizei stride, const GLvoid* ptr ) ;
! FUNCTION: void glGetPointerv ( GLenum pname, GLvoid** params ) ;
! FUNCTION: void glArrayElement ( GLint i ) ;
! FUNCTION: void glDrawArrays ( GLenum mode, GLint first, GLsizei count ) ;
! FUNCTION: void glDrawElements ( GLenum mode, GLsizei count, GLenum type, const GLvoid* indices );
! FUNCTION: void glInterleavedArrays ( GLenum format, GLsizei stride, const GLvoid* pointer ) ;


! Lighting

FUNCTION: void glShadeModel ( GLenum mode ) ;

FUNCTION: void glLightf ( GLenum light, GLenum pname, GLfloat param ) ;
FUNCTION: void glLighti ( GLenum light, GLenum pname, GLint param ) ;
! FUNCTION: void glLightfv ( GLenum light, GLenum pname, const GLfloat *params ) ;
! FUNCTION: void glLightiv ( GLenum light, GLenum pname, const GLint *params ) ;
! FUNCTION: void glGetLightfv ( GLenum light, GLenum pname, GLfloat *params ) ;
! FUNCTION: void glGetLightiv ( GLenum light, GLenum pname, GLint *params ) ;

FUNCTION: void glLightModelf ( GLenum pname, GLfloat param ) ;
FUNCTION: void glLightModeli ( GLenum pname, GLint param ) ;
! FUNCTION: void glLightModelfv ( GLenum pname, const GLfloat *params ) ;
! FUNCTION: void glLightModeliv ( GLenum pname, const GLint *params ) ;

FUNCTION: void glMaterialf ( GLenum face, GLenum pname, GLfloat param ) ;
FUNCTION: void glMateriali ( GLenum face, GLenum pname, GLint param ) ;
! FUNCTION: void glMaterialfv ( GLenum face, GLenum pname, const GLfloat *params ) ;
! FUNCTION: void glMaterialiv ( GLenum face, GLenum pname, const GLint *params ) ;

! FUNCTION: void glGetMaterialfv ( GLenum face, GLenum pname, GLfloat *params ) ;
! FUNCTION: void glGetMaterialiv ( GLenum face, GLenum pname, GLint *params ) ;

FUNCTION: void glColorMaterial ( GLenum face, GLenum mode ) ;


! Raster functions

FUNCTION: void glPixelZoom ( GLfloat xfactor, GLfloat yfactor ) ;

FUNCTION: void glPixelStoref ( GLenum pname, GLfloat param ) ;
FUNCTION: void glPixelStorei ( GLenum pname, GLint param ) ;

FUNCTION: void glPixelTransferf ( GLenum pname, GLfloat param ) ;
FUNCTION: void glPixelTransferi ( GLenum pname, GLint param ) ;

! FUNCTION: void glPixelMapfv ( GLenum map, GLsizei mapsize, const GLfloat *values ) ;
! FUNCTION: void glPixelMapuiv ( GLenum map, GLsizei mapsize, const GLuint *values ) ;
! FUNCTION: void glPixelMapusv ( GLenum map, GLsizei mapsize, const GLushort *values ) ;

! FUNCTION: void glGetPixelMapfv ( GLenum map, GLfloat *values ) ;
! FUNCTION: void glGetPixelMapuiv ( GLenum map, GLuint *values ) ;
! FUNCTION: void glGetPixelMapusv ( GLenum map, GLushort *values ) ;

! FUNCTION: void glBitmap ( GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, const GLubyte *bitmap ) ;

FUNCTION: void glReadPixels ( GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid* pixels ) ;

! FUNCTION: void glDrawPixels ( GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels ) ;
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

! FUNCTION: void glTexGendv ( GLenum coord, GLenum pname, const GLdouble *params ) ;
! FUNCTION: void glTexGenfv ( GLenum coord, GLenum pname, const GLfloat *params ) ;
! FUNCTION: void glTexGeniv ( GLenum coord, GLenum pname, const GLint *params ) ;

! FUNCTION: void glGetTexGendv ( GLenum coord, GLenum pname, GLdouble *params ) ;
! FUNCTION: void glGetTexGenfv ( GLenum coord, GLenum pname, GLfloat *params ) ;
! FUNCTION: void glGetTexGeniv ( GLenum coord, GLenum pname, GLint *params ) ;

FUNCTION: void glTexEnvf ( GLenum target, GLenum pname, GLfloat param ) ;
FUNCTION: void glTexEnvi ( GLenum target, GLenum pname, GLint param ) ;
! FUNCTION: void glTexEnvfv ( GLenum target, GLenum pname, const GLfloat *params ) ;
! FUNCTION: void glTexEnviv ( GLenum target, GLenum pname, const GLint *params ) ;

! FUNCTION: void glGetTexEnvfv ( GLenum target, GLenum pname, GLfloat *params ) ;
! FUNCTION: void glGetTexEnviv ( GLenum target, GLenum pname, GLint *params ) ;

FUNCTION: void glTexParameterf ( GLenum target, GLenum pname, GLfloat param ) ;
FUNCTION: void glTexParameteri ( GLenum target, GLenum pname, GLint param ) ;

! FUNCTION: void glTexParameterfv ( GLenum target, GLenum pname, const GLfloat *params ) ;
! FUNCTION: void glTexParameteriv ( GLenum target, GLenum pname, const GLint *params ) ;

! FUNCTION: void glGetTexParameterfv ( GLenum target, GLenum pname, GLfloat *params) ;
! FUNCTION: void glGetTexParameteriv ( GLenum target, GLenum pname, GLint *params ) ;

! FUNCTION: void glGetTexLevelParameterfv ( GLenum target, GLint level, GLenum pname, GLfloat *params );                                       
! FUNCTION: void glGetTexLevelParameteriv ( GLenum target, GLint level, GLenum pname, GLint *params );                                         

! FUNCTION: void glTexImage1D ( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLint border, GLenum format, GLenum type, const GLvoid* pixels ) ;

! FUNCTION: void glTexImage2D ( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels ) ;

! FUNCTION: void glGetTexImage ( GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels );                          


! 1.1 functions

! FUNCTION: void glGenTextures ( GLsizei n, GLuint *textures ) ;

! FUNCTION: void glDeleteTextures ( GLsizei n, const GLuint *textures) ;

FUNCTION: void glBindTexture ( GLenum target, GLuint texture ) ;

! FUNCTION: void glPrioritizeTextures ( GLsizei n, const GLuint *textures, const GLclampf *priorities ) ;

! FUNCTION: GLboolean glAreTexturesResident ( GLsizei n, const GLuint *textures, GLboolean *residences ) ;

FUNCTION: GLboolean glIsTexture ( GLuint texture ) ;

! FUNCTION: void glTexSubImage1D ( GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const GLvoid *pixels ) ;

! FUNCTION: void glTexSubImage2D ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels ) ;

FUNCTION: void glCopyTexImage1D ( GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border ) ;

FUNCTION: void glCopyTexImage2D ( GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border ) ;

FUNCTION: void glCopyTexSubImage1D ( GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width ) ;

FUNCTION: void glCopyTexSubImage2D ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height ) ;


! Evaluators

! FUNCTION: void glMap1d ( GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, const GLdouble *points ) ;
! FUNCTION: void glMap1f ( GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, const GLfloat *points ) ;

! FUNCTION: void glMap2d ( GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, const GLdouble *points ) ;
! FUNCTION: void glMap2f ( GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, const GLfloat *points ) ;

! GFUNCTION: void glGetMapdv ( GLenum target, GLenum query, GLdouble *v ) ;
! FUNCTION: void glGetMapfv ( GLenum target, GLenum query, GLfloat *v ) ;
! FUNCTION: void glGetMapiv ( GLenum target, GLenum query, GLint *v ) ;

FUNCTION: void glEvalCoord1d ( GLdouble u ) ;
FUNCTION: void glEvalCoord1f ( GLfloat u ) ;

! FUNCTION: void glEvalCoord1dv ( const GLdouble *u ) ;
! FUNCTION: void glEvalCoord1fv ( const GLfloat *u ) ;

FUNCTION: void glEvalCoord2d ( GLdouble u, GLdouble v ) ;
FUNCTION: void glEvalCoord2f ( GLfloat u, GLfloat v ) ;

! FUNCTION: void glEvalCoord2dv ( const GLdouble *u ) ;
! FUNCTION: void glEvalCoord2fv ( const GLfloat *u ) ;

! FUNCTION: void glMapGrid1d ( GLint un, GLdouble u1, GLdouble u2 ) ;
! FUNCTION: void glMapGrid1f ( GLint un, GLfloat u1, GLfloat u2 ) ;

FUNCTION: void glMapGrid2d ( GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2 ) ;
FUNCTION: void glMapGrid2f ( GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2 ) ;

FUNCTION: void glEvalPoint1 ( GLint i ) ;
FUNCTION: void glEvalPoint2 ( GLint i, GLint j ) ;

FUNCTION: void glEvalMesh1 ( GLenum mode, GLint i1, GLint i2 ) ;
FUNCTION: void glEvalMesh2 ( GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2 ) ;


! Fog

FUNCTION: void glFogf ( GLenum pname, GLfloat param ) ;
FUNCTION: void glFogi ( GLenum pname, GLint param ) ;
! FUNCTION: void glFogfv ( GLenum pname, const GLfloat *params ) ;
! FUNCTION: void glFogiv ( GLenum pname, const GLint *params ) ;


! Selection and Feedback

! FUNCTION: void glFeedbackBuffer ( GLsizei size, GLenum type, GLfloat *buffer ) ;

FUNCTION: void glPassThrough ( GLfloat token ) ;
! FUNCTION: void glSelectBuffer ( GLsizei size, GLuint *buffer ) ;
FUNCTION: void glInitNames ( ) ;
FUNCTION: void glLoadName ( GLuint name ) ;
FUNCTION: void glPushName ( GLuint name ) ;
FUNCTION: void glPopName ( ) ;


! OpenGL 1.2

: GL_PACK_SKIP_IMAGES               HEX: 806B ;
: GL_PACK_IMAGE_HEIGHT              HEX: 806C ;
: GL_UNPACK_SKIP_IMAGES             HEX: 806D ;
: GL_UNPACK_IMAGE_HEIGHT            HEX: 806E ;
: GL_TEXTURE_3D                     HEX: 806F ;
: GL_PROXY_TEXTURE_3D               HEX: 8070 ;
: GL_TEXTURE_DEPTH                  HEX: 8071 ;
: GL_TEXTURE_WRAP_R                 HEX: 8072 ;
: GL_MAX_3D_TEXTURE_SIZE            HEX: 8073 ;
: GL_BGR                            HEX: 80E0 ;
: GL_BGRA                           HEX: 80E1 ;
: GL_UNSIGNED_BYTE_3_3_2            HEX: 8032 ;
: GL_UNSIGNED_BYTE_2_3_3_REV        HEX: 8362 ;
: GL_UNSIGNED_SHORT_5_6_5           HEX: 8363 ;
: GL_UNSIGNED_SHORT_5_6_5_REV       HEX: 8364 ;
: GL_UNSIGNED_SHORT_4_4_4_4         HEX: 8033 ;
: GL_UNSIGNED_SHORT_4_4_4_4_REV     HEX: 8365 ;
: GL_UNSIGNED_SHORT_5_5_5_1         HEX: 8034 ;
: GL_UNSIGNED_SHORT_1_5_5_5_REV     HEX: 8366 ;
: GL_UNSIGNED_INT_8_8_8_8           HEX: 8035 ;
: GL_UNSIGNED_INT_8_8_8_8_REV       HEX: 8367 ;
: GL_UNSIGNED_INT_10_10_10_2        HEX: 8036 ;
: GL_UNSIGNED_INT_2_10_10_10_REV    HEX: 8368 ;
: GL_RESCALE_NORMAL                 HEX: 803A ;
: GL_LIGHT_MODEL_COLOR_CONTROL      HEX: 81F8 ;
: GL_SINGLE_COLOR                   HEX: 81F9 ;
: GL_SEPARATE_SPECULAR_COLOR        HEX: 81FA ;
: GL_CLAMP_TO_EDGE                  HEX: 812F ;
: GL_TEXTURE_MIN_LOD                HEX: 813A ;
: GL_TEXTURE_MAX_LOD                HEX: 813B ;
: GL_TEXTURE_BASE_LEVEL             HEX: 813C ;
: GL_TEXTURE_MAX_LEVEL              HEX: 813D ;
: GL_MAX_ELEMENTS_VERTICES          HEX: 80E8 ;
: GL_MAX_ELEMENTS_INDICES           HEX: 80E9 ;
: GL_ALIASED_POINT_SIZE_RANGE       HEX: 846D ;
: GL_ALIASED_LINE_WIDTH_RANGE       HEX: 846E ;

! FUNCTION: void glDrawRangeElements ( GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const GLvoid *indices ) ;

! FUNCTION: void glTexImage3D ( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const GLvoid *pixels ) ;

! FUNCTION: void glTexSubImage3D ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const GLvoid *pixels) ;

! FUNCTION: void glCopyTexSubImage3D ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height ) ;

! TODO: the rest. looks fiddly

! OpenGL 1.3
: GL_ACTIVE_TEXTURE                 HEX: 84E0 ;
: GL_CLIENT_ACTIVE_TEXTURE          HEX: 84E1 ;
: GL_MAX_TEXTURE_UNITS              HEX: 84E2 ;
: GL_TEXTURE0                       HEX: 84C0 ;
: GL_TEXTURE1                       HEX: 84C1 ;
: GL_TEXTURE2                       HEX: 84C2 ;
: GL_TEXTURE3                       HEX: 84C3 ;
: GL_TEXTURE4                       HEX: 84C4 ;
: GL_TEXTURE5                       HEX: 84C5 ;
: GL_TEXTURE6                       HEX: 84C6 ;
: GL_TEXTURE7                       HEX: 84C7 ;
: GL_TEXTURE8                       HEX: 84C8 ;
: GL_TEXTURE9                       HEX: 84C9 ;
: GL_TEXTURE10                      HEX: 84CA ;
: GL_TEXTURE11                      HEX: 84CB ;
: GL_TEXTURE12                      HEX: 84CC ;
: GL_TEXTURE13                      HEX: 84CD ;
: GL_TEXTURE14                      HEX: 84CE ;
: GL_TEXTURE15                      HEX: 84CF ;
: GL_TEXTURE16                      HEX: 84D0 ;
: GL_TEXTURE17                      HEX: 84D1 ;
: GL_TEXTURE18                      HEX: 84D2 ;
: GL_TEXTURE19                      HEX: 84D3 ;
: GL_TEXTURE20                      HEX: 84D4 ;
: GL_TEXTURE21                      HEX: 84D5 ;
: GL_TEXTURE22                      HEX: 84D6 ;
: GL_TEXTURE23                      HEX: 84D7 ;
: GL_TEXTURE24                      HEX: 84D8 ;
: GL_TEXTURE25                      HEX: 84D9 ;
: GL_TEXTURE26                      HEX: 84DA ;
: GL_TEXTURE27                      HEX: 84DB ;
: GL_TEXTURE28                      HEX: 84DC ;
: GL_TEXTURE29                      HEX: 84DD ;
: GL_TEXTURE30                      HEX: 84DE ;
: GL_TEXTURE31                      HEX: 84DF ;
: GL_NORMAL_MAP                     HEX: 8511 ;
: GL_REFLECTION_MAP                 HEX: 8512 ;
: GL_TEXTURE_CUBE_MAP               HEX: 8513 ;
: GL_TEXTURE_BINDING_CUBE_MAP       HEX: 8514 ;
: GL_TEXTURE_CUBE_MAP_POSITIVE_X    HEX: 8515 ;
: GL_TEXTURE_CUBE_MAP_NEGATIVE_X    HEX: 8516 ;
: GL_TEXTURE_CUBE_MAP_POSITIVE_Y    HEX: 8517 ;
: GL_TEXTURE_CUBE_MAP_NEGATIVE_Y    HEX: 8518 ;
: GL_TEXTURE_CUBE_MAP_POSITIVE_Z    HEX: 8519 ;
: GL_TEXTURE_CUBE_MAP_NEGATIVE_Z    HEX: 851A ;
: GL_PROXY_TEXTURE_CUBE_MAP         HEX: 851B ;
: GL_MAX_CUBE_MAP_TEXTURE_SIZE      HEX: 851C ;
: GL_COMBINE                        HEX: 8570 ;
: GL_COMBINE_RGB                    HEX: 8571 ;
: GL_COMBINE_ALPHA                  HEX: 8572 ;
: GL_RGB_SCALE                      HEX: 8573 ;
: GL_ADD_SIGNED                     HEX: 8574 ;
: GL_INTERPOLATE                    HEX: 8575 ;
: GL_CONSTANT                       HEX: 8576 ;
: GL_PRIMARY_COLOR                  HEX: 8577 ;
: GL_PREVIOUS                       HEX: 8578 ;
: GL_SOURCE0_RGB                    HEX: 8580 ;
: GL_SOURCE1_RGB                    HEX: 8581 ;
: GL_SOURCE2_RGB                    HEX: 8582 ;
: GL_SOURCE0_ALPHA                  HEX: 8588 ;
: GL_SOURCE1_ALPHA                  HEX: 8589 ;
: GL_SOURCE2_ALPHA                  HEX: 858A ;
: GL_OPERAND0_RGB                   HEX: 8590 ;
: GL_OPERAND1_RGB                   HEX: 8591 ;
: GL_OPERAND2_RGB                   HEX: 8592 ;
: GL_OPERAND0_ALPHA                 HEX: 8598 ;
: GL_OPERAND1_ALPHA                 HEX: 8599 ;
: GL_OPERAND2_ALPHA                 HEX: 859A ;
: GL_SUBTRACT                       HEX: 84E7 ;
: GL_TRANSPOSE_MODELVIEW_MATRIX     HEX: 84E3 ;
: GL_TRANSPOSE_PROJECTION_MATRIX    HEX: 84E4 ;
: GL_TRANSPOSE_TEXTURE_MATRIX       HEX: 84E5 ;
: GL_TRANSPOSE_COLOR_MATRIX         HEX: 84E6 ;
: GL_COMPRESSED_ALPHA               HEX: 84E9 ;
: GL_COMPRESSED_LUMINANCE           HEX: 84EA ;
: GL_COMPRESSED_LUMINANCE_ALPHA     HEX: 84EB ;
: GL_COMPRESSED_INTENSITY           HEX: 84EC ;
: GL_COMPRESSED_RGB                 HEX: 84ED ;
: GL_COMPRESSED_RGBA                HEX: 84EE ;
: GL_TEXTURE_COMPRESSION_HINT       HEX: 84EF ;
: GL_TEXTURE_COMPRESSED_IMAGE_SIZE  HEX: 86A0 ;
: GL_TEXTURE_COMPRESSED             HEX: 86A1 ;
: GL_NUM_COMPRESSED_TEXTURE_FORMATS HEX: 86A2 ;
: GL_COMPRESSED_TEXTURE_FORMATS     HEX: 86A3 ;
: GL_DOT3_RGB                       HEX: 86AE ;
: GL_DOT3_RGBA                      HEX: 86AF ;
: GL_CLAMP_TO_BORDER                HEX: 812D ;
: GL_MULTISAMPLE                    HEX: 809D ;
: GL_SAMPLE_ALPHA_TO_COVERAGE       HEX: 809E ;
: GL_SAMPLE_ALPHA_TO_ONE            HEX: 809F ;
: GL_SAMPLE_COVERAGE                HEX: 80A0 ;
: GL_SAMPLE_BUFFERS                 HEX: 80A8 ;
: GL_SAMPLES                        HEX: 80A9 ;
: GL_SAMPLE_COVERAGE_VALUE          HEX: 80AA ;
: GL_SAMPLE_COVERAGE_INVERT         HEX: 80AB ;
: GL_MULTISAMPLE_BIT                HEX: 20000000 ;

! OpenGL 1.4
: GL_POINT_SIZE_MIN                 HEX: 8126 ;
: GL_POINT_SIZE_MAX                 HEX: 8127 ;
: GL_POINT_FADE_THRESHOLD_SIZE      HEX: 8128 ;
: GL_POINT_DISTANCE_ATTENUATION     HEX: 8129 ;
: GL_FOG_COORDINATE_SOURCE          HEX: 8450 ;
: GL_FOG_COORDINATE                 HEX: 8451 ;
: GL_FRAGMENT_DEPTH                 HEX: 8452 ;
: GL_CURRENT_FOG_COORDINATE         HEX: 8453 ;
: GL_FOG_COORDINATE_ARRAY_TYPE      HEX: 8454 ;
: GL_FOG_COORDINATE_ARRAY_STRIDE    HEX: 8455 ;
: GL_FOG_COORDINATE_ARRAY_POINTER   HEX: 8456 ;
: GL_FOG_COORDINATE_ARRAY           HEX: 8457 ;
: GL_COLOR_SUM                      HEX: 8458 ;
: GL_CURRENT_SECONDARY_COLOR        HEX: 8459 ;
: GL_SECONDARY_COLOR_ARRAY_SIZE     HEX: 845A ;
: GL_SECONDARY_COLOR_ARRAY_TYPE     HEX: 845B ;
: GL_SECONDARY_COLOR_ARRAY_STRIDE   HEX: 845C ;
: GL_SECONDARY_COLOR_ARRAY_POINTER  HEX: 845D ;
: GL_SECONDARY_COLOR_ARRAY          HEX: 845E ;
: GL_INCR_WRAP                      HEX: 8507 ;
: GL_DECR_WRAP                      HEX: 8508 ;
: GL_MAX_TEXTURE_LOD_BIAS           HEX: 84FD ;
: GL_TEXTURE_FILTER_CONTROL         HEX: 8500 ;
: GL_TEXTURE_LOD_BIAS               HEX: 8501 ;
: GL_GENERATE_MIPMAP                HEX: 8191 ;
: GL_GENERATE_MIPMAP_HINT           HEX: 8192 ;
: GL_BLEND_DST_RGB                  HEX: 80C8 ;
: GL_BLEND_SRC_RGB                  HEX: 80C9 ;
: GL_BLEND_DST_ALPHA                HEX: 80CA ;
: GL_BLEND_SRC_ALPHA                HEX: 80CB ;
: GL_MIRRORED_REPEAT                HEX: 8370 ;
: GL_DEPTH_COMPONENT16              HEX: 81A5 ;
: GL_DEPTH_COMPONENT24              HEX: 81A6 ;
: GL_DEPTH_COMPONENT32              HEX: 81A7 ;
: GL_TEXTURE_DEPTH_SIZE             HEX: 884A ;
: GL_DEPTH_TEXTURE_MODE             HEX: 884B ;
: GL_TEXTURE_COMPARE_MODE           HEX: 884C ;
: GL_TEXTURE_COMPARE_FUNC           HEX: 884D ;
: GL_COMPARE_R_TO_TEXTURE           HEX: 884E ;
