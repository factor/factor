! Copyright (C) 2023 CapitalEx.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators kernel multiline raylib system ;
IN: rlgl

<<
"raylib" {
    { [ os windows? ] [ "raylib.dll" ] }
    { [ os macosx? ] [ "libraylib.dylib" ] }
    { [ os unix? ] [ "libraylib.so" ] }
} cond cdecl add-library

"raylib" deploy-library
>>

CONSTANT: RLGL_VERSION "4.5"

CONSTANT: RL_TEXTURE_WRAP_S                       0x2802      ! GL_TEXTURE_WRAP_S
CONSTANT: RL_TEXTURE_WRAP_T                       0x2803      ! GL_TEXTURE_WRAP_T
CONSTANT: RL_TEXTURE_MAG_FILTER                   0x2800      ! GL_TEXTURE_MAG_FILTER
CONSTANT: RL_TEXTURE_MIN_FILTER                   0x2801      ! GL_TEXTURE_MIN_FILTER

CONSTANT: RL_TEXTURE_FILTER_NEAREST               0x2600      ! GL_NEAREST
CONSTANT: RL_TEXTURE_FILTER_LINEAR                0x2601      ! GL_LINEAR
CONSTANT: RL_TEXTURE_FILTER_MIP_NEAREST           0x2700      ! GL_NEAREST_MIPMAP_NEAREST
CONSTANT: RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR    0x2702      ! GL_NEAREST_MIPMAP_LINEAR
CONSTANT: RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST    0x2701      ! GL_LINEAR_MIPMAP_NEAREST
CONSTANT: RL_TEXTURE_FILTER_MIP_LINEAR            0x2703      ! GL_LINEAR_MIPMAP_LINEAR
CONSTANT: RL_TEXTURE_FILTER_ANISOTROPIC           0x3000      ! Anisotropic filter (custom identifier)
CONSTANT: RL_TEXTURE_MIPMAP_BIAS_RATIO            0x4000      ! Texture mipmap bias, percentage ratio (custom identifier)

CONSTANT: RL_TEXTURE_WRAP_REPEAT                  0x2901      ! GL_REPEAT
CONSTANT: RL_TEXTURE_WRAP_CLAMP                   0x812F      ! GL_CLAMP_TO_EDGE
CONSTANT: RL_TEXTURE_WRAP_MIRROR_REPEAT           0x8370      ! GL_MIRRORED_REPEAT
CONSTANT: RL_TEXTURE_WRAP_MIRROR_CLAMP            0x8742      ! GL_MIRROR_CLAMP_EXT

! Matrix modes (equivalent to OpenGL)
CONSTANT: RL_MODELVIEW                            0x1700      ! GL_MODELVIEW
CONSTANT: RL_PROJECTION                           0x1701      ! GL_PROJECTION
CONSTANT: RL_TEXTURE                              0x1702      ! GL_TEXTURE

! Primitive assembly draw modes
CONSTANT: RL_LINES                                0x0001      ! GL_LINES
CONSTANT: RL_TRIANGLES                            0x0004      ! GL_TRIANGLES
CONSTANT: RL_QUADS                                0x0007      ! GL_QUADS

! GL equivalent data types
CONSTANT: RL_UNSIGNED_BYTE                        0x1401      ! GL_UNSIGNED_BYTE
CONSTANT: RL_FLOAT                                0x1406      ! GL_FLOAT

! GL buffer usage hint
CONSTANT: RL_STREAM_DRAW                          0x88E0      ! GL_STREAM_DRAW
CONSTANT: RL_STREAM_READ                          0x88E1      ! GL_STREAM_READ
CONSTANT: RL_STREAM_COPY                          0x88E2      ! GL_STREAM_COPY
CONSTANT: RL_STATIC_DRAW                          0x88E4      ! GL_STATIC_DRAW
CONSTANT: RL_STATIC_READ                          0x88E5      ! GL_STATIC_READ
CONSTANT: RL_STATIC_COPY                          0x88E6      ! GL_STATIC_COPY
CONSTANT: RL_DYNAMIC_DRAW                         0x88E8      ! GL_DYNAMIC_DRAW
CONSTANT: RL_DYNAMIC_READ                         0x88E9      ! GL_DYNAMIC_READ
CONSTANT: RL_DYNAMIC_COPY                         0x88EA      ! GL_DYNAMIC_COPY

! GL Shader type
CONSTANT: RL_FRAGMENT_SHADER                      0x8B30      ! GL_FRAGMENT_SHADER
CONSTANT: RL_VERTEX_SHADER                        0x8B31      ! GL_VERTEX_SHADER
CONSTANT: RL_COMPUTE_SHADER                       0x91B9      ! GL_COMPUTE_SHADER

! GL blending factors
CONSTANT: RL_ZERO                                 0           ! GL_ZERO
CONSTANT: RL_ONE                                  1           ! GL_ONE
CONSTANT: RL_SRC_COLOR                            0x0300      ! GL_SRC_COLOR
CONSTANT: RL_ONE_MINUS_SRC_COLOR                  0x0301      ! GL_ONE_MINUS_SRC_COLOR
CONSTANT: RL_SRC_ALPHA                            0x0302      ! GL_SRC_ALPHA
CONSTANT: RL_ONE_MINUS_SRC_ALPHA                  0x0303      ! GL_ONE_MINUS_SRC_ALPHA
CONSTANT: RL_DST_ALPHA                            0x0304      ! GL_DST_ALPHA
CONSTANT: RL_ONE_MINUS_DST_ALPHA                  0x0305      ! GL_ONE_MINUS_DST_ALPHA
CONSTANT: RL_DST_COLOR                            0x0306      ! GL_DST_COLOR
CONSTANT: RL_ONE_MINUS_DST_COLOR                  0x0307      ! GL_ONE_MINUS_DST_COLOR
CONSTANT: RL_SRC_ALPHA_SATURATE                   0x0308      ! GL_SRC_ALPHA_SATURATE
CONSTANT: RL_CONSTANT_COLOR                       0x8001      ! GL_CONSTANT_COLOR
CONSTANT: RL_ONE_MINUS_CONSTANT_COLOR             0x8002      ! GL_ONE_MINUS_CONSTANT_COLOR
CONSTANT: RL_CONSTANT_ALPHA                       0x8003      ! GL_CONSTANT_ALPHA
CONSTANT: RL_ONE_MINUS_CONSTANT_ALPHA             0x8004      ! GL_ONE_MINUS_CONSTANT_ALPHA

