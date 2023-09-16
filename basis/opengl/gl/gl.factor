! Copyright (C) 2005 Alex Chapman.
! See https://factorcode.org/license.txt for BSD license.

! This file is based on the gl.h that comes with xorg-x11 6.8.2
USING: alien alien.c-types alien.libraries alien.syntax
io.encodings.ascii kernel opengl.gl.extensions system ;
IN: opengl.gl

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
TYPEDEF: longlong  GLint64
TYPEDEF: ulonglong GLuint64
TYPEDEF: void*     GLsync
C-TYPE: GLvoid

TYPEDEF: c-string[ascii] GLstring

! Constants

! Boolean values
CONSTANT: GL_FALSE                          0x0
CONSTANT: GL_TRUE                           0x1

! Data types
CONSTANT: GL_BYTE                           0x1400
CONSTANT: GL_UNSIGNED_BYTE                  0x1401
CONSTANT: GL_SHORT                          0x1402
CONSTANT: GL_UNSIGNED_SHORT                 0x1403
CONSTANT: GL_INT                            0x1404
CONSTANT: GL_UNSIGNED_INT                   0x1405
CONSTANT: GL_FLOAT                          0x1406
CONSTANT: GL_2_BYTES                        0x1407
CONSTANT: GL_3_BYTES                        0x1408
CONSTANT: GL_4_BYTES                        0x1409
CONSTANT: GL_DOUBLE                         0x140A

! Primitives
CONSTANT: GL_POINTS                         0x0000
CONSTANT: GL_LINES                          0x0001
CONSTANT: GL_LINE_LOOP                      0x0002
CONSTANT: GL_LINE_STRIP                     0x0003
CONSTANT: GL_TRIANGLES                      0x0004
CONSTANT: GL_TRIANGLE_STRIP                 0x0005
CONSTANT: GL_TRIANGLE_FAN                   0x0006
CONSTANT: GL_QUADS                          0x0007
CONSTANT: GL_QUAD_STRIP                     0x0008
CONSTANT: GL_POLYGON                        0x0009

! Vertex arrays
CONSTANT: GL_VERTEX_ARRAY                   0x8074
CONSTANT: GL_NORMAL_ARRAY                   0x8075
CONSTANT: GL_COLOR_ARRAY                    0x8076
CONSTANT: GL_INDEX_ARRAY                    0x8077
CONSTANT: GL_TEXTURE_COORD_ARRAY            0x8078
CONSTANT: GL_EDGE_FLAG_ARRAY                0x8079
CONSTANT: GL_VERTEX_ARRAY_SIZE              0x807A
CONSTANT: GL_VERTEX_ARRAY_TYPE              0x807B
CONSTANT: GL_VERTEX_ARRAY_STRIDE            0x807C
CONSTANT: GL_NORMAL_ARRAY_TYPE              0x807E
CONSTANT: GL_NORMAL_ARRAY_STRIDE            0x807F
CONSTANT: GL_COLOR_ARRAY_SIZE               0x8081
CONSTANT: GL_COLOR_ARRAY_TYPE               0x8082
CONSTANT: GL_COLOR_ARRAY_STRIDE             0x8083
CONSTANT: GL_INDEX_ARRAY_TYPE               0x8085
CONSTANT: GL_INDEX_ARRAY_STRIDE             0x8086
CONSTANT: GL_TEXTURE_COORD_ARRAY_SIZE       0x8088
CONSTANT: GL_TEXTURE_COORD_ARRAY_TYPE       0x8089
CONSTANT: GL_TEXTURE_COORD_ARRAY_STRIDE     0x808A
CONSTANT: GL_EDGE_FLAG_ARRAY_STRIDE         0x808C
CONSTANT: GL_VERTEX_ARRAY_POINTER           0x808E
CONSTANT: GL_NORMAL_ARRAY_POINTER           0x808F
CONSTANT: GL_COLOR_ARRAY_POINTER            0x8090
CONSTANT: GL_INDEX_ARRAY_POINTER            0x8091
CONSTANT: GL_TEXTURE_COORD_ARRAY_POINTER    0x8092
CONSTANT: GL_EDGE_FLAG_ARRAY_POINTER        0x8093
CONSTANT: GL_V2F                            0x2A20
CONSTANT: GL_V3F                            0x2A21
CONSTANT: GL_C4UB_V2F                       0x2A22
CONSTANT: GL_C4UB_V3F                       0x2A23
CONSTANT: GL_C3F_V3F                        0x2A24
CONSTANT: GL_N3F_V3F                        0x2A25
CONSTANT: GL_C4F_N3F_V3F                    0x2A26
CONSTANT: GL_T2F_V3F                        0x2A27
CONSTANT: GL_T4F_V4F                        0x2A28
CONSTANT: GL_T2F_C4UB_V3F                   0x2A29
CONSTANT: GL_T2F_C3F_V3F                    0x2A2A
CONSTANT: GL_T2F_N3F_V3F                    0x2A2B
CONSTANT: GL_T2F_C4F_N3F_V3F                0x2A2C
CONSTANT: GL_T4F_C4F_N3F_V4F                0x2A2D

! Matrix mode
CONSTANT: GL_MATRIX_MODE                    0x0BA0
CONSTANT: GL_MODELVIEW                      0x1700
CONSTANT: GL_PROJECTION                     0x1701
CONSTANT: GL_TEXTURE                        0x1702

! Points
CONSTANT: GL_POINT_SMOOTH                   0x0B10
CONSTANT: GL_POINT_SIZE                     0x0B11
CONSTANT: GL_POINT_SIZE_GRANULARITY         0x0B13
CONSTANT: GL_POINT_SIZE_RANGE               0x0B12

! Lines
CONSTANT: GL_LINE_SMOOTH                    0x0B20
CONSTANT: GL_LINE_STIPPLE                   0x0B24
CONSTANT: GL_LINE_STIPPLE_PATTERN           0x0B25
CONSTANT: GL_LINE_STIPPLE_REPEAT            0x0B26
CONSTANT: GL_LINE_WIDTH                     0x0B21
CONSTANT: GL_LINE_WIDTH_GRANULARITY         0x0B23
CONSTANT: GL_LINE_WIDTH_RANGE               0x0B22

! Polygons
CONSTANT: GL_POINT                          0x1B00
CONSTANT: GL_LINE                           0x1B01
CONSTANT: GL_FILL                           0x1B02
CONSTANT: GL_CW                             0x0900
CONSTANT: GL_CCW                            0x0901
CONSTANT: GL_FRONT                          0x0404
CONSTANT: GL_BACK                           0x0405
CONSTANT: GL_POLYGON_MODE                   0x0B40
CONSTANT: GL_POLYGON_SMOOTH                 0x0B41
CONSTANT: GL_POLYGON_STIPPLE                0x0B42
CONSTANT: GL_EDGE_FLAG                      0x0B43
CONSTANT: GL_CULL_FACE                      0x0B44
CONSTANT: GL_CULL_FACE_MODE                 0x0B45
CONSTANT: GL_FRONT_FACE                     0x0B46
CONSTANT: GL_POLYGON_OFFSET_FACTOR          0x8038
CONSTANT: GL_POLYGON_OFFSET_UNITS           0x2A00
CONSTANT: GL_POLYGON_OFFSET_POINT           0x2A01
CONSTANT: GL_POLYGON_OFFSET_LINE            0x2A02
CONSTANT: GL_POLYGON_OFFSET_FILL            0x8037

! Display Lists
CONSTANT: GL_COMPILE                        0x1300
CONSTANT: GL_COMPILE_AND_EXECUTE            0x1301
CONSTANT: GL_LIST_BASE                      0x0B32
CONSTANT: GL_LIST_INDEX                     0x0B33
CONSTANT: GL_LIST_MODE                      0x0B30

! Depth buffer
CONSTANT: GL_NEVER                          0x0200
CONSTANT: GL_LESS                           0x0201
CONSTANT: GL_EQUAL                          0x0202
CONSTANT: GL_LEQUAL                         0x0203
CONSTANT: GL_GREATER                        0x0204
CONSTANT: GL_NOTEQUAL                       0x0205
CONSTANT: GL_GEQUAL                         0x0206
CONSTANT: GL_ALWAYS                         0x0207
CONSTANT: GL_DEPTH_TEST                     0x0B71
CONSTANT: GL_DEPTH_BITS                     0x0D56
CONSTANT: GL_DEPTH_CLEAR_VALUE              0x0B73
CONSTANT: GL_DEPTH_FUNC                     0x0B74
CONSTANT: GL_DEPTH_RANGE                    0x0B70
CONSTANT: GL_DEPTH_WRITEMASK                0x0B72
CONSTANT: GL_DEPTH_COMPONENT                0x1902

! Lighting
CONSTANT: GL_LIGHTING                       0x0B50
CONSTANT: GL_LIGHT0                         0x4000
CONSTANT: GL_LIGHT1                         0x4001
CONSTANT: GL_LIGHT2                         0x4002
CONSTANT: GL_LIGHT3                         0x4003
CONSTANT: GL_LIGHT4                         0x4004
CONSTANT: GL_LIGHT5                         0x4005
CONSTANT: GL_LIGHT6                         0x4006
CONSTANT: GL_LIGHT7                         0x4007
CONSTANT: GL_SPOT_EXPONENT                  0x1205
CONSTANT: GL_SPOT_CUTOFF                    0x1206
CONSTANT: GL_CONSTANT_ATTENUATION           0x1207
CONSTANT: GL_LINEAR_ATTENUATION             0x1208
CONSTANT: GL_QUADRATIC_ATTENUATION          0x1209
CONSTANT: GL_AMBIENT                        0x1200
CONSTANT: GL_DIFFUSE                        0x1201
CONSTANT: GL_SPECULAR                       0x1202
CONSTANT: GL_SHININESS                      0x1601
CONSTANT: GL_EMISSION                       0x1600
CONSTANT: GL_POSITION                       0x1203
CONSTANT: GL_SPOT_DIRECTION                 0x1204
CONSTANT: GL_AMBIENT_AND_DIFFUSE            0x1602
CONSTANT: GL_COLOR_INDEXES                  0x1603
CONSTANT: GL_LIGHT_MODEL_TWO_SIDE           0x0B52
CONSTANT: GL_LIGHT_MODEL_LOCAL_VIEWER       0x0B51
CONSTANT: GL_LIGHT_MODEL_AMBIENT            0x0B53
CONSTANT: GL_FRONT_AND_BACK                 0x0408
CONSTANT: GL_SHADE_MODEL                    0x0B54
CONSTANT: GL_FLAT                           0x1D00
CONSTANT: GL_SMOOTH                         0x1D01
CONSTANT: GL_COLOR_MATERIAL                 0x0B57
CONSTANT: GL_COLOR_MATERIAL_FACE            0x0B55
CONSTANT: GL_COLOR_MATERIAL_PARAMETER       0x0B56
CONSTANT: GL_NORMALIZE                      0x0BA1

! User clipping planes
CONSTANT: GL_CLIP_PLANE0                    0x3000
CONSTANT: GL_CLIP_PLANE1                    0x3001
CONSTANT: GL_CLIP_PLANE2                    0x3002
CONSTANT: GL_CLIP_PLANE3                    0x3003
CONSTANT: GL_CLIP_PLANE4                    0x3004
CONSTANT: GL_CLIP_PLANE5                    0x3005

! Accumulation buffer
CONSTANT: GL_ACCUM_RED_BITS                 0x0D58
CONSTANT: GL_ACCUM_GREEN_BITS               0x0D59
CONSTANT: GL_ACCUM_BLUE_BITS                0x0D5A
CONSTANT: GL_ACCUM_ALPHA_BITS               0x0D5B
CONSTANT: GL_ACCUM_CLEAR_VALUE              0x0B80
CONSTANT: GL_ACCUM                          0x0100
CONSTANT: GL_ADD                            0x0104
CONSTANT: GL_LOAD                           0x0101
CONSTANT: GL_MULT                           0x0103
CONSTANT: GL_RETURN                         0x0102

! Alpha testing
CONSTANT: GL_ALPHA_TEST                     0x0BC0
CONSTANT: GL_ALPHA_TEST_REF                 0x0BC2
CONSTANT: GL_ALPHA_TEST_FUNC                0x0BC1

! Blending
CONSTANT: GL_BLEND                          0x0BE2
CONSTANT: GL_BLEND_SRC                      0x0BE1
CONSTANT: GL_BLEND_DST                      0x0BE0
CONSTANT: GL_ZERO                           0x0
CONSTANT: GL_ONE                            0x1
CONSTANT: GL_SRC_COLOR                      0x0300
CONSTANT: GL_ONE_MINUS_SRC_COLOR            0x0301
CONSTANT: GL_SRC_ALPHA                      0x0302
CONSTANT: GL_ONE_MINUS_SRC_ALPHA            0x0303
CONSTANT: GL_DST_ALPHA                      0x0304
CONSTANT: GL_ONE_MINUS_DST_ALPHA            0x0305
CONSTANT: GL_DST_COLOR                      0x0306
CONSTANT: GL_ONE_MINUS_DST_COLOR            0x0307
CONSTANT: GL_SRC_ALPHA_SATURATE             0x0308

! Render Mode
CONSTANT: GL_FEEDBACK                       0x1C01
CONSTANT: GL_RENDER                         0x1C00
CONSTANT: GL_SELECT                         0x1C02

! Feedback
CONSTANT: GL_2D                             0x0600
CONSTANT: GL_3D                             0x0601
CONSTANT: GL_3D_COLOR                       0x0602
CONSTANT: GL_3D_COLOR_TEXTURE               0x0603
CONSTANT: GL_4D_COLOR_TEXTURE               0x0604
CONSTANT: GL_POINT_TOKEN                    0x0701
CONSTANT: GL_LINE_TOKEN                     0x0702
CONSTANT: GL_LINE_RESET_TOKEN               0x0707
CONSTANT: GL_POLYGON_TOKEN                  0x0703
CONSTANT: GL_BITMAP_TOKEN                   0x0704
CONSTANT: GL_DRAW_PIXEL_TOKEN               0x0705
CONSTANT: GL_COPY_PIXEL_TOKEN               0x0706
CONSTANT: GL_PASS_THROUGH_TOKEN             0x0700
CONSTANT: GL_FEEDBACK_BUFFER_POINTER        0x0DF0
CONSTANT: GL_FEEDBACK_BUFFER_SIZE           0x0DF1
CONSTANT: GL_FEEDBACK_BUFFER_TYPE           0x0DF2

! Selection
CONSTANT: GL_SELECTION_BUFFER_POINTER       0x0DF3
CONSTANT: GL_SELECTION_BUFFER_SIZE          0x0DF4

! Fog
CONSTANT: GL_FOG                            0x0B60
CONSTANT: GL_FOG_MODE                       0x0B65
CONSTANT: GL_FOG_DENSITY                    0x0B62
CONSTANT: GL_FOG_COLOR                      0x0B66
CONSTANT: GL_FOG_INDEX                      0x0B61
CONSTANT: GL_FOG_START                      0x0B63
CONSTANT: GL_FOG_END                        0x0B64
CONSTANT: GL_LINEAR                         0x2601
CONSTANT: GL_EXP                            0x0800
CONSTANT: GL_EXP2                           0x0801

! Logic Ops
CONSTANT: GL_LOGIC_OP                       0x0BF1
CONSTANT: GL_INDEX_LOGIC_OP                 0x0BF1
CONSTANT: GL_COLOR_LOGIC_OP                 0x0BF2
CONSTANT: GL_LOGIC_OP_MODE                  0x0BF0
CONSTANT: GL_CLEAR                          0x1500
CONSTANT: GL_SET                            0x150F
CONSTANT: GL_COPY                           0x1503
CONSTANT: GL_COPY_INVERTED                  0x150C
CONSTANT: GL_NOOP                           0x1505
CONSTANT: GL_INVERT                         0x150A
CONSTANT: GL_AND                            0x1501
CONSTANT: GL_NAND                           0x150E
CONSTANT: GL_OR                             0x1507
CONSTANT: GL_NOR                            0x1508
CONSTANT: GL_XOR                            0x1506
CONSTANT: GL_EQUIV                          0x1509
CONSTANT: GL_AND_REVERSE                    0x1502
CONSTANT: GL_AND_INVERTED                   0x1504
CONSTANT: GL_OR_REVERSE                     0x150B
CONSTANT: GL_OR_INVERTED                    0x150D

! Stencil
CONSTANT: GL_STENCIL_TEST                   0x0B90
CONSTANT: GL_STENCIL_WRITEMASK              0x0B98
CONSTANT: GL_STENCIL_BITS                   0x0D57
CONSTANT: GL_STENCIL_FUNC                   0x0B92
CONSTANT: GL_STENCIL_VALUE_MASK             0x0B93
CONSTANT: GL_STENCIL_REF                    0x0B97
CONSTANT: GL_STENCIL_FAIL                   0x0B94
CONSTANT: GL_STENCIL_PASS_DEPTH_PASS        0x0B96
CONSTANT: GL_STENCIL_PASS_DEPTH_FAIL        0x0B95
CONSTANT: GL_STENCIL_CLEAR_VALUE            0x0B91
CONSTANT: GL_STENCIL_INDEX                  0x1901
CONSTANT: GL_KEEP                           0x1E00
CONSTANT: GL_REPLACE                        0x1E01
CONSTANT: GL_INCR                           0x1E02
CONSTANT: GL_DECR                           0x1E03

! Buffers, Pixel Drawing/Reading
CONSTANT: GL_NONE                           0x0
CONSTANT: GL_LEFT                           0x0406
CONSTANT: GL_RIGHT                          0x0407
CONSTANT: GL_FRONT_LEFT                     0x0400
CONSTANT: GL_FRONT_RIGHT                    0x0401
CONSTANT: GL_BACK_LEFT                      0x0402
CONSTANT: GL_BACK_RIGHT                     0x0403
CONSTANT: GL_AUX0                           0x0409
CONSTANT: GL_AUX1                           0x040A
CONSTANT: GL_AUX2                           0x040B
CONSTANT: GL_AUX3                           0x040C
CONSTANT: GL_COLOR_INDEX                    0x1900
CONSTANT: GL_RED                            0x1903
CONSTANT: GL_GREEN                          0x1904
CONSTANT: GL_BLUE                           0x1905
CONSTANT: GL_ALPHA                          0x1906
CONSTANT: GL_LUMINANCE                      0x1909
CONSTANT: GL_LUMINANCE_ALPHA                0x190A
CONSTANT: GL_ALPHA_BITS                     0x0D55
CONSTANT: GL_RED_BITS                       0x0D52
CONSTANT: GL_GREEN_BITS                     0x0D53
CONSTANT: GL_BLUE_BITS                      0x0D54
CONSTANT: GL_INDEX_BITS                     0x0D51
CONSTANT: GL_SUBPIXEL_BITS                  0x0D50
CONSTANT: GL_AUX_BUFFERS                    0x0C00
CONSTANT: GL_READ_BUFFER                    0x0C02
CONSTANT: GL_DRAW_BUFFER                    0x0C01
CONSTANT: GL_DOUBLEBUFFER                   0x0C32
CONSTANT: GL_STEREO                         0x0C33
CONSTANT: GL_BITMAP                         0x1A00
CONSTANT: GL_COLOR                          0x1800
CONSTANT: GL_DEPTH                          0x1801
CONSTANT: GL_STENCIL                        0x1802
CONSTANT: GL_DITHER                         0x0BD0
CONSTANT: GL_RGB                            0x1907
CONSTANT: GL_RGBA                           0x1908

! Implementation limits
CONSTANT: GL_MAX_LIST_NESTING               0x0B31
CONSTANT: GL_MAX_ATTRIB_STACK_DEPTH         0x0D35
CONSTANT: GL_MAX_MODELVIEW_STACK_DEPTH      0x0D36
CONSTANT: GL_MAX_NAME_STACK_DEPTH           0x0D37
CONSTANT: GL_MAX_PROJECTION_STACK_DEPTH     0x0D38
CONSTANT: GL_MAX_TEXTURE_STACK_DEPTH        0x0D39
CONSTANT: GL_MAX_EVAL_ORDER                 0x0D30
CONSTANT: GL_MAX_LIGHTS                     0x0D31
CONSTANT: GL_MAX_CLIP_PLANES                0x0D32
CONSTANT: GL_MAX_TEXTURE_SIZE               0x0D33
CONSTANT: GL_MAX_PIXEL_MAP_TABLE            0x0D34
CONSTANT: GL_MAX_VIEWPORT_DIMS              0x0D3A
CONSTANT: GL_MAX_CLIENT_ATTRIB_STACK_DEPTH  0x0D3B

! Gets
CONSTANT: GL_ATTRIB_STACK_DEPTH             0x0BB0
CONSTANT: GL_CLIENT_ATTRIB_STACK_DEPTH      0x0BB1
CONSTANT: GL_COLOR_CLEAR_VALUE              0x0C22
CONSTANT: GL_COLOR_WRITEMASK                0x0C23
CONSTANT: GL_CURRENT_INDEX                  0x0B01
CONSTANT: GL_CURRENT_COLOR                  0x0B00
CONSTANT: GL_CURRENT_NORMAL                 0x0B02
CONSTANT: GL_CURRENT_RASTER_COLOR           0x0B04
CONSTANT: GL_CURRENT_RASTER_DISTANCE        0x0B09
CONSTANT: GL_CURRENT_RASTER_INDEX           0x0B05
CONSTANT: GL_CURRENT_RASTER_POSITION        0x0B07
CONSTANT: GL_CURRENT_RASTER_TEXTURE_COORDS  0x0B06
CONSTANT: GL_CURRENT_RASTER_POSITION_VALID  0x0B08
CONSTANT: GL_CURRENT_TEXTURE_COORDS         0x0B03
CONSTANT: GL_INDEX_CLEAR_VALUE              0x0C20
CONSTANT: GL_INDEX_MODE                     0x0C30
CONSTANT: GL_INDEX_WRITEMASK                0x0C21
CONSTANT: GL_MODELVIEW_MATRIX               0x0BA6
CONSTANT: GL_MODELVIEW_STACK_DEPTH          0x0BA3
CONSTANT: GL_NAME_STACK_DEPTH               0x0D70
CONSTANT: GL_PROJECTION_MATRIX              0x0BA7
CONSTANT: GL_PROJECTION_STACK_DEPTH         0x0BA4
CONSTANT: GL_RENDER_MODE                    0x0C40
CONSTANT: GL_RGBA_MODE                      0x0C31
CONSTANT: GL_TEXTURE_MATRIX                 0x0BA8
CONSTANT: GL_TEXTURE_STACK_DEPTH            0x0BA5
CONSTANT: GL_VIEWPORT                       0x0BA2

! Evaluators inline
CONSTANT: GL_AUTO_NORMAL                    0x0D80
CONSTANT: GL_MAP1_COLOR_4                   0x0D90
CONSTANT: GL_MAP1_INDEX                     0x0D91
CONSTANT: GL_MAP1_NORMAL                    0x0D92
CONSTANT: GL_MAP1_TEXTURE_COORD_1           0x0D93
CONSTANT: GL_MAP1_TEXTURE_COORD_2           0x0D94
CONSTANT: GL_MAP1_TEXTURE_COORD_3           0x0D95
CONSTANT: GL_MAP1_TEXTURE_COORD_4           0x0D96
CONSTANT: GL_MAP1_VERTEX_3                  0x0D97
CONSTANT: GL_MAP1_VERTEX_4                  0x0D98
CONSTANT: GL_MAP2_COLOR_4                   0x0DB0
CONSTANT: GL_MAP2_INDEX                     0x0DB1
CONSTANT: GL_MAP2_NORMAL                    0x0DB2
CONSTANT: GL_MAP2_TEXTURE_COORD_1           0x0DB3
CONSTANT: GL_MAP2_TEXTURE_COORD_2           0x0DB4
CONSTANT: GL_MAP2_TEXTURE_COORD_3           0x0DB5
CONSTANT: GL_MAP2_TEXTURE_COORD_4           0x0DB6
CONSTANT: GL_MAP2_VERTEX_3                  0x0DB7
CONSTANT: GL_MAP2_VERTEX_4                  0x0DB8
CONSTANT: GL_MAP1_GRID_DOMAIN               0x0DD0
CONSTANT: GL_MAP1_GRID_SEGMENTS             0x0DD1
CONSTANT: GL_MAP2_GRID_DOMAIN               0x0DD2
CONSTANT: GL_MAP2_GRID_SEGMENTS             0x0DD3
CONSTANT: GL_COEFF                          0x0A00
CONSTANT: GL_DOMAIN                         0x0A02
CONSTANT: GL_ORDER                          0x0A01

! Hints inline
CONSTANT: GL_FOG_HINT                       0x0C54
CONSTANT: GL_LINE_SMOOTH_HINT               0x0C52
CONSTANT: GL_PERSPECTIVE_CORRECTION_HINT    0x0C50
CONSTANT: GL_POINT_SMOOTH_HINT              0x0C51
CONSTANT: GL_POLYGON_SMOOTH_HINT            0x0C53
CONSTANT: GL_DONT_CARE                      0x1100
CONSTANT: GL_FASTEST                        0x1101
CONSTANT: GL_NICEST                         0x1102

