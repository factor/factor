! Copyright (C) 2005 Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.

! This file is based on the gl.h that comes with xorg-x11 6.8.2

USING: alien alien.syntax combinators kernel parser sequences
system words opengl.gl.extensions ;

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
TYPEDEF: void*   GLvoid*

! Constants

! Boolean values
CONSTANT: GL_FALSE                          HEX: 0
CONSTANT: GL_TRUE                           HEX: 1

! Data types
CONSTANT: GL_BYTE                           HEX: 1400
CONSTANT: GL_UNSIGNED_BYTE                  HEX: 1401
CONSTANT: GL_SHORT                          HEX: 1402
CONSTANT: GL_UNSIGNED_SHORT                 HEX: 1403
CONSTANT: GL_INT                            HEX: 1404
CONSTANT: GL_UNSIGNED_INT                   HEX: 1405
CONSTANT: GL_FLOAT                          HEX: 1406
CONSTANT: GL_2_BYTES                        HEX: 1407
CONSTANT: GL_3_BYTES                        HEX: 1408
CONSTANT: GL_4_BYTES                        HEX: 1409
CONSTANT: GL_DOUBLE                         HEX: 140A

! Primitives
CONSTANT: GL_POINTS                         HEX: 0000
CONSTANT: GL_LINES                          HEX: 0001
CONSTANT: GL_LINE_LOOP                      HEX: 0002
CONSTANT: GL_LINE_STRIP                     HEX: 0003
CONSTANT: GL_TRIANGLES                      HEX: 0004
CONSTANT: GL_TRIANGLE_STRIP                 HEX: 0005
CONSTANT: GL_TRIANGLE_FAN                   HEX: 0006
CONSTANT: GL_QUADS                          HEX: 0007
CONSTANT: GL_QUAD_STRIP                     HEX: 0008
CONSTANT: GL_POLYGON                        HEX: 0009

! Vertex arrays
CONSTANT: GL_VERTEX_ARRAY                   HEX: 8074
CONSTANT: GL_NORMAL_ARRAY                   HEX: 8075
CONSTANT: GL_COLOR_ARRAY                    HEX: 8076
CONSTANT: GL_INDEX_ARRAY                    HEX: 8077
CONSTANT: GL_TEXTURE_COORD_ARRAY            HEX: 8078
CONSTANT: GL_EDGE_FLAG_ARRAY                HEX: 8079
CONSTANT: GL_VERTEX_ARRAY_SIZE              HEX: 807A
CONSTANT: GL_VERTEX_ARRAY_TYPE              HEX: 807B
CONSTANT: GL_VERTEX_ARRAY_STRIDE            HEX: 807C
CONSTANT: GL_NORMAL_ARRAY_TYPE              HEX: 807E
CONSTANT: GL_NORMAL_ARRAY_STRIDE            HEX: 807F
CONSTANT: GL_COLOR_ARRAY_SIZE               HEX: 8081
CONSTANT: GL_COLOR_ARRAY_TYPE               HEX: 8082
CONSTANT: GL_COLOR_ARRAY_STRIDE             HEX: 8083
CONSTANT: GL_INDEX_ARRAY_TYPE               HEX: 8085
CONSTANT: GL_INDEX_ARRAY_STRIDE             HEX: 8086
CONSTANT: GL_TEXTURE_COORD_ARRAY_SIZE       HEX: 8088
CONSTANT: GL_TEXTURE_COORD_ARRAY_TYPE       HEX: 8089
CONSTANT: GL_TEXTURE_COORD_ARRAY_STRIDE     HEX: 808A
CONSTANT: GL_EDGE_FLAG_ARRAY_STRIDE         HEX: 808C
CONSTANT: GL_VERTEX_ARRAY_POINTER           HEX: 808E
CONSTANT: GL_NORMAL_ARRAY_POINTER           HEX: 808F
CONSTANT: GL_COLOR_ARRAY_POINTER            HEX: 8090
CONSTANT: GL_INDEX_ARRAY_POINTER            HEX: 8091
CONSTANT: GL_TEXTURE_COORD_ARRAY_POINTER    HEX: 8092
CONSTANT: GL_EDGE_FLAG_ARRAY_POINTER        HEX: 8093
CONSTANT: GL_V2F                            HEX: 2A20
CONSTANT: GL_V3F                            HEX: 2A21
CONSTANT: GL_C4UB_V2F                       HEX: 2A22
CONSTANT: GL_C4UB_V3F                       HEX: 2A23
CONSTANT: GL_C3F_V3F                        HEX: 2A24
CONSTANT: GL_N3F_V3F                        HEX: 2A25
CONSTANT: GL_C4F_N3F_V3F                    HEX: 2A26
CONSTANT: GL_T2F_V3F                        HEX: 2A27
CONSTANT: GL_T4F_V4F                        HEX: 2A28
CONSTANT: GL_T2F_C4UB_V3F                   HEX: 2A29
CONSTANT: GL_T2F_C3F_V3F                    HEX: 2A2A
CONSTANT: GL_T2F_N3F_V3F                    HEX: 2A2B
CONSTANT: GL_T2F_C4F_N3F_V3F                HEX: 2A2C
CONSTANT: GL_T4F_C4F_N3F_V4F                HEX: 2A2D

! Matrix mode
CONSTANT: GL_MATRIX_MODE                    HEX: 0BA0
CONSTANT: GL_MODELVIEW                      HEX: 1700
CONSTANT: GL_PROJECTION                     HEX: 1701
CONSTANT: GL_TEXTURE                        HEX: 1702

! Points
CONSTANT: GL_POINT_SMOOTH                   HEX: 0B10
CONSTANT: GL_POINT_SIZE                     HEX: 0B11
CONSTANT: GL_POINT_SIZE_GRANULARITY         HEX: 0B13
CONSTANT: GL_POINT_SIZE_RANGE               HEX: 0B12

! Lines
CONSTANT: GL_LINE_SMOOTH                    HEX: 0B20
CONSTANT: GL_LINE_STIPPLE                   HEX: 0B24
CONSTANT: GL_LINE_STIPPLE_PATTERN           HEX: 0B25
CONSTANT: GL_LINE_STIPPLE_REPEAT            HEX: 0B26
CONSTANT: GL_LINE_WIDTH                     HEX: 0B21
CONSTANT: GL_LINE_WIDTH_GRANULARITY         HEX: 0B23
CONSTANT: GL_LINE_WIDTH_RANGE               HEX: 0B22

! Polygons
CONSTANT: GL_POINT                          HEX: 1B00
CONSTANT: GL_LINE                           HEX: 1B01
CONSTANT: GL_FILL                           HEX: 1B02
CONSTANT: GL_CW                             HEX: 0900
CONSTANT: GL_CCW                            HEX: 0901
CONSTANT: GL_FRONT                          HEX: 0404
CONSTANT: GL_BACK                           HEX: 0405
CONSTANT: GL_POLYGON_MODE                   HEX: 0B40
CONSTANT: GL_POLYGON_SMOOTH                 HEX: 0B41
CONSTANT: GL_POLYGON_STIPPLE                HEX: 0B42
CONSTANT: GL_EDGE_FLAG                      HEX: 0B43
CONSTANT: GL_CULL_FACE                      HEX: 0B44
CONSTANT: GL_CULL_FACE_MODE                 HEX: 0B45
CONSTANT: GL_FRONT_FACE                     HEX: 0B46
CONSTANT: GL_POLYGON_OFFSET_FACTOR          HEX: 8038
CONSTANT: GL_POLYGON_OFFSET_UNITS           HEX: 2A00
CONSTANT: GL_POLYGON_OFFSET_POINT           HEX: 2A01
CONSTANT: GL_POLYGON_OFFSET_LINE            HEX: 2A02
CONSTANT: GL_POLYGON_OFFSET_FILL            HEX: 8037

! Display Lists
CONSTANT: GL_COMPILE                        HEX: 1300
CONSTANT: GL_COMPILE_AND_EXECUTE            HEX: 1301
CONSTANT: GL_LIST_BASE                      HEX: 0B32
CONSTANT: GL_LIST_INDEX                     HEX: 0B33
CONSTANT: GL_LIST_MODE                      HEX: 0B30

! Depth buffer
CONSTANT: GL_NEVER                          HEX: 0200
CONSTANT: GL_LESS                           HEX: 0201
CONSTANT: GL_EQUAL                          HEX: 0202
CONSTANT: GL_LEQUAL                         HEX: 0203
CONSTANT: GL_GREATER                        HEX: 0204
CONSTANT: GL_NOTEQUAL                       HEX: 0205
CONSTANT: GL_GEQUAL                         HEX: 0206
CONSTANT: GL_ALWAYS                         HEX: 0207
CONSTANT: GL_DEPTH_TEST                     HEX: 0B71
CONSTANT: GL_DEPTH_BITS                     HEX: 0D56
CONSTANT: GL_DEPTH_CLEAR_VALUE              HEX: 0B73
CONSTANT: GL_DEPTH_FUNC                     HEX: 0B74
CONSTANT: GL_DEPTH_RANGE                    HEX: 0B70
CONSTANT: GL_DEPTH_WRITEMASK                HEX: 0B72
CONSTANT: GL_DEPTH_COMPONENT                HEX: 1902

! Lighting
CONSTANT: GL_LIGHTING                       HEX: 0B50
CONSTANT: GL_LIGHT0                         HEX: 4000
CONSTANT: GL_LIGHT1                         HEX: 4001
CONSTANT: GL_LIGHT2                         HEX: 4002
CONSTANT: GL_LIGHT3                         HEX: 4003
CONSTANT: GL_LIGHT4                         HEX: 4004
CONSTANT: GL_LIGHT5                         HEX: 4005
CONSTANT: GL_LIGHT6                         HEX: 4006
CONSTANT: GL_LIGHT7                         HEX: 4007
CONSTANT: GL_SPOT_EXPONENT                  HEX: 1205
CONSTANT: GL_SPOT_CUTOFF                    HEX: 1206
CONSTANT: GL_CONSTANT_ATTENUATION           HEX: 1207
CONSTANT: GL_LINEAR_ATTENUATION             HEX: 1208
CONSTANT: GL_QUADRATIC_ATTENUATION          HEX: 1209
CONSTANT: GL_AMBIENT                        HEX: 1200
CONSTANT: GL_DIFFUSE                        HEX: 1201
CONSTANT: GL_SPECULAR                       HEX: 1202
CONSTANT: GL_SHININESS                      HEX: 1601
CONSTANT: GL_EMISSION                       HEX: 1600
CONSTANT: GL_POSITION                       HEX: 1203
CONSTANT: GL_SPOT_DIRECTION                 HEX: 1204
CONSTANT: GL_AMBIENT_AND_DIFFUSE            HEX: 1602
CONSTANT: GL_COLOR_INDEXES                  HEX: 1603
CONSTANT: GL_LIGHT_MODEL_TWO_SIDE           HEX: 0B52
CONSTANT: GL_LIGHT_MODEL_LOCAL_VIEWER       HEX: 0B51
CONSTANT: GL_LIGHT_MODEL_AMBIENT            HEX: 0B53
CONSTANT: GL_FRONT_AND_BACK                 HEX: 0408
CONSTANT: GL_SHADE_MODEL                    HEX: 0B54
CONSTANT: GL_FLAT                           HEX: 1D00
CONSTANT: GL_SMOOTH                         HEX: 1D01
CONSTANT: GL_COLOR_MATERIAL                 HEX: 0B57
CONSTANT: GL_COLOR_MATERIAL_FACE            HEX: 0B55
CONSTANT: GL_COLOR_MATERIAL_PARAMETER       HEX: 0B56
CONSTANT: GL_NORMALIZE                      HEX: 0BA1

! User clipping planes
CONSTANT: GL_CLIP_PLANE0                    HEX: 3000
CONSTANT: GL_CLIP_PLANE1                    HEX: 3001
CONSTANT: GL_CLIP_PLANE2                    HEX: 3002
CONSTANT: GL_CLIP_PLANE3                    HEX: 3003
CONSTANT: GL_CLIP_PLANE4                    HEX: 3004
CONSTANT: GL_CLIP_PLANE5                    HEX: 3005

! Accumulation buffer
CONSTANT: GL_ACCUM_RED_BITS                 HEX: 0D58
CONSTANT: GL_ACCUM_GREEN_BITS               HEX: 0D59
CONSTANT: GL_ACCUM_BLUE_BITS                HEX: 0D5A
CONSTANT: GL_ACCUM_ALPHA_BITS               HEX: 0D5B
CONSTANT: GL_ACCUM_CLEAR_VALUE              HEX: 0B80
CONSTANT: GL_ACCUM                          HEX: 0100
CONSTANT: GL_ADD                            HEX: 0104
CONSTANT: GL_LOAD                           HEX: 0101
CONSTANT: GL_MULT                           HEX: 0103
CONSTANT: GL_RETURN                         HEX: 0102

! Alpha testing
CONSTANT: GL_ALPHA_TEST                     HEX: 0BC0
CONSTANT: GL_ALPHA_TEST_REF                 HEX: 0BC2
CONSTANT: GL_ALPHA_TEST_FUNC                HEX: 0BC1

! Blending
CONSTANT: GL_BLEND                          HEX: 0BE2
CONSTANT: GL_BLEND_SRC                      HEX: 0BE1
CONSTANT: GL_BLEND_DST                      HEX: 0BE0
CONSTANT: GL_ZERO                           HEX: 0
CONSTANT: GL_ONE                            HEX: 1
CONSTANT: GL_SRC_COLOR                      HEX: 0300
CONSTANT: GL_ONE_MINUS_SRC_COLOR            HEX: 0301
CONSTANT: GL_SRC_ALPHA                      HEX: 0302
CONSTANT: GL_ONE_MINUS_SRC_ALPHA            HEX: 0303
CONSTANT: GL_DST_ALPHA                      HEX: 0304
CONSTANT: GL_ONE_MINUS_DST_ALPHA            HEX: 0305
CONSTANT: GL_DST_COLOR                      HEX: 0306
CONSTANT: GL_ONE_MINUS_DST_COLOR            HEX: 0307
CONSTANT: GL_SRC_ALPHA_SATURATE             HEX: 0308

! Render Mode
CONSTANT: GL_FEEDBACK                       HEX: 1C01
CONSTANT: GL_RENDER                         HEX: 1C00
CONSTANT: GL_SELECT                         HEX: 1C02

! Feedback
CONSTANT: GL_2D                             HEX: 0600
CONSTANT: GL_3D                             HEX: 0601
CONSTANT: GL_3D_COLOR                       HEX: 0602
CONSTANT: GL_3D_COLOR_TEXTURE               HEX: 0603
CONSTANT: GL_4D_COLOR_TEXTURE               HEX: 0604
CONSTANT: GL_POINT_TOKEN                    HEX: 0701
CONSTANT: GL_LINE_TOKEN                     HEX: 0702
CONSTANT: GL_LINE_RESET_TOKEN               HEX: 0707
CONSTANT: GL_POLYGON_TOKEN                  HEX: 0703
CONSTANT: GL_BITMAP_TOKEN                   HEX: 0704
CONSTANT: GL_DRAW_PIXEL_TOKEN               HEX: 0705
CONSTANT: GL_COPY_PIXEL_TOKEN               HEX: 0706
CONSTANT: GL_PASS_THROUGH_TOKEN             HEX: 0700
CONSTANT: GL_FEEDBACK_BUFFER_POINTER        HEX: 0DF0
CONSTANT: GL_FEEDBACK_BUFFER_SIZE           HEX: 0DF1
CONSTANT: GL_FEEDBACK_BUFFER_TYPE           HEX: 0DF2

