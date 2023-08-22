! Copyright (C) 2005 Alex Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax kernel
sequences system combinators opengl.gl alien.destructors ;
IN: opengl.glu

<<

os {
    { [ dup macosx? ] [ drop ] }
    { [ dup windows? ] [ drop ] }
    { [ dup unix? ] [ drop "glu" "libGLU.so.1" cdecl add-library ] }
} cond

>>

LIBRARY: glu

! These are defined as structs in glu.h, but we only ever use pointers to them
C-TYPE: GLUnurbs
C-TYPE: GLUquadric
C-TYPE: GLUtesselator
C-TYPE: GLubyte
TYPEDEF: void* GLUfuncptr

! StringName
CONSTANT: GLU_VERSION                        100800
CONSTANT: GLU_EXTENSIONS                     100801

! ErrorCode
CONSTANT: GLU_INVALID_ENUM                   100900
CONSTANT: GLU_INVALID_VALUE                  100901
CONSTANT: GLU_OUT_OF_MEMORY                  100902
CONSTANT: GLU_INCOMPATIBLE_GL_VERSION        100903
CONSTANT: GLU_INVALID_OPERATION              100904

! NurbsDisplay
CONSTANT: GLU_OUTLINE_POLYGON                100240
CONSTANT: GLU_OUTLINE_PATCH                  100241

! NurbsCallback
CONSTANT: GLU_NURBS_ERROR                    100103
CONSTANT: GLU_ERROR                          100103
CONSTANT: GLU_NURBS_BEGIN                    100164
CONSTANT: GLU_NURBS_BEGIN_EXT                100164
CONSTANT: GLU_NURBS_VERTEX                   100165
CONSTANT: GLU_NURBS_VERTEX_EXT               100165
CONSTANT: GLU_NURBS_NORMAL                   100166
CONSTANT: GLU_NURBS_NORMAL_EXT               100166
CONSTANT: GLU_NURBS_COLOR                    100167
CONSTANT: GLU_NURBS_COLOR_EXT                100167
CONSTANT: GLU_NURBS_TEXTURE_COORD            100168
CONSTANT: GLU_NURBS_TEX_COORD_EXT            100168
CONSTANT: GLU_NURBS_END                      100169
CONSTANT: GLU_NURBS_END_EXT                  100169
CONSTANT: GLU_NURBS_BEGIN_DATA               100170
CONSTANT: GLU_NURBS_BEGIN_DATA_EXT           100170
CONSTANT: GLU_NURBS_VERTEX_DATA              100171
CONSTANT: GLU_NURBS_VERTEX_DATA_EXT          100171
CONSTANT: GLU_NURBS_NORMAL_DATA              100172
CONSTANT: GLU_NURBS_NORMAL_DATA_EXT          100172
CONSTANT: GLU_NURBS_COLOR_DATA               100173
CONSTANT: GLU_NURBS_COLOR_DATA_EXT           100173
CONSTANT: GLU_NURBS_TEXTURE_COORD_DATA       100174
CONSTANT: GLU_NURBS_TEX_COORD_DATA_EXT       100174
CONSTANT: GLU_NURBS_END_DATA                 100175
CONSTANT: GLU_NURBS_END_DATA_EXT             100175