! GL blending functions/equations
CONSTANT: RL_FUNC_ADD                             0x8006      ! GL_FUNC_ADD
CONSTANT: RL_MIN                                  0x8007      ! GL_MIN
CONSTANT: RL_MAX                                  0x8008      ! GL_MAX
CONSTANT: RL_FUNC_SUBTRACT                        0x800A      ! GL_FUNC_SUBTRACT
CONSTANT: RL_FUNC_REVERSE_SUBTRACT                0x800B      ! GL_FUNC_REVERSE_SUBTRACT
CONSTANT: RL_BLEND_EQUATION                       0x8009      ! GL_BLEND_EQUATION
CONSTANT: RL_BLEND_EQUATION_RGB                   0x8009      ! GL_BLEND_EQUATION_RGB   ! (Same as BLEND_EQUATION)
CONSTANT: RL_BLEND_EQUATION_ALPHA                 0x883D      ! GL_BLEND_EQUATION_ALPHA
CONSTANT: RL_BLEND_DST_RGB                        0x80C8      ! GL_BLEND_DST_RGB
CONSTANT: RL_BLEND_SRC_RGB                        0x80C9      ! GL_BLEND_SRC_RGB
CONSTANT: RL_BLEND_DST_ALPHA                      0x80CA      ! GL_BLEND_DST_ALPHA
CONSTANT: RL_BLEND_SRC_ALPHA                      0x80CB      ! GL_BLEND_SRC_ALPHA
CONSTANT: RL_BLEND_COLOR                          0x8005      ! GL_BLEND_COLOR


STRUCT: rlVertexBuffer
    { elementCount int     }  ! Number of elements in the buffer ( QUADS )
    { _vertices    float*  }  ! Vertex position ( XYZ - 3 components per vertex ) ( shader-location = 0 )
    { _texcoords   float*  }  ! Vertex texture coordinates ( UV - 2 components per vertex ) ( shader-location = 1 )
    { _colors      uchar*  }  ! Vertex colors ( RGBA - 4 components per vertex ) ( shader-location = 3 )
    { _indices     uint*   }  ! Vertex indices ( in case vertex data comes indexed ) ( 6 indices per quad )
    { vaoId        uint    }  ! OpenGL Vertex Array Object id
    { vboId        uint[4] }  ! OpenGL Vertex Buffer Objects id ( 4 types of vertex data )
;

ARRAY-SLOTS: rlVertexBuffer float _vertices  [ elementCount>> 3 * ] vertices 
ARRAY-SLOTS: rlVertexBuffer float _texcoords [ elementCount>> 2 * ] texcoords
ARRAY-SLOTS: rlVertexBuffer uchar _colors    [ elementCount>> 4 * ] colors
ARRAY-SLOTS: rlVertexBuffer uint  _indices   [ elementCount>> 6 * ] indices

! Draw call type
! NOTE: Only texture changes register a new draw, other state-change-related elements are not
! used at this moment ( vaoId, shaderId, matrices ), raylib just forces a batch draw call if any
! of those state-change happens ( this is done in core module )
STRUCT: rlDrawCall
    { mode             int  } ! Drawing mode: LINES, TRIANGLES, QUADS
    { vertexCount      int  } ! Number of vertex of the draw
    { vertexAlignment  int  } ! Number of vertex required for index alignment ( LINES, TRIANGLES )
    { textureId        uint } ! Texture id to be used on the draw -> Use to create new draw call if changes
; 

! rlRenderBatch type
STRUCT: rlRenderBatch
    { bufferCount    int              } ! Number of vertex buffers ( multi-buffering support )
    { currentBuffer  int              } ! Current buffer tracking in case of multi-buffering
    { _vertexBuffer   rlVertexBuffer* } ! Dynamic buffer ( s ) for vertex data
    { _draws          rlDrawCall*     } ! Draw calls array, depends on textureId
    { drawCounter    int              } ! Draw calls counter
    { currentDepth   float            } ! Current depth value for next draw
;

ARRAY-SLOTS: rlRenderBatch rlVertexBuffer _vertexBuffer [ bufferCount>> ] vertexBuffer
ARRAY-SLOTS: rlRenderBatch rlDrawCall _draws [ drawCounter>> ] draws

! OpenGL version
ENUM: rlGlVersion
    RL_OPENGL_11                ! OpenGL 1.1
    RL_OPENGL_21                ! OpenGL 2.1 ( GLSL 120 )
    RL_OPENGL_33                ! OpenGL 3.3 ( GLSL 330 )
    RL_OPENGL_43                ! OpenGL 4.3 ( using GLSL 330 )
    RL_OPENGL_ES_20             ! OpenGL ES 2.0 ( GLSL 100 )
; 