! Selection
CONSTANT: GL_SELECTION_BUFFER_POINTER       HEX: 0DF3
CONSTANT: GL_SELECTION_BUFFER_SIZE          HEX: 0DF4

! Fog
CONSTANT: GL_FOG                            HEX: 0B60
CONSTANT: GL_FOG_MODE                       HEX: 0B65
CONSTANT: GL_FOG_DENSITY                    HEX: 0B62
CONSTANT: GL_FOG_COLOR                      HEX: 0B66
CONSTANT: GL_FOG_INDEX                      HEX: 0B61
CONSTANT: GL_FOG_START                      HEX: 0B63
CONSTANT: GL_FOG_END                        HEX: 0B64
CONSTANT: GL_LINEAR                         HEX: 2601
CONSTANT: GL_EXP                            HEX: 0800
CONSTANT: GL_EXP2                           HEX: 0801

! Logic Ops
CONSTANT: GL_LOGIC_OP                       HEX: 0BF1
CONSTANT: GL_INDEX_LOGIC_OP                 HEX: 0BF1
CONSTANT: GL_COLOR_LOGIC_OP                 HEX: 0BF2
CONSTANT: GL_LOGIC_OP_MODE                  HEX: 0BF0
CONSTANT: GL_CLEAR                          HEX: 1500
CONSTANT: GL_SET                            HEX: 150F
CONSTANT: GL_COPY                           HEX: 1503
CONSTANT: GL_COPY_INVERTED                  HEX: 150C
CONSTANT: GL_NOOP                           HEX: 1505
CONSTANT: GL_INVERT                         HEX: 150A
CONSTANT: GL_AND                            HEX: 1501
CONSTANT: GL_NAND                           HEX: 150E
CONSTANT: GL_OR                             HEX: 1507
CONSTANT: GL_NOR                            HEX: 1508
CONSTANT: GL_XOR                            HEX: 1506
CONSTANT: GL_EQUIV                          HEX: 1509
CONSTANT: GL_AND_REVERSE                    HEX: 1502
CONSTANT: GL_AND_INVERTED                   HEX: 1504
CONSTANT: GL_OR_REVERSE                     HEX: 150B
CONSTANT: GL_OR_INVERTED                    HEX: 150D

! Stencil
CONSTANT: GL_STENCIL_TEST                   HEX: 0B90
CONSTANT: GL_STENCIL_WRITEMASK              HEX: 0B98
CONSTANT: GL_STENCIL_BITS                   HEX: 0D57
CONSTANT: GL_STENCIL_FUNC                   HEX: 0B92
CONSTANT: GL_STENCIL_VALUE_MASK             HEX: 0B93
CONSTANT: GL_STENCIL_REF                    HEX: 0B97
CONSTANT: GL_STENCIL_FAIL                   HEX: 0B94
CONSTANT: GL_STENCIL_PASS_DEPTH_PASS        HEX: 0B96
CONSTANT: GL_STENCIL_PASS_DEPTH_FAIL        HEX: 0B95
CONSTANT: GL_STENCIL_CLEAR_VALUE            HEX: 0B91
CONSTANT: GL_STENCIL_INDEX                  HEX: 1901
CONSTANT: GL_KEEP                           HEX: 1E00
CONSTANT: GL_REPLACE                        HEX: 1E01
CONSTANT: GL_INCR                           HEX: 1E02
CONSTANT: GL_DECR                           HEX: 1E03

! Buffers, Pixel Drawing/Reading
CONSTANT: GL_NONE                           HEX:    0
CONSTANT: GL_LEFT                           HEX: 0406
CONSTANT: GL_RIGHT                          HEX: 0407

CONSTANT: GL_FRONT_RIGHT                    HEX: 0401
CONSTANT: GL_BACK_LEFT                      HEX: 0402
CONSTANT: GL_BACK_RIGHT                     HEX: 0403
CONSTANT: GL_AUX0                           HEX: 0409
CONSTANT: GL_AUX1                           HEX: 040A
CONSTANT: GL_AUX2                           HEX: 040B
CONSTANT: GL_AUX3                           HEX: 040C
CONSTANT: GL_COLOR_INDEX                    HEX: 1900
CONSTANT: GL_RED                            HEX: 1903
CONSTANT: GL_GREEN                          HEX: 1904
CONSTANT: GL_BLUE                           HEX: 1905
CONSTANT: GL_ALPHA                          HEX: 1906
CONSTANT: GL_LUMINANCE                      HEX: 1909
CONSTANT: GL_LUMINANCE_ALPHA                HEX: 190A
CONSTANT: GL_ALPHA_BITS                     HEX: 0D55
CONSTANT: GL_RED_BITS                       HEX: 0D52
CONSTANT: GL_GREEN_BITS                     HEX: 0D53
CONSTANT: GL_BLUE_BITS                      HEX: 0D54
CONSTANT: GL_INDEX_BITS                     HEX: 0D51
CONSTANT: GL_SUBPIXEL_BITS                  HEX: 0D50
CONSTANT: GL_AUX_BUFFERS                    HEX: 0C00
CONSTANT: GL_READ_BUFFER                    HEX: 0C02
CONSTANT: GL_DRAW_BUFFER                    HEX: 0C01
CONSTANT: GL_DOUBLEBUFFER                   HEX: 0C32
CONSTANT: GL_STEREO                         HEX: 0C33
CONSTANT: GL_BITMAP                         HEX: 1A00
CONSTANT: GL_COLOR                          HEX: 1800
CONSTANT: GL_DEPTH                          HEX: 1801
CONSTANT: GL_STENCIL                        HEX: 1802
CONSTANT: GL_DITHER                         HEX: 0BD0
CONSTANT: GL_RGB                            HEX: 1907
CONSTANT: GL_RGBA                           HEX: 1908

! GL_BGRA_ext: http://www.opengl.org/registry/specs/EXT/bgra.txt
CONSTANT: GL_BGR_EXT                        HEX: 80E0
CONSTANT: GL_BGRA_EXT                       HEX: 80E1

! Implementation limits
CONSTANT: GL_MAX_LIST_NESTING               HEX: 0B31
CONSTANT: GL_MAX_ATTRIB_STACK_DEPTH         HEX: 0D35
CONSTANT: GL_MAX_MODELVIEW_STACK_DEPTH      HEX: 0D36
CONSTANT: GL_MAX_NAME_STACK_DEPTH           HEX: 0D37
CONSTANT: GL_MAX_PROJECTION_STACK_DEPTH     HEX: 0D38
CONSTANT: GL_MAX_TEXTURE_STACK_DEPTH        HEX: 0D39
CONSTANT: GL_MAX_EVAL_ORDER                 HEX: 0D30
CONSTANT: GL_MAX_LIGHTS                     HEX: 0D31
CONSTANT: GL_MAX_CLIP_PLANES                HEX: 0D32
CONSTANT: GL_MAX_TEXTURE_SIZE               HEX: 0D33
CONSTANT: GL_MAX_PIXEL_MAP_TABLE            HEX: 0D34
CONSTANT: GL_MAX_VIEWPORT_DIMS              HEX: 0D3A
CONSTANT: GL_MAX_CLIENT_ATTRIB_STACK_DEPTH  HEX: 0D3B

! Gets
CONSTANT: GL_ATTRIB_STACK_DEPTH             HEX: 0BB0
CONSTANT: GL_CLIENT_ATTRIB_STACK_DEPTH      HEX: 0BB1
CONSTANT: GL_COLOR_CLEAR_VALUE              HEX: 0C22
CONSTANT: GL_COLOR_WRITEMASK                HEX: 0C23
CONSTANT: GL_CURRENT_INDEX                  HEX: 0B01
CONSTANT: GL_CURRENT_COLOR                  HEX: 0B00
CONSTANT: GL_CURRENT_NORMAL                 HEX: 0B02
CONSTANT: GL_CURRENT_RASTER_COLOR           HEX: 0B04
CONSTANT: GL_CURRENT_RASTER_DISTANCE        HEX: 0B09
CONSTANT: GL_CURRENT_RASTER_INDEX           HEX: 0B05
CONSTANT: GL_CURRENT_RASTER_POSITION        HEX: 0B07
CONSTANT: GL_CURRENT_RASTER_TEXTURE_COORDS  HEX: 0B06
CONSTANT: GL_CURRENT_RASTER_POSITION_VALID  HEX: 0B08
CONSTANT: GL_CURRENT_TEXTURE_COORDS         HEX: 0B03
CONSTANT: GL_INDEX_CLEAR_VALUE              HEX: 0C20
CONSTANT: GL_INDEX_MODE                     HEX: 0C30
CONSTANT: GL_INDEX_WRITEMASK                HEX: 0C21
CONSTANT: GL_MODELVIEW_MATRIX               HEX: 0BA6
CONSTANT: GL_MODELVIEW_STACK_DEPTH          HEX: 0BA3
CONSTANT: GL_NAME_STACK_DEPTH               HEX: 0D70
CONSTANT: GL_PROJECTION_MATRIX              HEX: 0BA7
CONSTANT: GL_PROJECTION_STACK_DEPTH         HEX: 0BA4
CONSTANT: GL_RENDER_MODE                    HEX: 0C40
CONSTANT: GL_RGBA_MODE                      HEX: 0C31
CONSTANT: GL_TEXTURE_MATRIX                 HEX: 0BA8
CONSTANT: GL_TEXTURE_STACK_DEPTH            HEX: 0BA5
CONSTANT: GL_VIEWPORT                       HEX: 0BA2

! Evaluators inline
CONSTANT: GL_AUTO_NORMAL                    HEX: 0D80
CONSTANT: GL_MAP1_COLOR_4                   HEX: 0D90
CONSTANT: GL_MAP1_INDEX                     HEX: 0D91
CONSTANT: GL_MAP1_NORMAL                    HEX: 0D92
CONSTANT: GL_MAP1_TEXTURE_COORD_1           HEX: 0D93
CONSTANT: GL_MAP1_TEXTURE_COORD_2           HEX: 0D94
CONSTANT: GL_MAP1_TEXTURE_COORD_3           HEX: 0D95
CONSTANT: GL_MAP1_TEXTURE_COORD_4           HEX: 0D96
CONSTANT: GL_MAP1_VERTEX_3                  HEX: 0D97
CONSTANT: GL_MAP1_VERTEX_4                  HEX: 0D98
CONSTANT: GL_MAP2_COLOR_4                   HEX: 0DB0
CONSTANT: GL_MAP2_INDEX                     HEX: 0DB1
CONSTANT: GL_MAP2_NORMAL                    HEX: 0DB2
CONSTANT: GL_MAP2_TEXTURE_COORD_1           HEX: 0DB3
CONSTANT: GL_MAP2_TEXTURE_COORD_2           HEX: 0DB4
CONSTANT: GL_MAP2_TEXTURE_COORD_3           HEX: 0DB5
CONSTANT: GL_MAP2_TEXTURE_COORD_4           HEX: 0DB6
CONSTANT: GL_MAP2_VERTEX_3                  HEX: 0DB7
CONSTANT: GL_MAP2_VERTEX_4                  HEX: 0DB8
CONSTANT: GL_MAP1_GRID_DOMAIN               HEX: 0DD0
CONSTANT: GL_MAP1_GRID_SEGMENTS             HEX: 0DD1
CONSTANT: GL_MAP2_GRID_DOMAIN               HEX: 0DD2
CONSTANT: GL_MAP2_GRID_SEGMENTS             HEX: 0DD3
CONSTANT: GL_COEFF                          HEX: 0A00
CONSTANT: GL_DOMAIN                         HEX: 0A02
CONSTANT: GL_ORDER                          HEX: 0A01

! Hints inline
CONSTANT: GL_FOG_HINT                       HEX: 0C54
CONSTANT: GL_LINE_SMOOTH_HINT               HEX: 0C52
CONSTANT: GL_PERSPECTIVE_CORRECTION_HINT    HEX: 0C50
CONSTANT: GL_POINT_SMOOTH_HINT              HEX: 0C51
CONSTANT: GL_POLYGON_SMOOTH_HINT            HEX: 0C53
CONSTANT: GL_DONT_CARE                      HEX: 1100
CONSTANT: GL_FASTEST                        HEX: 1101
CONSTANT: GL_NICEST                         HEX: 1102

! Scissor box inline
CONSTANT: GL_SCISSOR_TEST                   HEX: 0C11
CONSTANT: GL_SCISSOR_BOX                    HEX: 0C10

! Pixel Mode / Transfer inline
CONSTANT: GL_MAP_COLOR                      HEX: 0D10
CONSTANT: GL_MAP_STENCIL                    HEX: 0D11
CONSTANT: GL_INDEX_SHIFT                    HEX: 0D12
CONSTANT: GL_INDEX_OFFSET                   HEX: 0D13
CONSTANT: GL_RED_SCALE                      HEX: 0D14
CONSTANT: GL_RED_BIAS                       HEX: 0D15
CONSTANT: GL_GREEN_SCALE                    HEX: 0D18
CONSTANT: GL_GREEN_BIAS                     HEX: 0D19
CONSTANT: GL_BLUE_SCALE                     HEX: 0D1A
CONSTANT: GL_BLUE_BIAS                      HEX: 0D1B
CONSTANT: GL_ALPHA_SCALE                    HEX: 0D1C
CONSTANT: GL_ALPHA_BIAS                     HEX: 0D1D
CONSTANT: GL_DEPTH_SCALE                    HEX: 0D1E
CONSTANT: GL_DEPTH_BIAS                     HEX: 0D1F
CONSTANT: GL_PIXEL_MAP_S_TO_S_SIZE          HEX: 0CB1
CONSTANT: GL_PIXEL_MAP_I_TO_I_SIZE          HEX: 0CB0
CONSTANT: GL_PIXEL_MAP_I_TO_R_SIZE          HEX: 0CB2
CONSTANT: GL_PIXEL_MAP_I_TO_G_SIZE          HEX: 0CB3
CONSTANT: GL_PIXEL_MAP_I_TO_B_SIZE          HEX: 0CB4
CONSTANT: GL_PIXEL_MAP_I_TO_A_SIZE          HEX: 0CB5
CONSTANT: GL_PIXEL_MAP_R_TO_R_SIZE          HEX: 0CB6
CONSTANT: GL_PIXEL_MAP_G_TO_G_SIZE          HEX: 0CB7
CONSTANT: GL_PIXEL_MAP_B_TO_B_SIZE          HEX: 0CB8
CONSTANT: GL_PIXEL_MAP_A_TO_A_SIZE          HEX: 0CB9
CONSTANT: GL_PIXEL_MAP_S_TO_S               HEX: 0C71
CONSTANT: GL_PIXEL_MAP_I_TO_I               HEX: 0C70
CONSTANT: GL_PIXEL_MAP_I_TO_R               HEX: 0C72
CONSTANT: GL_PIXEL_MAP_I_TO_G               HEX: 0C73
CONSTANT: GL_PIXEL_MAP_I_TO_B               HEX: 0C74
CONSTANT: GL_PIXEL_MAP_I_TO_A               HEX: 0C75
CONSTANT: GL_PIXEL_MAP_R_TO_R               HEX: 0C76
CONSTANT: GL_PIXEL_MAP_G_TO_G               HEX: 0C77
CONSTANT: GL_PIXEL_MAP_B_TO_B               HEX: 0C78
CONSTANT: GL_PIXEL_MAP_A_TO_A               HEX: 0C79
CONSTANT: GL_PACK_ALIGNMENT                 HEX: 0D05
CONSTANT: GL_PACK_LSB_FIRST                 HEX: 0D01
CONSTANT: GL_PACK_ROW_LENGTH                HEX: 0D02
CONSTANT: GL_PACK_SKIP_PIXELS               HEX: 0D04
CONSTANT: GL_PACK_SKIP_ROWS                 HEX: 0D03
CONSTANT: GL_PACK_SWAP_BYTES                HEX: 0D00
CONSTANT: GL_UNPACK_ALIGNMENT               HEX: 0CF5
CONSTANT: GL_UNPACK_LSB_FIRST               HEX: 0CF1
CONSTANT: GL_UNPACK_ROW_LENGTH              HEX: 0CF2
CONSTANT: GL_UNPACK_SKIP_PIXELS             HEX: 0CF4
CONSTANT: GL_UNPACK_SKIP_ROWS               HEX: 0CF3
CONSTANT: GL_UNPACK_SWAP_BYTES              HEX: 0CF0
CONSTANT: GL_ZOOM_X                         HEX: 0D16
CONSTANT: GL_ZOOM_Y                         HEX: 0D17