! NurbsError
CONSTANT: GLU_NURBS_ERROR1                   100251
CONSTANT: GLU_NURBS_ERROR2                   100252
CONSTANT: GLU_NURBS_ERROR3                   100253
CONSTANT: GLU_NURBS_ERROR4                   100254
CONSTANT: GLU_NURBS_ERROR5                   100255
CONSTANT: GLU_NURBS_ERROR6                   100256
CONSTANT: GLU_NURBS_ERROR7                   100257
CONSTANT: GLU_NURBS_ERROR8                   100258
CONSTANT: GLU_NURBS_ERROR9                   100259
CONSTANT: GLU_NURBS_ERROR10                  100260
CONSTANT: GLU_NURBS_ERROR11                  100261
CONSTANT: GLU_NURBS_ERROR12                  100262
CONSTANT: GLU_NURBS_ERROR13                  100263
CONSTANT: GLU_NURBS_ERROR14                  100264
CONSTANT: GLU_NURBS_ERROR15                  100265
CONSTANT: GLU_NURBS_ERROR16                  100266
CONSTANT: GLU_NURBS_ERROR17                  100267
CONSTANT: GLU_NURBS_ERROR18                  100268
CONSTANT: GLU_NURBS_ERROR19                  100269
CONSTANT: GLU_NURBS_ERROR20                  100270
CONSTANT: GLU_NURBS_ERROR21                  100271
CONSTANT: GLU_NURBS_ERROR22                  100272
CONSTANT: GLU_NURBS_ERROR23                  100273
CONSTANT: GLU_NURBS_ERROR24                  100274
CONSTANT: GLU_NURBS_ERROR25                  100275
CONSTANT: GLU_NURBS_ERROR26                  100276
CONSTANT: GLU_NURBS_ERROR27                  100277
CONSTANT: GLU_NURBS_ERROR28                  100278
CONSTANT: GLU_NURBS_ERROR29                  100279
CONSTANT: GLU_NURBS_ERROR30                  100280
CONSTANT: GLU_NURBS_ERROR31                  100281
CONSTANT: GLU_NURBS_ERROR32                  100282
CONSTANT: GLU_NURBS_ERROR33                  100283
CONSTANT: GLU_NURBS_ERROR34                  100284
CONSTANT: GLU_NURBS_ERROR35                  100285
CONSTANT: GLU_NURBS_ERROR36                  100286
CONSTANT: GLU_NURBS_ERROR37                  100287

! NurbsProperty
CONSTANT: GLU_AUTO_LOAD_MATRIX               100200
CONSTANT: GLU_CULLING                        100201
CONSTANT: GLU_SAMPLING_TOLERANCE             100203
CONSTANT: GLU_DISPLAY_MODE                   100204
CONSTANT: GLU_PARAMETRIC_TOLERANCE           100202
CONSTANT: GLU_SAMPLING_METHOD                100205
CONSTANT: GLU_U_STEP                         100206
CONSTANT: GLU_V_STEP                         100207
CONSTANT: GLU_NURBS_MODE                     100160
CONSTANT: GLU_NURBS_MODE_EXT                 100160
CONSTANT: GLU_NURBS_TESSELLATOR              100161
CONSTANT: GLU_NURBS_TESSELLATOR_EXT          100161
CONSTANT: GLU_NURBS_RENDERER                 100162
CONSTANT: GLU_NURBS_RENDERER_EXT             100162

! NurbsSampling
CONSTANT: GLU_OBJECT_PARAMETRIC_ERROR        100208
CONSTANT: GLU_OBJECT_PARAMETRIC_ERROR_EXT    100208
CONSTANT: GLU_OBJECT_PATH_LENGTH             100209
CONSTANT: GLU_OBJECT_PATH_LENGTH_EXT         100209
CONSTANT: GLU_PATH_LENGTH                    100215
CONSTANT: GLU_PARAMETRIC_ERROR               100216
CONSTANT: GLU_DOMAIN_DISTANCE                100217

! NurbsTrim
CONSTANT: GLU_MAP1_TRIM_2                    100210
CONSTANT: GLU_MAP1_TRIM_3                    100211

! QuadricDrawStyle
CONSTANT: GLU_POINT                          100010
CONSTANT: GLU_LINE                           100011
CONSTANT: GLU_FILL                           100012
CONSTANT: GLU_SILHOUETTE                     100013

! QuadricNormal
CONSTANT: GLU_SMOOTH                         100000
CONSTANT: GLU_FLAT                           100001
CONSTANT: GLU_NONE                           100002