! Scissor box inline
CONSTANT: GL_SCISSOR_TEST                   0x0C11
CONSTANT: GL_SCISSOR_BOX                    0x0C10

! Pixel Mode / Transfer inline
CONSTANT: GL_MAP_COLOR                      0x0D10
CONSTANT: GL_MAP_STENCIL                    0x0D11
CONSTANT: GL_INDEX_SHIFT                    0x0D12
CONSTANT: GL_INDEX_OFFSET                   0x0D13
CONSTANT: GL_RED_SCALE                      0x0D14
CONSTANT: GL_RED_BIAS                       0x0D15
CONSTANT: GL_GREEN_SCALE                    0x0D18
CONSTANT: GL_GREEN_BIAS                     0x0D19
CONSTANT: GL_BLUE_SCALE                     0x0D1A
CONSTANT: GL_BLUE_BIAS                      0x0D1B
CONSTANT: GL_ALPHA_SCALE                    0x0D1C
CONSTANT: GL_ALPHA_BIAS                     0x0D1D
CONSTANT: GL_DEPTH_SCALE                    0x0D1E
CONSTANT: GL_DEPTH_BIAS                     0x0D1F
CONSTANT: GL_PIXEL_MAP_S_TO_S_SIZE          0x0CB1
CONSTANT: GL_PIXEL_MAP_I_TO_I_SIZE          0x0CB0
CONSTANT: GL_PIXEL_MAP_I_TO_R_SIZE          0x0CB2
CONSTANT: GL_PIXEL_MAP_I_TO_G_SIZE          0x0CB3
CONSTANT: GL_PIXEL_MAP_I_TO_B_SIZE          0x0CB4
CONSTANT: GL_PIXEL_MAP_I_TO_A_SIZE          0x0CB5
CONSTANT: GL_PIXEL_MAP_R_TO_R_SIZE          0x0CB6
CONSTANT: GL_PIXEL_MAP_G_TO_G_SIZE          0x0CB7
CONSTANT: GL_PIXEL_MAP_B_TO_B_SIZE          0x0CB8
CONSTANT: GL_PIXEL_MAP_A_TO_A_SIZE          0x0CB9
CONSTANT: GL_PIXEL_MAP_S_TO_S               0x0C71
CONSTANT: GL_PIXEL_MAP_I_TO_I               0x0C70
CONSTANT: GL_PIXEL_MAP_I_TO_R               0x0C72
CONSTANT: GL_PIXEL_MAP_I_TO_G               0x0C73
CONSTANT: GL_PIXEL_MAP_I_TO_B               0x0C74
CONSTANT: GL_PIXEL_MAP_I_TO_A               0x0C75
CONSTANT: GL_PIXEL_MAP_R_TO_R               0x0C76
CONSTANT: GL_PIXEL_MAP_G_TO_G               0x0C77
CONSTANT: GL_PIXEL_MAP_B_TO_B               0x0C78
CONSTANT: GL_PIXEL_MAP_A_TO_A               0x0C79
CONSTANT: GL_PACK_ALIGNMENT                 0x0D05
CONSTANT: GL_PACK_LSB_FIRST                 0x0D01
CONSTANT: GL_PACK_ROW_LENGTH                0x0D02
CONSTANT: GL_PACK_SKIP_PIXELS               0x0D04
CONSTANT: GL_PACK_SKIP_ROWS                 0x0D03
CONSTANT: GL_PACK_SWAP_BYTES                0x0D00
CONSTANT: GL_UNPACK_ALIGNMENT               0x0CF5
CONSTANT: GL_UNPACK_LSB_FIRST               0x0CF1
CONSTANT: GL_UNPACK_ROW_LENGTH              0x0CF2
CONSTANT: GL_UNPACK_SKIP_PIXELS             0x0CF4
CONSTANT: GL_UNPACK_SKIP_ROWS               0x0CF3
CONSTANT: GL_UNPACK_SWAP_BYTES              0x0CF0
CONSTANT: GL_ZOOM_X                         0x0D16
CONSTANT: GL_ZOOM_Y                         0x0D17

! Texture mapping inline
CONSTANT: GL_TEXTURE_ENV                    0x2300
CONSTANT: GL_TEXTURE_ENV_MODE               0x2200
CONSTANT: GL_TEXTURE_1D                     0x0DE0
CONSTANT: GL_TEXTURE_2D                     0x0DE1
CONSTANT: GL_TEXTURE_WRAP_S                 0x2802
CONSTANT: GL_TEXTURE_WRAP_T                 0x2803
CONSTANT: GL_TEXTURE_MAG_FILTER             0x2800
CONSTANT: GL_TEXTURE_MIN_FILTER             0x2801
CONSTANT: GL_TEXTURE_ENV_COLOR              0x2201
CONSTANT: GL_TEXTURE_GEN_S                  0x0C60
CONSTANT: GL_TEXTURE_GEN_T                  0x0C61
CONSTANT: GL_TEXTURE_GEN_MODE               0x2500
CONSTANT: GL_TEXTURE_BORDER_COLOR           0x1004
CONSTANT: GL_TEXTURE_WIDTH                  0x1000
CONSTANT: GL_TEXTURE_HEIGHT                 0x1001
CONSTANT: GL_TEXTURE_BORDER                 0x1005
CONSTANT: GL_TEXTURE_COMPONENTS             0x1003
CONSTANT: GL_TEXTURE_RED_SIZE               0x805C
CONSTANT: GL_TEXTURE_GREEN_SIZE             0x805D
CONSTANT: GL_TEXTURE_BLUE_SIZE              0x805E
CONSTANT: GL_TEXTURE_ALPHA_SIZE             0x805F
CONSTANT: GL_TEXTURE_LUMINANCE_SIZE         0x8060
CONSTANT: GL_TEXTURE_INTENSITY_SIZE         0x8061
CONSTANT: GL_NEAREST_MIPMAP_NEAREST         0x2700
CONSTANT: GL_NEAREST_MIPMAP_LINEAR          0x2702
CONSTANT: GL_LINEAR_MIPMAP_NEAREST          0x2701
CONSTANT: GL_LINEAR_MIPMAP_LINEAR           0x2703
CONSTANT: GL_OBJECT_LINEAR                  0x2401
CONSTANT: GL_OBJECT_PLANE                   0x2501
CONSTANT: GL_EYE_LINEAR                     0x2400
CONSTANT: GL_EYE_PLANE                      0x2502
CONSTANT: GL_SPHERE_MAP                     0x2402
CONSTANT: GL_DECAL                          0x2101
CONSTANT: GL_MODULATE                       0x2100
CONSTANT: GL_NEAREST                        0x2600
CONSTANT: GL_REPEAT                         0x2901
CONSTANT: GL_CLAMP                          0x2900
CONSTANT: GL_S                              0x2000
CONSTANT: GL_T                              0x2001
CONSTANT: GL_R                              0x2002
CONSTANT: GL_Q                              0x2003
CONSTANT: GL_TEXTURE_GEN_R                  0x0C62
CONSTANT: GL_TEXTURE_GEN_Q                  0x0C63

! Utility inline
CONSTANT: GL_VENDOR                         0x1F00
CONSTANT: GL_RENDERER                       0x1F01
CONSTANT: GL_VERSION                        0x1F02
CONSTANT: GL_EXTENSIONS                     0x1F03

! Errors inline
CONSTANT: GL_NO_ERROR                       0x0
CONSTANT: GL_INVALID_VALUE                  0x0501
CONSTANT: GL_INVALID_ENUM                   0x0500
CONSTANT: GL_INVALID_OPERATION              0x0502
CONSTANT: GL_STACK_OVERFLOW                 0x0503
CONSTANT: GL_STACK_UNDERFLOW                0x0504
CONSTANT: GL_OUT_OF_MEMORY                  0x0505

! glPush/PopAttrib bits
CONSTANT: GL_CURRENT_BIT                    0x00000001
CONSTANT: GL_POINT_BIT                      0x00000002
CONSTANT: GL_LINE_BIT                       0x00000004
CONSTANT: GL_POLYGON_BIT                    0x00000008
CONSTANT: GL_POLYGON_STIPPLE_BIT            0x00000010
CONSTANT: GL_PIXEL_MODE_BIT                 0x00000020
CONSTANT: GL_LIGHTING_BIT                   0x00000040
CONSTANT: GL_FOG_BIT                        0x00000080
CONSTANT: GL_DEPTH_BUFFER_BIT               0x00000100
CONSTANT: GL_ACCUM_BUFFER_BIT               0x00000200
CONSTANT: GL_STENCIL_BUFFER_BIT             0x00000400
CONSTANT: GL_VIEWPORT_BIT                   0x00000800
CONSTANT: GL_TRANSFORM_BIT                  0x00001000
CONSTANT: GL_ENABLE_BIT                     0x00002000
CONSTANT: GL_COLOR_BUFFER_BIT               0x00004000
CONSTANT: GL_HINT_BIT                       0x00008000
CONSTANT: GL_EVAL_BIT                       0x00010000
CONSTANT: GL_LIST_BIT                       0x00020000
CONSTANT: GL_TEXTURE_BIT                    0x00040000
CONSTANT: GL_SCISSOR_BIT                    0x00080000
CONSTANT: GL_ALL_ATTRIB_BITS                0x000FFFFF

! OpenGL 1.1
CONSTANT: GL_PROXY_TEXTURE_1D               0x8063
CONSTANT: GL_PROXY_TEXTURE_2D               0x8064
CONSTANT: GL_TEXTURE_PRIORITY               0x8066
CONSTANT: GL_TEXTURE_RESIDENT               0x8067
CONSTANT: GL_TEXTURE_BINDING_1D             0x8068
CONSTANT: GL_TEXTURE_BINDING_2D             0x8069
CONSTANT: GL_TEXTURE_INTERNAL_FORMAT        0x1003
CONSTANT: GL_ALPHA4                         0x803B
CONSTANT: GL_ALPHA8                         0x803C
CONSTANT: GL_ALPHA12                        0x803D
CONSTANT: GL_ALPHA16                        0x803E
CONSTANT: GL_LUMINANCE4                     0x803F
CONSTANT: GL_LUMINANCE8                     0x8040
CONSTANT: GL_LUMINANCE12                    0x8041
CONSTANT: GL_LUMINANCE16                    0x8042
CONSTANT: GL_LUMINANCE4_ALPHA4              0x8043
CONSTANT: GL_LUMINANCE6_ALPHA2              0x8044
CONSTANT: GL_LUMINANCE8_ALPHA8              0x8045
CONSTANT: GL_LUMINANCE12_ALPHA4             0x8046
CONSTANT: GL_LUMINANCE12_ALPHA12            0x8047
CONSTANT: GL_LUMINANCE16_ALPHA16            0x8048
CONSTANT: GL_INTENSITY                      0x8049
CONSTANT: GL_INTENSITY4                     0x804A
CONSTANT: GL_INTENSITY8                     0x804B
CONSTANT: GL_INTENSITY12                    0x804C
CONSTANT: GL_INTENSITY16                    0x804D
CONSTANT: GL_R3_G3_B2                       0x2A10
CONSTANT: GL_RGB4                           0x804F
CONSTANT: GL_RGB5                           0x8050
CONSTANT: GL_RGB8                           0x8051
CONSTANT: GL_RGB10                          0x8052
CONSTANT: GL_RGB12                          0x8053
CONSTANT: GL_RGB16                          0x8054
CONSTANT: GL_RGBA2                          0x8055
CONSTANT: GL_RGBA4                          0x8056
CONSTANT: GL_RGB5_A1                        0x8057
CONSTANT: GL_RGBA8                          0x8058
CONSTANT: GL_RGB10_A2                       0x8059
CONSTANT: GL_RGBA12                         0x805A
CONSTANT: GL_RGBA16                         0x805B
CONSTANT: GL_CLIENT_PIXEL_STORE_BIT         0x00000001
CONSTANT: GL_CLIENT_VERTEX_ARRAY_BIT        0x00000002
CONSTANT: GL_ALL_CLIENT_ATTRIB_BITS         0xFFFFFFFF
CONSTANT: GL_CLIENT_ALL_ATTRIB_BITS         0xFFFFFFFF

LIBRARY: gl

<<
os linux? [
    "gl" "libGL.so.1" cdecl add-library
] when
>>

! Miscellaneous

FUNCTION: void glClearIndex ( GLfloat c )
FUNCTION: void glClearColor ( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha )
FUNCTION: void glClear ( GLbitfield mask )
FUNCTION: void glIndexMask ( GLuint mask )
FUNCTION: void glColorMask ( GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha )
FUNCTION: void glAlphaFunc ( GLenum func, GLclampf ref )
FUNCTION: void glBlendFunc ( GLenum sfactor, GLenum dfactor )
FUNCTION: void glLogicOp ( GLenum opcode )
FUNCTION: void glCullFace ( GLenum mode )
FUNCTION: void glFrontFace ( GLenum mode )
FUNCTION: void glPointSize ( GLfloat size )
FUNCTION: void glLineWidth ( GLfloat width )
FUNCTION: void glLineStipple ( GLint factor, GLushort pattern )
FUNCTION: void glPolygonMode ( GLenum face, GLenum mode )
FUNCTION: void glPolygonOffset ( GLfloat factor, GLfloat units )
FUNCTION: void glPolygonStipple ( GLubyte* mask )
FUNCTION: void glGetPolygonStipple ( GLubyte* mask )
FUNCTION: void glEdgeFlag ( GLboolean flag )
FUNCTION: void glEdgeFlagv ( GLboolean* flag )
FUNCTION: void glScissor ( GLint x, GLint y, GLsizei width, GLsizei height )
FUNCTION: void glClipPlane ( GLenum plane, GLdouble* equation )
FUNCTION: void glGetClipPlane ( GLenum plane, GLdouble* equation )
FUNCTION: void glDrawBuffer ( GLenum mode )
FUNCTION: void glReadBuffer ( GLenum mode )
FUNCTION: void glEnable ( GLenum cap )
FUNCTION: void glDisable ( GLenum cap )
FUNCTION: GLboolean glIsEnabled ( GLenum cap )

FUNCTION: void glEnableClientState ( GLenum cap )
FUNCTION: void glDisableClientState ( GLenum cap )
FUNCTION: void glGetBooleanv ( GLenum pname, GLboolean* params )
FUNCTION: void glGetDoublev ( GLenum pname, GLdouble* params )
FUNCTION: void glGetFloatv ( GLenum pname, GLfloat* params )
FUNCTION: void glGetIntegerv ( GLenum pname, GLint* params )

FUNCTION: void glPushAttrib ( GLbitfield mask )
FUNCTION: void glPopAttrib ( )

FUNCTION: void glPushClientAttrib ( GLbitfield mask )
FUNCTION: void glPopClientAttrib ( )

FUNCTION: GLint glRenderMode ( GLenum mode )
FUNCTION: GLenum glGetError ( )
FUNCTION: GLstring glGetString ( GLenum name )
FUNCTION: void glFinish ( )
FUNCTION: void glFlush ( )
FUNCTION: void glHint ( GLenum target, GLenum mode )

FUNCTION: void glClearDepth ( GLclampd depth )
FUNCTION: void glDepthFunc ( GLenum func )
FUNCTION: void glDepthMask ( GLboolean flag )
FUNCTION: void glDepthRange ( GLclampd near_val, GLclampd far_val )

FUNCTION: void glClearAccum ( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha )
FUNCTION: void glAccum ( GLenum op, GLfloat value )

FUNCTION: void glMatrixMode ( GLenum mode )
FUNCTION: void glOrtho ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top,
                         GLdouble near_val, GLdouble far_val )
FUNCTION: void glFrustum ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top,
                           GLdouble near_val, GLdouble far_val )
FUNCTION: void glViewport ( GLint x, GLint y, GLsizei width, GLsizei height )
FUNCTION: void glPushMatrix ( )
FUNCTION: void glPopMatrix ( )
FUNCTION: void glLoadIdentity ( )
FUNCTION: void glLoadMatrixd ( GLdouble* m )
FUNCTION: void glLoadMatrixf ( GLfloat* m )
FUNCTION: void glMultMatrixd ( GLdouble* m )
FUNCTION: void glMultMatrixf ( GLfloat* m )
FUNCTION: void glRotated ( GLdouble angle, GLdouble x, GLdouble y, GLdouble z )
FUNCTION: void glRotatef ( GLfloat angle, GLfloat x, GLfloat y, GLfloat z )
FUNCTION: void glScaled ( GLdouble x, GLdouble y, GLdouble z )
FUNCTION: void glScalef ( GLfloat x, GLfloat y, GLfloat z )
FUNCTION: void glTranslated ( GLdouble x, GLdouble y, GLdouble z )
FUNCTION: void glTranslatef ( GLfloat x, GLfloat y, GLfloat z )


FUNCTION: GLboolean glIsList ( GLuint list )
FUNCTION: void glDeleteLists ( GLuint list, GLsizei range )
FUNCTION: GLuint glGenLists ( GLsizei range )
FUNCTION: void glNewList ( GLuint list, GLenum mode )
FUNCTION: void glEndList ( )
FUNCTION: void glCallList ( GLuint list )
FUNCTION: void glCallLists ( GLsizei n, GLenum type, GLvoid* lists )
FUNCTION: void glListBase ( GLuint base )

FUNCTION: void glBegin ( GLenum mode )
FUNCTION: void glEnd ( )

FUNCTION: void glVertex2d ( GLdouble x, GLdouble y )
FUNCTION: void glVertex2f ( GLfloat x, GLfloat y )
FUNCTION: void glVertex2i ( GLint x, GLint y )
FUNCTION: void glVertex2s ( GLshort x, GLshort y )

FUNCTION: void glVertex3d ( GLdouble x, GLdouble y, GLdouble z )
FUNCTION: void glVertex3f ( GLfloat x, GLfloat y, GLfloat z )
FUNCTION: void glVertex3i ( GLint x, GLint y, GLint z )
FUNCTION: void glVertex3s ( GLshort x, GLshort y, GLshort z )

FUNCTION: void glVertex4d ( GLdouble x, GLdouble y, GLdouble z, GLdouble w )
FUNCTION: void glVertex4f ( GLfloat x, GLfloat y, GLfloat z, GLfloat w )
FUNCTION: void glVertex4i ( GLint x, GLint y, GLint z, GLint w )
FUNCTION: void glVertex4s ( GLshort x, GLshort y, GLshort z, GLshort w )

FUNCTION: void glVertex2dv ( GLdouble* v )
FUNCTION: void glVertex2fv ( GLfloat* v )
FUNCTION: void glVertex2iv ( GLint* v )
FUNCTION: void glVertex2sv ( GLshort* v )

FUNCTION: void glVertex3dv ( GLdouble* v )
FUNCTION: void glVertex3fv ( GLfloat* v )
FUNCTION: void glVertex3iv ( GLint* v )
FUNCTION: void glVertex3sv ( GLshort* v )

FUNCTION: void glVertex4dv ( GLdouble* v )
FUNCTION: void glVertex4fv ( GLfloat* v )
FUNCTION: void glVertex4iv ( GLint* v )
FUNCTION: void glVertex4sv ( GLshort* v )

FUNCTION: void glNormal3b ( GLbyte nx, GLbyte ny, GLbyte nz )
FUNCTION: void glNormal3d ( GLdouble nx, GLdouble ny, GLdouble nz )
FUNCTION: void glNormal3f ( GLfloat nx, GLfloat ny, GLfloat nz )
FUNCTION: void glNormal3i ( GLint nx, GLint ny, GLint nz )
FUNCTION: void glNormal3s ( GLshort nx, GLshort ny, GLshort nz )

FUNCTION: void glNormal3bv ( GLbyte* v )
FUNCTION: void glNormal3dv ( GLdouble* v )
FUNCTION: void glNormal3fv ( GLfloat* v )
FUNCTION: void glNormal3iv ( GLint* v )
FUNCTION: void glNormal3sv ( GLshort* v )

FUNCTION: void glIndexd ( GLdouble c )
FUNCTION: void glIndexf ( GLfloat c )
FUNCTION: void glIndexi ( GLint c )
FUNCTION: void glIndexs ( GLshort c )
FUNCTION: void glIndexub ( GLubyte c )

FUNCTION: void glIndexdv ( GLdouble* c )
FUNCTION: void glIndexfv ( GLfloat* c )
FUNCTION: void glIndexiv ( GLint* c )
FUNCTION: void glIndexsv ( GLshort* c )
FUNCTION: void glIndexubv ( GLubyte* c )

FUNCTION: void glColor3b ( GLbyte red, GLbyte green, GLbyte blue )
FUNCTION: void glColor3d ( GLdouble red, GLdouble green, GLdouble blue )
FUNCTION: void glColor3f ( GLfloat red, GLfloat green, GLfloat blue )
FUNCTION: void glColor3i ( GLint red, GLint green, GLint blue )
FUNCTION: void glColor3s ( GLshort red, GLshort green, GLshort blue )
FUNCTION: void glColor3ub ( GLubyte red, GLubyte green, GLubyte blue )
FUNCTION: void glColor3ui ( GLuint red, GLuint green, GLuint blue )
FUNCTION: void glColor3us ( GLushort red, GLushort green, GLushort blue )

FUNCTION: void glColor4b ( GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha )
FUNCTION: void glColor4d ( GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha )
FUNCTION: void glColor4f ( GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha )
FUNCTION: void glColor4i ( GLint red, GLint green, GLint blue, GLint alpha )
FUNCTION: void glColor4s ( GLshort red, GLshort green, GLshort blue, GLshort alpha )
FUNCTION: void glColor4ub ( GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha )
FUNCTION: void glColor4ui ( GLuint red, GLuint green, GLuint blue, GLuint alpha )
FUNCTION: void glColor4us ( GLushort red, GLushort green, GLushort blue, GLushort alpha )

FUNCTION: void glColor3bv ( GLbyte* v )
FUNCTION: void glColor3dv ( GLdouble* v )
FUNCTION: void glColor3fv ( GLfloat* v )
FUNCTION: void glColor3iv ( GLint* v )
FUNCTION: void glColor3sv ( GLshort* v )
FUNCTION: void glColor3ubv ( GLubyte* v )
FUNCTION: void glColor3uiv ( GLuint* v )
FUNCTION: void glColor3usv ( GLushort* v )

FUNCTION: void glColor4bv ( GLbyte* v )
FUNCTION: void glColor4dv ( GLdouble* v )
FUNCTION: void glColor4fv ( GLfloat* v )
FUNCTION: void glColor4iv ( GLint* v )
FUNCTION: void glColor4sv ( GLshort* v )
FUNCTION: void glColor4ubv ( GLubyte* v )
FUNCTION: void glColor4uiv ( GLuint* v )
FUNCTION: void glColor4usv ( GLushort* v )


FUNCTION: void glTexCoord1d ( GLdouble s )
FUNCTION: void glTexCoord1f ( GLfloat s )
FUNCTION: void glTexCoord1i ( GLint s )
FUNCTION: void glTexCoord1s ( GLshort s )

FUNCTION: void glTexCoord2d ( GLdouble s, GLdouble t )
FUNCTION: void glTexCoord2f ( GLfloat s, GLfloat t )
FUNCTION: void glTexCoord2i ( GLint s, GLint t )
FUNCTION: void glTexCoord2s ( GLshort s, GLshort t )

FUNCTION: void glTexCoord3d ( GLdouble s, GLdouble t, GLdouble r )
FUNCTION: void glTexCoord3f ( GLfloat s, GLfloat t, GLfloat r )
FUNCTION: void glTexCoord3i ( GLint s, GLint t, GLint r )
FUNCTION: void glTexCoord3s ( GLshort s, GLshort t, GLshort r )

FUNCTION: void glTexCoord4d ( GLdouble s, GLdouble t, GLdouble r, GLdouble q )
FUNCTION: void glTexCoord4f ( GLfloat s, GLfloat t, GLfloat r, GLfloat q )
FUNCTION: void glTexCoord4i ( GLint s, GLint t, GLint r, GLint q )
FUNCTION: void glTexCoord4s ( GLshort s, GLshort t, GLshort r, GLshort q )

FUNCTION: void glTexCoord1dv ( GLdouble* v )
FUNCTION: void glTexCoord1fv ( GLfloat* v )
FUNCTION: void glTexCoord1iv ( GLint* v )
FUNCTION: void glTexCoord1sv ( GLshort* v )

FUNCTION: void glTexCoord2dv ( GLdouble* v )
FUNCTION: void glTexCoord2fv ( GLfloat* v )
FUNCTION: void glTexCoord2iv ( GLint* v )
FUNCTION: void glTexCoord2sv ( GLshort* v )

FUNCTION: void glTexCoord3dv ( GLdouble* v )
FUNCTION: void glTexCoord3fv ( GLfloat* v )
FUNCTION: void glTexCoord3iv ( GLint* v )
FUNCTION: void glTexCoord3sv ( GLshort* v )

FUNCTION: void glTexCoord4dv ( GLdouble* v )
FUNCTION: void glTexCoord4fv ( GLfloat* v )
FUNCTION: void glTexCoord4iv ( GLint* v )
FUNCTION: void glTexCoord4sv ( GLshort* v )