! Trace log level
! NOTE: Organized by priority level
ENUM: rlTraceLogLevel 
    RL_LOG_ALL                  ! Display all logs
    RL_LOG_TRACE                ! Trace logging, intended for internal use only
    RL_LOG_DEBUG                ! Debug logging, used for internal debugging, it should be disabled on release builds
    RL_LOG_INFO                 ! Info logging, used for program execution info
    RL_LOG_WARNING              ! Warning logging, used on recoverable failures
    RL_LOG_ERROR                ! Error logging, used on unrecoverable failures
    RL_LOG_FATAL                ! Fatal logging, used to abort program: exit ( EXIT_FAILURE )
    RL_LOG_NONE                 ! Disable logging
;

! Texture pixel formats
! NOTE: Support depends on OpenGL version
ENUM: rlPixelFormat
    RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE          ! 8 bit per pixel ( no alpha )
    RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA         ! 8*2 bpp ( 2 channels )
    RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5             ! 16 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8             ! 24 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1           ! 16 bpp ( 1 bit alpha )
    RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4           ! 16 bpp ( 4 bit alpha )
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8           ! 32 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R32                ! 32 bpp ( 1 channel - float )
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32          ! 32*3 bpp ( 3 channels - float )
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32       ! 32*4 bpp ( 4 channels - float )
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGB             ! 4 bpp ( no alpha )
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA            ! 4 bpp ( 1 bit alpha )
    RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA            ! 8 bpp
    RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA            ! 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC1_RGB             ! 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_RGB             ! 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA        ! 8 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGB             ! 4 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA            ! 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA        ! 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA        ! 2 bpp
; 

! Texture parameters: filter mode
! NOTE 1: Filtering considers mipmaps if available in the texture
! NOTE 2: Filter is accordingly set for minification and magnification
ENUM: rlTextureFilter
    RL_TEXTURE_FILTER_POINT            ! No filter, just pixel approximation
    RL_TEXTURE_FILTER_BILINEAR         ! Linear filtering
    RL_TEXTURE_FILTER_TRILINEAR        ! Trilinear filtering ( linear with mipmaps )
    RL_TEXTURE_FILTER_ANISOTROPIC_4X   ! Anisotropic filtering 4x
    RL_TEXTURE_FILTER_ANISOTROPIC_8X   ! Anisotropic filtering 8x
    RL_TEXTURE_FILTER_ANISOTROPIC_16X  ! Anisotropic filtering 16x
; 

! Color blending modes ( pre-defined )
ENUM: rlBlendMode
    RL_BLEND_ALPHA                     ! Blend textures considering alpha ( default )
    RL_BLEND_ADDITIVE                  ! Blend textures adding colors
    RL_BLEND_MULTIPLIED                ! Blend textures multiplying colors
    RL_BLEND_ADD_COLORS                ! Blend textures adding colors ( alternative )
    RL_BLEND_SUBTRACT_COLORS           ! Blend textures subtracting colors ( alternative )
    RL_BLEND_ALPHA_PREMULTIPLY         ! Blend premultiplied textures considering alpha
    RL_BLEND_CUSTOM                    ! Blend textures using custom src/dst factors ( use rlSetBlendFactors ( ) )
    RL_BLEND_CUSTOM_SEPARATE           !  Blend textures using custom src/dst factors ( use rlSetBlendFactorsSeparate ( ) )
;

! Shader location point type
ENUM: rlShaderLocationIndex
    RL_SHADER_LOC_VERTEX_POSITION      ! Shader location: vertex attribute: position
    RL_SHADER_LOC_VERTEX_TEXCOORD01    ! Shader location: vertex attribute: texcoord01
    RL_SHADER_LOC_VERTEX_TEXCOORD02    ! Shader location: vertex attribute: texcoord02
    RL_SHADER_LOC_VERTEX_NORMAL        ! Shader location: vertex attribute: normal
    RL_SHADER_LOC_VERTEX_TANGENT       ! Shader location: vertex attribute: tangent
    RL_SHADER_LOC_VERTEX_COLOR         ! Shader location: vertex attribute: color
    RL_SHADER_LOC_MATRIX_MVP           ! Shader location: matrix uniform: model-view-projection
    RL_SHADER_LOC_MATRIX_VIEW          ! Shader location: matrix uniform: view ( camera transform )
    RL_SHADER_LOC_MATRIX_PROJECTION    ! Shader location: matrix uniform: projection
    RL_SHADER_LOC_MATRIX_MODEL         ! Shader location: matrix uniform: model ( transform )
    RL_SHADER_LOC_MATRIX_NORMAL        ! Shader location: matrix uniform: normal
    RL_SHADER_LOC_VECTOR_VIEW          ! Shader location: vector uniform: view
    RL_SHADER_LOC_COLOR_DIFFUSE        ! Shader location: vector uniform: diffuse color
    RL_SHADER_LOC_COLOR_SPECULAR       ! Shader location: vector uniform: specular color
    RL_SHADER_LOC_COLOR_AMBIENT        ! Shader location: vector uniform: ambient color
    RL_SHADER_LOC_MAP_ALBEDO           ! Shader location: sampler2d texture: albedo ( same as: RL_SHADER_LOC_MAP_DIFFUSE )
    RL_SHADER_LOC_MAP_METALNESS        ! Shader location: sampler2d texture: metalness ( same as: RL_SHADER_LOC_MAP_SPECULAR )
    RL_SHADER_LOC_MAP_NORMAL           ! Shader location: sampler2d texture: normal
    RL_SHADER_LOC_MAP_ROUGHNESS        ! Shader location: sampler2d texture: roughness
    RL_SHADER_LOC_MAP_OCCLUSION        ! Shader location: sampler2d texture: occlusion
    RL_SHADER_LOC_MAP_EMISSION         ! Shader location: sampler2d texture: emission
    RL_SHADER_LOC_MAP_HEIGHT           ! Shader location: sampler2d texture: height
    RL_SHADER_LOC_MAP_CUBEMAP          ! Shader location: samplerCube texture: cubemap
    RL_SHADER_LOC_MAP_IRRADIANCE       ! Shader location: samplerCube texture: irradiance
    RL_SHADER_LOC_MAP_PREFILTER        ! Shader location: samplerCube texture: prefilter
    RL_SHADER_LOC_MAP_BRDF             ! Shader location: sampler2d texture: brdf