! Texture mapping inline
CONSTANT: GL_TEXTURE_ENV                    HEX: 2300
CONSTANT: GL_TEXTURE_ENV_MODE               HEX: 2200
CONSTANT: GL_TEXTURE_1D                     HEX: 0DE0
CONSTANT: GL_TEXTURE_2D                     HEX: 0DE1
CONSTANT: GL_TEXTURE_WRAP_S                 HEX: 2802
CONSTANT: GL_TEXTURE_WRAP_T                 HEX: 2803
CONSTANT: GL_TEXTURE_MAG_FILTER             HEX: 2800
CONSTANT: GL_TEXTURE_MIN_FILTER             HEX: 2801
CONSTANT: GL_TEXTURE_ENV_COLOR              HEX: 2201
CONSTANT: GL_TEXTURE_GEN_S                  HEX: 0C60
CONSTANT: GL_TEXTURE_GEN_T                  HEX: 0C61
CONSTANT: GL_TEXTURE_GEN_MODE               HEX: 2500
CONSTANT: GL_TEXTURE_BORDER_COLOR           HEX: 1004
CONSTANT: GL_TEXTURE_WIDTH                  HEX: 1000
CONSTANT: GL_TEXTURE_HEIGHT                 HEX: 1001
CONSTANT: GL_TEXTURE_BORDER                 HEX: 1005
CONSTANT: GL_TEXTURE_COMPONENTS             HEX: 1003
CONSTANT: GL_TEXTURE_RED_SIZE               HEX: 805C
CONSTANT: GL_TEXTURE_GREEN_SIZE             HEX: 805D
CONSTANT: GL_TEXTURE_BLUE_SIZE              HEX: 805E
CONSTANT: GL_TEXTURE_ALPHA_SIZE             HEX: 805F
CONSTANT: GL_TEXTURE_LUMINANCE_SIZE         HEX: 8060
CONSTANT: GL_TEXTURE_INTENSITY_SIZE         HEX: 8061
CONSTANT: GL_NEAREST_MIPMAP_NEAREST         HEX: 2700
CONSTANT: GL_NEAREST_MIPMAP_LINEAR          HEX: 2702
CONSTANT: GL_LINEAR_MIPMAP_NEAREST          HEX: 2701
CONSTANT: GL_LINEAR_MIPMAP_LINEAR           HEX: 2703
CONSTANT: GL_OBJECT_LINEAR                  HEX: 2401
CONSTANT: GL_OBJECT_PLANE                   HEX: 2501
CONSTANT: GL_EYE_LINEAR                     HEX: 2400
CONSTANT: GL_EYE_PLANE                      HEX: 2502
CONSTANT: GL_SPHERE_MAP                     HEX: 2402
CONSTANT: GL_DECAL                          HEX: 2101
CONSTANT: GL_MODULATE                       HEX: 2100
CONSTANT: GL_NEAREST                        HEX: 2600
CONSTANT: GL_REPEAT                         HEX: 2901
CONSTANT: GL_CLAMP                          HEX: 2900
CONSTANT: GL_S                              HEX: 2000
CONSTANT: GL_T                              HEX: 2001
CONSTANT: GL_R                              HEX: 2002
CONSTANT: GL_Q                              HEX: 2003
CONSTANT: GL_TEXTURE_GEN_R                  HEX: 0C62
CONSTANT: GL_TEXTURE_GEN_Q                  HEX: 0C63

! Utility inline
CONSTANT: GL_VENDOR                         HEX: 1F00
CONSTANT: GL_RENDERER                       HEX: 1F01
CONSTANT: GL_VERSION                        HEX: 1F02
CONSTANT: GL_EXTENSIONS                     HEX: 1F03

! Errors inline
CONSTANT: GL_NO_ERROR                       HEX:    0
CONSTANT: GL_INVALID_VALUE                  HEX: 0501
CONSTANT: GL_INVALID_ENUM                   HEX: 0500
CONSTANT: GL_INVALID_OPERATION              HEX: 0502
CONSTANT: GL_STACK_OVERFLOW                 HEX: 0503
CONSTANT: GL_STACK_UNDERFLOW                HEX: 0504
CONSTANT: GL_OUT_OF_MEMORY                  HEX: 0505

! glPush/PopAttrib bits
CONSTANT: GL_CURRENT_BIT                    HEX: 00000001
CONSTANT: GL_POINT_BIT                      HEX: 00000002
CONSTANT: GL_LINE_BIT                       HEX: 00000004
CONSTANT: GL_POLYGON_BIT                    HEX: 00000008
CONSTANT: GL_POLYGON_STIPPLE_BIT            HEX: 00000010
CONSTANT: GL_PIXEL_MODE_BIT                 HEX: 00000020
CONSTANT: GL_LIGHTING_BIT                   HEX: 00000040
CONSTANT: GL_FOG_BIT                        HEX: 00000080
CONSTANT: GL_DEPTH_BUFFER_BIT               HEX: 00000100
CONSTANT: GL_ACCUM_BUFFER_BIT               HEX: 00000200
CONSTANT: GL_STENCIL_BUFFER_BIT             HEX: 00000400
CONSTANT: GL_VIEWPORT_BIT                   HEX: 00000800
CONSTANT: GL_TRANSFORM_BIT                  HEX: 00001000
CONSTANT: GL_ENABLE_BIT                     HEX: 00002000
CONSTANT: GL_COLOR_BUFFER_BIT               HEX: 00004000
CONSTANT: GL_HINT_BIT                       HEX: 00008000
CONSTANT: GL_EVAL_BIT                       HEX: 00010000
CONSTANT: GL_LIST_BIT                       HEX: 00020000
CONSTANT: GL_TEXTURE_BIT                    HEX: 00040000
CONSTANT: GL_SCISSOR_BIT                    HEX: 00080000
CONSTANT: GL_ALL_ATTRIB_BITS                HEX: 000FFFFF

! OpenGL 1.1
CONSTANT: GL_PROXY_TEXTURE_1D               HEX: 8063
CONSTANT: GL_PROXY_TEXTURE_2D               HEX: 8064
CONSTANT: GL_TEXTURE_PRIORITY               HEX: 8066
CONSTANT: GL_TEXTURE_RESIDENT               HEX: 8067
CONSTANT: GL_TEXTURE_BINDING_1D             HEX: 8068
CONSTANT: GL_TEXTURE_BINDING_2D             HEX: 8069
CONSTANT: GL_TEXTURE_INTERNAL_FORMAT        HEX: 1003
CONSTANT: GL_ALPHA4                         HEX: 803B
CONSTANT: GL_ALPHA8                         HEX: 803C
CONSTANT: GL_ALPHA12                        HEX: 803D
CONSTANT: GL_ALPHA16                        HEX: 803E
CONSTANT: GL_LUMINANCE4                     HEX: 803F
CONSTANT: GL_LUMINANCE8                     HEX: 8040
CONSTANT: GL_LUMINANCE12                    HEX: 8041
CONSTANT: GL_LUMINANCE16                    HEX: 8042
CONSTANT: GL_LUMINANCE4_ALPHA4              HEX: 8043
CONSTANT: GL_LUMINANCE6_ALPHA2              HEX: 8044
CONSTANT: GL_LUMINANCE8_ALPHA8              HEX: 8045
CONSTANT: GL_LUMINANCE12_ALPHA4             HEX: 8046
CONSTANT: GL_LUMINANCE12_ALPHA12            HEX: 8047
CONSTANT: GL_LUMINANCE16_ALPHA16            HEX: 8048
CONSTANT: GL_INTENSITY                      HEX: 8049
CONSTANT: GL_INTENSITY4                     HEX: 804A
CONSTANT: GL_INTENSITY8                     HEX: 804B
CONSTANT: GL_INTENSITY12                    HEX: 804C
CONSTANT: GL_INTENSITY16                    HEX: 804D
CONSTANT: GL_R3_G3_B2                       HEX: 2A10
CONSTANT: GL_RGB4                           HEX: 804F
CONSTANT: GL_RGB5                           HEX: 8050
CONSTANT: GL_RGB8                           HEX: 8051
CONSTANT: GL_RGB10                          HEX: 8052
CONSTANT: GL_RGB12                          HEX: 8053
CONSTANT: GL_RGB16                          HEX: 8054
CONSTANT: GL_RGBA2                          HEX: 8055
CONSTANT: GL_RGBA4                          HEX: 8056
CONSTANT: GL_RGB5_A1                        HEX: 8057
CONSTANT: GL_RGBA8                          HEX: 8058
CONSTANT: GL_RGB10_A2                       HEX: 8059
CONSTANT: GL_RGBA12                         HEX: 805A
CONSTANT: GL_RGBA16                         HEX: 805B
CONSTANT: GL_CLIENT_PIXEL_STORE_BIT         HEX: 00000001
CONSTANT: GL_CLIENT_VERTEX_ARRAY_BIT        HEX: 00000002
CONSTANT: GL_ALL_CLIENT_ATTRIB_BITS         HEX: FFFFFFFF
CONSTANT: GL_CLIENT_ALL_ATTRIB_BITS         HEX: FFFFFFFF

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
FUNCTION: char* glGetString ( GLenum name ) ;
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

<< reset-gl-function-number-counter >>

! OpenGL 1.2

CONSTANT: GL_SMOOTH_POINT_SIZE_RANGE HEX: 0B12
CONSTANT: GL_SMOOTH_POINT_SIZE_GRANULARITY HEX: 0B13
CONSTANT: GL_SMOOTH_LINE_WIDTH_RANGE HEX: 0B22
CONSTANT: GL_SMOOTH_LINE_WIDTH_GRANULARITY HEX: 0B23
CONSTANT: GL_UNSIGNED_BYTE_3_3_2 HEX: 8032
CONSTANT: GL_UNSIGNED_SHORT_4_4_4_4 HEX: 8033
CONSTANT: GL_UNSIGNED_SHORT_5_5_5_1 HEX: 8034
CONSTANT: GL_UNSIGNED_INT_8_8_8_8 HEX: 8035
CONSTANT: GL_UNSIGNED_INT_10_10_10_2 HEX: 8036
CONSTANT: GL_RESCALE_NORMAL HEX: 803A
CONSTANT: GL_TEXTURE_BINDING_3D HEX: 806A
CONSTANT: GL_PACK_SKIP_IMAGES HEX: 806B
CONSTANT: GL_PACK_IMAGE_HEIGHT HEX: 806C
CONSTANT: GL_UNPACK_SKIP_IMAGES HEX: 806D
CONSTANT: GL_UNPACK_IMAGE_HEIGHT HEX: 806E
CONSTANT: GL_TEXTURE_3D HEX: 806F
CONSTANT: GL_PROXY_TEXTURE_3D HEX: 8070
CONSTANT: GL_TEXTURE_DEPTH HEX: 8071
CONSTANT: GL_TEXTURE_WRAP_R HEX: 8072
CONSTANT: GL_MAX_3D_TEXTURE_SIZE HEX: 8073
CONSTANT: GL_BGR HEX: 80E0
CONSTANT: GL_BGRA HEX: 80E1
CONSTANT: GL_MAX_ELEMENTS_VERTICES HEX: 80E8
CONSTANT: GL_MAX_ELEMENTS_INDICES HEX: 80E9
CONSTANT: GL_CLAMP_TO_EDGE HEX: 812F
CONSTANT: GL_TEXTURE_MIN_LOD HEX: 813A
CONSTANT: GL_TEXTURE_MAX_LOD HEX: 813B
CONSTANT: GL_TEXTURE_BASE_LEVEL HEX: 813C
CONSTANT: GL_TEXTURE_MAX_LEVEL HEX: 813D
CONSTANT: GL_LIGHT_MODEL_COLOR_CONTROL HEX: 81F8
CONSTANT: GL_SINGLE_COLOR HEX: 81F9
CONSTANT: GL_SEPARATE_SPECULAR_COLOR HEX: 81FA
CONSTANT: GL_UNSIGNED_BYTE_2_3_3_REV HEX: 8362
CONSTANT: GL_UNSIGNED_SHORT_5_6_5 HEX: 8363
CONSTANT: GL_UNSIGNED_SHORT_5_6_5_REV HEX: 8364
CONSTANT: GL_UNSIGNED_SHORT_4_4_4_4_REV HEX: 8365
CONSTANT: GL_UNSIGNED_SHORT_1_5_5_5_REV HEX: 8366
CONSTANT: GL_UNSIGNED_INT_8_8_8_8_REV HEX: 8367
CONSTANT: GL_UNSIGNED_INT_2_10_10_10_REV HEX: 8368
CONSTANT: GL_ALIASED_POINT_SIZE_RANGE HEX: 846D
CONSTANT: GL_ALIASED_LINE_WIDTH_RANGE HEX: 846E

GL-FUNCTION: void glCopyTexSubImage3D { glCopyTexSubImage3DEXT } ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height ) ;
GL-FUNCTION: void glDrawRangeElements { glDrawRangeElementsEXT } ( GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, GLvoid* indices ) ;
GL-FUNCTION: void glTexImage3D { glTexImage3DEXT } ( GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, GLvoid* pixels ) ;
GL-FUNCTION: void glTexSubImage3D { glTexSubImage3DEXT } ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, GLvoid* pixels ) ;