FUNCTION: void glRasterPos2d ( GLdouble x, GLdouble y )
FUNCTION: void glRasterPos2f ( GLfloat x, GLfloat y )
FUNCTION: void glRasterPos2i ( GLint x, GLint y )
FUNCTION: void glRasterPos2s ( GLshort x, GLshort y )

FUNCTION: void glRasterPos3d ( GLdouble x, GLdouble y, GLdouble z )
FUNCTION: void glRasterPos3f ( GLfloat x, GLfloat y, GLfloat z )
FUNCTION: void glRasterPos3i ( GLint x, GLint y, GLint z )
FUNCTION: void glRasterPos3s ( GLshort x, GLshort y, GLshort z )

FUNCTION: void glRasterPos4d ( GLdouble x, GLdouble y, GLdouble z, GLdouble w )
FUNCTION: void glRasterPos4f ( GLfloat x, GLfloat y, GLfloat z, GLfloat w )
FUNCTION: void glRasterPos4i ( GLint x, GLint y, GLint z, GLint w )
FUNCTION: void glRasterPos4s ( GLshort x, GLshort y, GLshort z, GLshort w )

FUNCTION: void glRasterPos2dv ( GLdouble* v )
FUNCTION: void glRasterPos2fv ( GLfloat* v )
FUNCTION: void glRasterPos2iv ( GLint* v )
FUNCTION: void glRasterPos2sv ( GLshort* v )

FUNCTION: void glRasterPos3dv ( GLdouble* v )
FUNCTION: void glRasterPos3fv ( GLfloat* v )
FUNCTION: void glRasterPos3iv ( GLint* v )
FUNCTION: void glRasterPos3sv ( GLshort* v )

FUNCTION: void glRasterPos4dv ( GLdouble* v )
FUNCTION: void glRasterPos4fv ( GLfloat* v )
FUNCTION: void glRasterPos4iv ( GLint* v )
FUNCTION: void glRasterPos4sv ( GLshort* v )


FUNCTION: void glRectd ( GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2 )
FUNCTION: void glRectf ( GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2 )
FUNCTION: void glRecti ( GLint x1, GLint y1, GLint x2, GLint y2 )
FUNCTION: void glRects ( GLshort x1, GLshort y1, GLshort x2, GLshort y2 )

FUNCTION: void glRectdv ( GLdouble* v1, GLdouble* v2 )
FUNCTION: void glRectfv ( GLfloat* v1, GLfloat* v2 )
FUNCTION: void glRectiv ( GLint* v1, GLint* v2 )
FUNCTION: void glRectsv ( GLshort* v1, GLshort* v2 )


! Vertex Arrays (1.1)

FUNCTION: void glVertexPointer ( GLint size, GLenum type, GLsizei stride, GLvoid* ptr )
FUNCTION: void glNormalPointer ( GLenum type, GLsizei stride, GLvoid* ptr )
FUNCTION: void glColorPointer ( GLint size, GLenum type, GLsizei stride, GLvoid* ptr )
FUNCTION: void glIndexPointer ( GLenum type, GLsizei stride, GLvoid* ptr )
FUNCTION: void glTexCoordPointer ( GLint size, GLenum type, GLsizei stride, GLvoid* ptr )
FUNCTION: void glEdgeFlagPointer ( GLsizei stride, GLvoid* ptr )

! [09:39] (slava) NULL <void*>
! [09:39] (slava) then keep that object
! [09:39] (slava) when you want to get the value stored there,* void*
! [09:39] (slava) which returns an alien
FUNCTION: void glGetPointerv ( GLenum pname, GLvoid** params )

FUNCTION: void glArrayElement ( GLint i )
FUNCTION: void glDrawArrays ( GLenum mode, GLint first, GLsizei count )
FUNCTION: void glDrawElements ( GLenum mode, GLsizei count, GLenum type, GLvoid* indices )
FUNCTION: void glInterleavedArrays ( GLenum format, GLsizei stride, GLvoid* pointer )

! Lighting

FUNCTION: void glShadeModel ( GLenum mode )

FUNCTION: void glLightf ( GLenum light, GLenum pname, GLfloat param )
FUNCTION: void glLighti ( GLenum light, GLenum pname, GLint param )
FUNCTION: void glLightfv ( GLenum light, GLenum pname, GLfloat* params )
FUNCTION: void glLightiv ( GLenum light, GLenum pname, GLint* params )
FUNCTION: void glGetLightfv ( GLenum light, GLenum pname, GLfloat* params )
FUNCTION: void glGetLightiv ( GLenum light, GLenum pname, GLint* params )

FUNCTION: void glLightModelf ( GLenum pname, GLfloat param )
FUNCTION: void glLightModeli ( GLenum pname, GLint param )
FUNCTION: void glLightModelfv ( GLenum pname, GLfloat* params )
FUNCTION: void glLightModeliv ( GLenum pname, GLint* params )

FUNCTION: void glMaterialf ( GLenum face, GLenum pname, GLfloat param )
FUNCTION: void glMateriali ( GLenum face, GLenum pname, GLint param )
FUNCTION: void glMaterialfv ( GLenum face, GLenum pname, GLfloat* params )
FUNCTION: void glMaterialiv ( GLenum face, GLenum pname, GLint* params )

FUNCTION: void glGetMaterialfv ( GLenum face, GLenum pname, GLfloat* params )
FUNCTION: void glGetMaterialiv ( GLenum face, GLenum pname, GLint* params )

FUNCTION: void glColorMaterial ( GLenum face, GLenum mode )


! Raster functions

FUNCTION: void glPixelZoom ( GLfloat xfactor, GLfloat yfactor )

FUNCTION: void glPixelStoref ( GLenum pname, GLfloat param )
FUNCTION: void glPixelStorei ( GLenum pname, GLint param )

FUNCTION: void glPixelTransferf ( GLenum pname, GLfloat param )
FUNCTION: void glPixelTransferi ( GLenum pname, GLint param )

FUNCTION: void glPixelMapfv ( GLenum map, GLsizei mapsize, GLfloat* values )
FUNCTION: void glPixelMapuiv ( GLenum map, GLsizei mapsize, GLuint* values )
FUNCTION: void glPixelMapusv ( GLenum map, GLsizei mapsize, GLushort* values )

FUNCTION: void glGetPixelMapfv ( GLenum map, GLfloat* values )
FUNCTION: void glGetPixelMapuiv ( GLenum map, GLuint* values )
FUNCTION: void glGetPixelMapusv ( GLenum map, GLushort* values )

FUNCTION: void glBitmap ( GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig,
                          GLfloat xmove, GLfloat ymove, GLubyte* bitmap )

FUNCTION: void glReadPixels ( GLint x, GLint y, GLsizei width, GLsizei height,
                              GLenum format, GLenum type, GLvoid* pixels )

FUNCTION: void glDrawPixels ( GLsizei width, GLsizei height, GLenum format,
                              GLenum type, GLvoid* pixels )
FUNCTION: void glCopyPixels ( GLint x, GLint y, GLsizei width, GLsizei height, GLenum type )

! Stenciling
FUNCTION: void glStencilFunc ( GLenum func, GLint ref, GLuint mask )
FUNCTION: void glStencilMask ( GLuint mask )
FUNCTION: void glStencilOp ( GLenum fail, GLenum zfail, GLenum zpass )
FUNCTION: void glClearStencil ( GLint s )


! Texture mapping

FUNCTION: void glTexGend ( GLenum coord, GLenum pname, GLdouble param )
FUNCTION: void glTexGenf ( GLenum coord, GLenum pname, GLfloat param )
FUNCTION: void glTexGeni ( GLenum coord, GLenum pname, GLint param )

FUNCTION: void glTexGendv ( GLenum coord, GLenum pname, GLdouble* params )
FUNCTION: void glTexGenfv ( GLenum coord, GLenum pname, GLfloat* params )
FUNCTION: void glTexGeniv ( GLenum coord, GLenum pname, GLint* params )

FUNCTION: void glGetTexGendv ( GLenum coord, GLenum pname, GLdouble* params )
FUNCTION: void glGetTexGenfv ( GLenum coord, GLenum pname, GLfloat* params )
FUNCTION: void glGetTexGeniv ( GLenum coord, GLenum pname, GLint* params )

FUNCTION: void glTexEnvf ( GLenum target, GLenum pname, GLfloat param )
FUNCTION: void glTexEnvi ( GLenum target, GLenum pname, GLint param )
FUNCTION: void glTexEnvfv ( GLenum target, GLenum pname, GLfloat* params )
FUNCTION: void glTexEnviv ( GLenum target, GLenum pname, GLint* params )

FUNCTION: void glGetTexEnvfv ( GLenum target, GLenum pname, GLfloat* params )
FUNCTION: void glGetTexEnviv ( GLenum target, GLenum pname, GLint* params )

FUNCTION: void glTexParameterf ( GLenum target, GLenum pname, GLfloat param )
FUNCTION: void glTexParameteri ( GLenum target, GLenum pname, GLint param )

FUNCTION: void glTexParameterfv ( GLenum target, GLenum pname, GLfloat* params )
FUNCTION: void glTexParameteriv ( GLenum target, GLenum pname, GLint* params )

FUNCTION: void glGetTexParameterfv ( GLenum target, GLenum pname, GLfloat* params )
FUNCTION: void glGetTexParameteriv ( GLenum target, GLenum pname, GLint* params )

FUNCTION: void glGetTexLevelParameterfv ( GLenum target, GLint level,
                                          GLenum pname, GLfloat* params )
FUNCTION: void glGetTexLevelParameteriv ( GLenum target, GLint level,
                                          GLenum pname, GLint* params )

FUNCTION: void glTexImage1D ( GLenum target, GLint level, GLint internalFormat, GLsizei width,
                              GLint border, GLenum format, GLenum type, GLvoid* pixels )

FUNCTION: void glTexImage2D ( GLenum target, GLint level, GLint internalFormat,
                              GLsizei width, GLsizei height, GLint border,
                              GLenum format, GLenum type, GLvoid* pixels )

FUNCTION: void glGetTexImage ( GLenum target, GLint level, GLenum format,
                               GLenum type, GLvoid* pixels )


! 1.1 functions

FUNCTION: void glGenTextures ( GLsizei n, GLuint* textures )

FUNCTION: void glDeleteTextures ( GLsizei n, GLuint* textures )

FUNCTION: void glBindTexture ( GLenum target, GLuint texture )

FUNCTION: void glPrioritizeTextures ( GLsizei n, GLuint* textures, GLclampf* priorities )

FUNCTION: GLboolean glAreTexturesResident ( GLsizei n, GLuint* textures, GLboolean* residences )

FUNCTION: GLboolean glIsTexture ( GLuint texture )

FUNCTION: void glTexSubImage1D ( GLenum target, GLint level, GLint xoffset, GLsizei width,
                                 GLenum format, GLenum type, GLvoid* pixels )

FUNCTION: void glTexSubImage2D ( GLenum target, GLint level, GLint xoffset, GLint yoffset,
                                 GLsizei width, GLsizei height, GLenum format,
                                 GLenum type, GLvoid* pixels )

FUNCTION: void glCopyTexImage1D ( GLenum target, GLint level, GLenum internalformat,
                                  GLint x, GLint y, GLsizei width, GLint border )

FUNCTION: void glCopyTexImage2D ( GLenum target, GLint level, GLenum internalformat,
                                  GLint x, GLint y,
                                  GLsizei width, GLsizei height, GLint border )

FUNCTION: void glCopyTexSubImage1D ( GLenum target, GLint level, GLint xoffset,
                                     GLint x, GLint y, GLsizei width )

FUNCTION: void glCopyTexSubImage2D ( GLenum target, GLint level, GLint xoffset, GLint yoffset,
                                     GLint x, GLint y, GLsizei width, GLsizei height )


! Evaluators

FUNCTION: void glMap1d ( GLenum target, GLdouble u1, GLdouble u2,
                         GLint stride, GLint order, GLdouble* points )
FUNCTION: void glMap1f ( GLenum target, GLfloat u1, GLfloat u2,
                         GLint stride, GLint order, GLfloat* points )

FUNCTION: void glMap2d ( GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder,
                         GLdouble v1, GLdouble v2, GLint vstride, GLint vorder,
                         GLdouble* points )
FUNCTION: void glMap2f ( GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder,
                         GLfloat v1, GLfloat v2, GLint vstride, GLint vorder,
                         GLfloat* points )

FUNCTION: void glGetMapdv ( GLenum target, GLenum query, GLdouble* v )
FUNCTION: void glGetMapfv ( GLenum target, GLenum query, GLfloat* v )
FUNCTION: void glGetMapiv ( GLenum target, GLenum query, GLint* v )

FUNCTION: void glEvalCoord1d ( GLdouble u )
FUNCTION: void glEvalCoord1f ( GLfloat u )

FUNCTION: void glEvalCoord1dv ( GLdouble* u )
FUNCTION: void glEvalCoord1fv ( GLfloat* u )

FUNCTION: void glEvalCoord2d ( GLdouble u, GLdouble v )
FUNCTION: void glEvalCoord2f ( GLfloat u, GLfloat v )

FUNCTION: void glEvalCoord2dv ( GLdouble* u )
FUNCTION: void glEvalCoord2fv ( GLfloat* u )

FUNCTION: void glMapGrid1d ( GLint un, GLdouble u1, GLdouble u2 )
FUNCTION: void glMapGrid1f ( GLint un, GLfloat u1, GLfloat u2 )

FUNCTION: void glMapGrid2d ( GLint un, GLdouble u1, GLdouble u2,
                             GLint vn, GLdouble v1, GLdouble v2 )
FUNCTION: void glMapGrid2f ( GLint un, GLfloat u1, GLfloat u2,
                             GLint vn, GLfloat v1, GLfloat v2 )

FUNCTION: void glEvalPoint1 ( GLint i )
FUNCTION: void glEvalPoint2 ( GLint i, GLint j )

FUNCTION: void glEvalMesh1 ( GLenum mode, GLint i1, GLint i2 )
FUNCTION: void glEvalMesh2 ( GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2 )


! Fog

FUNCTION: void glFogf ( GLenum pname, GLfloat param )
FUNCTION: void glFogi ( GLenum pname, GLint param )
FUNCTION: void glFogfv ( GLenum pname, GLfloat* params )
FUNCTION: void glFogiv ( GLenum pname, GLint* params )


! Selection and Feedback

FUNCTION: void glFeedbackBuffer ( GLsizei size, GLenum type, GLfloat* buffer )

FUNCTION: void glPassThrough ( GLfloat token )
FUNCTION: void glSelectBuffer ( GLsizei size, GLuint* buffer )
FUNCTION: void glInitNames ( )
FUNCTION: void glLoadName ( GLuint name )
FUNCTION: void glPushName ( GLuint name )
FUNCTION: void glPopName ( )

<< reset-gl-function-number-counter >>

! OpenGL 1.2

CONSTANT: GL_SMOOTH_POINT_SIZE_RANGE 0x0B12
CONSTANT: GL_SMOOTH_POINT_SIZE_GRANULARITY 0x0B13
CONSTANT: GL_SMOOTH_LINE_WIDTH_RANGE 0x0B22
CONSTANT: GL_SMOOTH_LINE_WIDTH_GRANULARITY 0x0B23
CONSTANT: GL_UNSIGNED_BYTE_3_3_2 0x8032
CONSTANT: GL_UNSIGNED_SHORT_4_4_4_4 0x8033
CONSTANT: GL_UNSIGNED_SHORT_5_5_5_1 0x8034
CONSTANT: GL_UNSIGNED_INT_8_8_8_8 0x8035
CONSTANT: GL_UNSIGNED_INT_10_10_10_2 0x8036
CONSTANT: GL_RESCALE_NORMAL 0x803A
CONSTANT: GL_TEXTURE_BINDING_3D 0x806A
CONSTANT: GL_PACK_SKIP_IMAGES 0x806B
CONSTANT: GL_PACK_IMAGE_HEIGHT 0x806C
CONSTANT: GL_UNPACK_SKIP_IMAGES 0x806D
CONSTANT: GL_UNPACK_IMAGE_HEIGHT 0x806E
CONSTANT: GL_TEXTURE_3D 0x806F
CONSTANT: GL_PROXY_TEXTURE_3D 0x8070
CONSTANT: GL_TEXTURE_DEPTH 0x8071
CONSTANT: GL_TEXTURE_WRAP_R 0x8072
CONSTANT: GL_MAX_3D_TEXTURE_SIZE 0x8073
CONSTANT: GL_BGR 0x80E0
CONSTANT: GL_BGRA 0x80E1
CONSTANT: GL_MAX_ELEMENTS_VERTICES 0x80E8
CONSTANT: GL_MAX_ELEMENTS_INDICES 0x80E9
CONSTANT: GL_CLAMP_TO_EDGE 0x812F
CONSTANT: GL_TEXTURE_MIN_LOD 0x813A
CONSTANT: GL_TEXTURE_MAX_LOD 0x813B
CONSTANT: GL_TEXTURE_BASE_LEVEL 0x813C
CONSTANT: GL_TEXTURE_MAX_LEVEL 0x813D
CONSTANT: GL_LIGHT_MODEL_COLOR_CONTROL 0x81F8
CONSTANT: GL_SINGLE_COLOR 0x81F9
CONSTANT: GL_SEPARATE_SPECULAR_COLOR 0x81FA
CONSTANT: GL_UNSIGNED_BYTE_2_3_3_REV 0x8362
CONSTANT: GL_UNSIGNED_SHORT_5_6_5 0x8363
CONSTANT: GL_UNSIGNED_SHORT_5_6_5_REV 0x8364
CONSTANT: GL_UNSIGNED_SHORT_4_4_4_4_REV 0x8365
CONSTANT: GL_UNSIGNED_SHORT_1_5_5_5_REV 0x8366
CONSTANT: GL_UNSIGNED_INT_8_8_8_8_REV 0x8367
CONSTANT: GL_UNSIGNED_INT_2_10_10_10_REV 0x8368
CONSTANT: GL_ALIASED_POINT_SIZE_RANGE 0x846D
CONSTANT: GL_ALIASED_LINE_WIDTH_RANGE 0x846E

GL-FUNCTION: void glCopyTexSubImage3D { glCopyTexSubImage3DEXT } ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height )
GL-FUNCTION: void glDrawRangeElements { glDrawRangeElementsEXT } ( GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, GLvoid* indices )
GL-FUNCTION: void glTexImage3D { glTexImage3DEXT } ( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, GLvoid* pixels )
GL-FUNCTION: void glTexSubImage3D { glTexSubImage3DEXT } ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, GLvoid* pixels )


! GL_ARB_imaging


CONSTANT: GL_CONSTANT_COLOR                 0x8001
CONSTANT: GL_ONE_MINUS_CONSTANT_COLOR       0x8002
CONSTANT: GL_CONSTANT_ALPHA                 0x8003
CONSTANT: GL_ONE_MINUS_CONSTANT_ALPHA       0x8004
CONSTANT: GL_BLEND_COLOR                    0x8005
CONSTANT: GL_FUNC_ADD                       0x8006
CONSTANT: GL_MIN                            0x8007
CONSTANT: GL_MAX                            0x8008
CONSTANT: GL_BLEND_EQUATION                 0x8009
CONSTANT: GL_FUNC_SUBTRACT                  0x800A
CONSTANT: GL_FUNC_REVERSE_SUBTRACT          0x800B


! OpenGL 1.3


CONSTANT: GL_MULTISAMPLE 0x809D
CONSTANT: GL_SAMPLE_ALPHA_TO_COVERAGE 0x809E
CONSTANT: GL_SAMPLE_ALPHA_TO_ONE 0x809F
CONSTANT: GL_SAMPLE_COVERAGE 0x80A0
CONSTANT: GL_SAMPLE_BUFFERS 0x80A8
CONSTANT: GL_SAMPLES 0x80A9
CONSTANT: GL_SAMPLE_COVERAGE_VALUE 0x80AA
CONSTANT: GL_SAMPLE_COVERAGE_INVERT 0x80AB
CONSTANT: GL_CLAMP_TO_BORDER 0x812D
CONSTANT: GL_TEXTURE0 0x84C0
CONSTANT: GL_TEXTURE1 0x84C1
CONSTANT: GL_TEXTURE2 0x84C2
CONSTANT: GL_TEXTURE3 0x84C3
CONSTANT: GL_TEXTURE4 0x84C4
CONSTANT: GL_TEXTURE5 0x84C5
CONSTANT: GL_TEXTURE6 0x84C6
CONSTANT: GL_TEXTURE7 0x84C7
CONSTANT: GL_TEXTURE8 0x84C8
CONSTANT: GL_TEXTURE9 0x84C9
CONSTANT: GL_TEXTURE10 0x84CA
CONSTANT: GL_TEXTURE11 0x84CB
CONSTANT: GL_TEXTURE12 0x84CC
CONSTANT: GL_TEXTURE13 0x84CD
CONSTANT: GL_TEXTURE14 0x84CE
CONSTANT: GL_TEXTURE15 0x84CF
CONSTANT: GL_TEXTURE16 0x84D0
CONSTANT: GL_TEXTURE17 0x84D1
CONSTANT: GL_TEXTURE18 0x84D2
CONSTANT: GL_TEXTURE19 0x84D3
CONSTANT: GL_TEXTURE20 0x84D4
CONSTANT: GL_TEXTURE21 0x84D5
CONSTANT: GL_TEXTURE22 0x84D6
CONSTANT: GL_TEXTURE23 0x84D7
CONSTANT: GL_TEXTURE24 0x84D8
CONSTANT: GL_TEXTURE25 0x84D9
CONSTANT: GL_TEXTURE26 0x84DA
CONSTANT: GL_TEXTURE27 0x84DB
CONSTANT: GL_TEXTURE28 0x84DC
CONSTANT: GL_TEXTURE29 0x84DD
CONSTANT: GL_TEXTURE30 0x84DE
CONSTANT: GL_TEXTURE31 0x84DF
CONSTANT: GL_ACTIVE_TEXTURE 0x84E0
CONSTANT: GL_CLIENT_ACTIVE_TEXTURE 0x84E1
CONSTANT: GL_MAX_TEXTURE_UNITS 0x84E2
CONSTANT: GL_TRANSPOSE_MODELVIEW_MATRIX 0x84E3
CONSTANT: GL_TRANSPOSE_PROJECTION_MATRIX 0x84E4
CONSTANT: GL_TRANSPOSE_TEXTURE_MATRIX 0x84E5
CONSTANT: GL_TRANSPOSE_COLOR_MATRIX 0x84E6
CONSTANT: GL_SUBTRACT 0x84E7
CONSTANT: GL_COMPRESSED_ALPHA 0x84E9
CONSTANT: GL_COMPRESSED_LUMINANCE 0x84EA
CONSTANT: GL_COMPRESSED_LUMINANCE_ALPHA 0x84EB
CONSTANT: GL_COMPRESSED_INTENSITY 0x84EC
CONSTANT: GL_COMPRESSED_RGB 0x84ED
CONSTANT: GL_COMPRESSED_RGBA 0x84EE
CONSTANT: GL_TEXTURE_COMPRESSION_HINT 0x84EF
CONSTANT: GL_NORMAL_MAP 0x8511
CONSTANT: GL_REFLECTION_MAP 0x8512
CONSTANT: GL_TEXTURE_CUBE_MAP 0x8513
CONSTANT: GL_TEXTURE_BINDING_CUBE_MAP 0x8514
CONSTANT: GL_TEXTURE_CUBE_MAP_POSITIVE_X 0x8515
CONSTANT: GL_TEXTURE_CUBE_MAP_NEGATIVE_X 0x8516
CONSTANT: GL_TEXTURE_CUBE_MAP_POSITIVE_Y 0x8517
CONSTANT: GL_TEXTURE_CUBE_MAP_NEGATIVE_Y 0x8518
CONSTANT: GL_TEXTURE_CUBE_MAP_POSITIVE_Z 0x8519
CONSTANT: GL_TEXTURE_CUBE_MAP_NEGATIVE_Z 0x851A
CONSTANT: GL_PROXY_TEXTURE_CUBE_MAP 0x851B
CONSTANT: GL_MAX_CUBE_MAP_TEXTURE_SIZE 0x851C
CONSTANT: GL_COMBINE 0x8570
CONSTANT: GL_COMBINE_RGB 0x8571
CONSTANT: GL_COMBINE_ALPHA 0x8572
CONSTANT: GL_RGB_SCALE 0x8573
CONSTANT: GL_ADD_SIGNED 0x8574
CONSTANT: GL_INTERPOLATE 0x8575
CONSTANT: GL_CONSTANT 0x8576
CONSTANT: GL_PRIMARY_COLOR 0x8577
CONSTANT: GL_PREVIOUS 0x8578
CONSTANT: GL_SOURCE0_RGB 0x8580
CONSTANT: GL_SOURCE1_RGB 0x8581
CONSTANT: GL_SOURCE2_RGB 0x8582
CONSTANT: GL_SOURCE0_ALPHA 0x8588
CONSTANT: GL_SOURCE1_ALPHA 0x8589
CONSTANT: GL_SOURCE2_ALPHA 0x858A
CONSTANT: GL_OPERAND0_RGB 0x8590
CONSTANT: GL_OPERAND1_RGB 0x8591
CONSTANT: GL_OPERAND2_RGB 0x8592
CONSTANT: GL_OPERAND0_ALPHA 0x8598
CONSTANT: GL_OPERAND1_ALPHA 0x8599
CONSTANT: GL_OPERAND2_ALPHA 0x859A
CONSTANT: GL_TEXTURE_COMPRESSED_IMAGE_SIZE 0x86A0
CONSTANT: GL_TEXTURE_COMPRESSED 0x86A1
CONSTANT: GL_NUM_COMPRESSED_TEXTURE_FORMATS 0x86A2
CONSTANT: GL_COMPRESSED_TEXTURE_FORMATS 0x86A3
CONSTANT: GL_DOT3_RGB 0x86AE
CONSTANT: GL_DOT3_RGBA 0x86AF
CONSTANT: GL_MULTISAMPLE_BIT 0x20000000