;

CONSTANT: RL_SHADER_LOC_MAP_DIFFUSE   RL_SHADER_LOC_MAP_ALBEDO
CONSTANT: RL_SHADER_LOC_MAP_SPECULAR  RL_SHADER_LOC_MAP_METALNESS

! Shader uniform data type
ENUM: rlShaderUniformDataType
    RL_SHADER_UNIFORM_FLOAT            ! Shader uniform type: float
    RL_SHADER_UNIFORM_VEC2             ! Shader uniform type: vec2 ( 2 float )
    RL_SHADER_UNIFORM_VEC3             ! Shader uniform type: vec3 ( 3 float )
    RL_SHADER_UNIFORM_VEC4             ! Shader uniform type: vec4 ( 4 float )
    RL_SHADER_UNIFORM_INT              ! Shader uniform type: int
    RL_SHADER_UNIFORM_IVEC2            ! Shader uniform type: ivec2 ( 2 int )
    RL_SHADER_UNIFORM_IVEC3            ! Shader uniform type: ivec3 ( 3 int )
    RL_SHADER_UNIFORM_IVEC4            ! Shader uniform type: ivec4 ( 4 int )
    RL_SHADER_UNIFORM_SAMPLER2D        ! Shader uniform type: sampler2d
;

! Shader attribute data types
ENUM: rlShaderAttributeDataType
    RL_SHADER_ATTRIB_FLOAT              ! Shader attribute type: float
    RL_SHADER_ATTRIB_VEC2               ! Shader attribute type: vec2 ( 2 float )
    RL_SHADER_ATTRIB_VEC3               ! Shader attribute type: vec3 ( 3 float )
    RL_SHADER_ATTRIB_VEC4               ! Shader attribute type: vec4 ( 4 float )
;

! Framebuffer attachment type
! NOTE: By default up to 8 color channels defined, but it can be more
ENUM: rlFramebufferAttachType
    RL_ATTACHMENT_COLOR_CHANNEL0  ! Framebuffer attachment type: color 0
    RL_ATTACHMENT_COLOR_CHANNEL1  ! Framebuffer attachment type: color 1
    RL_ATTACHMENT_COLOR_CHANNEL2  ! Framebuffer attachment type: color 2
    RL_ATTACHMENT_COLOR_CHANNEL3  ! Framebuffer attachment type: color 3
    RL_ATTACHMENT_COLOR_CHANNEL4  ! Framebuffer attachment type: color 4
    RL_ATTACHMENT_COLOR_CHANNEL5  ! Framebuffer attachment type: color 5
    RL_ATTACHMENT_COLOR_CHANNEL6  ! Framebuffer attachment type: color 6
    RL_ATTACHMENT_COLOR_CHANNEL7  ! Framebuffer attachment type: color 7
    { RL_ATTACHMENT_DEPTH   100 } ! Framebuffer attachment type: depth
    { RL_ATTACHMENT_STENCIL 200 } ! Framebuffer attachment type: stencil
; 

! Framebuffer texture attachment type
ENUM: rlFramebufferAttachTextureType
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X   ! Framebuffer texture attachment type: cubemap, +X side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X   ! Framebuffer texture attachment type: cubemap, -X side
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y   ! Framebuffer texture attachment type: cubemap, +Y side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y   ! Framebuffer texture attachment type: cubemap, -Y side
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z   ! Framebuffer texture attachment type: cubemap, +Z side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z   ! Framebuffer texture attachment type: cubemap, -Z side
    { RL_ATTACHMENT_TEXTURE2D    100 } ! Framebuffer texture attachment type: texture2d
    { RL_ATTACHMENT_RENDERBUFFER 200 } ! Framebuffer texture attachment type: renderbuffer
; 

! Face culling mode
ENUM: rlCullMode
    RL_CULL_FACE_FRONT
    RL_CULL_FACE_BACK
; 

FUNCTION-ALIAS: rl-matrix-mode   void rlMatrixMode ( int mode )                              ! Choose the current matrix to be transformed
FUNCTION-ALIAS: rl-push-matrix   void rlPushMatrix ( )                                       ! Push the current matrix to stack
FUNCTION-ALIAS: rl-pop-matrix    void rlPopMatrix ( )                                        ! Pop latest inserted matrix from stack
FUNCTION-ALIAS: rl-load-identity void rlLoadIdentity ( )                                     ! Reset current matrix to identity matrix
FUNCTION-ALIAS: rl-translatef    void rlTranslatef ( float x, float y, float z )             ! Multiply the current matrix by a translation matrix
FUNCTION-ALIAS: rl-rotatef       void rlRotatef ( float angle, float x, float y, float z )   ! Multiply the current matrix by a rotation matrix
FUNCTION-ALIAS: rl-scalef        void rlScalef ( float x, float y, float z )                 ! Multiply the current matrix by a scaling matrix
FUNCTION-ALIAS: rl-mult-matrixf  void rlMultMatrixf ( float* matf )                          ! Multiply the current matrix by another matrix
FUNCTION-ALIAS: rl-frustum       void rlFrustum ( double left, double right, double bottom, double top, double znear, double zfar ) 
FUNCTION-ALIAS: rl-ortho         void rlOrtho ( double left, double right, double bottom, double top, double znear, double zfar ) 
FUNCTION-ALIAS: rl-viewport      void rlViewport ( int x, int y, int width, int height )     ! Set the viewport area