! OpenGL 1.3


CONSTANT: GL_MULTISAMPLE HEX: 809D
CONSTANT: GL_SAMPLE_ALPHA_TO_COVERAGE HEX: 809E
CONSTANT: GL_SAMPLE_ALPHA_TO_ONE HEX: 809F
CONSTANT: GL_SAMPLE_COVERAGE HEX: 80A0
CONSTANT: GL_SAMPLE_BUFFERS HEX: 80A8
CONSTANT: GL_SAMPLES HEX: 80A9
CONSTANT: GL_SAMPLE_COVERAGE_VALUE HEX: 80AA
CONSTANT: GL_SAMPLE_COVERAGE_INVERT HEX: 80AB
CONSTANT: GL_CLAMP_TO_BORDER HEX: 812D
CONSTANT: GL_TEXTURE0 HEX: 84C0
CONSTANT: GL_TEXTURE1 HEX: 84C1
CONSTANT: GL_TEXTURE2 HEX: 84C2
CONSTANT: GL_TEXTURE3 HEX: 84C3
CONSTANT: GL_TEXTURE4 HEX: 84C4
CONSTANT: GL_TEXTURE5 HEX: 84C5
CONSTANT: GL_TEXTURE6 HEX: 84C6
CONSTANT: GL_TEXTURE7 HEX: 84C7
CONSTANT: GL_TEXTURE8 HEX: 84C8
CONSTANT: GL_TEXTURE9 HEX: 84C9
CONSTANT: GL_TEXTURE10 HEX: 84CA
CONSTANT: GL_TEXTURE11 HEX: 84CB
CONSTANT: GL_TEXTURE12 HEX: 84CC
CONSTANT: GL_TEXTURE13 HEX: 84CD
CONSTANT: GL_TEXTURE14 HEX: 84CE
CONSTANT: GL_TEXTURE15 HEX: 84CF
CONSTANT: GL_TEXTURE16 HEX: 84D0
CONSTANT: GL_TEXTURE17 HEX: 84D1
CONSTANT: GL_TEXTURE18 HEX: 84D2
CONSTANT: GL_TEXTURE19 HEX: 84D3
CONSTANT: GL_TEXTURE20 HEX: 84D4
CONSTANT: GL_TEXTURE21 HEX: 84D5
CONSTANT: GL_TEXTURE22 HEX: 84D6
CONSTANT: GL_TEXTURE23 HEX: 84D7
CONSTANT: GL_TEXTURE24 HEX: 84D8
CONSTANT: GL_TEXTURE25 HEX: 84D9
CONSTANT: GL_TEXTURE26 HEX: 84DA
CONSTANT: GL_TEXTURE27 HEX: 84DB
CONSTANT: GL_TEXTURE28 HEX: 84DC
CONSTANT: GL_TEXTURE29 HEX: 84DD
CONSTANT: GL_TEXTURE30 HEX: 84DE
CONSTANT: GL_TEXTURE31 HEX: 84DF
CONSTANT: GL_ACTIVE_TEXTURE HEX: 84E0
CONSTANT: GL_CLIENT_ACTIVE_TEXTURE HEX: 84E1
CONSTANT: GL_MAX_TEXTURE_UNITS HEX: 84E2
CONSTANT: GL_TRANSPOSE_MODELVIEW_MATRIX HEX: 84E3
CONSTANT: GL_TRANSPOSE_PROJECTION_MATRIX HEX: 84E4
CONSTANT: GL_TRANSPOSE_TEXTURE_MATRIX HEX: 84E5
CONSTANT: GL_TRANSPOSE_COLOR_MATRIX HEX: 84E6
CONSTANT: GL_SUBTRACT HEX: 84E7
CONSTANT: GL_COMPRESSED_ALPHA HEX: 84E9
CONSTANT: GL_COMPRESSED_LUMINANCE HEX: 84EA
CONSTANT: GL_COMPRESSED_LUMINANCE_ALPHA HEX: 84EB
CONSTANT: GL_COMPRESSED_INTENSITY HEX: 84EC
CONSTANT: GL_COMPRESSED_RGB HEX: 84ED
CONSTANT: GL_COMPRESSED_RGBA HEX: 84EE
CONSTANT: GL_TEXTURE_COMPRESSION_HINT HEX: 84EF
CONSTANT: GL_NORMAL_MAP HEX: 8511
CONSTANT: GL_REFLECTION_MAP HEX: 8512
CONSTANT: GL_TEXTURE_CUBE_MAP HEX: 8513
CONSTANT: GL_TEXTURE_BINDING_CUBE_MAP HEX: 8514
CONSTANT: GL_TEXTURE_CUBE_MAP_POSITIVE_X HEX: 8515
CONSTANT: GL_TEXTURE_CUBE_MAP_NEGATIVE_X HEX: 8516
CONSTANT: GL_TEXTURE_CUBE_MAP_POSITIVE_Y HEX: 8517
CONSTANT: GL_TEXTURE_CUBE_MAP_NEGATIVE_Y HEX: 8518
CONSTANT: GL_TEXTURE_CUBE_MAP_POSITIVE_Z HEX: 8519
CONSTANT: GL_TEXTURE_CUBE_MAP_NEGATIVE_Z HEX: 851A
CONSTANT: GL_PROXY_TEXTURE_CUBE_MAP HEX: 851B
CONSTANT: GL_MAX_CUBE_MAP_TEXTURE_SIZE HEX: 851C
CONSTANT: GL_COMBINE HEX: 8570
CONSTANT: GL_COMBINE_RGB HEX: 8571
CONSTANT: GL_COMBINE_ALPHA HEX: 8572
CONSTANT: GL_RGB_SCALE HEX: 8573
CONSTANT: GL_ADD_SIGNED HEX: 8574
CONSTANT: GL_INTERPOLATE HEX: 8575
CONSTANT: GL_CONSTANT HEX: 8576
CONSTANT: GL_PRIMARY_COLOR HEX: 8577
CONSTANT: GL_PREVIOUS HEX: 8578
CONSTANT: GL_SOURCE0_RGB HEX: 8580
CONSTANT: GL_SOURCE1_RGB HEX: 8581
CONSTANT: GL_SOURCE2_RGB HEX: 8582
CONSTANT: GL_SOURCE0_ALPHA HEX: 8588
CONSTANT: GL_SOURCE1_ALPHA HEX: 8589
CONSTANT: GL_SOURCE2_ALPHA HEX: 858A
CONSTANT: GL_OPERAND0_RGB HEX: 8590
CONSTANT: GL_OPERAND1_RGB HEX: 8591
CONSTANT: GL_OPERAND2_RGB HEX: 8592
CONSTANT: GL_OPERAND0_ALPHA HEX: 8598
CONSTANT: GL_OPERAND1_ALPHA HEX: 8599
CONSTANT: GL_OPERAND2_ALPHA HEX: 859A
CONSTANT: GL_TEXTURE_COMPRESSED_IMAGE_SIZE HEX: 86A0
CONSTANT: GL_TEXTURE_COMPRESSED HEX: 86A1
CONSTANT: GL_NUM_COMPRESSED_TEXTURE_FORMATS HEX: 86A2
CONSTANT: GL_COMPRESSED_TEXTURE_FORMATS HEX: 86A3
CONSTANT: GL_DOT3_RGB HEX: 86AE
CONSTANT: GL_DOT3_RGBA HEX: 86AF
CONSTANT: GL_MULTISAMPLE_BIT HEX: 20000000

GL-FUNCTION: void glActiveTexture { glActiveTextureARB } ( GLenum texture ) ;
GL-FUNCTION: void glClientActiveTexture { glClientActiveTextureARB } ( GLenum texture ) ;
GL-FUNCTION: void glCompressedTexImage1D { glCompressedTexImage1DARB } ( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, GLvoid* data ) ;
GL-FUNCTION: void glCompressedTexImage2D { glCompressedTexImage2DARB } ( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, GLvoid* data ) ;
GL-FUNCTION: void glCompressedTexImage3D { glCompressedTexImage2DARB } ( GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, GLvoid* data ) ;
GL-FUNCTION: void glCompressedTexSubImage1D { glCompressedTexSubImage1DARB } ( GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, GLvoid* data ) ;
GL-FUNCTION: void glCompressedTexSubImage2D { glCompressedTexSubImage2DARB } ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, GLvoid* data ) ;
GL-FUNCTION: void glCompressedTexSubImage3D { glCompressedTexSubImage3DARB } ( GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, GLvoid* data ) ;
GL-FUNCTION: void glGetCompressedTexImage { glGetCompressedTexImageARB } ( GLenum target, GLint lod, GLvoid* img ) ;
GL-FUNCTION: void glLoadTransposeMatrixd { glLoadTransposeMatrixdARB } ( GLdouble m[16] ) ;
GL-FUNCTION: void glLoadTransposeMatrixf { glLoadTransposeMatrixfARB } ( GLfloat m[16] ) ;
GL-FUNCTION: void glMultTransposeMatrixd { glMultTransposeMatrixdARB } ( GLdouble m[16] ) ;
GL-FUNCTION: void glMultTransposeMatrixf { glMultTransposeMatrixfARB } ( GLfloat m[16] ) ;
GL-FUNCTION: void glMultiTexCoord1d { glMultiTexCoord1dARB } ( GLenum target, GLdouble s ) ;
GL-FUNCTION: void glMultiTexCoord1dv { glMultiTexCoord1dvARB } ( GLenum target, GLdouble* v ) ;
GL-FUNCTION: void glMultiTexCoord1f { glMultiTexCoord1fARB } ( GLenum target, GLfloat s ) ;
GL-FUNCTION: void glMultiTexCoord1fv { glMultiTexCoord1fvARB } ( GLenum target, GLfloat* v ) ;
GL-FUNCTION: void glMultiTexCoord1i { glMultiTexCoord1iARB } ( GLenum target, GLint s ) ;
GL-FUNCTION: void glMultiTexCoord1iv { glMultiTexCoord1ivARB } ( GLenum target, GLint* v ) ;
GL-FUNCTION: void glMultiTexCoord1s { glMultiTexCoord1sARB } ( GLenum target, GLshort s ) ;
GL-FUNCTION: void glMultiTexCoord1sv { glMultiTexCoord1svARB } ( GLenum target, GLshort* v ) ;
GL-FUNCTION: void glMultiTexCoord2d { glMultiTexCoord2dARB } ( GLenum target, GLdouble s, GLdouble t ) ;
GL-FUNCTION: void glMultiTexCoord2dv { glMultiTexCoord2dvARB } ( GLenum target, GLdouble* v ) ;
GL-FUNCTION: void glMultiTexCoord2f { glMultiTexCoord2fARB } ( GLenum target, GLfloat s, GLfloat t ) ;
GL-FUNCTION: void glMultiTexCoord2fv { glMultiTexCoord2fvARB } ( GLenum target, GLfloat* v ) ;
GL-FUNCTION: void glMultiTexCoord2i { glMultiTexCoord2iARB } ( GLenum target, GLint s, GLint t ) ;
GL-FUNCTION: void glMultiTexCoord2iv { glMultiTexCoord2ivARB } ( GLenum target, GLint* v ) ;
GL-FUNCTION: void glMultiTexCoord2s { glMultiTexCoord2sARB } ( GLenum target, GLshort s, GLshort t ) ;
GL-FUNCTION: void glMultiTexCoord2sv { glMultiTexCoord2svARB } ( GLenum target, GLshort* v ) ;
GL-FUNCTION: void glMultiTexCoord3d { glMultiTexCoord3dARB } ( GLenum target, GLdouble s, GLdouble t, GLdouble r ) ;
GL-FUNCTION: void glMultiTexCoord3dv { glMultiTexCoord3dvARB } ( GLenum target, GLdouble* v ) ;
GL-FUNCTION: void glMultiTexCoord3f { glMultiTexCoord3fARB } ( GLenum target, GLfloat s, GLfloat t, GLfloat r ) ;
GL-FUNCTION: void glMultiTexCoord3fv { glMultiTexCoord3fvARB } ( GLenum target, GLfloat* v ) ;
GL-FUNCTION: void glMultiTexCoord3i { glMultiTexCoord3iARB } ( GLenum target, GLint s, GLint t, GLint r ) ;
GL-FUNCTION: void glMultiTexCoord3iv { glMultiTexCoord3ivARB } ( GLenum target, GLint* v ) ;
GL-FUNCTION: void glMultiTexCoord3s { glMultiTexCoord3sARB } ( GLenum target, GLshort s, GLshort t, GLshort r ) ;
GL-FUNCTION: void glMultiTexCoord3sv { glMultiTexCoord3svARB } ( GLenum target, GLshort* v ) ;
GL-FUNCTION: void glMultiTexCoord4d { glMultiTexCoord4dARB } ( GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q ) ;
GL-FUNCTION: void glMultiTexCoord4dv { glMultiTexCoord4dvARB } ( GLenum target, GLdouble* v ) ;
GL-FUNCTION: void glMultiTexCoord4f { glMultiTexCoord4fARB } ( GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q ) ;
GL-FUNCTION: void glMultiTexCoord4fv { glMultiTexCoord4fvARB } ( GLenum target, GLfloat* v ) ;
GL-FUNCTION: void glMultiTexCoord4i { glMultiTexCoord4iARB } ( GLenum target, GLint s, GLint t, GLint r, GLint q ) ;
GL-FUNCTION: void glMultiTexCoord4iv { glMultiTexCoord4ivARB } ( GLenum target, GLint* v ) ;
GL-FUNCTION: void glMultiTexCoord4s { glMultiTexCoord4sARB } ( GLenum target, GLshort s, GLshort t, GLshort r, GLshort q ) ;
GL-FUNCTION: void glMultiTexCoord4sv { glMultiTexCoord4svARB } ( GLenum target, GLshort* v ) ;
GL-FUNCTION: void glSampleCoverage { glSampleCoverageARB } ( GLclampf value, GLboolean invert ) ;


! OpenGL 1.4