! QuadricOrientation
CONSTANT: GLU_OUTSIDE                        100020
CONSTANT: GLU_INSIDE                         100021

! TessCallback
CONSTANT: GLU_TESS_BEGIN                     100100
CONSTANT: GLU_BEGIN                          100100
CONSTANT: GLU_TESS_VERTEX                    100101
CONSTANT: GLU_VERTEX                         100101
CONSTANT: GLU_TESS_END                       100102
CONSTANT: GLU_END                            100102
CONSTANT: GLU_TESS_ERROR                     100103
CONSTANT: GLU_TESS_EDGE_FLAG                 100104
CONSTANT: GLU_EDGE_FLAG                      100104
CONSTANT: GLU_TESS_COMBINE                   100105
CONSTANT: GLU_TESS_BEGIN_DATA                100106
CONSTANT: GLU_TESS_VERTEX_DATA               100107
CONSTANT: GLU_TESS_END_DATA                  100108
CONSTANT: GLU_TESS_ERROR_DATA                100109
CONSTANT: GLU_TESS_EDGE_FLAG_DATA            100110
CONSTANT: GLU_TESS_COMBINE_DATA              100111

! TessContour
CONSTANT: GLU_CW                             100120
CONSTANT: GLU_CCW                            100121
CONSTANT: GLU_INTERIOR                       100122
CONSTANT: GLU_EXTERIOR                       100123
CONSTANT: GLU_UNKNOWN                        100124

! TessProperty
CONSTANT: GLU_TESS_WINDING_RULE              100140
CONSTANT: GLU_TESS_BOUNDARY_ONLY             100141
CONSTANT: GLU_TESS_TOLERANCE                 100142

! TessError
CONSTANT: GLU_TESS_ERROR1                    100151
CONSTANT: GLU_TESS_ERROR2                    100152
CONSTANT: GLU_TESS_ERROR3                    100153
CONSTANT: GLU_TESS_ERROR4                    100154
CONSTANT: GLU_TESS_ERROR5                    100155
CONSTANT: GLU_TESS_ERROR6                    100156
CONSTANT: GLU_TESS_ERROR7                    100157
CONSTANT: GLU_TESS_ERROR8                    100158
CONSTANT: GLU_TESS_MISSING_BEGIN_POLYGON     100151
CONSTANT: GLU_TESS_MISSING_BEGIN_CONTOUR     100152
CONSTANT: GLU_TESS_MISSING_END_POLYGON       100153
CONSTANT: GLU_TESS_MISSING_END_CONTOUR       100154
CONSTANT: GLU_TESS_COORD_TOO_LARGE           100155
CONSTANT: GLU_TESS_NEED_COMBINE_CALLBACK     100156

! TessWinding
CONSTANT: GLU_TESS_WINDING_ODD               100130
CONSTANT: GLU_TESS_WINDING_NONZERO           100131
CONSTANT: GLU_TESS_WINDING_POSITIVE          100132
CONSTANT: GLU_TESS_WINDING_NEGATIVE          100133
CONSTANT: GLU_TESS_WINDING_ABS_GEQ_TWO       100134

LIBRARY: glu

FUNCTION: void gluBeginCurve ( GLUnurbs* nurb )
FUNCTION: void gluBeginPolygon ( GLUtesselator* tess )
FUNCTION: void gluBeginSurface ( GLUnurbs* nurb )
FUNCTION: void gluBeginTrim ( GLUnurbs* nurb )