! ------------------------------------------------------------------------------------
! Functions Declaration - Vertex level operations
! ------------------------------------------------------------------------------------
FUNCTION-ALIAS: rl-begin        void rlBegin ( int mode )                                ! Initialize drawing mode ( how to organize vertex )
FUNCTION-ALIAS: rl-end          void rlEnd ( )                                           ! Finish vertex providing
FUNCTION-ALIAS: rl-vertex2i     void rlVertex2i ( int x, int y )                         ! Define one vertex ( position ) - 2 int
FUNCTION-ALIAS: rl-vertex2f     void rlVertex2f ( float x, float y )                     ! Define one vertex ( position ) - 2 float
FUNCTION-ALIAS: rl-vertex3f     void rlVertex3f ( float x, float y, float z )            ! Define one vertex ( position ) - 3 float
FUNCTION-ALIAS: rl-text-coord2f void rlTexCoord2f ( float x, float y )                   ! Define one vertex ( texture coordinate ) - 2 float
FUNCTION-ALIAS: rl-normal3f     void rlNormal3f ( float x, float y, float z )            ! Define one vertex ( normal ) - 3 float
FUNCTION-ALIAS: rl-color4ub     void rlColor4ub ( uchar r, uchar g, uchar b, uchar a )   ! Define one vertex ( color ) - 4 byte
FUNCTION-ALIAS: rl-color3f      void rlColor3f ( float x, float y, float z )             ! Define one vertex ( color ) - 3 float
FUNCTION-ALIAS: rl-color4f      void rlColor4f ( float x, float y, float z, float w )    ! Define one vertex ( color ) - 4 float

! ------------------------------------------------------------------------------------
! Functions Declaration - OpenGL style functions ( common to 1.1, 3.3+, ES2 )
! NOTE: This functions are used to completely abstract raylib code from OpenGL layer,
! some of them are direct wrappers over OpenGL calls, some others are custom
! ------------------------------------------------------------------------------------

! Vertex buffers state
FUNCTION-ALIAS: rl-enable-vertex-array           bool rlEnableVertexArray ( uint vaoId )         ! Enable vertex array ( VAO, if supported )
FUNCTION-ALIAS: rl-disable-vertex-array          void rlDisableVertexArray ( )                   ! Disable vertex array ( VAO, if supported )
FUNCTION-ALIAS: rl-enable-vertex-buffer          void rlEnableVertexBuffer ( uint id )           ! Enable vertex buffer ( VBO )
FUNCTION-ALIAS: rl-disable-vertex-buffer         void rlDisableVertexBuffer ( )                  ! Disable vertex buffer ( VBO )
FUNCTION-ALIAS: rl-enable-vertex-buffer-element  void rlEnableVertexBufferElement ( uint id )    ! Enable vertex buffer element ( VBO element )
FUNCTION-ALIAS: rl-disable-vertex-buffer-element void rlDisableVertexBufferElement ( )           ! Disable vertex buffer element ( VBO element )
FUNCTION-ALIAS: rl-enable-vertex-attribute       void rlEnableVertexAttribute ( uint index )     ! Enable vertex attribute index
FUNCTION-ALIAS: rl-disable-vertex-attribute      void rlDisableVertexAttribute ( uint index )    ! Disable vertex attribute index
! #if defined ( GRAPHICS_API_OPENGL_11 )
! FUNCTION-ALIAS: void rlEnableStatePointer ( int vertexAttribType, void* buffer )     ! Enable attribute state pointer
! FUNCTION-ALIAS: void rlDisableStatePointer ( int vertexAttribType )                  ! Disable attribute state pointer
! #endif

! Textures state
FUNCTION-ALIAS: rl-active-texture-slot     void rlActiveTextureSlot ( int slot )                       ! Select and active a texture slot
FUNCTION-ALIAS: rl-enable-texture          void rlEnableTexture ( uint id )                            ! Enable texture
FUNCTION-ALIAS: rl-disable-texture         void rlDisableTexture ( )                                   ! Disable texture
FUNCTION-ALIAS: rl-enable-texture-cubemap  void rlEnableTextureCubemap ( uint id )                     ! Enable texture cubemap
FUNCTION-ALIAS: rl-disable-texture-cubemap void rlDisableTextureCubemap ( )                            ! Disable texture cubemap
FUNCTION-ALIAS: rl-texture-parameters      void rlTextureParameters ( uint id, int param, int value )  ! Set texture parameters ( filter, wrap )
FUNCTION-ALIAS: rl-cubemap-parameters      void rlCubemapParameters ( uint id, int param, int value )  ! Set cubemap parameters ( filter, wrap )

! Shader state
FUNCTION-ALIAS: rl-enable-shader  void rlEnableShader ( uint id )  ! Enable shader program
FUNCTION-ALIAS: rl-disable-shader void rlDisableShader ( )         ! Disable shader program

! Framebuffer state
FUNCTION-ALIAS: rl-enable-framebuffer    void rlEnableFramebuffer ( uint id )    ! Enable render texture ( fbo )
FUNCTION-ALIAS: rl-disable-framebuffer   void rlDisableFramebuffer ( )           ! Disable render texture ( fbo ), return to default framebuffer
FUNCTION-ALIAS: rl-activate-draw-buffers void rlActiveDrawBuffers ( int count )  ! Activate multiple draw color buffers