CONSTANT: GL_BLEND_DST_RGB HEX: 80C8
CONSTANT: GL_BLEND_SRC_RGB HEX: 80C9
CONSTANT: GL_BLEND_DST_ALPHA HEX: 80CA
CONSTANT: GL_BLEND_SRC_ALPHA HEX: 80CB
CONSTANT: GL_POINT_SIZE_MIN HEX: 8126
CONSTANT: GL_POINT_SIZE_MAX HEX: 8127
CONSTANT: GL_POINT_FADE_THRESHOLD_SIZE HEX: 8128
CONSTANT: GL_POINT_DISTANCE_ATTENUATION HEX: 8129
CONSTANT: GL_GENERATE_MIPMAP HEX: 8191
CONSTANT: GL_GENERATE_MIPMAP_HINT HEX: 8192
CONSTANT: GL_DEPTH_COMPONENT16 HEX: 81A5
CONSTANT: GL_DEPTH_COMPONENT24 HEX: 81A6
CONSTANT: GL_DEPTH_COMPONENT32 HEX: 81A7
CONSTANT: GL_MIRRORED_REPEAT HEX: 8370
CONSTANT: GL_FOG_COORDINATE_SOURCE HEX: 8450
CONSTANT: GL_FOG_COORDINATE HEX: 8451
CONSTANT: GL_FRAGMENT_DEPTH HEX: 8452
CONSTANT: GL_CURRENT_FOG_COORDINATE HEX: 8453
CONSTANT: GL_FOG_COORDINATE_ARRAY_TYPE HEX: 8454
CONSTANT: GL_FOG_COORDINATE_ARRAY_STRIDE HEX: 8455
CONSTANT: GL_FOG_COORDINATE_ARRAY_POINTER HEX: 8456
CONSTANT: GL_FOG_COORDINATE_ARRAY HEX: 8457
CONSTANT: GL_COLOR_SUM HEX: 8458
CONSTANT: GL_CURRENT_SECONDARY_COLOR HEX: 8459
CONSTANT: GL_SECONDARY_COLOR_ARRAY_SIZE HEX: 845A
CONSTANT: GL_SECONDARY_COLOR_ARRAY_TYPE HEX: 845B
CONSTANT: GL_SECONDARY_COLOR_ARRAY_STRIDE HEX: 845C
CONSTANT: GL_SECONDARY_COLOR_ARRAY_POINTER HEX: 845D
CONSTANT: GL_SECONDARY_COLOR_ARRAY HEX: 845E
CONSTANT: GL_MAX_TEXTURE_LOD_BIAS HEX: 84FD
CONSTANT: GL_TEXTURE_FILTER_CONTROL HEX: 8500
CONSTANT: GL_TEXTURE_LOD_BIAS HEX: 8501
CONSTANT: GL_INCR_WRAP HEX: 8507
CONSTANT: GL_DECR_WRAP HEX: 8508
CONSTANT: GL_TEXTURE_DEPTH_SIZE HEX: 884A
CONSTANT: GL_DEPTH_TEXTURE_MODE HEX: 884B
CONSTANT: GL_TEXTURE_COMPARE_MODE HEX: 884C
CONSTANT: GL_TEXTURE_COMPARE_FUNC HEX: 884D
CONSTANT: GL_COMPARE_R_TO_TEXTURE HEX: 884E

GL-FUNCTION: void glBlendColor { glBlendColorEXT } ( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha ) ;
GL-FUNCTION: void glBlendEquation { glBlendEquationEXT } ( GLenum mode ) ;
GL-FUNCTION: void glBlendFuncSeparate { glBlendFuncSeparateEXT } ( GLenum sfactorRGB, GLenum dfactorRGB, GLenum sfactorAlpha, GLenum dfactorAlpha ) ;
GL-FUNCTION: void glFogCoordPointer { glFogCoordPointerEXT } ( GLenum type, GLsizei stride, GLvoid* pointer ) ;
GL-FUNCTION: void glFogCoordd { glFogCoorddEXT } ( GLdouble coord ) ;
GL-FUNCTION: void glFogCoorddv { glFogCoorddvEXT } ( GLdouble* coord ) ;
GL-FUNCTION: void glFogCoordf { glFogCoordfEXT } ( GLfloat coord ) ;
GL-FUNCTION: void glFogCoordfv { glFogCoordfvEXT } ( GLfloat* coord ) ;
GL-FUNCTION: void glMultiDrawArrays { glMultiDrawArraysEXT } ( GLenum mode, GLint* first, GLsizei* count, GLsizei primcount ) ;
GL-FUNCTION: void glMultiDrawElements { glMultiDrawElementsEXT } ( GLenum mode, GLsizei* count, GLenum type, GLvoid** indices, GLsizei primcount ) ;
GL-FUNCTION: void glPointParameterf { glPointParameterfARB } ( GLenum pname, GLfloat param ) ;
GL-FUNCTION: void glPointParameterfv { glPointParameterfvARB } ( GLenum pname, GLfloat* params ) ;
GL-FUNCTION: void glSecondaryColor3b { glSecondaryColor3bEXT } ( GLbyte red, GLbyte green, GLbyte blue ) ;
GL-FUNCTION: void glSecondaryColor3bv { glSecondaryColor3bvEXT } ( GLbyte* v ) ;
GL-FUNCTION: void glSecondaryColor3d { glSecondaryColor3dEXT } ( GLdouble red, GLdouble green, GLdouble blue ) ;
GL-FUNCTION: void glSecondaryColor3dv { glSecondaryColor3dvEXT } ( GLdouble* v ) ;
GL-FUNCTION: void glSecondaryColor3f { glSecondaryColor3fEXT } ( GLfloat red, GLfloat green, GLfloat blue ) ;
GL-FUNCTION: void glSecondaryColor3fv { glSecondaryColor3fvEXT } ( GLfloat* v ) ;
GL-FUNCTION: void glSecondaryColor3i { glSecondaryColor3iEXT } ( GLint red, GLint green, GLint blue ) ;
GL-FUNCTION: void glSecondaryColor3iv { glSecondaryColor3ivEXT } ( GLint* v ) ;
GL-FUNCTION: void glSecondaryColor3s { glSecondaryColor3sEXT } ( GLshort red, GLshort green, GLshort blue ) ;
GL-FUNCTION: void glSecondaryColor3sv { glSecondaryColor3svEXT } ( GLshort* v ) ;
GL-FUNCTION: void glSecondaryColor3ub { glSecondaryColor3ubEXT } ( GLubyte red, GLubyte green, GLubyte blue ) ;
GL-FUNCTION: void glSecondaryColor3ubv { glSecondaryColor3ubvEXT } ( GLubyte* v ) ;
GL-FUNCTION: void glSecondaryColor3ui { glSecondaryColor3uiEXT } ( GLuint red, GLuint green, GLuint blue ) ;
GL-FUNCTION: void glSecondaryColor3uiv { glSecondaryColor3uivEXT } ( GLuint* v ) ;
GL-FUNCTION: void glSecondaryColor3us { glSecondaryColor3usEXT } ( GLushort red, GLushort green, GLushort blue ) ;
GL-FUNCTION: void glSecondaryColor3usv { glSecondaryColor3usvEXT } ( GLushort* v ) ;
GL-FUNCTION: void glSecondaryColorPointer { glSecondaryColorPointerEXT } ( GLint size, GLenum type, GLsizei stride, GLvoid* pointer ) ;
GL-FUNCTION: void glWindowPos2d { glWindowPos2dARB } ( GLdouble x, GLdouble y ) ;
GL-FUNCTION: void glWindowPos2dv { glWindowPos2dvARB } ( GLdouble* p ) ;
GL-FUNCTION: void glWindowPos2f { glWindowPos2fARB } ( GLfloat x, GLfloat y ) ;
GL-FUNCTION: void glWindowPos2fv { glWindowPos2fvARB } ( GLfloat* p ) ;
GL-FUNCTION: void glWindowPos2i { glWindowPos2iARB } ( GLint x, GLint y ) ;
GL-FUNCTION: void glWindowPos2iv { glWindowPos2ivARB } ( GLint* p ) ;
GL-FUNCTION: void glWindowPos2s { glWindowPos2sARB } ( GLshort x, GLshort y ) ;
GL-FUNCTION: void glWindowPos2sv { glWindowPos2svARB } ( GLshort* p ) ;
GL-FUNCTION: void glWindowPos3d { glWindowPos3dARB } ( GLdouble x, GLdouble y, GLdouble z ) ;
GL-FUNCTION: void glWindowPos3dv { glWindowPos3dvARB } ( GLdouble* p ) ;
GL-FUNCTION: void glWindowPos3f { glWindowPos3fARB } ( GLfloat x, GLfloat y, GLfloat z ) ;
GL-FUNCTION: void glWindowPos3fv { glWindowPos3fvARB } ( GLfloat* p ) ;
GL-FUNCTION: void glWindowPos3i { glWindowPos3iARB } ( GLint x, GLint y, GLint z ) ;
GL-FUNCTION: void glWindowPos3iv { glWindowPos3ivARB } ( GLint* p ) ;
GL-FUNCTION: void glWindowPos3s { glWindowPos3sARB } ( GLshort x, GLshort y, GLshort z ) ;
GL-FUNCTION: void glWindowPos3sv { glWindowPos3svARB } ( GLshort* p ) ;

! OpenGL 1.5

CONSTANT: GL_BUFFER_SIZE HEX: 8764
CONSTANT: GL_BUFFER_USAGE HEX: 8765
CONSTANT: GL_QUERY_COUNTER_BITS HEX: 8864
CONSTANT: GL_CURRENT_QUERY HEX: 8865
CONSTANT: GL_QUERY_RESULT HEX: 8866
CONSTANT: GL_QUERY_RESULT_AVAILABLE HEX: 8867
CONSTANT: GL_ARRAY_BUFFER HEX: 8892
CONSTANT: GL_ELEMENT_ARRAY_BUFFER HEX: 8893
CONSTANT: GL_ARRAY_BUFFER_BINDING HEX: 8894
CONSTANT: GL_ELEMENT_ARRAY_BUFFER_BINDING HEX: 8895
CONSTANT: GL_VERTEX_ARRAY_BUFFER_BINDING HEX: 8896
CONSTANT: GL_NORMAL_ARRAY_BUFFER_BINDING HEX: 8897
CONSTANT: GL_COLOR_ARRAY_BUFFER_BINDING HEX: 8898
CONSTANT: GL_INDEX_ARRAY_BUFFER_BINDING HEX: 8899
CONSTANT: GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING HEX: 889A
CONSTANT: GL_EDGE_FLAG_ARRAY_BUFFER_BINDING HEX: 889B
CONSTANT: GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING HEX: 889C
CONSTANT: GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING HEX: 889D
CONSTANT: GL_WEIGHT_ARRAY_BUFFER_BINDING HEX: 889E
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING HEX: 889F
CONSTANT: GL_READ_ONLY HEX: 88B8
CONSTANT: GL_WRITE_ONLY HEX: 88B9
CONSTANT: GL_READ_WRITE HEX: 88BA
CONSTANT: GL_BUFFER_ACCESS HEX: 88BB
CONSTANT: GL_BUFFER_MAPPED HEX: 88BC
CONSTANT: GL_BUFFER_MAP_POINTER HEX: 88BD
CONSTANT: GL_STREAM_DRAW HEX: 88E0
CONSTANT: GL_STREAM_READ HEX: 88E1
CONSTANT: GL_STREAM_COPY HEX: 88E2
CONSTANT: GL_STATIC_DRAW HEX: 88E4
CONSTANT: GL_STATIC_READ HEX: 88E5
CONSTANT: GL_STATIC_COPY HEX: 88E6
CONSTANT: GL_DYNAMIC_DRAW HEX: 88E8
CONSTANT: GL_DYNAMIC_READ HEX: 88E9
CONSTANT: GL_DYNAMIC_COPY HEX: 88EA
CONSTANT: GL_SAMPLES_PASSED HEX: 8914
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

GL-FUNCTION: void glBeginQuery { glBeginQueryARB } ( GLenum target, GLuint id ) ;
GL-FUNCTION: void glBindBuffer { glBindBufferARB } ( GLenum target, GLuint buffer ) ;
GL-FUNCTION: void glBufferData { glBufferDataARB } ( GLenum target, GLsizeiptr size, GLvoid* data, GLenum usage ) ;
GL-FUNCTION: void glBufferSubData { glBufferSubDataARB } ( GLenum target, GLintptr offset, GLsizeiptr size, GLvoid* data ) ;
GL-FUNCTION: void glDeleteBuffers { glDeleteBuffersARB } ( GLsizei n, GLuint* buffers ) ;
GL-FUNCTION: void glDeleteQueries { glDeleteQueriesARB } ( GLsizei n, GLuint* ids ) ;
GL-FUNCTION: void glEndQuery { glEndQueryARB } ( GLenum target ) ;
GL-FUNCTION: void glGenBuffers { glGenBuffersARB } ( GLsizei n, GLuint* buffers ) ;
GL-FUNCTION: void glGenQueries { glGenQueriesARB } ( GLsizei n, GLuint* ids ) ;
GL-FUNCTION: void glGetBufferParameteriv { glGetBufferParameterivARB } ( GLenum target, GLenum pname, GLint* params ) ;
GL-FUNCTION: void glGetBufferPointerv { glGetBufferPointervARB } ( GLenum target, GLenum pname, GLvoid** params ) ;
GL-FUNCTION: void glGetBufferSubData { glGetBufferSubDataARB } ( GLenum target, GLintptr offset, GLsizeiptr size, GLvoid* data ) ;
GL-FUNCTION: void glGetQueryObjectiv { glGetQueryObjectivARB } ( GLuint id, GLenum pname, GLint* params ) ;
GL-FUNCTION: void glGetQueryObjectuiv { glGetQueryObjectuivARB } ( GLuint id, GLenum pname, GLuint* params ) ;
GL-FUNCTION: void glGetQueryiv { glGetQueryivARB } ( GLenum target, GLenum pname, GLint* params ) ;
GL-FUNCTION: GLboolean glIsBuffer { glIsBufferARB } ( GLuint buffer ) ;
GL-FUNCTION: GLboolean glIsQuery { glIsQueryARB } ( GLuint id ) ;
GL-FUNCTION: GLvoid* glMapBuffer { glMapBufferARB } ( GLenum target, GLenum access ) ;
GL-FUNCTION: GLboolean glUnmapBuffer { glUnmapBufferARB } ( GLenum target ) ;


! OpenGL 2.0