GL-FUNCTION: void glActiveTexture { glActiveTextureARB } ( GLenum texture )
GL-FUNCTION: void glClientActiveTexture { glClientActiveTextureARB } ( GLenum texture )
GL-FUNCTION: void glCompressedTexImage1D { glCompressedTexImage1DARB } ( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, GLvoid* data )
GL-FUNCTION: void glCompressedTexImage2D { glCompressedTexImage2DARB } ( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, GLvoid* data )
GL-FUNCTION: void glCompressedTexImage3D { glCompressedTexImage2DARB } ( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, GLvoid* data )
GL-FUNCTION: void glCompressedTexSubImage1D { glCompressedTexSubImage1DARB } ( GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, GLvoid* data )
GL-FUNCTION: void glCompressedTexSubImage2D { glCompressedTexSubImage2DARB } ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, GLvoid* data )
GL-FUNCTION: void glCompressedTexSubImage3D { glCompressedTexSubImage3DARB } ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, GLvoid* data )
GL-FUNCTION: void glGetCompressedTexImage { glGetCompressedTexImageARB } ( GLenum target, GLint lod, GLvoid* img )
GL-FUNCTION: void glLoadTransposeMatrixd { glLoadTransposeMatrixdARB } ( GLdouble* m )
GL-FUNCTION: void glLoadTransposeMatrixf { glLoadTransposeMatrixfARB } ( GLfloat* m )
GL-FUNCTION: void glMultTransposeMatrixd { glMultTransposeMatrixdARB } ( GLdouble* m )
GL-FUNCTION: void glMultTransposeMatrixf { glMultTransposeMatrixfARB } ( GLfloat* m )
GL-FUNCTION: void glMultiTexCoord1d { glMultiTexCoord1dARB } ( GLenum target, GLdouble s )
GL-FUNCTION: void glMultiTexCoord1dv { glMultiTexCoord1dvARB } ( GLenum target, GLdouble* v )
GL-FUNCTION: void glMultiTexCoord1f { glMultiTexCoord1fARB } ( GLenum target, GLfloat s )
GL-FUNCTION: void glMultiTexCoord1fv { glMultiTexCoord1fvARB } ( GLenum target, GLfloat* v )
GL-FUNCTION: void glMultiTexCoord1i { glMultiTexCoord1iARB } ( GLenum target, GLint s )
GL-FUNCTION: void glMultiTexCoord1iv { glMultiTexCoord1ivARB } ( GLenum target, GLint* v )
GL-FUNCTION: void glMultiTexCoord1s { glMultiTexCoord1sARB } ( GLenum target, GLshort s )
GL-FUNCTION: void glMultiTexCoord1sv { glMultiTexCoord1svARB } ( GLenum target, GLshort* v )
GL-FUNCTION: void glMultiTexCoord2d { glMultiTexCoord2dARB } ( GLenum target, GLdouble s, GLdouble t )
GL-FUNCTION: void glMultiTexCoord2dv { glMultiTexCoord2dvARB } ( GLenum target, GLdouble* v )
GL-FUNCTION: void glMultiTexCoord2f { glMultiTexCoord2fARB } ( GLenum target, GLfloat s, GLfloat t )
GL-FUNCTION: void glMultiTexCoord2fv { glMultiTexCoord2fvARB } ( GLenum target, GLfloat* v )
GL-FUNCTION: void glMultiTexCoord2i { glMultiTexCoord2iARB } ( GLenum target, GLint s, GLint t )
GL-FUNCTION: void glMultiTexCoord2iv { glMultiTexCoord2ivARB } ( GLenum target, GLint* v )
GL-FUNCTION: void glMultiTexCoord2s { glMultiTexCoord2sARB } ( GLenum target, GLshort s, GLshort t )
GL-FUNCTION: void glMultiTexCoord2sv { glMultiTexCoord2svARB } ( GLenum target, GLshort* v )
GL-FUNCTION: void glMultiTexCoord3d { glMultiTexCoord3dARB } ( GLenum target, GLdouble s, GLdouble t, GLdouble r )
GL-FUNCTION: void glMultiTexCoord3dv { glMultiTexCoord3dvARB } ( GLenum target, GLdouble* v )
GL-FUNCTION: void glMultiTexCoord3f { glMultiTexCoord3fARB } ( GLenum target, GLfloat s, GLfloat t, GLfloat r )
GL-FUNCTION: void glMultiTexCoord3fv { glMultiTexCoord3fvARB } ( GLenum target, GLfloat* v )
GL-FUNCTION: void glMultiTexCoord3i { glMultiTexCoord3iARB } ( GLenum target, GLint s, GLint t, GLint r )
GL-FUNCTION: void glMultiTexCoord3iv { glMultiTexCoord3ivARB } ( GLenum target, GLint* v )
GL-FUNCTION: void glMultiTexCoord3s { glMultiTexCoord3sARB } ( GLenum target, GLshort s, GLshort t, GLshort r )
GL-FUNCTION: void glMultiTexCoord3sv { glMultiTexCoord3svARB } ( GLenum target, GLshort* v )
GL-FUNCTION: void glMultiTexCoord4d { glMultiTexCoord4dARB } ( GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q )
GL-FUNCTION: void glMultiTexCoord4dv { glMultiTexCoord4dvARB } ( GLenum target, GLdouble* v )
GL-FUNCTION: void glMultiTexCoord4f { glMultiTexCoord4fARB } ( GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q )
GL-FUNCTION: void glMultiTexCoord4fv { glMultiTexCoord4fvARB } ( GLenum target, GLfloat* v )
GL-FUNCTION: void glMultiTexCoord4i { glMultiTexCoord4iARB } ( GLenum target, GLint s, GLint t, GLint r, GLint q )
GL-FUNCTION: void glMultiTexCoord4iv { glMultiTexCoord4ivARB } ( GLenum target, GLint* v )
GL-FUNCTION: void glMultiTexCoord4s { glMultiTexCoord4sARB } ( GLenum target, GLshort s, GLshort t, GLshort r, GLshort q )
GL-FUNCTION: void glMultiTexCoord4sv { glMultiTexCoord4svARB } ( GLenum target, GLshort* v )
GL-FUNCTION: void glSampleCoverage { glSampleCoverageARB } ( GLclampf value, GLboolean invert )


! OpenGL 1.4


CONSTANT: GL_BLEND_DST_RGB 0x80C8
CONSTANT: GL_BLEND_SRC_RGB 0x80C9
CONSTANT: GL_BLEND_DST_ALPHA 0x80CA
CONSTANT: GL_BLEND_SRC_ALPHA 0x80CB
CONSTANT: GL_POINT_SIZE_MIN 0x8126
CONSTANT: GL_POINT_SIZE_MAX 0x8127
CONSTANT: GL_POINT_FADE_THRESHOLD_SIZE 0x8128
CONSTANT: GL_POINT_DISTANCE_ATTENUATION 0x8129
CONSTANT: GL_GENERATE_MIPMAP 0x8191
CONSTANT: GL_GENERATE_MIPMAP_HINT 0x8192
CONSTANT: GL_DEPTH_COMPONENT16 0x81A5
CONSTANT: GL_DEPTH_COMPONENT24 0x81A6
CONSTANT: GL_DEPTH_COMPONENT32 0x81A7
CONSTANT: GL_MIRRORED_REPEAT 0x8370
CONSTANT: GL_FOG_COORDINATE_SOURCE 0x8450
CONSTANT: GL_FOG_COORDINATE 0x8451
CONSTANT: GL_FRAGMENT_DEPTH 0x8452
CONSTANT: GL_CURRENT_FOG_COORDINATE 0x8453
CONSTANT: GL_FOG_COORDINATE_ARRAY_TYPE 0x8454
CONSTANT: GL_FOG_COORDINATE_ARRAY_STRIDE 0x8455
CONSTANT: GL_FOG_COORDINATE_ARRAY_POINTER 0x8456
CONSTANT: GL_FOG_COORDINATE_ARRAY 0x8457
CONSTANT: GL_COLOR_SUM 0x8458
CONSTANT: GL_CURRENT_SECONDARY_COLOR 0x8459
CONSTANT: GL_SECONDARY_COLOR_ARRAY_SIZE 0x845A
CONSTANT: GL_SECONDARY_COLOR_ARRAY_TYPE 0x845B
CONSTANT: GL_SECONDARY_COLOR_ARRAY_STRIDE 0x845C
CONSTANT: GL_SECONDARY_COLOR_ARRAY_POINTER 0x845D
CONSTANT: GL_SECONDARY_COLOR_ARRAY 0x845E
CONSTANT: GL_MAX_TEXTURE_LOD_BIAS 0x84FD
CONSTANT: GL_TEXTURE_FILTER_CONTROL 0x8500
CONSTANT: GL_TEXTURE_LOD_BIAS 0x8501
CONSTANT: GL_INCR_WRAP 0x8507
CONSTANT: GL_DECR_WRAP 0x8508
CONSTANT: GL_TEXTURE_DEPTH_SIZE 0x884A
CONSTANT: GL_DEPTH_TEXTURE_MODE 0x884B
CONSTANT: GL_TEXTURE_COMPARE_MODE 0x884C
CONSTANT: GL_TEXTURE_COMPARE_FUNC 0x884D
CONSTANT: GL_COMPARE_R_TO_TEXTURE 0x884E

GL-FUNCTION: void glBlendColor { glBlendColorEXT } ( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha )
GL-FUNCTION: void glBlendEquation { glBlendEquationEXT } ( GLenum mode )
GL-FUNCTION: void glBlendFuncSeparate { glBlendFuncSeparateEXT } ( GLenum sfactorRGB, GLenum dfactorRGB, GLenum sfactorAlpha, GLenum dfactorAlpha )
GL-FUNCTION: void glFogCoordPointer { glFogCoordPointerEXT } ( GLenum type, GLsizei stride, GLvoid* pointer )
GL-FUNCTION: void glFogCoordd { glFogCoorddEXT } ( GLdouble coord )
GL-FUNCTION: void glFogCoorddv { glFogCoorddvEXT } ( GLdouble* coord )
GL-FUNCTION: void glFogCoordf { glFogCoordfEXT } ( GLfloat coord )
GL-FUNCTION: void glFogCoordfv { glFogCoordfvEXT } ( GLfloat* coord )
GL-FUNCTION: void glMultiDrawArrays { glMultiDrawArraysEXT } ( GLenum mode, GLint* first, GLsizei* count, GLsizei primcount )
GL-FUNCTION: void glMultiDrawElements { glMultiDrawElementsEXT } ( GLenum mode, GLsizei* count, GLenum type, GLvoid** indices, GLsizei primcount )
GL-FUNCTION: void glPointParameterf { glPointParameterfARB } ( GLenum pname, GLfloat param )
GL-FUNCTION: void glPointParameterfv { glPointParameterfvARB } ( GLenum pname, GLfloat* params )
GL-FUNCTION: void glPointParameteri { glPointParameteriARB } ( GLenum pname, GLint param )
GL-FUNCTION: void glPointParameteriv { glPointParameterivARB } ( GLenum pname, GLint* params )
GL-FUNCTION: void glSecondaryColor3b { glSecondaryColor3bEXT } ( GLbyte red, GLbyte green, GLbyte blue )
GL-FUNCTION: void glSecondaryColor3bv { glSecondaryColor3bvEXT } ( GLbyte* v )
GL-FUNCTION: void glSecondaryColor3d { glSecondaryColor3dEXT } ( GLdouble red, GLdouble green, GLdouble blue )
GL-FUNCTION: void glSecondaryColor3dv { glSecondaryColor3dvEXT } ( GLdouble* v )
GL-FUNCTION: void glSecondaryColor3f { glSecondaryColor3fEXT } ( GLfloat red, GLfloat green, GLfloat blue )
GL-FUNCTION: void glSecondaryColor3fv { glSecondaryColor3fvEXT } ( GLfloat* v )
GL-FUNCTION: void glSecondaryColor3i { glSecondaryColor3iEXT } ( GLint red, GLint green, GLint blue )
GL-FUNCTION: void glSecondaryColor3iv { glSecondaryColor3ivEXT } ( GLint* v )
GL-FUNCTION: void glSecondaryColor3s { glSecondaryColor3sEXT } ( GLshort red, GLshort green, GLshort blue )
GL-FUNCTION: void glSecondaryColor3sv { glSecondaryColor3svEXT } ( GLshort* v )
GL-FUNCTION: void glSecondaryColor3ub { glSecondaryColor3ubEXT } ( GLubyte red, GLubyte green, GLubyte blue )
GL-FUNCTION: void glSecondaryColor3ubv { glSecondaryColor3ubvEXT } ( GLubyte* v )
GL-FUNCTION: void glSecondaryColor3ui { glSecondaryColor3uiEXT } ( GLuint red, GLuint green, GLuint blue )
GL-FUNCTION: void glSecondaryColor3uiv { glSecondaryColor3uivEXT } ( GLuint* v )
GL-FUNCTION: void glSecondaryColor3us { glSecondaryColor3usEXT } ( GLushort red, GLushort green, GLushort blue )
GL-FUNCTION: void glSecondaryColor3usv { glSecondaryColor3usvEXT } ( GLushort* v )
GL-FUNCTION: void glSecondaryColorPointer { glSecondaryColorPointerEXT } ( GLint size, GLenum type, GLsizei stride, GLvoid* pointer )
GL-FUNCTION: void glWindowPos2d { glWindowPos2dARB } ( GLdouble x, GLdouble y )
GL-FUNCTION: void glWindowPos2dv { glWindowPos2dvARB } ( GLdouble* p )
GL-FUNCTION: void glWindowPos2f { glWindowPos2fARB } ( GLfloat x, GLfloat y )
GL-FUNCTION: void glWindowPos2fv { glWindowPos2fvARB } ( GLfloat* p )
GL-FUNCTION: void glWindowPos2i { glWindowPos2iARB } ( GLint x, GLint y )
GL-FUNCTION: void glWindowPos2iv { glWindowPos2ivARB } ( GLint* p )
GL-FUNCTION: void glWindowPos2s { glWindowPos2sARB } ( GLshort x, GLshort y )
GL-FUNCTION: void glWindowPos2sv { glWindowPos2svARB } ( GLshort* p )
GL-FUNCTION: void glWindowPos3d { glWindowPos3dARB } ( GLdouble x, GLdouble y, GLdouble z )
GL-FUNCTION: void glWindowPos3dv { glWindowPos3dvARB } ( GLdouble* p )
GL-FUNCTION: void glWindowPos3f { glWindowPos3fARB } ( GLfloat x, GLfloat y, GLfloat z )
GL-FUNCTION: void glWindowPos3fv { glWindowPos3fvARB } ( GLfloat* p )
GL-FUNCTION: void glWindowPos3i { glWindowPos3iARB } ( GLint x, GLint y, GLint z )
GL-FUNCTION: void glWindowPos3iv { glWindowPos3ivARB } ( GLint* p )
GL-FUNCTION: void glWindowPos3s { glWindowPos3sARB } ( GLshort x, GLshort y, GLshort z )
GL-FUNCTION: void glWindowPos3sv { glWindowPos3svARB } ( GLshort* p )

! OpenGL 1.5

CONSTANT: GL_BUFFER_SIZE 0x8764
CONSTANT: GL_BUFFER_USAGE 0x8765
CONSTANT: GL_QUERY_COUNTER_BITS 0x8864
CONSTANT: GL_CURRENT_QUERY 0x8865
CONSTANT: GL_QUERY_RESULT 0x8866
CONSTANT: GL_QUERY_RESULT_AVAILABLE 0x8867
CONSTANT: GL_ARRAY_BUFFER 0x8892
CONSTANT: GL_ELEMENT_ARRAY_BUFFER 0x8893
CONSTANT: GL_ARRAY_BUFFER_BINDING 0x8894
CONSTANT: GL_ELEMENT_ARRAY_BUFFER_BINDING 0x8895
CONSTANT: GL_VERTEX_ARRAY_BUFFER_BINDING 0x8896
CONSTANT: GL_NORMAL_ARRAY_BUFFER_BINDING 0x8897
CONSTANT: GL_COLOR_ARRAY_BUFFER_BINDING 0x8898
CONSTANT: GL_INDEX_ARRAY_BUFFER_BINDING 0x8899
CONSTANT: GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING 0x889A
CONSTANT: GL_EDGE_FLAG_ARRAY_BUFFER_BINDING 0x889B
CONSTANT: GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING 0x889C
CONSTANT: GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING 0x889D
CONSTANT: GL_WEIGHT_ARRAY_BUFFER_BINDING 0x889E
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING 0x889F
CONSTANT: GL_READ_ONLY 0x88B8
CONSTANT: GL_WRITE_ONLY 0x88B9
CONSTANT: GL_READ_WRITE 0x88BA
CONSTANT: GL_BUFFER_ACCESS 0x88BB
CONSTANT: GL_BUFFER_MAPPED 0x88BC
CONSTANT: GL_BUFFER_MAP_POINTER 0x88BD
CONSTANT: GL_STREAM_DRAW 0x88E0
CONSTANT: GL_STREAM_READ 0x88E1
CONSTANT: GL_STREAM_COPY 0x88E2
CONSTANT: GL_STATIC_DRAW 0x88E4
CONSTANT: GL_STATIC_READ 0x88E5
CONSTANT: GL_STATIC_COPY 0x88E6
CONSTANT: GL_DYNAMIC_DRAW 0x88E8
CONSTANT: GL_DYNAMIC_READ 0x88E9
CONSTANT: GL_DYNAMIC_COPY 0x88EA
CONSTANT: GL_SAMPLES_PASSED 0x8914
ALIAS: GL_FOG_COORD_SRC GL_FOG_COORDINATE_SOURCE
ALIAS: GL_FOG_COORD GL_FOG_COORDINATE
ALIAS: GL_FOG_COORD_ARRAY GL_FOG_COORDINATE_ARRAY
ALIAS: GL_SRC0_RGB GL_SOURCE0_RGB
ALIAS: GL_FOG_COORD_ARRAY_POINTER GL_FOG_COORDINATE_ARRAY_POINTER
ALIAS: GL_FOG_COORD_ARRAY_TYPE GL_FOG_COORDINATE_ARRAY_TYPE
ALIAS: GL_SRC1_ALPHA GL_SOURCE1_ALPHA
ALIAS: GL_CURRENT_FOG_COORD GL_CURRENT_FOG_COORDINATE
ALIAS: GL_FOG_COORD_ARRAY_STRIDE GL_FOG_COORDINATE_ARRAY_STRIDE
ALIAS: GL_SRC0_ALPHA GL_SOURCE0_ALPHA
ALIAS: GL_SRC1_RGB GL_SOURCE1_RGB
ALIAS: GL_FOG_COORD_ARRAY_BUFFER_BINDING GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING
ALIAS: GL_SRC2_ALPHA GL_SOURCE2_ALPHA
ALIAS: GL_SRC2_RGB GL_SOURCE2_RGB

TYPEDEF: ptrdiff_t GLsizeiptr
TYPEDEF: ptrdiff_t GLintptr

GL-FUNCTION: void glBeginQuery { glBeginQueryARB } ( GLenum target, GLuint id )
GL-FUNCTION: void glBindBuffer { glBindBufferARB } ( GLenum target, GLuint buffer )
GL-FUNCTION: void glBufferData { glBufferDataARB } ( GLenum target, GLsizeiptr size, GLvoid* data, GLenum usage )
GL-FUNCTION: void glBufferSubData { glBufferSubDataARB } ( GLenum target, GLintptr offset, GLsizeiptr size, GLvoid* data )
GL-FUNCTION: void glDeleteBuffers { glDeleteBuffersARB } ( GLsizei n, GLuint* buffers )
GL-FUNCTION: void glDeleteQueries { glDeleteQueriesARB } ( GLsizei n, GLuint* ids )
GL-FUNCTION: void glEndQuery { glEndQueryARB } ( GLenum target )
GL-FUNCTION: void glGenBuffers { glGenBuffersARB } ( GLsizei n, GLuint* buffers )
GL-FUNCTION: void glGenQueries { glGenQueriesARB } ( GLsizei n, GLuint* ids )
GL-FUNCTION: void glGetBufferParameteriv { glGetBufferParameterivARB } ( GLenum target, GLenum pname, GLint* params )
GL-FUNCTION: void glGetBufferPointerv { glGetBufferPointervARB } ( GLenum target, GLenum pname, GLvoid** params )
GL-FUNCTION: void glGetBufferSubData { glGetBufferSubDataARB } ( GLenum target, GLintptr offset, GLsizeiptr size, GLvoid* data )
GL-FUNCTION: void glGetQueryObjectiv { glGetQueryObjectivARB } ( GLuint id, GLenum pname, GLint* params )
GL-FUNCTION: void glGetQueryObjectuiv { glGetQueryObjectuivARB } ( GLuint id, GLenum pname, GLuint* params )
GL-FUNCTION: void glGetQueryiv { glGetQueryivARB } ( GLenum target, GLenum pname, GLint* params )
GL-FUNCTION: GLboolean glIsBuffer { glIsBufferARB } ( GLuint buffer )
GL-FUNCTION: GLboolean glIsQuery { glIsQueryARB } ( GLuint id )
GL-FUNCTION: GLvoid* glMapBuffer { glMapBufferARB } ( GLenum target, GLenum access )
GL-FUNCTION: GLboolean glUnmapBuffer { glUnmapBufferARB } ( GLenum target )


! OpenGL 2.0