FUNCTION: void gluCylinder ( GLUquadric* quad, GLdouble base, GLdouble top, GLdouble height, GLint slices, GLint stacks )
FUNCTION: void gluDeleteNurbsRenderer ( GLUnurbs* nurb )
FUNCTION: void gluDeleteQuadric ( GLUquadric* quad )
FUNCTION: void gluDeleteTess ( GLUtesselator* tess )
FUNCTION: void gluDisk ( GLUquadric* quad, GLdouble inner, GLdouble outer, GLint slices, GLint loops )
FUNCTION: void gluEndCurve ( GLUnurbs* nurb )
FUNCTION: void gluEndPolygon ( GLUtesselator* tess )
FUNCTION: void gluEndSurface ( GLUnurbs* nurb )
FUNCTION: void gluEndTrim ( GLUnurbs* nurb )
FUNCTION: c-string gluErrorString ( GLenum error )
FUNCTION: void gluGetNurbsProperty ( GLUnurbs* nurb, GLenum property, GLfloat* data )
FUNCTION: c-string gluGetString ( GLenum name )
FUNCTION: void gluGetTessProperty ( GLUtesselator* tess, GLenum which, GLdouble* data )
FUNCTION: void gluLoadSamplingMatrices ( GLUnurbs* nurb, GLfloat* model, GLfloat* perspective, GLint* view )
FUNCTION: void gluLookAt ( GLdouble eyeX, GLdouble eyeY, GLdouble eyeZ, GLdouble centerX, GLdouble centerY, GLdouble centerZ, GLdouble upX, GLdouble upY, GLdouble upZ )
FUNCTION: GLUnurbs* gluNewNurbsRenderer ( )
FUNCTION: GLUquadric* gluNewQuadric ( )
FUNCTION: GLUtesselator* gluNewTess ( )
FUNCTION: void gluNextContour ( GLUtesselator* tess, GLenum type )
FUNCTION: void gluNurbsCallback ( GLUnurbs* nurb, GLenum which, GLUfuncptr CallBackFunc )
! FUNCTION: void gluNurbsCallbackData ( GLUnurbs* nurb, GLvoid* userData ) ;
! FUNCTION: void gluNurbsCallbackDataEXT ( GLUnurbs* nurb, GLvoid* userData ) ;
FUNCTION: void gluNurbsCurve ( GLUnurbs* nurb, GLint knotCount, GLfloat *knots, GLint stride, GLfloat *control, GLint order, GLenum type )
FUNCTION: void gluNurbsProperty ( GLUnurbs* nurb, GLenum property, GLfloat value )
FUNCTION: void gluNurbsSurface ( GLUnurbs* nurb, GLint sKnotCount, GLfloat* sKnots, GLint tKnotCount, GLfloat* tKnots, GLint sStride, GLint tStride, GLfloat* control, GLint sOrder, GLint tOrder, GLenum type )
FUNCTION: void gluOrtho2D ( GLdouble left, GLdouble right, GLdouble bottom, GLdouble top )
FUNCTION: void gluPartialDisk ( GLUquadric* quad, GLdouble inner, GLdouble outer, GLint slices, GLint loops, GLdouble start, GLdouble sweep )
FUNCTION: void gluPerspective ( GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar )
FUNCTION: void gluPickMatrix ( GLdouble x, GLdouble y, GLdouble delX, GLdouble delY, GLint* viewport )
FUNCTION: GLint gluProject ( GLdouble objX, GLdouble objY, GLdouble objZ, GLdouble* model, GLdouble* proj, GLint* view, GLdouble* winX, GLdouble* winY, GLdouble* winZ )
FUNCTION: void gluPwlCurve ( GLUnurbs* nurb, GLint count, GLfloat* data, GLint stride, GLenum type )
FUNCTION: void gluQuadricCallback ( GLUquadric* quad, GLenum which, GLUfuncptr CallBackFunc )
FUNCTION: void gluQuadricDrawStyle ( GLUquadric* quad, GLenum draw )
FUNCTION: void gluQuadricNormals ( GLUquadric* quad, GLenum normal )
FUNCTION: void gluQuadricOrientation ( GLUquadric* quad, GLenum orientation )
FUNCTION: void gluQuadricTexture ( GLUquadric* quad, GLboolean texture )
FUNCTION: GLint gluScaleImage ( GLenum format, GLsizei wIn, GLsizei hIn, GLenum typeIn, void* dataIn, GLsizei wOut, GLsizei hOut, GLenum typeOut, GLvoid* dataOut )
FUNCTION: void gluSphere ( GLUquadric* quad, GLdouble radius, GLint slices, GLint stacks )
FUNCTION: void gluTessBeginContour ( GLUtesselator* tess )
FUNCTION: void gluTessBeginPolygon ( GLUtesselator* tess, GLvoid* data )
FUNCTION: void gluTessCallback ( GLUtesselator* tess, GLenum which, GLUfuncptr CallBackFunc )
FUNCTION: void gluTessEndContour ( GLUtesselator* tess )
FUNCTION: void gluTessEndPolygon ( GLUtesselator* tess )
FUNCTION: void gluTessNormal ( GLUtesselator* tess, GLdouble valueX, GLdouble valueY, GLdouble valueZ )
FUNCTION: void gluTessProperty ( GLUtesselator* tess, GLenum which, GLdouble data )
FUNCTION: void gluTessVertex ( GLUtesselator* tess, GLdouble* location, GLvoid* data )
FUNCTION: GLint gluUnProject ( GLdouble winX, GLdouble winY, GLdouble winZ, GLdouble* model, GLdouble* proj, GLint* view, GLdouble* objX, GLdouble* objY, GLdouble* objZ )