! General render state
FUNCTION-ALIAS: rl-enable-color-blend          void  rlEnableColorBlend ( )                             ! Enable color blending
FUNCTION-ALIAS: rl-disable-color-blend         void  rlDisableColorBlend ( )                            ! Disable color blending
FUNCTION-ALIAS: rl-enble-depth-test            void  rlEnableDepthTest ( )                              ! Enable depth test
FUNCTION-ALIAS: rl-disable-depth-test          void  rlDisableDepthTest ( )                             ! Disable depth test
FUNCTION-ALIAS: rl-enable-depth-mask           void  rlEnableDepthMask ( )                              ! Enable depth write
FUNCTION-ALIAS: rl-disable-depth-mask          void  rlDisableDepthMask ( )                             ! Disable depth write
FUNCTION-ALIAS: rl-enable-backface-culling     void  rlEnableBackfaceCulling ( )                        ! Enable backface culling
FUNCTION-ALIAS: rl-disable-backface-culling    void  rlDisableBackfaceCulling ( )                       ! Disable backface culling
FUNCTION-ALIAS: rl-set-cull-face               void  rlSetCullFace ( int mode )                         ! Set face culling mode
FUNCTION-ALIAS: rl-enable-scissor-test         void  rlEnableScissorTest ( )                            ! Enable scissor test
FUNCTION-ALIAS: rl-disable-scissor-test        void  rlDisableScissorTest ( )                           ! Disable scissor test
FUNCTION-ALIAS: rl-scissor                     void  rlScissor ( int x, int y, int width, int height )  ! Scissor test
FUNCTION-ALIAS: rl-enable-wire-mode            void  rlEnableWireMode ( )                               ! Enable wire mode
FUNCTION-ALIAS: rl-disable-wire-mode           void  rlDisableWireMode ( )                              ! Disable wire mode
FUNCTION-ALIAS: rl-set-line-width              void  rlSetLineWidth ( float width )                     ! Set the line drawing width
FUNCTION-ALIAS: rl-get-line-width              float rlGetLineWidth ( )                                 ! Get the line drawing width
FUNCTION-ALIAS: rl-enable-smooth-lines         void  rlEnableSmoothLines ( )                            ! Enable line aliasing
FUNCTION-ALIAS: rl-disable-smooth-lines        void  rlDisableSmoothLines ( )                           ! Disable line aliasing
FUNCTION-ALIAS: rl-enable-stereo-render        void  rlEnableStereoRender ( )                           ! Enable stereo rendering
FUNCTION-ALIAS: rl-disable-stereo-render       void  rlDisableStereoRender ( )                          ! Disable stereo rendering
FUNCTION-ALIAS: rl-is-stereo-rendering-enabled bool  rlIsStereoRenderEnabled ( )                        ! Check if stereo render is enabled

FUNCTION-ALIAS: rl-clear-color void rlClearColor ( uchar r, uchar g, uchar b, uchar a )                                                                                  ! Clear color buffer with color
FUNCTION-ALIAS: rl-clear-screen-buffers void rlClearScreenBuffers ( )                                                                                                    ! Clear used screen buffers ( color and depth )
FUNCTION-ALIAS: rl-check-errors void rlCheckErrors ( )                                                                                                                   ! Check and log OpenGL error codes
FUNCTION-ALIAS: rl-set-blend-mode void rlSetBlendMode ( int mode )                                                                                                       ! Set blending mode
FUNCTION-ALIAS: rl-set-blend-factors void rlSetBlendFactors ( int glSrcFactor, int glDstFactor, int glEquation )                                                         ! Set blending mode factor and equation ( using OpenGL factors )
FUNCTION-ALIAS: rl-set-blend-factors-seperate void rlSetBlendFactorsSeparate ( int glSrcRGB, int glDstRGB, int glSrcAlpha, int glDstAlpha, int glEqRGB, int glEqAlpha )  ! Set blending mode factors and equations separately ( using OpenGL factors )

! ------------------------------------------------------------------------------------
! Functions Declaration - rlgl functionality
! ------------------------------------------------------------------------------------
! rlgl initialization functions
FUNCTION-ALIAS: rl-gl-init                void rlglInit ( int width, int height )     ! Initialize rlgl ( buffers, shaders, textures, states )
FUNCTION-ALIAS: rl-gl-close               void rlglClose ( )                          ! De-initialize rlgl ( buffers, shaders, textures )
FUNCTION-ALIAS: rl-load-extensions        void rlLoadExtensions ( void* loader )      ! Load OpenGL extensions ( loader function required )
FUNCTION-ALIAS: rl-get-version            int  rlGetVersion ( )                       ! Get current OpenGL version
FUNCTION-ALIAS: rl-set-framebuffer-width  void rlSetFramebufferWidth ( int width )    ! Set current framebuffer width
FUNCTION-ALIAS: rl-get-framebuffer-width  int  rlGetFramebufferWidth ( )              ! Get default framebuffer width
FUNCTION-ALIAS: rl-set-framebuffer-height void rlSetFramebufferHeight ( int height )  ! Set current framebuffer height
FUNCTION-ALIAS: rl-get-framebuffer-height int  rlGetFramebufferHeight ( )             ! Get default framebuffer height

FUNCTION-ALIAS: rl-get-texture-id-default  uint rlGetTextureIdDefault ( )   ! Get default texture id
FUNCTION-ALIAS: rl-get-shader-id-default   uint rlGetShaderIdDefault ( )    ! Get default shader id
FUNCTION-ALIAS: rl-get-shader-locs-default int* rlGetShaderLocsDefault ( )  ! Get default shader locations