CONSTANT: GL_VERTEX_ATTRIB_ARRAY_ENABLED 0x8622
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_SIZE 0x8623
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_STRIDE 0x8624
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_TYPE 0x8625
CONSTANT: GL_CURRENT_VERTEX_ATTRIB 0x8626
CONSTANT: GL_VERTEX_PROGRAM_POINT_SIZE 0x8642
CONSTANT: GL_VERTEX_PROGRAM_TWO_SIDE 0x8643
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_POINTER 0x8645
CONSTANT: GL_STENCIL_BACK_FUNC 0x8800
CONSTANT: GL_STENCIL_BACK_FAIL 0x8801
CONSTANT: GL_STENCIL_BACK_PASS_DEPTH_FAIL 0x8802
CONSTANT: GL_STENCIL_BACK_PASS_DEPTH_PASS 0x8803
CONSTANT: GL_MAX_DRAW_BUFFERS 0x8824
CONSTANT: GL_DRAW_BUFFER0 0x8825
CONSTANT: GL_DRAW_BUFFER1 0x8826
CONSTANT: GL_DRAW_BUFFER2 0x8827
CONSTANT: GL_DRAW_BUFFER3 0x8828
CONSTANT: GL_DRAW_BUFFER4 0x8829
CONSTANT: GL_DRAW_BUFFER5 0x882A
CONSTANT: GL_DRAW_BUFFER6 0x882B
CONSTANT: GL_DRAW_BUFFER7 0x882C
CONSTANT: GL_DRAW_BUFFER8 0x882D
CONSTANT: GL_DRAW_BUFFER9 0x882E
CONSTANT: GL_DRAW_BUFFER10 0x882F
CONSTANT: GL_DRAW_BUFFER11 0x8830
CONSTANT: GL_DRAW_BUFFER12 0x8831
CONSTANT: GL_DRAW_BUFFER13 0x8832
CONSTANT: GL_DRAW_BUFFER14 0x8833
CONSTANT: GL_DRAW_BUFFER15 0x8834
CONSTANT: GL_BLEND_EQUATION_ALPHA 0x883D
CONSTANT: GL_POINT_SPRITE 0x8861
CONSTANT: GL_COORD_REPLACE 0x8862
CONSTANT: GL_MAX_VERTEX_ATTRIBS 0x8869
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_NORMALIZED 0x886A
CONSTANT: GL_MAX_TEXTURE_COORDS 0x8871
CONSTANT: GL_MAX_TEXTURE_IMAGE_UNITS 0x8872
CONSTANT: GL_FRAGMENT_SHADER 0x8B30
CONSTANT: GL_VERTEX_SHADER 0x8B31
CONSTANT: GL_MAX_FRAGMENT_UNIFORM_COMPONENTS 0x8B49
CONSTANT: GL_MAX_VERTEX_UNIFORM_COMPONENTS 0x8B4A
CONSTANT: GL_MAX_VARYING_FLOATS 0x8B4B
CONSTANT: GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS 0x8B4C
CONSTANT: GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS 0x8B4D
CONSTANT: GL_SHADER_TYPE 0x8B4F
CONSTANT: GL_FLOAT_VEC2 0x8B50
CONSTANT: GL_FLOAT_VEC3 0x8B51
CONSTANT: GL_FLOAT_VEC4 0x8B52
CONSTANT: GL_INT_VEC2 0x8B53
CONSTANT: GL_INT_VEC3 0x8B54
CONSTANT: GL_INT_VEC4 0x8B55
CONSTANT: GL_BOOL 0x8B56
CONSTANT: GL_BOOL_VEC2 0x8B57
CONSTANT: GL_BOOL_VEC3 0x8B58
CONSTANT: GL_BOOL_VEC4 0x8B59
CONSTANT: GL_FLOAT_MAT2 0x8B5A
CONSTANT: GL_FLOAT_MAT3 0x8B5B
CONSTANT: GL_FLOAT_MAT4 0x8B5C
CONSTANT: GL_SAMPLER_1D 0x8B5D
CONSTANT: GL_SAMPLER_2D 0x8B5E
CONSTANT: GL_SAMPLER_3D 0x8B5F
CONSTANT: GL_SAMPLER_CUBE 0x8B60
CONSTANT: GL_SAMPLER_1D_SHADOW 0x8B61
CONSTANT: GL_SAMPLER_2D_SHADOW 0x8B62
CONSTANT: GL_DELETE_STATUS 0x8B80
CONSTANT: GL_COMPILE_STATUS 0x8B81
CONSTANT: GL_LINK_STATUS 0x8B82
CONSTANT: GL_VALIDATE_STATUS 0x8B83
CONSTANT: GL_INFO_LOG_LENGTH 0x8B84
CONSTANT: GL_ATTACHED_SHADERS 0x8B85
CONSTANT: GL_ACTIVE_UNIFORMS 0x8B86
CONSTANT: GL_ACTIVE_UNIFORM_MAX_LENGTH 0x8B87
CONSTANT: GL_SHADER_SOURCE_LENGTH 0x8B88
CONSTANT: GL_ACTIVE_ATTRIBUTES 0x8B89
CONSTANT: GL_ACTIVE_ATTRIBUTE_MAX_LENGTH 0x8B8A
CONSTANT: GL_FRAGMENT_SHADER_DERIVATIVE_HINT 0x8B8B
CONSTANT: GL_SHADING_LANGUAGE_VERSION 0x8B8C
CONSTANT: GL_CURRENT_PROGRAM 0x8B8D
CONSTANT: GL_POINT_SPRITE_COORD_ORIGIN 0x8CA0
CONSTANT: GL_LOWER_LEFT 0x8CA1
CONSTANT: GL_UPPER_LEFT 0x8CA2
CONSTANT: GL_STENCIL_BACK_REF 0x8CA3
CONSTANT: GL_STENCIL_BACK_VALUE_MASK 0x8CA4
CONSTANT: GL_STENCIL_BACK_WRITEMASK 0x8CA5
ALIAS: GL_BLEND_EQUATION_RGB GL_BLEND_EQUATION

GL-FUNCTION: void glAttachShader { glAttachObjectARB } ( GLuint program, GLuint shader )
GL-FUNCTION: void glBindAttribLocation { glBindAttribLocationARB } ( GLuint program, GLuint index, GLstring name )
GL-FUNCTION: void glBlendEquationSeparate { glBlendEquationSeparateEXT } ( GLenum modeRGB, GLenum modeAlpha )
GL-FUNCTION: void glCompileShader { glCompileShaderARB } ( GLuint shader )
GL-FUNCTION: GLuint glCreateProgram { glCreateProgramObjectARB } ( )
GL-FUNCTION: GLuint glCreateShader { glCreateShaderObjectARB } ( GLenum type )
GL-FUNCTION: void glDeleteProgram { glDeleteObjectARB } ( GLuint program )
GL-FUNCTION: void glDeleteShader { glDeleteObjectARB } ( GLuint shader )
GL-FUNCTION: void glDetachShader { glDetachObjectARB } ( GLuint program, GLuint shader )
GL-FUNCTION: void glDisableVertexAttribArray { glDisableVertexAttribArrayARB } ( GLuint index )
GL-FUNCTION: void glDrawBuffers { glDrawBuffersARB glDrawBuffersATI } ( GLsizei n, GLenum* bufs )
GL-FUNCTION: void glEnableVertexAttribArray { glEnableVertexAttribArrayARB } ( GLuint index )
GL-FUNCTION: void glGetActiveAttrib { glGetActiveAttribARB } ( GLuint program, GLuint index, GLsizei maxLength, GLsizei* length, GLint* size, GLenum* type, GLstring name )
GL-FUNCTION: void glGetActiveUniform { glGetActiveUniformARB } ( GLuint program, GLuint index, GLsizei maxLength, GLsizei* length, GLint* size, GLenum* type, GLstring name )
GL-FUNCTION: void glGetAttachedShaders { glGetAttachedObjectsARB } ( GLuint program, GLsizei maxCount, GLsizei* count, GLuint* shaders )
GL-FUNCTION: GLint glGetAttribLocation { glGetAttribLocationARB } ( GLuint program, GLstring name )
GL-FUNCTION: void glGetProgramInfoLog { glGetInfoLogARB } ( GLuint program, GLsizei bufSize, GLsizei* length, GLstring infoLog )
GL-FUNCTION: void glGetProgramiv { glGetObjectParameterivARB } ( GLuint program, GLenum pname, GLint* param )
GL-FUNCTION: void glGetShaderInfoLog { glGetInfoLogARB } ( GLuint shader, GLsizei bufSize, GLsizei* length, GLstring infoLog )
GL-FUNCTION: void glGetShaderSource { glGetShaderSourceARB } ( GLint obj, GLsizei maxLength, GLsizei* length, GLstring source )
GL-FUNCTION: void glGetShaderiv { glGetObjectParameterivARB } ( GLuint shader, GLenum pname, GLint* param )
GL-FUNCTION: GLint glGetUniformLocation { glGetUniformLocationARB } ( GLint programObj, GLstring name )
GL-FUNCTION: void glGetUniformfv { glGetUniformfvARB } ( GLuint program, GLint location, GLfloat* params )
GL-FUNCTION: void glGetUniformiv { glGetUniformivARB } ( GLuint program, GLint location, GLint* params )
GL-FUNCTION: void glGetVertexAttribPointerv { glGetVertexAttribPointervARB } ( GLuint index, GLenum pname, GLvoid** pointer )
GL-FUNCTION: void glGetVertexAttribdv { glGetVertexAttribdvARB } ( GLuint index, GLenum pname, GLdouble* params )
GL-FUNCTION: void glGetVertexAttribfv { glGetVertexAttribfvARB } ( GLuint index, GLenum pname, GLfloat* params )
GL-FUNCTION: void glGetVertexAttribiv { glGetVertexAttribivARB } ( GLuint index, GLenum pname, GLint* params )
GL-FUNCTION: GLboolean glIsProgram { glIsProgramARB } ( GLuint program )
GL-FUNCTION: GLboolean glIsShader { glIsShaderARB } ( GLuint shader )
GL-FUNCTION: void glLinkProgram { glLinkProgramARB } ( GLuint program )
GL-FUNCTION: void glShaderSource { glShaderSourceARB } ( GLuint shader, GLsizei count, GLstring* strings, GLint* lengths )
GL-FUNCTION: void glStencilFuncSeparate { glStencilFuncSeparateATI } ( GLenum frontfunc, GLenum backfunc, GLint ref, GLuint mask )
GL-FUNCTION: void glStencilMaskSeparate { } ( GLenum face, GLuint mask )
GL-FUNCTION: void glStencilOpSeparate { glStencilOpSeparateATI } ( GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass )
GL-FUNCTION: void glUniform1f { glUniform1fARB } ( GLint location, GLfloat v0 )
GL-FUNCTION: void glUniform1fv { glUniform1fvARB } ( GLint location, GLsizei count, GLfloat* value )
GL-FUNCTION: void glUniform1i { glUniform1iARB } ( GLint location, GLint v0 )
GL-FUNCTION: void glUniform1iv { glUniform1ivARB } ( GLint location, GLsizei count, GLint* value )
GL-FUNCTION: void glUniform2f { glUniform2fARB } ( GLint location, GLfloat v0, GLfloat v1 )
GL-FUNCTION: void glUniform2fv { glUniform2fvARB } ( GLint location, GLsizei count, GLfloat* value )
GL-FUNCTION: void glUniform2i { glUniform2iARB } ( GLint location, GLint v0, GLint v1 )
GL-FUNCTION: void glUniform2iv { glUniform2ivARB } ( GLint location, GLsizei count, GLint* value )
GL-FUNCTION: void glUniform3f { glUniform3fARB } ( GLint location, GLfloat v0, GLfloat v1, GLfloat v2 )
GL-FUNCTION: void glUniform3fv { glUniform3fvARB } ( GLint location, GLsizei count, GLfloat* value )
GL-FUNCTION: void glUniform3i { glUniform3iARB } ( GLint location, GLint v0, GLint v1, GLint v2 )
GL-FUNCTION: void glUniform3iv { glUniform3ivARB } ( GLint location, GLsizei count, GLint* value )
GL-FUNCTION: void glUniform4f { glUniform4fARB } ( GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3 )
GL-FUNCTION: void glUniform4fv { glUniform4fvARB } ( GLint location, GLsizei count, GLfloat* value )
GL-FUNCTION: void glUniform4i { glUniform4iARB } ( GLint location, GLint v0, GLint v1, GLint v2, GLint v3 )
GL-FUNCTION: void glUniform4iv { glUniform4ivARB } ( GLint location, GLsizei count, GLint* value )
GL-FUNCTION: void glUniformMatrix2fv { glUniformMatrix2fvARB } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )
GL-FUNCTION: void glUniformMatrix3fv { glUniformMatrix3fvARB } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )
GL-FUNCTION: void glUniformMatrix4fv { glUniformMatrix4fvARB } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )
GL-FUNCTION: void glUseProgram { glUseProgramObjectARB } ( GLuint program )
GL-FUNCTION: void glValidateProgram { glValidateProgramARB } ( GLuint program )
GL-FUNCTION: void glVertexAttrib1d { glVertexAttrib1dARB } ( GLuint index, GLdouble x )
GL-FUNCTION: void glVertexAttrib1dv { glVertexAttrib1dvARB } ( GLuint index, GLdouble* v )
GL-FUNCTION: void glVertexAttrib1f { glVertexAttrib1fARB } ( GLuint index, GLfloat x )
GL-FUNCTION: void glVertexAttrib1fv { glVertexAttrib1fvARB } ( GLuint index, GLfloat* v )
GL-FUNCTION: void glVertexAttrib1s { glVertexAttrib1sARB } ( GLuint index, GLshort x )
GL-FUNCTION: void glVertexAttrib1sv { glVertexAttrib1svARB } ( GLuint index, GLshort* v )
GL-FUNCTION: void glVertexAttrib2d { glVertexAttrib2dARB } ( GLuint index, GLdouble x, GLdouble y )
GL-FUNCTION: void glVertexAttrib2dv { glVertexAttrib2dvARB } ( GLuint index, GLdouble* v )
GL-FUNCTION: void glVertexAttrib2f { glVertexAttrib2fARB } ( GLuint index, GLfloat x, GLfloat y )
GL-FUNCTION: void glVertexAttrib2fv { glVertexAttrib2fvARB } ( GLuint index, GLfloat* v )
GL-FUNCTION: void glVertexAttrib2s { glVertexAttrib2sARB } ( GLuint index, GLshort x, GLshort y )
GL-FUNCTION: void glVertexAttrib2sv { glVertexAttrib2svARB } ( GLuint index, GLshort* v )
GL-FUNCTION: void glVertexAttrib3d { glVertexAttrib3dARB } ( GLuint index, GLdouble x, GLdouble y, GLdouble z )
GL-FUNCTION: void glVertexAttrib3dv { glVertexAttrib3dvARB } ( GLuint index, GLdouble* v )
GL-FUNCTION: void glVertexAttrib3f { glVertexAttrib3fARB } ( GLuint index, GLfloat x, GLfloat y, GLfloat z )
GL-FUNCTION: void glVertexAttrib3fv { glVertexAttrib3fvARB } ( GLuint index, GLfloat* v )
GL-FUNCTION: void glVertexAttrib3s { glVertexAttrib3sARB } ( GLuint index, GLshort x, GLshort y, GLshort z )
GL-FUNCTION: void glVertexAttrib3sv { glVertexAttrib3svARB } ( GLuint index, GLshort* v )
GL-FUNCTION: void glVertexAttrib4Nbv { glVertexAttrib4NbvARB } ( GLuint index, GLbyte* v )
GL-FUNCTION: void glVertexAttrib4Niv { glVertexAttrib4NivARB } ( GLuint index, GLint* v )
GL-FUNCTION: void glVertexAttrib4Nsv { glVertexAttrib4NsvARB } ( GLuint index, GLshort* v )
GL-FUNCTION: void glVertexAttrib4Nub { glVertexAttrib4NubARB } ( GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w )
GL-FUNCTION: void glVertexAttrib4Nubv { glVertexAttrib4NubvARB } ( GLuint index, GLubyte* v )
GL-FUNCTION: void glVertexAttrib4Nuiv { glVertexAttrib4NuivARB } ( GLuint index, GLuint* v )
GL-FUNCTION: void glVertexAttrib4Nusv { glVertexAttrib4NusvARB } ( GLuint index, GLushort* v )
GL-FUNCTION: void glVertexAttrib4bv { glVertexAttrib4bvARB } ( GLuint index, GLbyte* v )
GL-FUNCTION: void glVertexAttrib4d { glVertexAttrib4dARB } ( GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w )
GL-FUNCTION: void glVertexAttrib4dv { glVertexAttrib4dvARB } ( GLuint index, GLdouble* v )
GL-FUNCTION: void glVertexAttrib4f { glVertexAttrib4fARB } ( GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w )
GL-FUNCTION: void glVertexAttrib4fv { glVertexAttrib4fvARB } ( GLuint index, GLfloat* v )
GL-FUNCTION: void glVertexAttrib4iv { glVertexAttrib4ivARB } ( GLuint index, GLint* v )
GL-FUNCTION: void glVertexAttrib4s { glVertexAttrib4sARB } ( GLuint index, GLshort x, GLshort y, GLshort z, GLshort w )
GL-FUNCTION: void glVertexAttrib4sv { glVertexAttrib4svARB } ( GLuint index, GLshort* v )
GL-FUNCTION: void glVertexAttrib4ubv { glVertexAttrib4ubvARB } ( GLuint index, GLubyte* v )
GL-FUNCTION: void glVertexAttrib4uiv { glVertexAttrib4uivARB } ( GLuint index, GLuint* v )
GL-FUNCTION: void glVertexAttrib4usv { glVertexAttrib4usvARB } ( GLuint index, GLushort* v )
GL-FUNCTION: void glVertexAttribPointer { glVertexAttribPointerARB } ( GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, GLvoid* pointer )


! OpenGL 2.1


CONSTANT: GL_CURRENT_RASTER_SECONDARY_COLOR 0x845F
CONSTANT: GL_PIXEL_PACK_BUFFER 0x88EB
CONSTANT: GL_PIXEL_UNPACK_BUFFER 0x88EC
CONSTANT: GL_PIXEL_PACK_BUFFER_BINDING 0x88ED
CONSTANT: GL_PIXEL_UNPACK_BUFFER_BINDING 0x88EF
CONSTANT: GL_SRGB 0x8C40
CONSTANT: GL_SRGB8 0x8C41
CONSTANT: GL_SRGB_ALPHA 0x8C42
CONSTANT: GL_SRGB8_ALPHA8 0x8C43
CONSTANT: GL_SLUMINANCE_ALPHA 0x8C44
CONSTANT: GL_SLUMINANCE8_ALPHA8 0x8C45
CONSTANT: GL_SLUMINANCE 0x8C46
CONSTANT: GL_SLUMINANCE8 0x8C47
CONSTANT: GL_COMPRESSED_SRGB 0x8C48
CONSTANT: GL_COMPRESSED_SRGB_ALPHA 0x8C49
CONSTANT: GL_COMPRESSED_SLUMINANCE 0x8C4A
CONSTANT: GL_COMPRESSED_SLUMINANCE_ALPHA 0x8C4B
CONSTANT: GL_FLOAT_MAT2x3  0x8B65
CONSTANT: GL_FLOAT_MAT2x4  0x8B66
CONSTANT: GL_FLOAT_MAT3x2  0x8B67
CONSTANT: GL_FLOAT_MAT3x4  0x8B68
CONSTANT: GL_FLOAT_MAT4x2  0x8B69
CONSTANT: GL_FLOAT_MAT4x3  0x8B6A

GL-FUNCTION: void glUniformMatrix2x3fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )
GL-FUNCTION: void glUniformMatrix2x4fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )
GL-FUNCTION: void glUniformMatrix3x2fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )
GL-FUNCTION: void glUniformMatrix3x4fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )
GL-FUNCTION: void glUniformMatrix4x2fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )
GL-FUNCTION: void glUniformMatrix4x3fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value )


! OpenGL 3.0


TYPEDEF: ushort  GLhalf

CONSTANT: GL_VERTEX_ATTRIB_ARRAY_INTEGER 0x88FD
CONSTANT: GL_SAMPLER_CUBE_SHADOW 0x8DC5
CONSTANT: GL_UNSIGNED_INT_VEC2 0x8DC6
CONSTANT: GL_UNSIGNED_INT_VEC3 0x8DC7
CONSTANT: GL_UNSIGNED_INT_VEC4 0x8DC8
CONSTANT: GL_INT_SAMPLER_1D 0x8DC9
CONSTANT: GL_INT_SAMPLER_2D 0x8DCA
CONSTANT: GL_INT_SAMPLER_3D 0x8DCB
CONSTANT: GL_INT_SAMPLER_CUBE 0x8DCC
CONSTANT: GL_INT_SAMPLER_2D_RECT 0x8DCD
CONSTANT: GL_INT_SAMPLER_1D_ARRAY 0x8DCE
CONSTANT: GL_INT_SAMPLER_2D_ARRAY 0x8DCF
CONSTANT: GL_UNSIGNED_INT_SAMPLER_1D 0x8DD1
CONSTANT: GL_UNSIGNED_INT_SAMPLER_2D 0x8DD2
CONSTANT: GL_UNSIGNED_INT_SAMPLER_3D 0x8DD3
CONSTANT: GL_UNSIGNED_INT_SAMPLER_CUBE 0x8DD4
CONSTANT: GL_UNSIGNED_INT_SAMPLER_2D_RECT 0x8DD5
CONSTANT: GL_UNSIGNED_INT_SAMPLER_1D_ARRAY 0x8DD6
CONSTANT: GL_UNSIGNED_INT_SAMPLER_2D_ARRAY 0x8DD7
CONSTANT: GL_MIN_PROGRAM_TEXEL_OFFSET 0x8904
CONSTANT: GL_MAX_PROGRAM_TEXEL_OFFSET 0x8905

CONSTANT: GL_RGBA32F 0x8814
CONSTANT: GL_RGB32F 0x8815
CONSTANT: GL_RGBA16F 0x881A
CONSTANT: GL_RGB16F 0x881B
CONSTANT: GL_TEXTURE_RED_TYPE 0x8C10
CONSTANT: GL_TEXTURE_GREEN_TYPE 0x8C11
CONSTANT: GL_TEXTURE_BLUE_TYPE 0x8C12
CONSTANT: GL_TEXTURE_ALPHA_TYPE 0x8C13
CONSTANT: GL_TEXTURE_DEPTH_TYPE 0x8C16
CONSTANT: GL_UNSIGNED_NORMALIZED 0x8C17

CONSTANT: GL_QUERY_WAIT               0x8E13
CONSTANT: GL_QUERY_NO_WAIT            0x8E14
CONSTANT: GL_QUERY_BY_REGION_WAIT     0x8E15
CONSTANT: GL_QUERY_BY_REGION_NO_WAIT  0x8E16

CONSTANT: GL_HALF_FLOAT 0x140B

CONSTANT: GL_MAP_READ_BIT                   0x0001
CONSTANT: GL_MAP_WRITE_BIT                  0x0002
CONSTANT: GL_MAP_INVALIDATE_RANGE_BIT       0x0004
CONSTANT: GL_MAP_INVALIDATE_BUFFER_BIT      0x0008
CONSTANT: GL_MAP_FLUSH_EXPLICIT_BIT         0x0010
CONSTANT: GL_MAP_UNSYNCHRONIZED_BIT         0x0020

CONSTANT: GL_R8              0x8229
CONSTANT: GL_R16             0x822A
CONSTANT: GL_RG8             0x822B
CONSTANT: GL_RG16            0x822C
CONSTANT: GL_R16F            0x822D
CONSTANT: GL_R32F            0x822E
CONSTANT: GL_RG16F           0x822F
CONSTANT: GL_RG32F           0x8230
CONSTANT: GL_R8I             0x8231
CONSTANT: GL_R8UI            0x8232
CONSTANT: GL_R16I            0x8233
CONSTANT: GL_R16UI           0x8234
CONSTANT: GL_R32I            0x8235
CONSTANT: GL_R32UI           0x8236
CONSTANT: GL_RG8I            0x8237
CONSTANT: GL_RG8UI           0x8238
CONSTANT: GL_RG16I           0x8239
CONSTANT: GL_RG16UI          0x823A
CONSTANT: GL_RG32I           0x823B
CONSTANT: GL_RG32UI          0x823C
CONSTANT: GL_RG              0x8227
CONSTANT: GL_COMPRESSED_RED  0x8225
CONSTANT: GL_COMPRESSED_RG   0x8226
CONSTANT: GL_RG_INTEGER      0x8228

CONSTANT: GL_VERTEX_ARRAY_BINDING 0x85B5

CONSTANT: GL_CLAMP_READ_COLOR      0x891C
CONSTANT: GL_FIXED_ONLY            0x891D

CONSTANT: GL_DEPTH_COMPONENT32F  0x8CAC
CONSTANT: GL_DEPTH32F_STENCIL8   0x8CAD

CONSTANT: GL_RGB9_E5                   0x8C3D
CONSTANT: GL_UNSIGNED_INT_5_9_9_9_REV  0x8C3E
CONSTANT: GL_TEXTURE_SHARED_SIZE       0x8C3F

CONSTANT: GL_R11F_G11F_B10F                0x8C3A
CONSTANT: GL_UNSIGNED_INT_10F_11F_11F_REV  0x8C3B

CONSTANT: GL_INVALID_FRAMEBUFFER_OPERATION 0x0506
CONSTANT: GL_MAX_RENDERBUFFER_SIZE 0x84E8
CONSTANT: GL_FRAMEBUFFER_BINDING 0x8CA6
CONSTANT: GL_RENDERBUFFER_BINDING 0x8CA7
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE 0x8CD0
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME 0x8CD1
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL 0x8CD2
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE 0x8CD3
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING 0x8210
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE 0x8211
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE 0x8212
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE 0x8213
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE 0x8214
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE 0x8215
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE 0x8216
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE 0x8217
CONSTANT: GL_FRAMEBUFFER_DEFAULT      0x8218
CONSTANT: GL_FRAMEBUFFER_UNDEFINED    0x8219
CONSTANT: GL_DEPTH_STENCIL_ATTACHMENT 0x821A
CONSTANT: GL_FRAMEBUFFER_COMPLETE 0x8CD5
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT 0x8CD6
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT 0x8CD7
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER 0x8CDB
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER 0x8CDC
CONSTANT: GL_FRAMEBUFFER_UNSUPPORTED 0x8CDD
CONSTANT: GL_MAX_COLOR_ATTACHMENTS 0x8CDF
CONSTANT: GL_COLOR_ATTACHMENT0 0x8CE0
CONSTANT: GL_COLOR_ATTACHMENT1 0x8CE1
CONSTANT: GL_COLOR_ATTACHMENT2 0x8CE2
CONSTANT: GL_COLOR_ATTACHMENT3 0x8CE3
CONSTANT: GL_COLOR_ATTACHMENT4 0x8CE4
CONSTANT: GL_COLOR_ATTACHMENT5 0x8CE5
CONSTANT: GL_COLOR_ATTACHMENT6 0x8CE6
CONSTANT: GL_COLOR_ATTACHMENT7 0x8CE7
CONSTANT: GL_COLOR_ATTACHMENT8 0x8CE8
CONSTANT: GL_COLOR_ATTACHMENT9 0x8CE9
CONSTANT: GL_COLOR_ATTACHMENT10 0x8CEA
CONSTANT: GL_COLOR_ATTACHMENT11 0x8CEB
CONSTANT: GL_COLOR_ATTACHMENT12 0x8CEC
CONSTANT: GL_COLOR_ATTACHMENT13 0x8CED
CONSTANT: GL_COLOR_ATTACHMENT14 0x8CEE
CONSTANT: GL_COLOR_ATTACHMENT15 0x8CEF
CONSTANT: GL_DEPTH_ATTACHMENT 0x8D00
CONSTANT: GL_STENCIL_ATTACHMENT 0x8D20
CONSTANT: GL_FRAMEBUFFER 0x8D40
CONSTANT: GL_RENDERBUFFER 0x8D41
CONSTANT: GL_RENDERBUFFER_WIDTH 0x8D42
CONSTANT: GL_RENDERBUFFER_HEIGHT 0x8D43
CONSTANT: GL_RENDERBUFFER_INTERNAL_FORMAT 0x8D44
CONSTANT: GL_STENCIL_INDEX1 0x8D46
CONSTANT: GL_STENCIL_INDEX4 0x8D47
CONSTANT: GL_STENCIL_INDEX8 0x8D48
CONSTANT: GL_STENCIL_INDEX16 0x8D49
CONSTANT: GL_RENDERBUFFER_RED_SIZE 0x8D50
CONSTANT: GL_RENDERBUFFER_GREEN_SIZE 0x8D51
CONSTANT: GL_RENDERBUFFER_BLUE_SIZE 0x8D52
CONSTANT: GL_RENDERBUFFER_ALPHA_SIZE 0x8D53
CONSTANT: GL_RENDERBUFFER_DEPTH_SIZE 0x8D54
CONSTANT: GL_RENDERBUFFER_STENCIL_SIZE 0x8D55