CONSTANT: GL_VERTEX_ATTRIB_ARRAY_ENABLED HEX: 8622
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_SIZE HEX: 8623
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_STRIDE HEX: 8624
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_TYPE HEX: 8625
CONSTANT: GL_CURRENT_VERTEX_ATTRIB HEX: 8626
CONSTANT: GL_VERTEX_PROGRAM_POINT_SIZE HEX: 8642
CONSTANT: GL_VERTEX_PROGRAM_TWO_SIDE HEX: 8643
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_POINTER HEX: 8645
CONSTANT: GL_STENCIL_BACK_FUNC HEX: 8800
CONSTANT: GL_STENCIL_BACK_FAIL HEX: 8801
CONSTANT: GL_STENCIL_BACK_PASS_DEPTH_FAIL HEX: 8802
CONSTANT: GL_STENCIL_BACK_PASS_DEPTH_PASS HEX: 8803
CONSTANT: GL_MAX_DRAW_BUFFERS HEX: 8824
CONSTANT: GL_DRAW_BUFFER0 HEX: 8825
CONSTANT: GL_DRAW_BUFFER1 HEX: 8826
CONSTANT: GL_DRAW_BUFFER2 HEX: 8827
CONSTANT: GL_DRAW_BUFFER3 HEX: 8828
CONSTANT: GL_DRAW_BUFFER4 HEX: 8829
CONSTANT: GL_DRAW_BUFFER5 HEX: 882A
CONSTANT: GL_DRAW_BUFFER6 HEX: 882B
CONSTANT: GL_DRAW_BUFFER7 HEX: 882C
CONSTANT: GL_DRAW_BUFFER8 HEX: 882D
CONSTANT: GL_DRAW_BUFFER9 HEX: 882E
CONSTANT: GL_DRAW_BUFFER10 HEX: 882F
CONSTANT: GL_DRAW_BUFFER11 HEX: 8830
CONSTANT: GL_DRAW_BUFFER12 HEX: 8831
CONSTANT: GL_DRAW_BUFFER13 HEX: 8832
CONSTANT: GL_DRAW_BUFFER14 HEX: 8833
CONSTANT: GL_DRAW_BUFFER15 HEX: 8834
CONSTANT: GL_BLEND_EQUATION_ALPHA HEX: 883D
CONSTANT: GL_POINT_SPRITE HEX: 8861
CONSTANT: GL_COORD_REPLACE HEX: 8862
CONSTANT: GL_MAX_VERTEX_ATTRIBS HEX: 8869
CONSTANT: GL_VERTEX_ATTRIB_ARRAY_NORMALIZED HEX: 886A
CONSTANT: GL_MAX_TEXTURE_COORDS HEX: 8871
CONSTANT: GL_MAX_TEXTURE_IMAGE_UNITS HEX: 8872
CONSTANT: GL_FRAGMENT_SHADER HEX: 8B30
CONSTANT: GL_VERTEX_SHADER HEX: 8B31
CONSTANT: GL_MAX_FRAGMENT_UNIFORM_COMPONENTS HEX: 8B49
CONSTANT: GL_MAX_VERTEX_UNIFORM_COMPONENTS HEX: 8B4A
CONSTANT: GL_MAX_VARYING_FLOATS HEX: 8B4B
CONSTANT: GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS HEX: 8B4C
CONSTANT: GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS HEX: 8B4D
CONSTANT: GL_SHADER_TYPE HEX: 8B4F
CONSTANT: GL_FLOAT_VEC2 HEX: 8B50
CONSTANT: GL_FLOAT_VEC3 HEX: 8B51
CONSTANT: GL_FLOAT_VEC4 HEX: 8B52
CONSTANT: GL_INT_VEC2 HEX: 8B53
CONSTANT: GL_INT_VEC3 HEX: 8B54
CONSTANT: GL_INT_VEC4 HEX: 8B55
CONSTANT: GL_BOOL HEX: 8B56
CONSTANT: GL_BOOL_VEC2 HEX: 8B57
CONSTANT: GL_BOOL_VEC3 HEX: 8B58
CONSTANT: GL_BOOL_VEC4 HEX: 8B59
CONSTANT: GL_FLOAT_MAT2 HEX: 8B5A
CONSTANT: GL_FLOAT_MAT3 HEX: 8B5B
CONSTANT: GL_FLOAT_MAT4 HEX: 8B5C
CONSTANT: GL_SAMPLER_1D HEX: 8B5D
CONSTANT: GL_SAMPLER_2D HEX: 8B5E
CONSTANT: GL_SAMPLER_3D HEX: 8B5F
CONSTANT: GL_SAMPLER_CUBE HEX: 8B60
CONSTANT: GL_SAMPLER_1D_SHADOW HEX: 8B61
CONSTANT: GL_SAMPLER_2D_SHADOW HEX: 8B62
CONSTANT: GL_DELETE_STATUS HEX: 8B80
CONSTANT: GL_COMPILE_STATUS HEX: 8B81
CONSTANT: GL_LINK_STATUS HEX: 8B82
CONSTANT: GL_VALIDATE_STATUS HEX: 8B83
CONSTANT: GL_INFO_LOG_LENGTH HEX: 8B84
CONSTANT: GL_ATTACHED_SHADERS HEX: 8B85
CONSTANT: GL_ACTIVE_UNIFORMS HEX: 8B86
CONSTANT: GL_ACTIVE_UNIFORM_MAX_LENGTH HEX: 8B87
CONSTANT: GL_SHADER_SOURCE_LENGTH HEX: 8B88
CONSTANT: GL_ACTIVE_ATTRIBUTES HEX: 8B89
CONSTANT: GL_ACTIVE_ATTRIBUTE_MAX_LENGTH HEX: 8B8A
CONSTANT: GL_FRAGMENT_SHADER_DERIVATIVE_HINT HEX: 8B8B
CONSTANT: GL_SHADING_LANGUAGE_VERSION HEX: 8B8C
CONSTANT: GL_CURRENT_PROGRAM HEX: 8B8D
CONSTANT: GL_POINT_SPRITE_COORD_ORIGIN HEX: 8CA0
CONSTANT: GL_LOWER_LEFT HEX: 8CA1
CONSTANT: GL_UPPER_LEFT HEX: 8CA2
CONSTANT: GL_STENCIL_BACK_REF HEX: 8CA3
CONSTANT: GL_STENCIL_BACK_VALUE_MASK HEX: 8CA4
CONSTANT: GL_STENCIL_BACK_WRITEMASK HEX: 8CA5
CONSTANT: GL_BLEND_EQUATION HEX: 8009
ALIAS: GL_BLEND_EQUATION_RGB GL_BLEND_EQUATION

TYPEDEF: char GLchar

GL-FUNCTION: void glAttachShader { glAttachObjectARB } ( GLuint program, GLuint shader ) ;
GL-FUNCTION: void glBindAttribLocation { glBindAttribLocationARB } ( GLuint program, GLuint index, GLchar* name ) ;
GL-FUNCTION: void glBlendEquationSeparate { glBlendEquationSeparateEXT } ( GLenum modeRGB, GLenum modeAlpha ) ;
GL-FUNCTION: void glCompileShader { glCompileShaderARB } ( GLuint shader ) ;
GL-FUNCTION: GLuint glCreateProgram { glCreateProgramObjectARB } (  ) ;
GL-FUNCTION: GLuint glCreateShader { glCreateShaderObjectARB } ( GLenum type ) ;
GL-FUNCTION: void glDeleteProgram { glDeleteObjectARB } ( GLuint program ) ;
GL-FUNCTION: void glDeleteShader { glDeleteObjectARB } ( GLuint shader ) ;
GL-FUNCTION: void glDetachShader { glDetachObjectARB } ( GLuint program, GLuint shader ) ;
GL-FUNCTION: void glDisableVertexAttribArray { glDisableVertexAttribArrayARB } ( GLuint index ) ;
GL-FUNCTION: void glDrawBuffers { glDrawBuffersARB glDrawBuffersATI } ( GLsizei n, GLenum* bufs ) ;
GL-FUNCTION: void glEnableVertexAttribArray { glEnableVertexAttribArrayARB } ( GLuint index ) ;
GL-FUNCTION: void glGetActiveAttrib { glGetActiveAttribARB } ( GLuint program, GLuint index, GLsizei maxLength, GLsizei* length, GLint* size, GLenum* type, GLchar* name ) ;
GL-FUNCTION: void glGetActiveUniform { glGetActiveUniformARB } ( GLuint program, GLuint index, GLsizei maxLength, GLsizei* length, GLint* size, GLenum* type, GLchar* name ) ;
GL-FUNCTION: void glGetAttachedShaders { glGetAttachedObjectsARB } ( GLuint program, GLsizei maxCount, GLsizei* count, GLuint* shaders ) ;
GL-FUNCTION: GLint glGetAttribLocation { glGetAttribLocationARB } ( GLuint program, GLchar* name ) ;
GL-FUNCTION: void glGetProgramInfoLog { glGetInfoLogARB } ( GLuint program, GLsizei bufSize, GLsizei* length, GLchar* infoLog ) ;
GL-FUNCTION: void glGetProgramiv { glGetObjectParameterivARB } ( GLuint program, GLenum pname, GLint* param ) ;
GL-FUNCTION: void glGetShaderInfoLog { glGetInfoLogARB } ( GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* infoLog ) ;
GL-FUNCTION: void glGetShaderSource { glGetShaderSourceARB } ( GLint obj, GLsizei maxLength, GLsizei* length, GLchar* source ) ;
GL-FUNCTION: void glGetShaderiv { glGetObjectParameterivARB } ( GLuint shader, GLenum pname, GLint* param ) ;
GL-FUNCTION: GLint glGetUniformLocation { glGetUniformLocationARB } ( GLint programObj, GLchar* name ) ;
GL-FUNCTION: void glGetUniformfv { glGetUniformfvARB } ( GLuint program, GLint location, GLfloat* params ) ;
GL-FUNCTION: void glGetUniformiv { glGetUniformivARB } ( GLuint program, GLint location, GLint* params ) ;
GL-FUNCTION: void glGetVertexAttribPointerv { glGetVertexAttribPointervARB } ( GLuint index, GLenum pname, GLvoid** pointer ) ;
GL-FUNCTION: void glGetVertexAttribdv { glGetVertexAttribdvARB } ( GLuint index, GLenum pname, GLdouble* params ) ;
GL-FUNCTION: void glGetVertexAttribfv { glGetVertexAttribfvARB } ( GLuint index, GLenum pname, GLfloat* params ) ;
GL-FUNCTION: void glGetVertexAttribiv { glGetVertexAttribivARB } ( GLuint index, GLenum pname, GLint* params ) ;
GL-FUNCTION: GLboolean glIsProgram { glIsProgramARB } ( GLuint program ) ;
GL-FUNCTION: GLboolean glIsShader { glIsShaderARB } ( GLuint shader ) ;
GL-FUNCTION: void glLinkProgram { glLinkProgramARB } ( GLuint program ) ;
GL-FUNCTION: void glShaderSource { glShaderSourceARB } ( GLuint shader, GLsizei count, GLchar** strings, GLint* lengths ) ;
GL-FUNCTION: void glStencilFuncSeparate { glStencilFuncSeparateATI } ( GLenum frontfunc, GLenum backfunc, GLint ref, GLuint mask ) ;
GL-FUNCTION: void glStencilMaskSeparate { } ( GLenum face, GLuint mask ) ;
GL-FUNCTION: void glStencilOpSeparate { glStencilOpSeparateATI } ( GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass ) ;
GL-FUNCTION: void glUniform1f { glUniform1fARB } ( GLint location, GLfloat v0 ) ;
GL-FUNCTION: void glUniform1fv { glUniform1fvARB } ( GLint location, GLsizei count, GLfloat* value ) ;
GL-FUNCTION: void glUniform1i { glUniform1iARB } ( GLint location, GLint v0 ) ;
GL-FUNCTION: void glUniform1iv { glUniform1ivARB } ( GLint location, GLsizei count, GLint* value ) ;
GL-FUNCTION: void glUniform2f { glUniform2fARB } ( GLint location, GLfloat v0, GLfloat v1 ) ;
GL-FUNCTION: void glUniform2fv { glUniform2fvARB } ( GLint location, GLsizei count, GLfloat* value ) ;
GL-FUNCTION: void glUniform2i { glUniform2iARB } ( GLint location, GLint v0, GLint v1 ) ;
GL-FUNCTION: void glUniform2iv { glUniform2ivARB } ( GLint location, GLsizei count, GLint* value ) ;
GL-FUNCTION: void glUniform3f { glUniform3fARB } ( GLint location, GLfloat v0, GLfloat v1, GLfloat v2 ) ;
GL-FUNCTION: void glUniform3fv { glUniform3fvARB } ( GLint location, GLsizei count, GLfloat* value ) ;
GL-FUNCTION: void glUniform3i { glUniform3iARB } ( GLint location, GLint v0, GLint v1, GLint v2 ) ;
GL-FUNCTION: void glUniform3iv { glUniform3ivARB } ( GLint location, GLsizei count, GLint* value ) ;
GL-FUNCTION: void glUniform4f { glUniform4fARB } ( GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3 ) ;
GL-FUNCTION: void glUniform4fv { glUniform4fvARB } ( GLint location, GLsizei count, GLfloat* value ) ;
GL-FUNCTION: void glUniform4i { glUniform4iARB } ( GLint location, GLint v0, GLint v1, GLint v2, GLint v3 ) ;
GL-FUNCTION: void glUniform4iv { glUniform4ivARB } ( GLint location, GLsizei count, GLint* value ) ;
GL-FUNCTION: void glUniformMatrix2fv { glUniformMatrix2fvARB } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;
GL-FUNCTION: void glUniformMatrix3fv { glUniformMatrix3fvARB } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;
GL-FUNCTION: void glUniformMatrix4fv { glUniformMatrix4fvARB } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;
GL-FUNCTION: void glUseProgram { glUseProgramObjectARB } ( GLuint program ) ;
GL-FUNCTION: void glValidateProgram { glValidateProgramARB } ( GLuint program ) ;
GL-FUNCTION: void glVertexAttrib1d { glVertexAttrib1dARB } ( GLuint index, GLdouble x ) ;
GL-FUNCTION: void glVertexAttrib1dv { glVertexAttrib1dvARB } ( GLuint index, GLdouble* v ) ;
GL-FUNCTION: void glVertexAttrib1f { glVertexAttrib1fARB } ( GLuint index, GLfloat x ) ;
GL-FUNCTION: void glVertexAttrib1fv { glVertexAttrib1fvARB } ( GLuint index, GLfloat* v ) ;
GL-FUNCTION: void glVertexAttrib1s { glVertexAttrib1sARB } ( GLuint index, GLshort x ) ;
GL-FUNCTION: void glVertexAttrib1sv { glVertexAttrib1svARB } ( GLuint index, GLshort* v ) ;
GL-FUNCTION: void glVertexAttrib2d { glVertexAttrib2dARB } ( GLuint index, GLdouble x, GLdouble y ) ;
GL-FUNCTION: void glVertexAttrib2dv { glVertexAttrib2dvARB } ( GLuint index, GLdouble* v ) ;
GL-FUNCTION: void glVertexAttrib2f { glVertexAttrib2fARB } ( GLuint index, GLfloat x, GLfloat y ) ;
GL-FUNCTION: void glVertexAttrib2fv { glVertexAttrib2fvARB } ( GLuint index, GLfloat* v ) ;
GL-FUNCTION: void glVertexAttrib2s { glVertexAttrib2sARB } ( GLuint index, GLshort x, GLshort y ) ;
GL-FUNCTION: void glVertexAttrib2sv { glVertexAttrib2svARB } ( GLuint index, GLshort* v ) ;
GL-FUNCTION: void glVertexAttrib3d { glVertexAttrib3dARB } ( GLuint index, GLdouble x, GLdouble y, GLdouble z ) ;
GL-FUNCTION: void glVertexAttrib3dv { glVertexAttrib3dvARB } ( GLuint index, GLdouble* v ) ;
GL-FUNCTION: void glVertexAttrib3f { glVertexAttrib3fARB } ( GLuint index, GLfloat x, GLfloat y, GLfloat z ) ;
GL-FUNCTION: void glVertexAttrib3fv { glVertexAttrib3fvARB } ( GLuint index, GLfloat* v ) ;
GL-FUNCTION: void glVertexAttrib3s { glVertexAttrib3sARB } ( GLuint index, GLshort x, GLshort y, GLshort z ) ;
GL-FUNCTION: void glVertexAttrib3sv { glVertexAttrib3svARB } ( GLuint index, GLshort* v ) ;
GL-FUNCTION: void glVertexAttrib4Nbv { glVertexAttrib4NbvARB } ( GLuint index, GLbyte* v ) ;
GL-FUNCTION: void glVertexAttrib4Niv { glVertexAttrib4NivARB } ( GLuint index, GLint* v ) ;
GL-FUNCTION: void glVertexAttrib4Nsv { glVertexAttrib4NsvARB } ( GLuint index, GLshort* v ) ;
GL-FUNCTION: void glVertexAttrib4Nub { glVertexAttrib4NubARB } ( GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w ) ;
GL-FUNCTION: void glVertexAttrib4Nubv { glVertexAttrib4NubvARB } ( GLuint index, GLubyte* v ) ;
GL-FUNCTION: void glVertexAttrib4Nuiv { glVertexAttrib4NuivARB } ( GLuint index, GLuint* v ) ;
GL-FUNCTION: void glVertexAttrib4Nusv { glVertexAttrib4NusvARB } ( GLuint index, GLushort* v ) ;
GL-FUNCTION: void glVertexAttrib4bv { glVertexAttrib4bvARB } ( GLuint index, GLbyte* v ) ;
GL-FUNCTION: void glVertexAttrib4d { glVertexAttrib4dARB } ( GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w ) ;
GL-FUNCTION: void glVertexAttrib4dv { glVertexAttrib4dvARB } ( GLuint index, GLdouble* v ) ;
GL-FUNCTION: void glVertexAttrib4f { glVertexAttrib4fARB } ( GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w ) ;
GL-FUNCTION: void glVertexAttrib4fv { glVertexAttrib4fvARB } ( GLuint index, GLfloat* v ) ;
GL-FUNCTION: void glVertexAttrib4iv { glVertexAttrib4ivARB } ( GLuint index, GLint* v ) ;
GL-FUNCTION: void glVertexAttrib4s { glVertexAttrib4sARB } ( GLuint index, GLshort x, GLshort y, GLshort z, GLshort w ) ;
GL-FUNCTION: void glVertexAttrib4sv { glVertexAttrib4svARB } ( GLuint index, GLshort* v ) ;
GL-FUNCTION: void glVertexAttrib4ubv { glVertexAttrib4ubvARB } ( GLuint index, GLubyte* v ) ;
GL-FUNCTION: void glVertexAttrib4uiv { glVertexAttrib4uivARB } ( GLuint index, GLuint* v ) ;
GL-FUNCTION: void glVertexAttrib4usv { glVertexAttrib4usvARB } ( GLuint index, GLushort* v ) ;
GL-FUNCTION: void glVertexAttribPointer { glVertexAttribPointerARB } ( GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, GLvoid* pointer ) ;