! Render batch management
! NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
! but this render batch API is exposed in case of custom batches are required
FUNCTION-ALIAS: rl-load-render-batch        rlRenderBatch rlLoadRenderBatch ( int numBuffers, int bufferElements )   ! Load a render batch system
FUNCTION-ALIAS: rl-unload-render-batch      void          rlUnloadRenderBatch ( rlRenderBatch batch )                ! Unload render batch system
FUNCTION-ALIAS: rl-draw-render-batch        void          rlDrawRenderBatch ( rlRenderBatch* batch )                 ! Draw render batch data ( Update->Draw->Reset )
FUNCTION-ALIAS: rl-set-render-batch-active  void          rlSetRenderBatchActive ( rlRenderBatch* batch )            ! Set the active render batch for rlgl ( NULL for default internal )
FUNCTION-ALIAS: rl-draw-render-batch-active void          rlDrawRenderBatchActive ( )                                ! Update and draw internal render batch
FUNCTION-ALIAS: rl-check-render-batch-limit bool          rlCheckRenderBatchLimit ( int vCount )                     ! Check internal buffer overflow for a given number of vertex

FUNCTION-ALIAS: rl-set-texture void rlSetTexture ( uint id )                ! Set current texture for render batch and check buffers limits

! ------------------------------------------------------------------------------------------------------------------------

! Vertex buffers management
FUNCTION-ALIAS: rl-load-vertex-array                    uint rlLoadVertexArray ( )                                                                 ! Load vertex array ( vao ) if supported
FUNCTION-ALIAS: rl-load-vertex-buffer                   uint rlLoadVertexBuffer ( void* buffer, int size, bool dynamic )                           ! Load a vertex buffer attribute
FUNCTION-ALIAS: rl-load-vertex-buffer-element           uint rlLoadVertexBufferElement ( void* buffer, int size, bool dynamic )                    ! Load a new attributes element buffer
FUNCTION-ALIAS: rl-update-vetex-buffer                  void rlUpdateVertexBuffer ( uint bufferId, void* data, int dataSize, int offset )          ! Update GPU buffer with new data
FUNCTION-ALIAS: rl-update-vetex-buffer-elements         void rlUpdateVertexBufferElements ( uint id, void* data, int dataSize, int offset )        ! Update vertex buffer elements with new data
FUNCTION-ALIAS: rl-unload-vertex-array                  void rlUnloadVertexArray ( uint vaoId ) 
FUNCTION-ALIAS: rl-unload-vertex-buffer                 void rlUnloadVertexBuffer ( uint vboId ) 
FUNCTION-ALIAS: rl-set-vertex-attribute                 void rlSetVertexAttribute ( uint index, int compSize, int type, bool normalized, int stride, void* pointer ) 
FUNCTION-ALIAS: rl-set-vertex-attribute-divisor         void rlSetVertexAttributeDivisor ( uint index, int divisor ) 
FUNCTION-ALIAS: rl-set-vertex-attribute-default         void rlSetVertexAttributeDefault ( int locIndex, void* value, int attribType, int count )  ! Set vertex attribute default value
FUNCTION-ALIAS: rl-draw-vertex-array                    void rlDrawVertexArray ( int offset, int count ) 
FUNCTION-ALIAS: rl-draw-vertex-array-elements           void rlDrawVertexArrayElements ( int offset, int count, void* buffer ) 
FUNCTION-ALIAS: rl-draw-vertex-array-instanced          void rlDrawVertexArrayInstanced ( int offset, int count, int instances ) 
FUNCTION-ALIAS: rl-draw-vertex-array-elements-instanced void rlDrawVertexArrayElementsInstanced ( int offset, int count, void* buffer, int instances ) 

! Textures management
FUNCTION-ALIAS: rl-load-texture           uint rlLoadTexture ( void* data, int width, int height, int format, int mipmapCount )                       ! Load texture in GPU
FUNCTION-ALIAS: rl-load-texture-depth     uint rlLoadTextureDepth ( int width, int height, bool useRenderBuffer )                                     ! Load depth texture/renderbuffer ( to be attached to fbo )
FUNCTION-ALIAS: rl-load-texture-cubemap   uint rlLoadTextureCubemap ( void* data, int size, int format )                                              ! Load texture cubemap
FUNCTION-ALIAS: rl-update-texture         void rlUpdateTexture ( uint id, int offsetX, int offsetY, int width, int height, int format, void* data )   ! Update GPU texture with new data
FUNCTION-ALIAS: rl-get-gl-texture-formats void rlGetGlTextureFormats ( int format, uint* glInternalFormat, uint* glFormat, uint* glType )             ! Get OpenGL internal formats
FUNCTION-ALIAS: rl-get-pixel-format-name  char* rlGetPixelFormatName ( uint format )                                                                  ! Get name string for pixel format
FUNCTION-ALIAS: rl-unload-texture         void rlUnloadTexture ( uint id )                                                                            ! Unload texture from GPU memory
FUNCTION-ALIAS: rl-gen-texture-mipmaps    void rlGenTextureMipmaps ( uint id, int width, int height, int format, int* mipmaps )                       ! Generate mipmap data for selected texture
FUNCTION-ALIAS: rl-read-texture-pixels    void* rlReadTexturePixels ( uint id, int width, int height, int format )                                    ! Read texture pixel data
FUNCTION-ALIAS: rl-read-screen-pixels     uchar* rlReadScreenPixels ( int width, int height )                                                         ! Read screen pixel data ( color buffer )

! Framebuffer management ( fbo )
FUNCTION-ALIAS: rl-load-framebuffer     uint rlLoadFramebuffer ( int width, int height )                                                 ! Load an empty framebuffer
FUNCTION-ALIAS: rl-framebuffer-attach   void rlFramebufferAttach ( uint fboId, uint texId, int attachType, int texType, int mipLevel )   ! Attach texture/renderbuffer to a framebuffer
FUNCTION-ALIAS: rl-framebuffer-complete bool rlFramebufferComplete ( uint id )                                                           ! Verify framebuffer is complete
FUNCTION-ALIAS: rl-unload-framebuffer   void rlUnloadFramebuffer ( uint id )                                                             ! Delete framebuffer from GPU