CONSTANT: GL_READ_FRAMEBUFFER 0x8CA8
CONSTANT: GL_DRAW_FRAMEBUFFER 0x8CA9

ALIAS: GL_DRAW_FRAMEBUFFER_BINDING GL_FRAMEBUFFER_BINDING
CONSTANT: GL_READ_FRAMEBUFFER_BINDING 0x8CAA

CONSTANT: GL_RENDERBUFFER_SAMPLES 0x8CAB
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE 0x8D56
CONSTANT: GL_MAX_SAMPLES 0x8D57

CONSTANT: GL_DEPTH_STENCIL         0x84F9
CONSTANT: GL_UNSIGNED_INT_24_8     0x84FA
CONSTANT: GL_DEPTH24_STENCIL8      0x88F0
CONSTANT: GL_TEXTURE_STENCIL_SIZE  0x88F1

CONSTANT: GL_RGBA32UI 0x8D70
CONSTANT: GL_RGB32UI 0x8D71

CONSTANT: GL_RGBA16UI 0x8D76
CONSTANT: GL_RGB16UI 0x8D77

CONSTANT: GL_RGBA8UI 0x8D7C
CONSTANT: GL_RGB8UI 0x8D7D

CONSTANT: GL_RGBA32I 0x8D82
CONSTANT: GL_RGB32I 0x8D83

CONSTANT: GL_RGBA16I 0x8D88
CONSTANT: GL_RGB16I 0x8D89

CONSTANT: GL_RGBA8I 0x8D8E
CONSTANT: GL_RGB8I 0x8D8F

CONSTANT: GL_RED_INTEGER 0x8D94
CONSTANT: GL_GREEN_INTEGER 0x8D95
CONSTANT: GL_BLUE_INTEGER 0x8D96
CONSTANT: GL_RGB_INTEGER 0x8D98
CONSTANT: GL_RGBA_INTEGER 0x8D99
CONSTANT: GL_BGR_INTEGER 0x8D9A
CONSTANT: GL_BGRA_INTEGER 0x8D9B

CONSTANT: GL_FLOAT_32_UNSIGNED_INT_24_8_REV  0x8DAD

CONSTANT: GL_TEXTURE_1D_ARRAY                      0x8C18
CONSTANT: GL_TEXTURE_2D_ARRAY                      0x8C1A

CONSTANT: GL_PROXY_TEXTURE_2D_ARRAY                0x8C1B

CONSTANT: GL_PROXY_TEXTURE_1D_ARRAY                0x8C19

CONSTANT: GL_TEXTURE_BINDING_1D_ARRAY              0x8C1C
CONSTANT: GL_TEXTURE_BINDING_2D_ARRAY              0x8C1D
CONSTANT: GL_MAX_ARRAY_TEXTURE_LAYERS              0x88FF

CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER  0x8CD4

CONSTANT: GL_SAMPLER_1D_ARRAY                      0x8DC0
CONSTANT: GL_SAMPLER_2D_ARRAY                      0x8DC1
CONSTANT: GL_SAMPLER_1D_ARRAY_SHADOW               0x8DC3
CONSTANT: GL_SAMPLER_2D_ARRAY_SHADOW               0x8DC4

CONSTANT: GL_COMPRESSED_RED_RGTC1               0x8DBB
CONSTANT: GL_COMPRESSED_SIGNED_RED_RGTC1        0x8DBC
CONSTANT: GL_COMPRESSED_RG_RGTC2            0x8DBD
CONSTANT: GL_COMPRESSED_SIGNED_RG_RGTC2     0x8DBE

CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER 0x8C8E
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_START 0x8C84
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_SIZE 0x8C85
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_BINDING 0x8C8F
CONSTANT: GL_INTERLEAVED_ATTRIBS 0x8C8C
CONSTANT: GL_SEPARATE_ATTRIBS 0x8C8D
CONSTANT: GL_PRIMITIVES_GENERATED 0x8C87
CONSTANT: GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN 0x8C88
CONSTANT: GL_RASTERIZER_DISCARD 0x8C89
CONSTANT: GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS 0x8C8A
CONSTANT: GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS 0x8C8B
CONSTANT: GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS 0x8C80
CONSTANT: GL_TRANSFORM_FEEDBACK_VARYINGS 0x8C83
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_MODE 0x8C7F
CONSTANT: GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH 0x8C76

CONSTANT: GL_FRAMEBUFFER_SRGB          0x8DB9

CONSTANT: GL_MAJOR_VERSION                  0x821B
CONSTANT: GL_MINOR_VERSION                  0x821C
CONSTANT: GL_NUM_EXTENSIONS                 0x821D
CONSTANT: GL_CONTEXT_FLAGS                  0x821E
CONSTANT: GL_INDEX                          0x8222
CONSTANT: GL_DEPTH_BUFFER                   0x8223
CONSTANT: GL_STENCIL_BUFFER                 0x8224
CONSTANT: GL_CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT 0x0001

ALIAS: GL_COMPARE_REF_TO_TEXTURE GL_COMPARE_R_TO_TEXTURE
ALIAS: GL_MAX_VARYING_COMPONENTS GL_MAX_VARYING_FLOATS
ALIAS: GL_MAX_CLIP_DISTANCES GL_MAX_CLIP_PLANES
ALIAS: GL_CLIP_DISTANCE0 GL_CLIP_PLANE0
ALIAS: GL_CLIP_DISTANCE1 GL_CLIP_PLANE1
ALIAS: GL_CLIP_DISTANCE2 GL_CLIP_PLANE2
ALIAS: GL_CLIP_DISTANCE3 GL_CLIP_PLANE3
ALIAS: GL_CLIP_DISTANCE4 GL_CLIP_PLANE4
ALIAS: GL_CLIP_DISTANCE5 GL_CLIP_PLANE5

GL-FUNCTION: void glVertexAttribIPointer { glVertexAttribIPointerEXT } ( GLuint index, GLint size, GLenum type, GLsizei stride, void* pointer )

GL-FUNCTION: void glGetVertexAttribIiv { glGetVertexAttribIivEXT } ( GLuint index, GLenum pname, GLint* params )
GL-FUNCTION: void glGetVertexAttribIuiv { glGetVertexAttribIuivEXT } ( GLuint index, GLenum pname, GLuint* params )

GL-FUNCTION: void glUniform1ui { glUniform1uiEXT } ( GLint location, GLuint v0 )
GL-FUNCTION: void glUniform2ui { glUniform2uiEXT } ( GLint location, GLuint v0, GLuint v1 )
GL-FUNCTION: void glUniform3ui { glUniform3uiEXT } ( GLint location, GLuint v0, GLuint v1, GLuint v2 )
GL-FUNCTION: void glUniform4ui { glUniform4uiEXT } ( GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3 )

GL-FUNCTION: void glUniform1uiv { glUniform1uivEXT } ( GLint location, GLsizei count, GLuint* value )
GL-FUNCTION: void glUniform2uiv { glUniform2uivEXT } ( GLint location, GLsizei count, GLuint* value )
GL-FUNCTION: void glUniform3uiv { glUniform3uivEXT } ( GLint location, GLsizei count, GLuint* value )
GL-FUNCTION: void glUniform4uiv { glUniform4uivEXT } ( GLint location, GLsizei count, GLuint* value )

GL-FUNCTION: void glGetUniformuiv { glGetUniformuivEXT } ( GLuint program, GLint location, GLuint* params )

GL-FUNCTION: void glBindFragDataLocation { glBindFragDataLocationEXT } ( GLuint program, GLuint colorNumber, GLstring name )
GL-FUNCTION: GLint glGetFragDataLocation { glGetFragDataLocationEXT } ( GLuint program, GLstring name )

GL-FUNCTION: void glBeginConditionalRender { glBeginConditionalRenderNV } ( GLuint id, GLenum mode )
GL-FUNCTION: void glEndConditionalRender { glEndConditionalRenderNV } ( )

GL-FUNCTION: void glBindVertexArray { glBindVertexArrayAPPLE } ( GLuint array )
GL-FUNCTION: void glDeleteVertexArrays { glDeleteVertexArraysAPPLE } ( GLsizei n, GLuint* arrays )
GL-FUNCTION: void glGenVertexArrays { glGenVertexArraysAPPLE } ( GLsizei n, GLuint* arrays )
GL-FUNCTION: GLboolean glIsVertexArray { glIsVertexArrayAPPLE } ( GLuint array )

GL-FUNCTION: void glClampColor { glClampColorARB } ( GLenum target, GLenum clamp )

GL-FUNCTION: void glBindFramebuffer { glBindFramebufferEXT } ( GLenum target, GLuint framebuffer )
GL-FUNCTION: void glBindRenderbuffer { glBindRenderbufferEXT } ( GLenum target, GLuint renderbuffer )
GL-FUNCTION: GLenum glCheckFramebufferStatus { glCheckFramebufferStatusEXT } ( GLenum target )
GL-FUNCTION: void glDeleteFramebuffers { glDeleteFramebuffersEXT } ( GLsizei n, GLuint* framebuffers )
GL-FUNCTION: void glDeleteRenderbuffers { glDeleteRenderbuffersEXT } ( GLsizei n, GLuint* renderbuffers )
GL-FUNCTION: void glFramebufferRenderbuffer { glFramebufferRenderbufferEXT } ( GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer )
GL-FUNCTION: void glFramebufferTexture1D { glFramebufferTexture1DEXT } ( GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level )
GL-FUNCTION: void glFramebufferTexture2D { glFramebufferTexture2DEXT } ( GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level )
GL-FUNCTION: void glFramebufferTexture3D { glFramebufferTexture3DEXT } ( GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset )
GL-FUNCTION: void glFramebufferTextureLayer { glFramebufferTextureLayerEXT }
    ( GLenum target, GLenum attachment,
      GLuint texture, GLint level, GLint layer )
GL-FUNCTION: void glGenFramebuffers { glGenFramebuffersEXT } ( GLsizei n, GLuint* framebuffers )
GL-FUNCTION: void glGenRenderbuffers { glGenRenderbuffersEXT } ( GLsizei n, GLuint* renderbuffers )
GL-FUNCTION: void glGenerateMipmap { glGenerateMipmapEXT } ( GLenum target )
GL-FUNCTION: void glGetFramebufferAttachmentParameteriv { glGetFramebufferAttachmentParameterivEXT } ( GLenum target, GLenum attachment, GLenum pname, GLint* params )
GL-FUNCTION: void glGetRenderbufferParameteriv { glGetRenderbufferParameterivEXT } ( GLenum target, GLenum pname, GLint* params )
GL-FUNCTION: GLboolean glIsFramebuffer { glIsFramebufferEXT } ( GLuint framebuffer )
GL-FUNCTION: GLboolean glIsRenderbuffer { glIsRenderbufferEXT } ( GLuint renderbuffer )
GL-FUNCTION: void glRenderbufferStorage { glRenderbufferStorageEXT } ( GLenum target, GLenum internalformat, GLsizei width, GLsizei height )

GL-FUNCTION: void glBlitFramebuffer { glBlitFramebufferEXT }
                                           ( GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1,
                                             GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1,
                                             GLbitfield mask, GLenum filter )

GL-FUNCTION: void glRenderbufferStorageMultisample { glRenderbufferStorageMultisampleEXT } (
            GLenum target, GLsizei samples,
            GLenum internalformat,
            GLsizei width, GLsizei height )

GL-FUNCTION: void glTexParameterIiv { glTexParameterIivEXT } ( GLenum target, GLenum pname, GLint* params )
GL-FUNCTION: void glTexParameterIuiv { glTexParameterIuivEXT } ( GLenum target, GLenum pname, GLuint* params )
GL-FUNCTION: void glGetTexParameterIiv { glGetTexParameterIivEXT } ( GLenum target, GLenum pname, GLint* params )
GL-FUNCTION: void glGetTexParameterIuiv { glGetTexParameterIuivEXT } ( GLenum target, GLenum pname, GLuint* params )

GL-FUNCTION: void glColorMaski { glColorMaskIndexedEXT }
    ( GLuint buf, GLboolean r, GLboolean g, GLboolean b, GLboolean a )

GL-FUNCTION: void glGetBooleani_v { glGetBooleanIndexedvEXT } ( GLenum value, GLuint index, GLboolean* data )

GL-FUNCTION: void glGetIntegeri_v { glGetIntegerIndexedvEXT } ( GLenum value, GLuint index, GLint* data )

GL-FUNCTION: void glEnablei { glEnableIndexedEXT } ( GLenum target, GLuint index )

GL-FUNCTION: void glDisablei { glDisableIndexedEXT } ( GLenum target, GLuint index )

GL-FUNCTION: GLboolean glIsEnabledi { glIsEnabledIndexedEXT } ( GLenum target, GLuint index )

GL-FUNCTION: void glBindBufferRange { glBindBufferRangeEXT } ( GLenum target, GLuint index, GLuint buffer,
                           GLintptr offset, GLsizeiptr size )
GL-FUNCTION: void glBindBufferBase { glBindBufferBaseEXT } ( GLenum target, GLuint index, GLuint buffer )

GL-FUNCTION: void glBeginTransformFeedback { glBeginTransformFeedbackEXT } ( GLenum primitiveMode )
GL-FUNCTION: void glEndTransformFeedback { glEndTransformFeedbackEXT } ( )

GL-FUNCTION: void glTransformFeedbackVaryings { glTransformFeedbackVaryingsEXT } ( GLuint program, GLsizei count,
                                      GLstring* varyings, GLenum bufferMode )
GL-FUNCTION: void glGetTransformFeedbackVarying { glGetTransformFeedbackVaryingEXT } ( GLuint program, GLuint index,
                                        GLsizei bufSize, GLsizei* length,
                                        GLsizei* size, GLenum* type, GLstring name )

GL-FUNCTION: void glClearBufferiv  { } ( GLenum buffer, GLint drawbuffer, GLint* value )
GL-FUNCTION: void glClearBufferuiv { } ( GLenum buffer, GLint drawbuffer, GLuint* value )
GL-FUNCTION: void glClearBufferfv  { } ( GLenum buffer, GLint drawbuffer, GLfloat* value )
GL-FUNCTION: void glClearBufferfi  { } ( GLenum buffer, GLint drawbuffer, GLfloat depth, GLint stencil )

GL-FUNCTION: GLubyte* glGetStringi { } ( GLenum value, GLuint index )

GL-FUNCTION: GLvoid* glMapBufferRange { } ( GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access )
GL-FUNCTION: void glFlushMappedBufferRange { glFlushMappedBufferRangeAPPLE } ( GLenum target, GLintptr offset, GLsizeiptr size )


! OpenGL 3.1

CONSTANT: GL_RED_SNORM                    0x8F90
CONSTANT: GL_RG_SNORM                     0x8F91
CONSTANT: GL_RGB_SNORM                    0x8F92
CONSTANT: GL_RGBA_SNORM                   0x8F93
CONSTANT: GL_R8_SNORM                     0x8F94
CONSTANT: GL_RG8_SNORM                    0x8F95
CONSTANT: GL_RGB8_SNORM                   0x8F96
CONSTANT: GL_RGBA8_SNORM                  0x8F97
CONSTANT: GL_R16_SNORM                    0x8F98
CONSTANT: GL_RG16_SNORM                   0x8F99
CONSTANT: GL_RGB16_SNORM                  0x8F9A
CONSTANT: GL_RGBA16_SNORM                 0x8F9B
CONSTANT: GL_SIGNED_NORMALIZED            0x8F9C

CONSTANT: GL_PRIMITIVE_RESTART            0x8F9D
CONSTANT: GL_PRIMITIVE_RESTART_INDEX      0x8F9E

CONSTANT: GL_COPY_READ_BUFFER             0x8F36
CONSTANT: GL_COPY_WRITE_BUFFER            0x8F37

CONSTANT: GL_UNIFORM_BUFFER                 0x8A11
CONSTANT: GL_UNIFORM_BUFFER_BINDING         0x8A28
CONSTANT: GL_UNIFORM_BUFFER_START           0x8A29
CONSTANT: GL_UNIFORM_BUFFER_SIZE            0x8A2A
CONSTANT: GL_MAX_VERTEX_UNIFORM_BLOCKS      0x8A2B
CONSTANT: GL_MAX_GEOMETRY_UNIFORM_BLOCKS    0x8A2C
CONSTANT: GL_MAX_FRAGMENT_UNIFORM_BLOCKS    0x8A2D
CONSTANT: GL_MAX_COMBINED_UNIFORM_BLOCKS    0x8A2E
CONSTANT: GL_MAX_UNIFORM_BUFFER_BINDINGS    0x8A2F
CONSTANT: GL_MAX_UNIFORM_BLOCK_SIZE         0x8A30
CONSTANT: GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS 0x8A31
CONSTANT: GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS 0x8A32
CONSTANT: GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS 0x8A33
CONSTANT: GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT 0x8A34
CONSTANT: GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH 0x8A35
CONSTANT: GL_ACTIVE_UNIFORM_BLOCKS          0x8A36
CONSTANT: GL_UNIFORM_TYPE                   0x8A37
CONSTANT: GL_UNIFORM_SIZE                   0x8A38
CONSTANT: GL_UNIFORM_NAME_LENGTH            0x8A39
CONSTANT: GL_UNIFORM_BLOCK_INDEX            0x8A3A
CONSTANT: GL_UNIFORM_OFFSET                 0x8A3B
CONSTANT: GL_UNIFORM_ARRAY_STRIDE           0x8A3C
CONSTANT: GL_UNIFORM_MATRIX_STRIDE          0x8A3D
CONSTANT: GL_UNIFORM_IS_ROW_MAJOR           0x8A3E
CONSTANT: GL_UNIFORM_BLOCK_BINDING          0x8A3F
CONSTANT: GL_UNIFORM_BLOCK_DATA_SIZE        0x8A40
CONSTANT: GL_UNIFORM_BLOCK_NAME_LENGTH      0x8A41
CONSTANT: GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS  0x8A42
CONSTANT: GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES 0x8A43
CONSTANT: GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER 0x8A44
CONSTANT: GL_UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER 0x8A45
CONSTANT: GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER 0x8A46
CONSTANT: GL_INVALID_INDEX                  0xFFFFFFFF

CONSTANT: GL_TEXTURE_RECTANGLE            0x84F5
CONSTANT: GL_TEXTURE_BINDING_RECTANGLE    0x84F6
CONSTANT: GL_PROXY_TEXTURE_RECTANGLE      0x84F7
CONSTANT: GL_MAX_RECTANGLE_TEXTURE_SIZE   0x84F8
CONSTANT: GL_SAMPLER_2D_RECT              0x8B63
CONSTANT: GL_SAMPLER_2D_RECT_SHADOW       0x8B64

CONSTANT: GL_SAMPLER_BUFFER 0x8DC2
CONSTANT: GL_INT_SAMPLER_BUFFER 0x8DD0
CONSTANT: GL_UNSIGNED_INT_SAMPLER_BUFFER 0x8DD8

CONSTANT: GL_TEXTURE_BUFFER 0x8C2A

CONSTANT: GL_MAX_TEXTURE_BUFFER_SIZE            0x8C2B
CONSTANT: GL_TEXTURE_BINDING_BUFFER             0x8C2C
CONSTANT: GL_TEXTURE_BUFFER_DATA_STORE_BINDING  0x8C2D
CONSTANT: GL_TEXTURE_BUFFER_FORMAT              0x8C2E

GL-FUNCTION: void glDrawArraysInstanced { glDrawArraysInstancedARB } ( GLenum mode, GLint first, GLsizei count, GLsizei primcount )
GL-FUNCTION: void glDrawElementsInstanced { glDrawElementsInstancedARB } ( GLenum mode, GLsizei count, GLenum type, GLvoid* indices, GLsizei primcount )
GL-FUNCTION: void glTexBuffer { glTexBufferEXT } ( GLenum target, GLenum internalformat, GLuint buffer )
GL-FUNCTION: void glPrimitiveRestartIndex { } ( GLuint index )

GL-FUNCTION: void glGetUniformIndices { } ( GLuint program, GLsizei uniformCount, GLstring* uniformNames, GLuint* uniformIndices )
GL-FUNCTION: void glGetActiveUniformsiv { } ( GLuint program, GLsizei uniformCount, GLuint* uniformIndices, GLenum pname, GLint* params )
GL-FUNCTION: void glGetActiveUniformName { } ( GLuint program, GLuint uniformIndex, GLsizei bufSize, GLsizei* length, GLstring uniformName )
GL-FUNCTION: GLuint glGetUniformBlockIndex { } ( GLuint program, GLstring uniformBlockName )
GL-FUNCTION: void glGetActiveUniformBlockiv { } ( GLuint program, GLuint uniformBlockIndex, GLenum pname, GLint* params )
GL-FUNCTION: void glGetActiveUniformBlockName { } ( GLuint program, GLuint uniformBlockIndex, GLsizei bufSize, GLsizei* length, GLstring uniformName )
GL-FUNCTION: void glUniformBlockBinding { } ( GLuint buffer, GLuint uniformBlockIndex, GLuint uniformBlockBinding )

GL-FUNCTION: void glCopyBufferSubData { glCopyBufferSubDataEXT } ( GLenum readtarget, GLenum writetarget, GLintptr readoffset, GLintptr writeoffset, GLsizeiptr size )


! OpenGL 3.2

CONSTANT: GL_CONTEXT_CORE_PROFILE_BIT 0x00000001
CONSTANT: GL_CONTEXT_COMPATIBILITY_PROFILE_BIT 0x00000002
CONSTANT: GL_LINES_ADJACENCY 0x000A
CONSTANT: GL_LINE_STRIP_ADJACENCY 0x000B
CONSTANT: GL_TRIANGLES_ADJACENCY 0x000C
CONSTANT: GL_TRIANGLE_STRIP_ADJACENCY 0x000D
CONSTANT: GL_PROGRAM_POINT_SIZE 0x8642
CONSTANT: GL_GEOMETRY_VERTICES_OUT 0x8916
CONSTANT: GL_GEOMETRY_INPUT_TYPE 0x8917
CONSTANT: GL_GEOMETRY_OUTPUT_TYPE 0x8918
CONSTANT: GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS 0x8C29
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_LAYERED 0x8DA7
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS 0x8DA8
CONSTANT: GL_GEOMETRY_SHADER 0x8DD9
CONSTANT: GL_MAX_GEOMETRY_UNIFORM_COMPONENTS 0x8DDF
CONSTANT: GL_MAX_GEOMETRY_OUTPUT_VERTICES 0x8DE0
CONSTANT: GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS 0x8DE1
CONSTANT: GL_MAX_VERTEX_OUTPUT_COMPONENTS 0x9122
CONSTANT: GL_MAX_GEOMETRY_INPUT_COMPONENTS 0x9123
CONSTANT: GL_MAX_GEOMETRY_OUTPUT_COMPONENTS 0x9124
CONSTANT: GL_MAX_FRAGMENT_INPUT_COMPONENTS 0x9125
CONSTANT: GL_CONTEXT_PROFILE_MASK 0x9126
CONSTANT: GL_MAX_SERVER_WAIT_TIMEOUT        0x9111
CONSTANT: GL_OBJECT_TYPE                    0x9112
CONSTANT: GL_SYNC_CONDITION                 0x9113
CONSTANT: GL_SYNC_STATUS                    0x9114
CONSTANT: GL_SYNC_FLAGS                     0x9115
CONSTANT: GL_SYNC_FENCE                     0x9116
CONSTANT: GL_SYNC_GPU_COMMANDS_COMPLETE     0x9117
CONSTANT: GL_UNSIGNALED                     0x9118
CONSTANT: GL_SIGNALED                       0x9119
CONSTANT: GL_ALREADY_SIGNALED               0x911A
CONSTANT: GL_TIMEOUT_EXPIRED                0x911B
CONSTANT: GL_CONDITION_SATISFIED            0x911C
CONSTANT: GL_WAIT_FAILED                    0x911D
CONSTANT: GL_SYNC_FLUSH_COMMANDS_BIT        0x00000001
CONSTANT: GL_TIMEOUT_IGNORED                0xFFFF,FFFF,FFFF,FFFF
CONSTANT: GL_SAMPLE_POSITION                0x8E50
CONSTANT: GL_SAMPLE_MASK                    0x8E51
CONSTANT: GL_SAMPLE_MASK_VALUE              0x8E52
CONSTANT: GL_MAX_SAMPLE_MASK_WORDS          0x8E59
CONSTANT: GL_TEXTURE_2D_MULTISAMPLE         0x9100
CONSTANT: GL_PROXY_TEXTURE_2D_MULTISAMPLE   0x9101
CONSTANT: GL_TEXTURE_2D_MULTISAMPLE_ARRAY   0x9102
CONSTANT: GL_PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY 0x9103
CONSTANT: GL_TEXTURE_BINDING_2D_MULTISAMPLE 0x9104
CONSTANT: GL_TEXTURE_BINDING_2D_MULTISAMPLE_ARRAY 0x9105
CONSTANT: GL_TEXTURE_SAMPLES                0x9106
CONSTANT: GL_TEXTURE_FIXED_SAMPLE_LOCATIONS 0x9107
CONSTANT: GL_SAMPLER_2D_MULTISAMPLE         0x9108
CONSTANT: GL_INT_SAMPLER_2D_MULTISAMPLE     0x9109
CONSTANT: GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE 0x910A
CONSTANT: GL_SAMPLER_2D_MULTISAMPLE_ARRAY   0x910B
CONSTANT: GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY 0x910C
CONSTANT: GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY 0x910D
CONSTANT: GL_MAX_COLOR_TEXTURE_SAMPLES      0x910E
CONSTANT: GL_MAX_DEPTH_TEXTURE_SAMPLES      0x910F
CONSTANT: GL_MAX_INTEGER_SAMPLES            0x9110
CONSTANT: GL_DEPTH_CLAMP                    0x864F
CONSTANT: GL_QUADS_FOLLOW_PROVOKING_VERTEX_CONVENTION 0x8E4C
CONSTANT: GL_FIRST_VERTEX_CONVENTION        0x8E4D
CONSTANT: GL_LAST_VERTEX_CONVENTION         0x8E4E
CONSTANT: GL_PROVOKING_VERTEX               0x8E4F
CONSTANT: GL_TEXTURE_CUBE_MAP_SEAMLESS      0x884F