! Not present on Windows
! FUNCTION: GLint gluBuild1DMipmapLevels ( GLenum target, GLint internalFormat, GLsizei width, GLenum format, GLenum type, GLint level, GLint base, GLint max, void* data ) ;
! FUNCTION: GLint gluBuild1DMipmaps ( GLenum target, GLint internalFormat, GLsizei width, GLenum format, GLenum type, void* data ) ;
! FUNCTION: GLint gluBuild2DMipmapLevels ( GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLenum format, GLenum type, GLint level, GLint base, GLint max, void* data ) ;
! FUNCTION: GLint gluBuild2DMipmaps ( GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLenum format, GLenum type, void* data ) ;
! FUNCTION: GLint gluBuild3DMipmapLevels ( GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, GLint level, GLint base, GLint max, void* data ) ;
! FUNCTION: GLint gluBuild3DMipmaps ( GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, void* data ) ;
! FUNCTION: GLboolean gluCheckExtension ( GLubyte* extName, GLubyte* extString ) ;
! FUNCTION: GLint gluUnProject4 ( GLdouble winX, GLdouble winY, GLdouble winZ, GLdouble clipW, GLdouble* model, GLdouble* proj, GLint* view, GLdouble nearVal, GLdouble farVal, GLdouble* objX, GLdouble* objY, GLdouble* objZ, GLdouble* objW ) ;

DESTRUCTOR: gluDeleteNurbsRenderer
DESTRUCTOR: gluDeleteQuadric
DESTRUCTOR: gluDeleteTess

CALLBACK: void GLUtessBeginCallback ( GLenum type )
CALLBACK: void GLUtessBeginDataCallback ( GLenum type, void* data )
CALLBACK: void GLUtessEdgeFlagCallback ( GLboolean flag )
CALLBACK: void GLUtessEdgeFlagDataCallback ( GLboolean flag, void* data )
CALLBACK: void GLUtessVertexCallback ( void* vertex_data )
CALLBACK: void GLUtessVertexDataCallback ( void* vertex_data, void* data )
CALLBACK: void GLUtessEndCallback ( )
CALLBACK: void GLUtessEndDataCallback ( void* data )
CALLBACK: void GLUtessCombineDataCallback ( GLdouble* coords, void** vertex_data, GLfloat* weight, void** out_data, void* data )
CALLBACK: void GLUtessErrorCallback ( GLenum errno )
CALLBACK: void GLUtessErrorDataCallback ( GLenum errno, void* data )

: gl-look-at ( eye focus up -- )
    [ first3 ] tri@ gluLookAt ;