! Shaders management
FUNCTION-ALIAS: rl-load-shader-code      uint rlLoadShaderCode ( char* vsCode, char* fsCode )                           ! Load shader from code strings
FUNCTION-ALIAS: rl-compile-shader        uint rlCompileShader ( char* shaderCode, int type )                            ! Compile custom shader and return shader id ( type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER )
FUNCTION-ALIAS: rl-load-shader-program   uint rlLoadShaderProgram ( uint vShaderId, uint fShaderId )                    ! Load custom shader program
FUNCTION-ALIAS: rl-unload-shader-program void rlUnloadShaderProgram ( uint id )                                         ! Unload shader program
FUNCTION-ALIAS: rl-get-location-uniform  int  rlGetLocationUniform ( uint shaderId, char* uniformName )                 ! Get shader location uniform
FUNCTION-ALIAS: rl-get-location-attrib   int  rlGetLocationAttrib ( uint shaderId, char* attribName )                   ! Get shader location attribute
FUNCTION-ALIAS: rl-set-uniform           void rlSetUniform ( int locIndex, void* value, int uniformType, int count )    ! Set shader value uniform
FUNCTION-ALIAS: rl-set-uniform-matrix    void rlSetUniformMatrix ( int locIndex, Matrix mat )                           ! Set shader value matrix
FUNCTION-ALIAS: rl-set-uniform-sampler   void rlSetUniformSampler ( int locIndex, uint textureId )                      ! Set shader value sampler
FUNCTION-ALIAS: rl-set-shader            void rlSetShader ( uint id, int* locs )                                        ! Set shader currently active ( id and locations )

! Compute shader management
FUNCTION-ALIAS: rl-load-compute-shader-program uint rlLoadComputeShaderProgram ( uint shaderId )                        ! Load compute shader program
FUNCTION-ALIAS: rl-compute-shader-dispatch     void rlComputeShaderDispatch ( uint groupX, uint groupY, uint groupZ )   ! Dispatch compute shader ( equivalent to* draw* for graphics pipeline )

! Shader buffer storage object management ( ssbo )
FUNCTION-ALIAS: rl-load-shader-buffer     uint rlLoadShaderBuffer ( uint size, void* data, int usageHint )                                  ! Load shader storage buffer object ( SSBO )
FUNCTION-ALIAS: rl-unload-shader-buffer   void rlUnloadShaderBuffer ( uint ssboId )                                                         ! Unload shader storage buffer object ( SSBO )
FUNCTION-ALIAS: rl-update-shader-buffer   void rlUpdateShaderBuffer ( uint id, void* data, uint dataSize, uint offset )                     ! Update SSBO buffer data
FUNCTION-ALIAS: rl-bind-shader-buffer     void rlBindShaderBuffer ( uint id, uint index )                                                   ! Bind SSBO buffer
FUNCTION-ALIAS: rl-read-shader-buffer     void rlReadShaderBuffer ( uint id, void* dest, uint count, uint offset )                          ! Read SSBO buffer data ( GPU->CPU )
FUNCTION-ALIAS: rl-copy-shader-buffer     void rlCopyShaderBuffer ( uint destId, uint srcId, uint destOffset, uint srcOffset, uint count )  ! Copy SSBO data between buffers
FUNCTION-ALIAS: rl-get-shader-buffer-size uint rlGetShaderBufferSize ( uint id )                                                            ! Get SSBO buffer size

! Buffer management
FUNCTION-ALIAS: rl-bind-image-texture void rlBindImageTexture ( uint id, uint index, int format, bool readonly )   ! Bind image texture

! Matrix state management
FUNCTION-ALIAS: rl-get-matrix-modelview          Matrix rlGetMatrixModelview ( )                                   ! Get internal modelview matrix
FUNCTION-ALIAS: rl-get-matrix-projection         Matrix rlGetMatrixProjection ( )                                  ! Get internal projection matrix
FUNCTION-ALIAS: rl-get-matrix-transform          Matrix rlGetMatrixTransform ( )                                   ! Get internal accumulated transform matrix
FUNCTION-ALIAS: rl-get-matrix-projection-stereo  Matrix rlGetMatrixProjectionStereo ( int eye )                    ! Get internal projection matrix for stereo render ( selected eye )
FUNCTION-ALIAS: rl-get-matrix-view-offset-stereo Matrix rlGetMatrixViewOffsetStereo ( int eye )                    ! Get internal view offset matrix for stereo render ( selected eye )
FUNCTION-ALIAS: rl-set-matrix-projection         void   rlSetMatrixProjection ( Matrix proj )                      ! Set a custom projection matrix ( replaces internal projection matrix )
FUNCTION-ALIAS: rl-set-matrix-modelview          void   rlSetMatrixModelview ( Matrix view )                       ! Set a custom modelview matrix ( replaces internal modelview matrix )
FUNCTION-ALIAS: rl-set-matrix-projection-stereo  void   rlSetMatrixProjectionStereo ( Matrix right, Matrix left )  ! Set eyes projection matrices for stereo rendering
FUNCTION-ALIAS: rl-set-matrix-view-offset-stereo void   rlSetMatrixViewOffsetStereo ( Matrix right, Matrix left )  ! Set eyes view offsets matrices for stereo rendering

! Quick and dirty cube/quad buffers load->draw->unload
FUNCTION-ALIAS: rl-load-draw-cube void rlLoadDrawCube ( )      ! Load and draw a cube
FUNCTION-ALIAS: rl-load-draw-quad void rlLoadDrawQuad ( )      ! Load and draw a quad