GL-FUNCTION: void glFramebufferTexture { glFramebufferTextureARB glFramebufferTextureEXT } ( GLenum target, GLenum attachment, GLuint texture, GLint level )
GL-FUNCTION: void glGetBufferParameteri64v { } ( GLenum target, GLenum pname, GLint64* params )
GL-FUNCTION: void glGetInteger64i_v { } ( GLenum target, GLuint index, GLint64* data )
GL-FUNCTION: void glProvokingVertex { } ( GLenum mode )

GL-FUNCTION: GLsync glFenceSync { } ( GLenum condition, GLbitfield flags )
GL-FUNCTION: GLboolean glIsSync { } ( GLsync sync )
GL-FUNCTION: void glDeleteSync { } ( GLsync sync )
GL-FUNCTION: GLenum glClientWaitSync { } ( GLsync sync, GLbitfield flags, GLuint64 timeout )
GL-FUNCTION: void glWaitSync { } ( GLsync sync, GLbitfield flags, GLuint64 timeout )
GL-FUNCTION: void glGetInteger64v { } ( GLenum pname, GLint64* params )
GL-FUNCTION: void glGetSynciv { } ( GLsync sync, GLenum pname, GLsizei bufSize, GLsizei* length, GLint* values )
GL-FUNCTION: void glTexImage2DMultisample { } ( GLenum target, GLsizei samples, GLint internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations )
GL-FUNCTION: void glTexImage3DMultisample { } ( GLenum target, GLsizei samples, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations )
GL-FUNCTION: void glGetMultisamplefv { } ( GLenum pname, GLuint index, GLfloat* val )
GL-FUNCTION: void glSampleMaski { } ( GLuint index, GLbitfield mask )
GL-FUNCTION: void glDrawElementsBaseVertex { glDrawElementsBaseVertexARB } ( GLenum mode, GLsizei count, GLenum type, GLvoid* indices, GLint basevertex )


! OpenGL 3.3

CONSTANT: GL_SRC1_COLOR                     0x88F9
CONSTANT: GL_ONE_MINUS_SRC1_COLOR           0x88FA
CONSTANT: GL_ONE_MINUS_SRC1_ALPHA           0x88FB
CONSTANT: GL_MAX_DUAL_SOURCE_DRAW_BUFFERS   0x88FC

CONSTANT: GL_ANY_SAMPLES_PASSED             0x8C2F

CONSTANT: GL_SAMPLER_BINDING                0x8919

CONSTANT: GL_RGB10_A2UI                     0x906F

CONSTANT: GL_TEXTURE_SWIZZLE_R              0x8E42
CONSTANT: GL_TEXTURE_SWIZZLE_G              0x8E43
CONSTANT: GL_TEXTURE_SWIZZLE_B              0x8E44
CONSTANT: GL_TEXTURE_SWIZZLE_A              0x8E45
CONSTANT: GL_TEXTURE_SWIZZLE_RGBA           0x8E46

CONSTANT: GL_TIME_ELAPSED                   0x88BF
CONSTANT: GL_TIMESTAMP                      0x8E28

CONSTANT: GL_INT_2_10_10_10_REV             0x8D9F

GL-FUNCTION: void glBindFragDataLocationIndexed { } ( GLuint program, GLuint colorNumber, GLuint index, GLstring name )
GL-FUNCTION: GLint glGetFragDataIndex { } ( GLuint program, GLstring name )

GL-FUNCTION: void glGenSamplers { } ( GLsizei count, GLuint* samplers )
GL-FUNCTION: void glDeleteSamplers { } ( GLsizei count, GLuint* samplers )
GL-FUNCTION: GLboolean glIsSampler { } ( GLuint sampler )
GL-FUNCTION: void glBindSampler { } ( GLenum unit, GLuint sampler )
GL-FUNCTION: void glSamplerParameteri { } ( GLuint sampler, GLenum pname, GLint param )
GL-FUNCTION: void glSamplerParameteriv { } ( GLuint sampler, GLenum pname, GLint* param )
GL-FUNCTION: void glSamplerParameterf { } ( GLuint sampler, GLenum pname, GLfloat param )
GL-FUNCTION: void glSamplerParameterfv { } ( GLuint sampler, GLenum pname, GLfloat* param )
GL-FUNCTION: void glSamplerParameterIiv { } ( GLuint sampler, GLenum pname, GLint* param )
GL-FUNCTION: void glSamplerParameterIuiv { } ( GLuint sampler, GLenum pname, GLuint* param )
GL-FUNCTION: void glGetSamplerParameteriv { } ( GLuint sampler, GLenum pname, GLint* params )
GL-FUNCTION: void glGetSamplerParameterIiv { } ( GLuint sampler, GLenum pname, GLint* params )
GL-FUNCTION: void glGetSamplerParameterfv { } ( GLuint sampler, GLenum pname, GLfloat* params )
GL-FUNCTION: void glGetSamplerParameterIfv { } ( GLuint sampler, GLenum pname, GLfloat* params )

GL-FUNCTION: void glQueryCounter { } ( GLuint id, GLenum target )
GL-FUNCTION: void glGetQueryObjecti64v { } ( GLuint id, GLenum pname, GLint64* params )
GL-FUNCTION: void glGetQueryObjectui64v { } ( GLuint id, GLenum pname, GLuint64* params )

GL-FUNCTION: void glVertexP2ui { } ( GLenum type, GLuint value )
GL-FUNCTION: void glVertexP2uiv { } ( GLenum type, GLuint* value )
GL-FUNCTION: void glVertexP3ui { } ( GLenum type, GLuint value )
GL-FUNCTION: void glVertexP3uiv { } ( GLenum type, GLuint* value )
GL-FUNCTION: void glVertexP4ui { } ( GLenum type, GLuint value )
GL-FUNCTION: void glVertexP4uiv { } ( GLenum type, GLuint* value )
GL-FUNCTION: void glTexCoordP1ui { } ( GLenum type, GLuint coords )
GL-FUNCTION: void glTexCoordP1uiv { } ( GLenum type, GLuint* coords )
GL-FUNCTION: void glTexCoordP2ui { } ( GLenum type, GLuint coords )
GL-FUNCTION: void glTexCoordP2uiv { } ( GLenum type, GLuint* coords )
GL-FUNCTION: void glTexCoordP3ui { } ( GLenum type, GLuint coords )
GL-FUNCTION: void glTexCoordP3uiv { } ( GLenum type, GLuint* coords )
GL-FUNCTION: void glTexCoordP4ui { } ( GLenum type, GLuint coords )
GL-FUNCTION: void glTexCoordP4uiv { } ( GLenum type, GLuint* coords )
GL-FUNCTION: void glMultiTexCoordP1ui { } ( GLenum texture, GLenum type, GLuint coords )
GL-FUNCTION: void glMultiTexCoordP1uiv { } ( GLenum texture, GLenum type, GLuint* coords )
GL-FUNCTION: void glMultiTexCoordP2ui { } ( GLenum texture, GLenum type, GLuint coords )
GL-FUNCTION: void glMultiTexCoordP2uiv { } ( GLenum texture, GLenum type, GLuint* coords )
GL-FUNCTION: void glMultiTexCoordP3ui { } ( GLenum texture, GLenum type, GLuint coords )
GL-FUNCTION: void glMultiTexCoordP3uiv { } ( GLenum texture, GLenum type, GLuint* coords )
GL-FUNCTION: void glMultiTexCoordP4ui { } ( GLenum texture, GLenum type, GLuint coords )
GL-FUNCTION: void glMultiTexCoordP4uiv { } ( GLenum texture, GLenum type, GLuint* coords )
GL-FUNCTION: void glNormalP3ui { } ( GLenum type, GLuint coords )
GL-FUNCTION: void glNormalP3uiv { } ( GLenum type, GLuint* coords )
GL-FUNCTION: void glColorP3ui { } ( GLenum type, GLuint color )
GL-FUNCTION: void glColorP3uiv { } ( GLenum type, GLuint* color )
GL-FUNCTION: void glColorP4ui { } ( GLenum type, GLuint color )
GL-FUNCTION: void glColorP4uiv { } ( GLenum type, GLuint* color )
GL-FUNCTION: void glSecondaryColorP3ui { } ( GLenum type, GLuint color )
GL-FUNCTION: void glSecondaryColorP3uiv { } ( GLenum type, GLuint* color )
GL-FUNCTION: void glVertexAttribP1ui { } ( GLuint index, GLenum type, GLboolean normalized, GLuint value )
GL-FUNCTION: void glVertexAttribP1uiv { } ( GLuint index, GLenum type, GLboolean normalized, GLuint* value )
GL-FUNCTION: void glVertexAttribP2ui { } ( GLuint index, GLenum type, GLboolean normalized, GLuint value )
GL-FUNCTION: void glVertexAttribP2uiv { } ( GLuint index, GLenum type, GLboolean normalized, GLuint* value )
GL-FUNCTION: void glVertexAttribP3ui { } ( GLuint index, GLenum type, GLboolean normalized, GLuint value )
GL-FUNCTION: void glVertexAttribP3uiv { } ( GLuint index, GLenum type, GLboolean normalized, GLuint* value )
GL-FUNCTION: void glVertexAttribP4ui { } ( GLuint index, GLenum type, GLboolean normalized, GLuint value )
GL-FUNCTION: void glVertexAttribP4uiv { } ( GLuint index, GLenum type, GLboolean normalized, GLuint* value )


! OpenGL 4.0

CONSTANT: GL_DRAW_INDIRECT_BUFFER           0x8F3F
CONSTANT: GL_DRAW_INDIRECT_BUFFER_BINDING   0x8F43

CONSTANT: GL_GEOMETRY_SHADER_INVOCATIONS    0x887F
CONSTANT: GL_MAX_GEOMETRY_SHADER_INVOCATIONS 0x8E5A
CONSTANT: GL_MIN_FRAGMENT_INTERPOLATION_OFFSET 0x8E5B
CONSTANT: GL_MAX_FRAGMENT_INTERPOLATION_OFFSET 0x8E5C
CONSTANT: GL_FRAGMENT_INTERPOLATION_OFFSET_BITS 0x8E5D
CONSTANT: GL_MAX_VERTEX_STREAMS             0x8E71

CONSTANT: GL_DOUBLE_VEC2                    0x8FFC
CONSTANT: GL_DOUBLE_VEC3                    0x8FFD
CONSTANT: GL_DOUBLE_VEC4                    0x8FFE
CONSTANT: GL_DOUBLE_MAT2                    0x8F46
CONSTANT: GL_DOUBLE_MAT3                    0x8F47
CONSTANT: GL_DOUBLE_MAT4                    0x8F48
CONSTANT: GL_DOUBLE_MAT2x3                  0x8F49
CONSTANT: GL_DOUBLE_MAT2x4                  0x8F4A
CONSTANT: GL_DOUBLE_MAT3x2                  0x8F4B
CONSTANT: GL_DOUBLE_MAT3x4                  0x8F4C
CONSTANT: GL_DOUBLE_MAT4x2                  0x8F4D
CONSTANT: GL_DOUBLE_MAT4x3                  0x8F4E

CONSTANT: GL_ACTIVE_SUBROUTINES             0x8DE5
CONSTANT: GL_ACTIVE_SUBROUTINE_UNIFORMS     0x8DE6
CONSTANT: GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS 0x8E47
CONSTANT: GL_ACTIVE_SUBROUTINE_MAX_LENGTH   0x8E48
CONSTANT: GL_ACTIVE_SUBROUTINE_UNIFORM_MAX_LENGTH 0x8E49
CONSTANT: GL_MAX_SUBROUTINES                0x8DE7
CONSTANT: GL_MAX_SUBROUTINE_UNIFORM_LOCATIONS 0x8DE8
CONSTANT: GL_NUM_COMPATIBLE_SUBROUTINES     0x8E4A
CONSTANT: GL_COMPATIBLE_SUBROUTINES         0x8E4B

CONSTANT: GL_PATCHES                        0x000E
CONSTANT: GL_PATCH_VERTICES                 0x8E72
CONSTANT: GL_PATCH_DEFAULT_INNER_LEVEL      0x8E73
CONSTANT: GL_PATCH_DEFAULT_OUTER_LEVEL      0x8E74
CONSTANT: GL_TESS_CONTROL_OUTPUT_VERTICES   0x8E75
CONSTANT: GL_TESS_GEN_MODE                  0x8E76
CONSTANT: GL_TESS_GEN_SPACING               0x8E77
CONSTANT: GL_TESS_GEN_VERTEX_ORDER          0x8E78
CONSTANT: GL_TESS_GEN_POINT_MODE            0x8E79
CONSTANT: GL_ISOLINES                       0x8E7A
CONSTANT: GL_FRACTIONAL_ODD                 0x8E7B
CONSTANT: GL_FRACTIONAL_EVEN                0x8E7C
CONSTANT: GL_MAX_PATCH_VERTICES             0x8E7D
CONSTANT: GL_MAX_TESS_GEN_LEVEL             0x8E7E
CONSTANT: GL_MAX_TESS_CONTROL_UNIFORM_COMPONENTS 0x8E7F
CONSTANT: GL_MAX_TESS_EVALUATION_UNIFORM_COMPONENTS 0x8E80
CONSTANT: GL_MAX_TESS_CONTROL_TEXTURE_IMAGE_UNITS 0x8E81
CONSTANT: GL_MAX_TESS_EVALUATION_TEXTURE_IMAGE_UNITS 0x8E82
CONSTANT: GL_MAX_TESS_CONTROL_OUTPUT_COMPONENTS 0x8E83
CONSTANT: GL_MAX_TESS_PATCH_COMPONENTS      0x8E84
CONSTANT: GL_MAX_TESS_CONTROL_TOTAL_OUTPUT_COMPONENTS 0x8E85
CONSTANT: GL_MAX_TESS_EVALUATION_OUTPUT_COMPONENTS 0x8E86
CONSTANT: GL_MAX_TESS_CONTROL_UNIFORM_BLOCKS 0x8E89
CONSTANT: GL_MAX_TESS_EVALUATION_UNIFORM_BLOCKS 0x8E8A
CONSTANT: GL_MAX_TESS_CONTROL_INPUT_COMPONENTS 0x886C
CONSTANT: GL_MAX_TESS_EVALUATION_INPUT_COMPONENTS 0x886D
CONSTANT: GL_MAX_COMBINED_TESS_CONTROL_UNIFORM_COMPONENTS 0x8E1E
CONSTANT: GL_MAX_COMBINED_TESS_EVALUATION_UNIFORM_COMPONENTS 0x8E1F
CONSTANT: GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_CONTROL_SHADER 0x84F0
CONSTANT: GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_EVALUATION_SHADER 0x84F1
CONSTANT: GL_TESS_EVALUATION_SHADER         0x8E87
CONSTANT: GL_TESS_CONTROL_SHADER            0x8E88
CONSTANT: GL_TRANSFORM_FEEDBACK             0x8E22
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_PAUSED 0x8E23
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_ACTIVE 0x8E24
CONSTANT: GL_TRANSFORM_FEEDBACK_BINDING     0x8E25
CONSTANT: GL_MAX_TRANSFORM_FEEDBACK_BUFFERS 0x8E70

GL-FUNCTION: void glUniform1d { } ( GLint location, GLdouble x )
GL-FUNCTION: void glUniform2d { } ( GLint location, GLdouble x, GLdouble y )
GL-FUNCTION: void glUniform3d { } ( GLint location, GLdouble x, GLdouble y, GLdouble z )
GL-FUNCTION: void glUniform4d { } ( GLint location, GLdouble x, GLdouble y, GLdouble z, GLdouble w )
GL-FUNCTION: void glUniform1dv { } ( GLint location, GLsizei count, GLdouble* value )
GL-FUNCTION: void glUniform2dv { } ( GLint location, GLsizei count, GLdouble* value )
GL-FUNCTION: void glUniform3dv { } ( GLint location, GLsizei count, GLdouble* value )
GL-FUNCTION: void glUniform4dv { } ( GLint location, GLsizei count, GLdouble* value )
GL-FUNCTION: void glUniformMatrix2dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glUniformMatrix3dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glUniformMatrix4dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glUniformMatrix2x3dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glUniformMatrix2x4dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glUniformMatrix3x2dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glUniformMatrix3x4dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glUniformMatrix4x2dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glUniformMatrix4x3dv { } ( GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glGetUniformdv { } ( GLuint program, GLint location, GLdouble* params )
GL-FUNCTION: void glProgramUniform1d { glProgramUniform1dEXT } ( GLuint program, GLint location, GLdouble x )
GL-FUNCTION: void glProgramUniform2d { glProgramUniform2dEXT } ( GLuint program, GLint location, GLdouble x, GLdouble y )
GL-FUNCTION: void glProgramUniform3d { glProgramUniform3dEXT } ( GLuint program, GLint location, GLdouble x, GLdouble y, GLdouble z )
GL-FUNCTION: void glProgramUniform4d { glProgramUniform4dEXT } ( GLuint program, GLint location, GLdouble x, GLdouble y, GLdouble z, GLdouble w )
GL-FUNCTION: void glProgramUniform1dv { glProgramUniform1dvEXT } ( GLuint program, GLint location, GLsizei count, GLdouble* value )
GL-FUNCTION: void glProgramUniform2dv { glProgramUniform2dvEXT } ( GLuint program, GLint location, GLsizei count, GLdouble* value )
GL-FUNCTION: void glProgramUniform3dv { glProgramUniform3dvEXT } ( GLuint program, GLint location, GLsizei count, GLdouble* value )
GL-FUNCTION: void glProgramUniform4dv { glProgramUniform4dvEXT } ( GLuint program, GLint location, GLsizei count, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix2dv { glProgramUniformMatrix2dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix3dv { glProgramUniformMatrix3dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix4dv { glProgramUniformMatrix4dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix2x3dv { glProgramUniformMatrix2x3dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix2x4dv { glProgramUniformMatrix2x4dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix3x2dv { glProgramUniformMatrix3x2dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix3x4dv { glProgramUniformMatrix3x4dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix4x2dv { glProgramUniformMatrix4x2dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )
GL-FUNCTION: void glProgramUniformMatrix4x3dv { glProgramUniformMatrix4x3dvEXT } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLdouble* value )

GL-FUNCTION: GLint glGetSubroutineUniformLocation { } ( GLuint program, GLenum shadertype, GLstring name )
GL-FUNCTION: GLuint glGetSubroutineIndex { } ( GLuint program, GLenum shadertype, GLstring name )
GL-FUNCTION: void glGetActiveSubroutineUniformiv { } ( GLuint program, GLenum shadertype, GLuint index, GLenum pname, GLint* values )
GL-FUNCTION: void glGetActiveSubroutineUniformName { } ( GLuint program, GLenum shadertype, GLuint index, GLsizei bufsize, GLsizei* length, GLstring name )
GL-FUNCTION: void glGetActiveSubroutineName { } ( GLuint program, GLenum shadertype, GLuint index, GLsizei bufsize, GLsizei* length, GLstring name )
GL-FUNCTION: void glUniformSubroutinesuiv { } ( GLenum shadertype, GLsizei count, GLuint* indices )
GL-FUNCTION: void glGetUniformSubroutineuiv { } ( GLenum shadertype, GLint location, GLuint* params )
GL-FUNCTION: void glGetProgramStageiv { } ( GLuint program, GLenum shadertype, GLenum pname, GLint* values )

GL-FUNCTION: void glPatchParameteri { } ( GLenum pname, GLint value )
GL-FUNCTION: void glPatchParameterfv { } ( GLenum pname, GLfloat* values )

GL-FUNCTION: void glBindTransformFeedback { } ( GLenum target, GLuint id )
GL-FUNCTION: void glDeleteTransformFeedbacks { } ( GLsizei n, GLuint* ids )
GL-FUNCTION: void glGenTransformFeedbacks { } ( GLsizei n, GLuint* ids )
GL-FUNCTION: GLboolean glIsTransformFeedback { } ( GLuint id )
GL-FUNCTION: void glPauseTransformFeedback { } ( )
GL-FUNCTION: void glResumeTransformFeedback { } ( )
GL-FUNCTION: void glDrawTransformFeedback { } ( GLenum mode, GLuint id )

GL-FUNCTION: void glDrawTransformFeedbackStream { } ( GLenum mode, GLuint id, GLuint stream )
GL-FUNCTION: void glBeginQueryIndexed { } ( GLenum target, GLuint index, GLuint id )
GL-FUNCTION: void glEndQueryIndexed { } ( GLenum target, GLuint index )
GL-FUNCTION: void glGetQueryIndexediv { } ( GLenum target, GLuint index, GLenum pname, GLint* params )


! GL_ARB_geometry_shader4

GL-FUNCTION: void glProgramParameteriARB { glProgramParameteriEXT }
    ( GLuint program, GLenum pname, GLint value )
GL-FUNCTION: void glFramebufferTextureLayerARB { glFramebufferTextureLayerEXT }
    ( GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer )
GL-FUNCTION: void glFramebufferTextureFaceARB { glFramebufferTextureFaceEXT }
    ( GLenum target, GLenum attachment, GLuint texture, GLint level, GLenum face )

CONSTANT: GL_MAX_GEOMETRY_VARYING_COMPONENTS_ARB 0x8DDD
CONSTANT: GL_MAX_VERTEX_VARYING_COMPONENTS_ARB 0x8DDE
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_LAYER_COUNT_ARB 0x8DA9


! GL_EXT_framebuffer_object

CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT 0x8CD9
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT 0x8CDA

! GL_ARB_texture_float

CONSTANT: GL_ALPHA32F_ARB 0x8816
CONSTANT: GL_INTENSITY32F_ARB 0x8817
CONSTANT: GL_LUMINANCE32F_ARB 0x8818
CONSTANT: GL_LUMINANCE_ALPHA32F_ARB 0x8819
CONSTANT: GL_ALPHA16F_ARB 0x881C
CONSTANT: GL_INTENSITY16F_ARB 0x881D
CONSTANT: GL_LUMINANCE16F_ARB 0x881E
CONSTANT: GL_LUMINANCE_ALPHA16F_ARB 0x881F
CONSTANT: GL_TEXTURE_LUMINANCE_TYPE_ARB 0x8C14
CONSTANT: GL_TEXTURE_INTENSITY_TYPE_ARB 0x8C15


! GL_EXT_texture_integer

CONSTANT: GL_ALPHA32UI_EXT 0x8D72
CONSTANT: GL_INTENSITY32UI_EXT 0x8D73
CONSTANT: GL_LUMINANCE32UI_EXT 0x8D74
CONSTANT: GL_LUMINANCE_ALPHA32UI_EXT 0x8D75

CONSTANT: GL_ALPHA16UI_EXT 0x8D78
CONSTANT: GL_INTENSITY16UI_EXT 0x8D79
CONSTANT: GL_LUMINANCE16UI_EXT 0x8D7A
CONSTANT: GL_LUMINANCE_ALPHA16UI_EXT 0x8D7B

CONSTANT: GL_ALPHA8UI_EXT 0x8D7E
CONSTANT: GL_INTENSITY8UI_EXT 0x8D7F
CONSTANT: GL_LUMINANCE8UI_EXT 0x8D80
CONSTANT: GL_LUMINANCE_ALPHA8UI_EXT 0x8D81

CONSTANT: GL_ALPHA32I_EXT 0x8D84
CONSTANT: GL_INTENSITY32I_EXT 0x8D85
CONSTANT: GL_LUMINANCE32I_EXT 0x8D86
CONSTANT: GL_LUMINANCE_ALPHA32I_EXT 0x8D87

CONSTANT: GL_ALPHA16I_EXT 0x8D8A
CONSTANT: GL_INTENSITY16I_EXT 0x8D8B
CONSTANT: GL_LUMINANCE16I_EXT 0x8D8C
CONSTANT: GL_LUMINANCE_ALPHA16I_EXT 0x8D8D

CONSTANT: GL_ALPHA8I_EXT 0x8D90
CONSTANT: GL_INTENSITY8I_EXT 0x8D91
CONSTANT: GL_LUMINANCE8I_EXT 0x8D92
CONSTANT: GL_LUMINANCE_ALPHA8I_EXT 0x8D93

CONSTANT: GL_ALPHA_INTEGER_EXT 0x8D97
CONSTANT: GL_LUMINANCE_INTEGER_EXT        0x8D9C
CONSTANT: GL_LUMINANCE_ALPHA_INTEGER_EXT  0x8D9D

GL-FUNCTION: void glClearColorIiEXT { } ( GLint r, GLint g, GLint b, GLint a )
GL-FUNCTION: void glClearColorIuiEXT { } ( GLuint r, GLuint g, GLuint b, GLuint a )


! GL_EXT_texture_compression_s3tc, GL_EXT_texture_compression_dxt1

CONSTANT: GL_COMPRESSED_RGB_S3TC_DXT1_EXT  0x83F0
CONSTANT: GL_COMPRESSED_RGBA_S3TC_DXT1_EXT 0x83F1
CONSTANT: GL_COMPRESSED_RGBA_S3TC_DXT3_EXT 0x83F2
CONSTANT: GL_COMPRESSED_RGBA_S3TC_DXT5_EXT 0x83F3


! GL_EXT_texture_compression_latc

CONSTANT: GL_COMPRESSED_LUMINANCE_LATC1_EXT              0x8C70
CONSTANT: GL_COMPRESSED_SIGNED_LUMINANCE_LATC1_EXT       0x8C71
CONSTANT: GL_COMPRESSED_LUMINANCE_ALPHA_LATC2_EXT        0x8C72
CONSTANT: GL_COMPRESSED_SIGNED_LUMINANCE_ALPHA_LATC2_EXT 0x8C73

! OpenGL 4.1

! GL_ARB_separate_shader_objects

GL-FUNCTION: void glProgramUniform1f { } ( GLuint program, GLint location, GLfloat v0 )
GL-FUNCTION: void glProgramUniform2f { } ( GLuint program, GLint location, GLfloat v0, GLfloat v1 )
GL-FUNCTION: void glProgramUniform3f { } ( GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2 )
GL-FUNCTION: void glProgramUniform4f { } ( GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3 )
GL-FUNCTION: void glProgramUniform1i { } ( GLuint program, GLint location, GLint v0 )
GL-FUNCTION: void glProgramUniform2i { } ( GLuint program, GLint location, GLint v0, GLint v1 )
GL-FUNCTION: void glProgramUniform3i { } ( GLuint program, GLint location, GLint v0, GLint v1, GLint v2 )
GL-FUNCTION: void glProgramUniform4i { } ( GLuint program, GLint location, GLint v0, GLint v1, GLint v2, GLint v3 )
GL-FUNCTION: void glProgramUniform1ui { } ( GLuint program, GLint location, GLuint v0 )
GL-FUNCTION: void glProgramUniform2ui { } ( GLuint program, GLint location, GLuint v0, GLuint v1 )
GL-FUNCTION: void glProgramUniform3ui { } ( GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2 )
GL-FUNCTION: void glProgramUniform4ui { } ( GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3 )
GL-FUNCTION: void glProgramUniform1fv { } ( GLuint program, GLint location, GLsizei count, GLfloat *value )
GL-FUNCTION: void glProgramUniform2fv { } ( GLuint program, GLint location, GLsizei count, GLfloat *value )
GL-FUNCTION: void glProgramUniform3fv { } ( GLuint program, GLint location, GLsizei count, GLfloat *value )
GL-FUNCTION: void glProgramUniform4fv { } ( GLuint program, GLint location, GLsizei count, GLfloat *value )
GL-FUNCTION: void glProgramUniform1iv { } ( GLuint program, GLint location, GLsizei count, GLint *value )
GL-FUNCTION: void glProgramUniform2iv { } ( GLuint program, GLint location, GLsizei count, GLint *value )
GL-FUNCTION: void glProgramUniform3iv { } ( GLuint program, GLint location, GLsizei count, GLint *value )
GL-FUNCTION: void glProgramUniform4iv { } ( GLuint program, GLint location, GLsizei count, GLint *value )
GL-FUNCTION: void glProgramUniform1uiv { } ( GLuint program, GLint location, GLsizei count, GLuint *value )
GL-FUNCTION: void glProgramUniform2uiv { } ( GLuint program, GLint location, GLsizei count, GLuint *value )
GL-FUNCTION: void glProgramUniform3uiv { } ( GLuint program, GLint location, GLsizei count, GLuint *value )
GL-FUNCTION: void glProgramUniform4uiv { } ( GLuint program, GLint location, GLsizei count, GLuint *value )
GL-FUNCTION: void glProgramUniformMatrix2fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )
GL-FUNCTION: void glProgramUniformMatrix3fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )
GL-FUNCTION: void glProgramUniformMatrix4fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )
GL-FUNCTION: void glProgramUniformMatrix2x3fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )
GL-FUNCTION: void glProgramUniformMatrix3x2fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )
GL-FUNCTION: void glProgramUniformMatrix2x4fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )
GL-FUNCTION: void glProgramUniformMatrix4x2fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )
GL-FUNCTION: void glProgramUniformMatrix3x4fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )
GL-FUNCTION: void glProgramUniformMatrix4x3fv { } ( GLuint program, GLint location, GLsizei count, GLboolean transpose, GLfloat *value )