! OpenGL 2.1


CONSTANT: GL_CURRENT_RASTER_SECONDARY_COLOR HEX: 845F
CONSTANT: GL_PIXEL_PACK_BUFFER HEX: 88EB
CONSTANT: GL_PIXEL_UNPACK_BUFFER HEX: 88EC
CONSTANT: GL_PIXEL_PACK_BUFFER_BINDING HEX: 88ED
CONSTANT: GL_PIXEL_UNPACK_BUFFER_BINDING HEX: 88EF
CONSTANT: GL_SRGB HEX: 8C40
CONSTANT: GL_SRGB8 HEX: 8C41
CONSTANT: GL_SRGB_ALPHA HEX: 8C42
CONSTANT: GL_SRGB8_ALPHA8 HEX: 8C43
CONSTANT: GL_SLUMINANCE_ALPHA HEX: 8C44
CONSTANT: GL_SLUMINANCE8_ALPHA8 HEX: 8C45
CONSTANT: GL_SLUMINANCE HEX: 8C46
CONSTANT: GL_SLUMINANCE8 HEX: 8C47
CONSTANT: GL_COMPRESSED_SRGB HEX: 8C48
CONSTANT: GL_COMPRESSED_SRGB_ALPHA HEX: 8C49
CONSTANT: GL_COMPRESSED_SLUMINANCE HEX: 8C4A
CONSTANT: GL_COMPRESSED_SLUMINANCE_ALPHA HEX: 8C4B

GL-FUNCTION: void glUniformMatrix2x3fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;
GL-FUNCTION: void glUniformMatrix2x4fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;
GL-FUNCTION: void glUniformMatrix3x2fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;
GL-FUNCTION: void glUniformMatrix3x4fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;
GL-FUNCTION: void glUniformMatrix4x2fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;
GL-FUNCTION: void glUniformMatrix4x3fv { } ( GLint location, GLsizei count, GLboolean transpose, GLfloat* value ) ;


! GL_EXT_framebuffer_object


CONSTANT: GL_INVALID_FRAMEBUFFER_OPERATION_EXT HEX: 0506
CONSTANT: GL_MAX_RENDERBUFFER_SIZE_EXT HEX: 84E8
CONSTANT: GL_FRAMEBUFFER_BINDING_EXT HEX: 8CA6
CONSTANT: GL_RENDERBUFFER_BINDING_EXT HEX: 8CA7
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE_EXT HEX: 8CD0
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME_EXT HEX: 8CD1
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL_EXT HEX: 8CD2
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE_EXT HEX: 8CD3
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_3D_ZOFFSET_EXT HEX: 8CD4
CONSTANT: GL_FRAMEBUFFER_COMPLETE_EXT HEX: 8CD5
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT HEX: 8CD6
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT HEX: 8CD7
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT HEX: 8CD9
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT HEX: 8CDA
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT HEX: 8CDB
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT HEX: 8CDC
CONSTANT: GL_FRAMEBUFFER_UNSUPPORTED_EXT HEX: 8CDD
CONSTANT: GL_MAX_COLOR_ATTACHMENTS_EXT HEX: 8CDF
CONSTANT: GL_COLOR_ATTACHMENT0_EXT HEX: 8CE0
CONSTANT: GL_COLOR_ATTACHMENT1_EXT HEX: 8CE1
CONSTANT: GL_COLOR_ATTACHMENT2_EXT HEX: 8CE2
CONSTANT: GL_COLOR_ATTACHMENT3_EXT HEX: 8CE3
CONSTANT: GL_COLOR_ATTACHMENT4_EXT HEX: 8CE4
CONSTANT: GL_COLOR_ATTACHMENT5_EXT HEX: 8CE5
CONSTANT: GL_COLOR_ATTACHMENT6_EXT HEX: 8CE6
CONSTANT: GL_COLOR_ATTACHMENT7_EXT HEX: 8CE7
CONSTANT: GL_COLOR_ATTACHMENT8_EXT HEX: 8CE8
CONSTANT: GL_COLOR_ATTACHMENT9_EXT HEX: 8CE9
CONSTANT: GL_COLOR_ATTACHMENT10_EXT HEX: 8CEA
CONSTANT: GL_COLOR_ATTACHMENT11_EXT HEX: 8CEB
CONSTANT: GL_COLOR_ATTACHMENT12_EXT HEX: 8CEC
CONSTANT: GL_COLOR_ATTACHMENT13_EXT HEX: 8CED
CONSTANT: GL_COLOR_ATTACHMENT14_EXT HEX: 8CEE
CONSTANT: GL_COLOR_ATTACHMENT15_EXT HEX: 8CEF
CONSTANT: GL_DEPTH_ATTACHMENT_EXT HEX: 8D00
CONSTANT: GL_STENCIL_ATTACHMENT_EXT HEX: 8D20
CONSTANT: GL_FRAMEBUFFER_EXT HEX: 8D40
CONSTANT: GL_RENDERBUFFER_EXT HEX: 8D41
CONSTANT: GL_RENDERBUFFER_WIDTH_EXT HEX: 8D42
CONSTANT: GL_RENDERBUFFER_HEIGHT_EXT HEX: 8D43
CONSTANT: GL_RENDERBUFFER_INTERNAL_FORMAT_EXT HEX: 8D44
CONSTANT: GL_STENCIL_INDEX1_EXT HEX: 8D46
CONSTANT: GL_STENCIL_INDEX4_EXT HEX: 8D47
CONSTANT: GL_STENCIL_INDEX8_EXT HEX: 8D48
CONSTANT: GL_STENCIL_INDEX16_EXT HEX: 8D49
CONSTANT: GL_RENDERBUFFER_RED_SIZE_EXT HEX: 8D50
CONSTANT: GL_RENDERBUFFER_GREEN_SIZE_EXT HEX: 8D51
CONSTANT: GL_RENDERBUFFER_BLUE_SIZE_EXT HEX: 8D52
CONSTANT: GL_RENDERBUFFER_ALPHA_SIZE_EXT HEX: 8D53
CONSTANT: GL_RENDERBUFFER_DEPTH_SIZE_EXT HEX: 8D54
CONSTANT: GL_RENDERBUFFER_STENCIL_SIZE_EXT HEX: 8D55

GL-FUNCTION: void glBindFramebufferEXT { } ( GLenum target, GLuint framebuffer ) ;
GL-FUNCTION: void glBindRenderbufferEXT { } ( GLenum target, GLuint renderbuffer ) ;
GL-FUNCTION: GLenum glCheckFramebufferStatusEXT { } ( GLenum target ) ;
GL-FUNCTION: void glDeleteFramebuffersEXT { } ( GLsizei n, GLuint* framebuffers ) ;
GL-FUNCTION: void glDeleteRenderbuffersEXT { } ( GLsizei n, GLuint* renderbuffers ) ;
GL-FUNCTION: void glFramebufferRenderbufferEXT { } ( GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer ) ;
GL-FUNCTION: void glFramebufferTexture1DEXT { } ( GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level ) ;
GL-FUNCTION: void glFramebufferTexture2DEXT { } ( GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level ) ;
GL-FUNCTION: void glFramebufferTexture3DEXT { } ( GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset ) ;
GL-FUNCTION: void glGenFramebuffersEXT { } ( GLsizei n, GLuint* framebuffers ) ;
GL-FUNCTION: void glGenRenderbuffersEXT { } ( GLsizei n, GLuint* renderbuffers ) ;
GL-FUNCTION: void glGenerateMipmapEXT { } ( GLenum target ) ;
GL-FUNCTION: void glGetFramebufferAttachmentParameterivEXT { } ( GLenum target, GLenum attachment, GLenum pname, GLint* params ) ;
GL-FUNCTION: void glGetRenderbufferParameterivEXT { } ( GLenum target, GLenum pname, GLint* params ) ;
GL-FUNCTION: GLboolean glIsFramebufferEXT { } ( GLuint framebuffer ) ;
GL-FUNCTION: GLboolean glIsRenderbufferEXT { } ( GLuint renderbuffer ) ;
GL-FUNCTION: void glRenderbufferStorageEXT { } ( GLenum target, GLenum internalformat, GLsizei width, GLsizei height ) ;


! GL_EXT_framebuffer_blit


GL-FUNCTION: void glBlitFramebufferEXT { } ( GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1,
                                             GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1,
                                             GLbitfield mask, GLenum filter ) ;

CONSTANT: GL_READ_FRAMEBUFFER_EXT HEX: 8CA8
CONSTANT: GL_DRAW_FRAMEBUFFER_EXT HEX: 8CA9

ALIAS: GL_DRAW_FRAMEBUFFER_BINDING_EXT GL_FRAMEBUFFER_BINDING_EXT
CONSTANT: GL_READ_FRAMEBUFFER_BINDING_EXT HEX: 8CAA


! GL_EXT_framebuffer_multisample


GL-FUNCTION: void glRenderbufferStorageMultisampleEXT { } (
            GLenum target, GLsizei samples,
            GLenum internalformat,
            GLsizei width, GLsizei height ) ;

CONSTANT: GL_RENDERBUFFER_SAMPLES_EXT HEX: 8CAB
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_EXT HEX: 8D56
CONSTANT: GL_MAX_SAMPLES_EXT HEX: 8D57


! GL_ARB_texture_float


CONSTANT: GL_RGBA32F_ARB HEX: 8814
CONSTANT: GL_RGB32F_ARB HEX: 8815
CONSTANT: GL_ALPHA32F_ARB HEX: 8816
CONSTANT: GL_INTENSITY32F_ARB HEX: 8817
CONSTANT: GL_LUMINANCE32F_ARB HEX: 8818
CONSTANT: GL_LUMINANCE_ALPHA32F_ARB HEX: 8819
CONSTANT: GL_RGBA16F_ARB HEX: 881A
CONSTANT: GL_RGB16F_ARB HEX: 881B
CONSTANT: GL_ALPHA16F_ARB HEX: 881C
CONSTANT: GL_INTENSITY16F_ARB HEX: 881D
CONSTANT: GL_LUMINANCE16F_ARB HEX: 881E
CONSTANT: GL_LUMINANCE_ALPHA16F_ARB HEX: 881F
CONSTANT: GL_TEXTURE_RED_TYPE_ARB HEX: 8C10
CONSTANT: GL_TEXTURE_GREEN_TYPE_ARB HEX: 8C11
CONSTANT: GL_TEXTURE_BLUE_TYPE_ARB HEX: 8C12
CONSTANT: GL_TEXTURE_ALPHA_TYPE_ARB HEX: 8C13
CONSTANT: GL_TEXTURE_LUMINANCE_TYPE_ARB HEX: 8C14
CONSTANT: GL_TEXTURE_INTENSITY_TYPE_ARB HEX: 8C15
CONSTANT: GL_TEXTURE_DEPTH_TYPE_ARB HEX: 8C16
CONSTANT: GL_UNSIGNED_NORMALIZED_ARB HEX: 8C17


! GL_EXT_gpu_shader4


GL-FUNCTION: void glVertexAttribI1iEXT { } ( GLuint index, GLint x ) ;
GL-FUNCTION: void glVertexAttribI2iEXT { } ( GLuint index, GLint x, GLint y ) ;
GL-FUNCTION: void glVertexAttribI3iEXT { } ( GLuint index, GLint x, GLint y, GLint z ) ;
GL-FUNCTION: void glVertexAttribI4iEXT { } ( GLuint index, GLint x, GLint y, GLint z, GLint w ) ;

GL-FUNCTION: void glVertexAttribI1uiEXT { } ( GLuint index, GLuint x ) ;
GL-FUNCTION: void glVertexAttribI2uiEXT { } ( GLuint index, GLuint x, GLuint y ) ;
GL-FUNCTION: void glVertexAttribI3uiEXT { } ( GLuint index, GLuint x, GLuint y, GLuint z ) ;
GL-FUNCTION: void glVertexAttribI4uiEXT { } ( GLuint index, GLuint x, GLuint y, GLuint z, GLuint w ) ;

GL-FUNCTION: void glVertexAttribI1ivEXT { } ( GLuint index, GLint* v ) ;
GL-FUNCTION: void glVertexAttribI2ivEXT { } ( GLuint index, GLint* v ) ;
GL-FUNCTION: void glVertexAttribI3ivEXT { } ( GLuint index, GLint* v ) ;
GL-FUNCTION: void glVertexAttribI4ivEXT { } ( GLuint index, GLint* v ) ;

GL-FUNCTION: void glVertexAttribI1uivEXT { } ( GLuint index, GLuint* v ) ;
GL-FUNCTION: void glVertexAttribI2uivEXT { } ( GLuint index, GLuint* v ) ;
GL-FUNCTION: void glVertexAttribI3uivEXT { } ( GLuint index, GLuint* v ) ;
GL-FUNCTION: void glVertexAttribI4uivEXT { } ( GLuint index, GLuint* v ) ;

GL-FUNCTION: void glVertexAttribI4bvEXT { } ( GLuint index, GLbyte* v ) ;
GL-FUNCTION: void glVertexAttribI4svEXT { } ( GLuint index, GLshort* v ) ;
GL-FUNCTION: void glVertexAttribI4ubvEXT { } ( GLuint index, GLubyte* v ) ;
GL-FUNCTION: void glVertexAttribI4usvEXT { } ( GLuint index, GLushort* v ) ;

GL-FUNCTION: void glVertexAttribIPointerEXT { } ( GLuint index, GLint size, GLenum type, GLsizei stride, void* pointer ) ;

GL-FUNCTION: void glGetVertexAttribIivEXT { } ( GLuint index, GLenum pname, GLint* params ) ;
GL-FUNCTION: void glGetVertexAttribIuivEXT { } ( GLuint index, GLenum pname, GLuint* params ) ;

GL-FUNCTION: void glUniform1uiEXT { } ( GLint location, GLuint v0 ) ;
GL-FUNCTION: void glUniform2uiEXT { } ( GLint location, GLuint v0, GLuint v1 ) ;
GL-FUNCTION: void glUniform3uiEXT { } ( GLint location, GLuint v0, GLuint v1, GLuint v2 ) ;
GL-FUNCTION: void glUniform4uiEXT { } ( GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3 ) ;

GL-FUNCTION: void glUniform1uivEXT { } ( GLint location, GLsizei count, GLuint* value ) ;
GL-FUNCTION: void glUniform2uivEXT { } ( GLint location, GLsizei count, GLuint* value ) ;
GL-FUNCTION: void glUniform3uivEXT { } ( GLint location, GLsizei count, GLuint* value ) ;
GL-FUNCTION: void glUniform4uivEXT { } ( GLint location, GLsizei count, GLuint* value ) ;

GL-FUNCTION: void glGetUniformuivEXT { } ( GLuint program, GLint location, GLuint* params ) ;

GL-FUNCTION: void glBindFragDataLocationEXT { } ( GLuint program, GLuint colorNumber, GLchar* name ) ;
GL-FUNCTION: GLint GetFragDataLocationEXT { } ( GLuint program, GLchar* name ) ;

CONSTANT: GL_VERTEX_ATTRIB_ARRAY_INTEGER_EXT HEX: 88FD
CONSTANT: GL_SAMPLER_1D_ARRAY_EXT HEX: 8DC0
CONSTANT: GL_SAMPLER_2D_ARRAY_EXT HEX: 8DC1
CONSTANT: GL_SAMPLER_BUFFER_EXT HEX: 8DC2
CONSTANT: GL_SAMPLER_1D_ARRAY_SHADOW_EXT HEX: 8DC3
CONSTANT: GL_SAMPLER_2D_ARRAY_SHADOW_EXT HEX: 8DC4
CONSTANT: GL_SAMPLER_CUBE_SHADOW_EXT HEX: 8DC5
CONSTANT: GL_UNSIGNED_INT_VEC2_EXT HEX: 8DC6
CONSTANT: GL_UNSIGNED_INT_VEC3_EXT HEX: 8DC7
CONSTANT: GL_UNSIGNED_INT_VEC4_EXT HEX: 8DC8
CONSTANT: GL_INT_SAMPLER_1D_EXT HEX: 8DC9
CONSTANT: GL_INT_SAMPLER_2D_EXT HEX: 8DCA
CONSTANT: GL_INT_SAMPLER_3D_EXT HEX: 8DCB
CONSTANT: GL_INT_SAMPLER_CUBE_EXT HEX: 8DCC
CONSTANT: GL_INT_SAMPLER_2D_RECT_EXT HEX: 8DCD
CONSTANT: GL_INT_SAMPLER_1D_ARRAY_EXT HEX: 8DCE
CONSTANT: GL_INT_SAMPLER_2D_ARRAY_EXT HEX: 8DCF
CONSTANT: GL_INT_SAMPLER_BUFFER_EXT HEX: 8DD0
CONSTANT: GL_UNSIGNED_INT_SAMPLER_1D_EXT HEX: 8DD1
CONSTANT: GL_UNSIGNED_INT_SAMPLER_2D_EXT HEX: 8DD2
CONSTANT: GL_UNSIGNED_INT_SAMPLER_3D_EXT HEX: 8DD3
CONSTANT: GL_UNSIGNED_INT_SAMPLER_CUBE_EXT HEX: 8DD4
CONSTANT: GL_UNSIGNED_INT_SAMPLER_2D_RECT_EXT HEX: 8DD5
CONSTANT: GL_UNSIGNED_INT_SAMPLER_1D_ARRAY_EXT HEX: 8DD6
CONSTANT: GL_UNSIGNED_INT_SAMPLER_2D_ARRAY_EXT HEX: 8DD7
CONSTANT: GL_UNSIGNED_INT_SAMPLER_BUFFER_EXT HEX: 8DD8
CONSTANT: GL_MIN_PROGRAM_TEXEL_OFFSET_EXT HEX: 8904
CONSTANT: GL_MAX_PROGRAM_TEXEL_OFFSET_EXT HEX: 8905


! GL_EXT_geometry_shader4


GL-FUNCTION: void glProgramParameteriEXT { } ( GLuint program, GLenum pname, GLint value ) ;
GL-FUNCTION: void glFramebufferTextureEXT { } ( GLenum target, GLenum attachment, 
                                                GLuint texture, GLint level ) ;
GL-FUNCTION: void glFramebufferTextureLayerEXT { } ( GLenum target, GLenum attachment, 
                                                     GLuint texture, GLint level, GLint layer ) ;
GL-FUNCTION: void glFramebufferTextureFaceEXT { } ( GLenum target, GLenum attachment,
                                                    GLuint texture, GLint level, GLenum face ) ;

CONSTANT: GL_GEOMETRY_SHADER_EXT HEX: 8DD9
CONSTANT: GL_GEOMETRY_VERTICES_OUT_EXT HEX: 8DDA
CONSTANT: GL_GEOMETRY_INPUT_TYPE_EXT HEX: 8DDB
CONSTANT: GL_GEOMETRY_OUTPUT_TYPE_EXT HEX: 8DDC
CONSTANT: GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS_EXT HEX: 8C29
CONSTANT: GL_MAX_GEOMETRY_VARYING_COMPONENTS_EXT HEX: 8DDD
CONSTANT: GL_MAX_VERTEX_VARYING_COMPONENTS_EXT HEX: 8DDE
CONSTANT: GL_MAX_VARYING_COMPONENTS_EXT HEX: 8B4B
CONSTANT: GL_MAX_GEOMETRY_UNIFORM_COMPONENTS_EXT HEX: 8DDF
CONSTANT: GL_MAX_GEOMETRY_OUTPUT_VERTICES_EXT HEX: 8DE0
CONSTANT: GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS_EXT HEX: 8DE1
CONSTANT: GL_LINES_ADJACENCY_EXT HEX: A
CONSTANT: GL_LINE_STRIP_ADJACENCY_EXT HEX: B
CONSTANT: GL_TRIANGLES_ADJACENCY_EXT HEX: C
CONSTANT: GL_TRIANGLE_STRIP_ADJACENCY_EXT HEX: D
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS_EXT HEX: 8DA8
CONSTANT: GL_FRAMEBUFFER_INCOMPLETE_LAYER_COUNT_EXT HEX: 8DA9
CONSTANT: GL_FRAMEBUFFER_ATTACHMENT_LAYERED_EXT HEX: 8DA7
ALIAS: GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER_EXT GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_3D_ZOFFSET_EXT
CONSTANT: GL_PROGRAM_POINT_SIZE_EXT HEX: 8642


! GL_EXT_texture_integer


GL-FUNCTION: void glClearColorIiEXT { } ( GLint r, GLint g, GLint b, GLint a ) ;
GL-FUNCTION: void glClearColorIuiEXT { } ( GLuint r, GLuint g, GLuint b, GLuint a ) ;
GL-FUNCTION: void glTexParameterIivEXT { } ( GLenum target, GLenum pname, GLint* params ) ;
GL-FUNCTION: void glTexParameterIuivEXT { } ( GLenum target, GLenum pname, GLuint* params ) ;
GL-FUNCTION: void glGetTexParameterIivEXT { } ( GLenum target, GLenum pname, GLint* params ) ;
GL-FUNCTION: void glGetTexParameterIuivEXT { } ( GLenum target, GLenum pname, GLuint* params ) ;

CONSTANT: GL_RGBA_INTEGER_MODE_EXT HEX: 8D9E

CONSTANT: GL_RGBA32UI_EXT HEX: 8D70
CONSTANT: GL_RGB32UI_EXT HEX: 8D71
CONSTANT: GL_ALPHA32UI_EXT HEX: 8D72
CONSTANT: GL_INTENSITY32UI_EXT HEX: 8D73
CONSTANT: GL_LUMINANCE32UI_EXT HEX: 8D74
CONSTANT: GL_LUMINANCE_ALPHA32UI_EXT HEX: 8D75

CONSTANT: GL_RGBA16UI_EXT HEX: 8D76
CONSTANT: GL_RGB16UI_EXT HEX: 8D77
CONSTANT: GL_ALPHA16UI_EXT HEX: 8D78
CONSTANT: GL_INTENSITY16UI_EXT HEX: 8D79
CONSTANT: GL_LUMINANCE16UI_EXT HEX: 8D7A
CONSTANT: GL_LUMINANCE_ALPHA16UI_EXT HEX: 8D7B

CONSTANT: GL_RGBA8UI_EXT HEX: 8D7C
CONSTANT: GL_RGB8UI_EXT HEX: 8D7D
CONSTANT: GL_ALPHA8UI_EXT HEX: 8D7E
CONSTANT: GL_INTENSITY8UI_EXT HEX: 8D7F
CONSTANT: GL_LUMINANCE8UI_EXT HEX: 8D80
CONSTANT: GL_LUMINANCE_ALPHA8UI_EXT HEX: 8D81

CONSTANT: GL_RGBA32I_EXT HEX: 8D82
CONSTANT: GL_RGB32I_EXT HEX: 8D83
CONSTANT: GL_ALPHA32I_EXT HEX: 8D84
CONSTANT: GL_INTENSITY32I_EXT HEX: 8D85
CONSTANT: GL_LUMINANCE32I_EXT HEX: 8D86
CONSTANT: GL_LUMINANCE_ALPHA32I_EXT HEX: 8D87

CONSTANT: GL_RGBA16I_EXT HEX: 8D88
CONSTANT: GL_RGB16I_EXT HEX: 8D89
CONSTANT: GL_ALPHA16I_EXT HEX: 8D8A
CONSTANT: GL_INTENSITY16I_EXT HEX: 8D8B
CONSTANT: GL_LUMINANCE16I_EXT HEX: 8D8C
CONSTANT: GL_LUMINANCE_ALPHA16I_EXT HEX: 8D8D

CONSTANT: GL_RGBA8I_EXT HEX: 8D8E
CONSTANT: GL_RGB8I_EXT HEX: 8D8F
CONSTANT: GL_ALPHA8I_EXT HEX: 8D90
CONSTANT: GL_INTENSITY8I_EXT HEX: 8D91
CONSTANT: GL_LUMINANCE8I_EXT HEX: 8D92
CONSTANT: GL_LUMINANCE_ALPHA8I_EXT HEX: 8D93

CONSTANT: GL_RED_INTEGER_EXT HEX: 8D94
CONSTANT: GL_GREEN_INTEGER_EXT HEX: 8D95
CONSTANT: GL_BLUE_INTEGER_EXT HEX: 8D96
CONSTANT: GL_ALPHA_INTEGER_EXT HEX: 8D97
CONSTANT: GL_RGB_INTEGER_EXT HEX: 8D98
CONSTANT: GL_RGBA_INTEGER_EXT HEX: 8D99
CONSTANT: GL_BGR_INTEGER_EXT HEX: 8D9A
CONSTANT: GL_BGRA_INTEGER_EXT HEX: 8D9B
CONSTANT: GL_LUMINANCE_INTEGER_EXT HEX: 8D9C
CONSTANT: GL_LUMINANCE_ALPHA_INTEGER_EXT HEX: 8D9D


! GL_EXT_transform_feedback


GL-FUNCTION: void glBindBufferRangeEXT { } ( GLenum target, GLuint index, GLuint buffer,
                           GLintptr offset, GLsizeiptr size ) ;
GL-FUNCTION: void glBindBufferOffsetEXT { } ( GLenum target, GLuint index, GLuint buffer,
                            GLintptr offset ) ;
GL-FUNCTION: void glBindBufferBaseEXT { } ( GLenum target, GLuint index, GLuint buffer ) ;

GL-FUNCTION: void glBeginTransformFeedbackEXT { } ( GLenum primitiveMode ) ;
GL-FUNCTION: void glEndTransformFeedbackEXT { } ( ) ;

GL-FUNCTION: void glTransformFeedbackVaryingsEXT { } ( GLuint program, GLsizei count,
                                      GLchar** varyings, GLenum bufferMode ) ;
GL-FUNCTION: void glGetTransformFeedbackVaryingEXT { } ( GLuint program, GLuint index,
                                        GLsizei bufSize, GLsizei* length, 
                                        GLsizei* size, GLenum* type, GLchar* name ) ;

GL-FUNCTION: void glGetIntegerIndexedvEXT { } ( GLenum param, GLuint index, GLint* values ) ;
GL-FUNCTION: void glGetBooleanIndexedvEXT { } ( GLenum param, GLuint index, GLboolean* values ) ;

CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_EXT HEX: 8C8E
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_START_EXT HEX: 8C84
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_SIZE_EXT HEX: 8C85
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_BINDING_EXT HEX: 8C8F
CONSTANT: GL_INTERLEAVED_ATTRIBS_EXT HEX: 8C8C
CONSTANT: GL_SEPARATE_ATTRIBS_EXT HEX: 8C8D
CONSTANT: GL_PRIMITIVES_GENERATED_EXT HEX: 8C87
CONSTANT: GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN_EXT HEX: 8C88
CONSTANT: GL_RASTERIZER_DISCARD_EXT HEX: 8C89
CONSTANT: GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS_EXT HEX: 8C8A
CONSTANT: GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS_EXT HEX: 8C8B
CONSTANT: GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS_EXT HEX: 8C80
CONSTANT: GL_TRANSFORM_FEEDBACK_VARYINGS_EXT HEX: 8C83
CONSTANT: GL_TRANSFORM_FEEDBACK_BUFFER_MODE_EXT HEX: 8C7F
CONSTANT: GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH_EXT HEX: 8C76