! OpenGL 4.2

! GL_ARB_shader_image_load_store

CONSTANT: GL_MAX_IMAGE_UNITS                                 0x8F38
CONSTANT: GL_MAX_COMBINED_IMAGE_UNITS_AND_FRAGMENT_OUTPUTS   0x8F39
CONSTANT: GL_MAX_IMAGE_SAMPLES                               0x906D
CONSTANT: GL_MAX_VERTEX_IMAGE_UNIFORMS                       0x90CA
CONSTANT: GL_MAX_TESS_CONTROL_IMAGE_UNIFORMS                 0x90CB
CONSTANT: GL_MAX_TESS_EVALUATION_IMAGE_UNIFORMS              0x90CC
CONSTANT: GL_MAX_GEOMETRY_IMAGE_UNIFORMS                     0x90CD
CONSTANT: GL_MAX_FRAGMENT_IMAGE_UNIFORMS                     0x90CE
CONSTANT: GL_MAX_COMBINED_IMAGE_UNIFORMS                     0x90CF
CONSTANT: GL_IMAGE_BINDING_NAME                              0x8F3A
CONSTANT: GL_IMAGE_BINDING_LEVEL                             0x8F3B
CONSTANT: GL_IMAGE_BINDING_LAYERED                           0x8F3C
CONSTANT: GL_IMAGE_BINDING_LAYER                             0x8F3D
CONSTANT: GL_IMAGE_BINDING_ACCESS                            0x8F3E
CONSTANT: GL_IMAGE_BINDING_FORMAT                            0x906E
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT                 0x00000001
CONSTANT: GL_ELEMENT_ARRAY_BARRIER_BIT                       0x00000002
CONSTANT: GL_UNIFORM_BARRIER_BIT                             0x00000004
CONSTANT: GL_TEXTURE_FETCH_BARRIER_BIT                       0x00000008
CONSTANT: GL_SHADER_IMAGE_ACCESS_BARRIER_BIT                 0x00000020
CONSTANT: GL_COMMAND_BARRIER_BIT                             0x00000040
CONSTANT: GL_PIXEL_BUFFER_BARRIER_BIT                        0x00000080
CONSTANT: GL_TEXTURE_UPDATE_BARRIER_BIT                      0x00000100
CONSTANT: GL_BUFFER_UPDATE_BARRIER_BIT                       0x00000200
CONSTANT: GL_FRAMEBUFFER_BARRIER_BIT                         0x00000400
CONSTANT: GL_TRANSFORM_FEEDBACK_BARRIER_BIT                  0x00000800
CONSTANT: GL_ATOMIC_COUNTER_BARRIER_BIT                      0x00001000
CONSTANT: GL_ALL_BARRIER_BITS                                0xFFFFFFFF
CONSTANT: GL_IMAGE_1D                                        0x904C
CONSTANT: GL_IMAGE_2D                                        0x904D
CONSTANT: GL_IMAGE_3D                                        0x904E
CONSTANT: GL_IMAGE_2D_RECT                                   0x904F
CONSTANT: GL_IMAGE_CUBE                                      0x9050
CONSTANT: GL_IMAGE_BUFFER                                    0x9051
CONSTANT: GL_IMAGE_1D_ARRAY                                  0x9052
CONSTANT: GL_IMAGE_2D_ARRAY                                  0x9053
CONSTANT: GL_IMAGE_CUBE_MAP_ARRAY                            0x9054
CONSTANT: GL_IMAGE_2D_MULTISAMPLE                            0x9055
CONSTANT: GL_IMAGE_2D_MULTISAMPLE_ARRAY                      0x9056
CONSTANT: GL_INT_IMAGE_1D                                    0x9057
CONSTANT: GL_INT_IMAGE_2D                                    0x9058
CONSTANT: GL_INT_IMAGE_3D                                    0x9059
CONSTANT: GL_INT_IMAGE_2D_RECT                               0x905A
CONSTANT: GL_INT_IMAGE_CUBE                                  0x905B
CONSTANT: GL_INT_IMAGE_BUFFER                                0x905C
CONSTANT: GL_INT_IMAGE_1D_ARRAY                              0x905D
CONSTANT: GL_INT_IMAGE_2D_ARRAY                              0x905E
CONSTANT: GL_INT_IMAGE_CUBE_MAP_ARRAY                        0x905F
CONSTANT: GL_INT_IMAGE_2D_MULTISAMPLE                        0x9060
CONSTANT: GL_INT_IMAGE_2D_MULTISAMPLE_ARRAY                  0x9061
CONSTANT: GL_UNSIGNED_INT_IMAGE_1D                           0x9062
CONSTANT: GL_UNSIGNED_INT_IMAGE_2D                           0x9063
CONSTANT: GL_UNSIGNED_INT_IMAGE_3D                           0x9064
CONSTANT: GL_UNSIGNED_INT_IMAGE_2D_RECT                      0x9065
CONSTANT: GL_UNSIGNED_INT_IMAGE_CUBE                         0x9066
CONSTANT: GL_UNSIGNED_INT_IMAGE_BUFFER                       0x9067
CONSTANT: GL_UNSIGNED_INT_IMAGE_1D_ARRAY                     0x9068
CONSTANT: GL_UNSIGNED_INT_IMAGE_2D_ARRAY                     0x9069
CONSTANT: GL_UNSIGNED_INT_IMAGE_CUBE_MAP_ARRAY               0x906A
CONSTANT: GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE               0x906B
CONSTANT: GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE_ARRAY         0x906C
CONSTANT: GL_IMAGE_FORMAT_COMPATIBILITY_TYPE                 0x90C7
CONSTANT: GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE              0x90C8
CONSTANT: GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS             0x90C9
GL-FUNCTION: void glMemoryBarrier { } ( GLbitfield barriers )


! GL_OES_EGL_image_external_essl3

GL-FUNCTION: void glBindImageTexture { } ( GLuint unit, GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum access, GLenum format )

! OpenGL 4.3

! GL_ARB_compute_shader

CONSTANT: GL_MAX_COMPUTE_UNIFORM_BLOCKS                         0x91BB
CONSTANT: GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS                    0x91BC
CONSTANT: GL_MAX_COMPUTE_IMAGE_UNIFORMS                         0x91BD
CONSTANT: GL_MAX_COMPUTE_SHARED_MEMORY_SIZE                     0x8262
CONSTANT: GL_MAX_COMPUTE_UNIFORM_COMPONENTS                     0x8263
CONSTANT: GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS                 0x8264
CONSTANT: GL_MAX_COMPUTE_ATOMIC_COUNTERS                        0x8265
CONSTANT: GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS            0x8266
CONSTANT: GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS                 0x90EB
CONSTANT: GL_MAX_COMPUTE_WORK_GROUP_COUNT                       0x91BE
CONSTANT: GL_MAX_COMPUTE_WORK_GROUP_SIZE                        0x91BF
CONSTANT: GL_COMPUTE_WORK_GROUP_SIZE                            0x8267
CONSTANT: GL_UNIFORM_BLOCK_REFERENCED_BY_COMPUTE_SHADER         0x90EC
CONSTANT: GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_COMPUTE_SHADER 0x90ED
CONSTANT: GL_DISPATCH_INDIRECT_BUFFER                           0x90EE
CONSTANT: GL_DISPATCH_INDIRECT_BUFFER_BINDING                   0x90EF
CONSTANT: GL_COMPUTE_SHADER                                     0x91B9
CONSTANT: GL_COMPUTE_SHADER_BIT                                 0x00000020

GL-FUNCTION: void glDispatchCompute { } ( GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z )
GL-FUNCTION: void glDispatchComputeIndirect { } ( GLintptr indirect )

! OpenGL 4.5

!  GL_ARB_direct_state_access

GL-FUNCTION: void glCreateTransformFeedbacks { } ( GLsizei n, GLuint *ids )
GL-FUNCTION: void glTransformFeedbackBufferBase { } ( GLuint xfb, GLuint index, GLuint buffer )
GL-FUNCTION: void glTransformFeedbackBufferRange { } ( GLuint xfb, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size )
GL-FUNCTION: void glGetTransformFeedbackiv { } ( GLuint xfb, GLenum pname, GLint *param )
GL-FUNCTION: void glGetTransformFeedbacki_v { } ( GLuint xfb, GLenum pname, GLuint index, GLint *param )
GL-FUNCTION: void glGetTransformFeedbacki64_v { } ( GLuint xfb, GLenum pname, GLuint index, GLint64 *param )
GL-FUNCTION: void glCreateBuffers { } ( GLsizei n, GLuint *buffers )
GL-FUNCTION: void glNamedBufferStorage { } ( GLuint buffer, GLsizeiptr size, void *data, GLbitfield flags )
GL-FUNCTION: void glNamedBufferData { } ( GLuint buffer, GLsizeiptr size, void *data, GLenum usage )
GL-FUNCTION: GLenum glCheckNamedFramebufferStatus { } ( GLuint framebuffer, GLenum target )
GL-FUNCTION: GLboolean glUnmapNamedBuffer { } ( GLuint buffer )
GL-FUNCTION: void glNamedBufferSubData { } ( GLuint buffer, GLintptr offset, GLsizeiptr size, void *data )
GL-FUNCTION: void glCopyNamedBufferSubData { } ( GLuint readBuffer, GLuint writeBuffer, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size )
GL-FUNCTION: void glClearNamedBufferData { } ( GLuint buffer, GLenum internalformat, GLenum format, GLenum type, void *data )
GL-FUNCTION: void glClearNamedBufferSubData { } ( GLuint buffer, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, void *data )
GL-FUNCTION: void* glMapNamedBuffer { } ( GLuint buffer, GLenum access )
GL-FUNCTION: void* glMapNamedBufferRange { } ( GLuint buffer, GLintptr offset, GLsizeiptr length, GLbitfield access )
GL-FUNCTION: void glFlushMappedNamedBufferRange { } ( GLuint buffer, GLintptr offset, GLsizeiptr length )
GL-FUNCTION: void glGetNamedBufferParameteriv { } ( GLuint buffer, GLenum pname, GLint *params )
GL-FUNCTION: void glGetNamedBufferParameteri64v { } ( GLuint buffer, GLenum pname, GLint64 *params )
GL-FUNCTION: void glGetNamedBufferPointerv { } ( GLuint buffer, GLenum pname, void **params )
GL-FUNCTION: void glGetNamedBufferSubData { } ( GLuint buffer, GLintptr offset, GLsizeiptr size, void *data )
GL-FUNCTION: void glCreateFramebuffers { } ( GLsizei n, GLuint *framebuffers )
GL-FUNCTION: void glNamedFramebufferRenderbuffer { } ( GLuint framebuffer, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer )
GL-FUNCTION: void glNamedFramebufferParameteri { } ( GLuint framebuffer, GLenum pname, GLint param )
GL-FUNCTION: void glNamedFramebufferTexture { } ( GLuint framebuffer, GLenum attachment, GLuint texture, GLint level )
GL-FUNCTION: void glNamedFramebufferTextureLayer { } ( GLuint framebuffer, GLenum attachment, GLuint texture, GLint level, GLint layer )
GL-FUNCTION: void glNamedFramebufferDrawBuffer { } ( GLuint framebuffer, GLenum mode )
GL-FUNCTION: void glNamedFramebufferDrawBuffers { } ( GLuint framebuffer, GLsizei n, GLenum *bufs )
GL-FUNCTION: void glNamedFramebufferReadBuffer { } ( GLuint framebuffer, GLenum mode )
GL-FUNCTION: void glInvalidateNamedFramebufferData { } ( GLuint framebuffer, GLsizei numAttachments, GLenum *attachments )
GL-FUNCTION: void glInvalidateNamedFramebufferSubData { } ( GLuint framebuffer, GLsizei numAttachments, GLenum *attachments, GLint x, GLint y, GLsizei width, GLsizei height )
GL-FUNCTION: void glClearNamedFramebufferiv { } ( GLuint framebuffer, GLenum buffer, GLint drawbuffer,  GLint *value )
GL-FUNCTION: void glClearNamedFramebufferuiv { } ( GLuint framebuffer, GLenum buffer, GLint drawbuffer,  GLuint *value )
GL-FUNCTION: void glClearNamedFramebufferfv { } ( GLuint framebuffer, GLenum buffer, GLint drawbuffer,  float *value )
GL-FUNCTION: void glClearNamedFramebufferfi { } ( GLuint framebuffer, GLenum buffer, GLint drawbuffer, float depth, GLint stencil )
GL-FUNCTION: void glBlitNamedFramebuffer { } ( GLuint readFramebuffer, GLuint drawFramebuffer, GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter )
GL-FUNCTION: void glGetNamedFramebufferParameteriv { } ( GLuint framebuffer, GLenum pname, GLint *param )
GL-FUNCTION: void glGetNamedFramebufferAttachmentParameteriv { } ( GLuint framebuffer, GLenum attachment, GLenum pname, GLint *params )
GL-FUNCTION: void glCreateRenderbuffers { } ( GLsizei n, GLuint *renderbuffers )
GL-FUNCTION: void glNamedRenderbufferStorage { } ( GLuint renderbuffer, GLenum internalformat, GLsizei width, GLsizei height )
GL-FUNCTION: void glNamedRenderbufferStorageMultisample { } ( GLuint renderbuffer, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height )
GL-FUNCTION: void glGetNamedRenderbufferParameteriv { } ( GLuint renderbuffer, GLenum pname, GLint *params )
GL-FUNCTION: void glCreateTextures { } ( GLenum target, GLsizei n, GLuint *textures )
GL-FUNCTION: void glTextureBuffer { } ( GLuint texture, GLenum internalformat, GLuint buffer )
GL-FUNCTION: void glTextureBufferRange { } ( GLuint texture, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size )
GL-FUNCTION: void glTextureStorage1D { } ( GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width )
GL-FUNCTION: void glTextureStorage2D { } ( GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height )
GL-FUNCTION: void glTextureStorage3D { } ( GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth )
GL-FUNCTION: void glTextureStorage2DMultisample { } ( GLuint texture, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height,  GLboolean fixedsamplelocations )
GL-FUNCTION: void glTextureStorage3DMultisample { } ( GLuint texture, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations )
GL-FUNCTION: void glTextureSubImage1D { } ( GLuint texture, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, void *pixels )
GL-FUNCTION: void glTextureSubImage2D { } ( GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, void *pixels )
GL-FUNCTION: void glTextureSubImage3D { } ( GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, void *pixels )
GL-FUNCTION: void glCompressedTextureSubImage1D { } ( GLuint texture, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize,  void *data )
GL-FUNCTION: void glCompressedTextureSubImage2D { } ( GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, void *data )
GL-FUNCTION: void glCompressedTextureSubImage3D { } ( GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize,  void *data )
GL-FUNCTION: void glCopyTextureSubImage1D { } ( GLuint texture, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width )
GL-FUNCTION: void glCopyTextureSubImage2D { } ( GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height )
GL-FUNCTION: void glCopyTextureSubImage3D { } ( GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height )
GL-FUNCTION: void glTextureParameterf { } ( GLuint texture, GLenum pname, float param )
GL-FUNCTION: void glTextureParameterfv { } ( GLuint texture, GLenum pname,  float *param )
GL-FUNCTION: void glTextureParameteri { } ( GLenum target, GLenum pname, GLint param )
GL-FUNCTION: void glTextureParameterIiv { } ( GLuint texture, GLenum pname,  GLint *params )
GL-FUNCTION: void glTextureParameterIuiv { } ( GLuint texture, GLenum pname,  GLuint *params )
GL-FUNCTION: void glTextureParameteriv { } ( GLuint texture, GLenum pname,  GLint *param )
GL-FUNCTION: void glGenerateTextureMipmap { } ( GLuint texture )
GL-FUNCTION: void glBindTextureUnit { } ( GLuint unit, GLuint texture )
GL-FUNCTION: void glGetTextureImage { } ( GLuint texture, GLint level, GLenum format, GLenum type, GLsizei bufSize, void *pixels )
GL-FUNCTION: void glGetCompressedTextureImage { } ( GLuint texture, GLint level, GLsizei bufSize, void *pixels )
GL-FUNCTION: void glGetTextureLevelParameterfv { } ( GLuint texture, GLint level, GLenum pname, float *params )
GL-FUNCTION: void glGetTextureLevelParameteriv { } ( GLuint texture, GLint level, GLenum pname, GLint *params )
GL-FUNCTION: void glGetTextureParameterfv { } ( GLuint texture,  GLenum pname, float *params )
GL-FUNCTION: void glGetTextureParameterIiv { } ( GLuint texture, GLenum pname, GLint *params )
GL-FUNCTION: void glGetTextureParameterIuiv { } ( GLuint texture, GLenum pname, GLuint *params )
GL-FUNCTION: void glGetTextureParameteriv { } ( GLuint texture, GLenum pname, GLint *params )
GL-FUNCTION: void glCreateVertexArrays { } ( GLsizei n, GLuint *arrays )
GL-FUNCTION: void glDisableVertexArrayAttrib { } ( GLuint vaobj, GLuint index )
GL-FUNCTION: void glEnableVertexArrayAttrib { } ( GLuint vaobj, GLuint index )
GL-FUNCTION: void glVertexArrayElementBuffer { } ( GLuint vaobj, GLuint buffer )
GL-FUNCTION: void glVertexArrayVertexBuffer { } ( GLuint vaobj, GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride )
GL-FUNCTION: void glVertexArrayVertexBuffers { } ( GLuint vaobj, GLuint first, GLsizei count,  GLuint *buffers, GLintptr *offsets, GLsizei *strides )
GL-FUNCTION: void glVertexArrayAttribFormat { } ( GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset )
GL-FUNCTION: void glVertexArrayAttribIFormat { } ( GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset )
GL-FUNCTION: void glVertexArrayAttribLFormat { } ( GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset )
GL-FUNCTION: void glVertexArrayAttribBinding { } ( GLuint vaobj, GLuint attribindex, GLuint bindingindex )
GL-FUNCTION: void glVertexArrayBindingDivisor { } ( GLuint vaobj, GLuint bindingindex, GLuint divisor )
GL-FUNCTION: void glGetVertexArrayiv { } ( GLuint vaobj, GLenum pname, GLint *param )
GL-FUNCTION: void glGetVertexArrayIndexediv { } ( GLuint vaobj, GLuint index, GLenum pname, GLint *param )
GL-FUNCTION: void glGetVertexArrayIndexed64iv { } ( GLuint vaobj, GLuint index, GLenum pname, GLint64 *param )
GL-FUNCTION: void glCreateSamplers { } ( GLsizei n, GLuint *samplers )
GL-FUNCTION: void glCreateProgramPipelines { } ( GLsizei n, GLuint *pipelines )
GL-FUNCTION: void glCreateQueries { } ( GLenum target, GLsizei n, GLuint *ids )
