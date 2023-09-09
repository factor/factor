! Copyright (C) 2023 CapitalEx.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: rlgl

HELP: <rlBlendMode>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlCullMode>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlFramebufferAttachTextureType>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlFramebufferAttachType>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlGlVersion>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlPixelFormat>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlShaderAttributeDataType>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlShaderLocationIndex>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlShaderUniformDataType>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlTextureFilter>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <rlTraceLogLevel>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: RLGL_VERSION
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ATTACHMENT_COLOR_CHANNEL0
{ $class-description "" } ;

HELP: RL_ATTACHMENT_COLOR_CHANNEL1
{ $class-description "" } ;

HELP: RL_ATTACHMENT_COLOR_CHANNEL2
{ $class-description "" } ;

HELP: RL_ATTACHMENT_COLOR_CHANNEL3
{ $class-description "" } ;

HELP: RL_ATTACHMENT_COLOR_CHANNEL4
{ $class-description "" } ;

HELP: RL_ATTACHMENT_COLOR_CHANNEL5
{ $class-description "" } ;

HELP: RL_ATTACHMENT_COLOR_CHANNEL6
{ $class-description "" } ;

HELP: RL_ATTACHMENT_COLOR_CHANNEL7
{ $class-description "" } ;

HELP: RL_ATTACHMENT_CUBEMAP_NEGATIVE_X
{ $class-description "" } ;

HELP: RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y
{ $class-description "" } ;

HELP: RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z
{ $class-description "" } ;

HELP: RL_ATTACHMENT_CUBEMAP_POSITIVE_X
{ $class-description "" } ;

HELP: RL_ATTACHMENT_CUBEMAP_POSITIVE_Y
{ $class-description "" } ;

HELP: RL_ATTACHMENT_CUBEMAP_POSITIVE_Z
{ $class-description "" } ;

HELP: RL_ATTACHMENT_DEPTH
{ $class-description "" } ;

HELP: RL_ATTACHMENT_RENDERBUFFER
{ $class-description "" } ;

HELP: RL_ATTACHMENT_STENCIL
{ $class-description "" } ;

HELP: RL_ATTACHMENT_TEXTURE2D
{ $class-description "" } ;

HELP: RL_BLEND_ADDITIVE
{ $class-description "" } ;

HELP: RL_BLEND_ADD_COLORS
{ $class-description "" } ;

HELP: RL_BLEND_ALPHA
{ $class-description "" } ;

HELP: RL_BLEND_ALPHA_PREMULTIPLY
{ $class-description "" } ;

HELP: RL_BLEND_COLOR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_BLEND_CUSTOM
{ $class-description "" } ;

HELP: RL_BLEND_CUSTOM_SEPARATE
{ $class-description "" } ;

HELP: RL_BLEND_DST_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_BLEND_DST_RGB
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_BLEND_EQUATION
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_BLEND_EQUATION_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_BLEND_EQUATION_RGB
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_BLEND_MULTIPLIED
{ $class-description "" } ;

HELP: RL_BLEND_SRC_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_BLEND_SRC_RGB
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_BLEND_SUBTRACT_COLORS
{ $class-description "" } ;

HELP: RL_COMPUTE_SHADER
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_CONSTANT_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_CONSTANT_COLOR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_CULL_FACE_BACK
{ $class-description "" } ;

HELP: RL_CULL_FACE_FRONT
{ $class-description "" } ;

HELP: RL_DST_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_DST_COLOR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_DYNAMIC_COPY
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_DYNAMIC_DRAW
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_DYNAMIC_READ
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_FLOAT
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_FRAGMENT_SHADER
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_FUNC_ADD
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_FUNC_REVERSE_SUBTRACT
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_FUNC_SUBTRACT
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_LINES
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_LOG_ALL
{ $class-description "" } ;

HELP: RL_LOG_DEBUG
{ $class-description "" } ;

HELP: RL_LOG_ERROR
{ $class-description "" } ;

HELP: RL_LOG_FATAL
{ $class-description "" } ;

HELP: RL_LOG_INFO
{ $class-description "" } ;

HELP: RL_LOG_NONE
{ $class-description "" } ;

HELP: RL_LOG_TRACE
{ $class-description "" } ;

HELP: RL_LOG_WARNING
{ $class-description "" } ;

HELP: RL_MAX
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_MIN
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_MODELVIEW
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ONE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ONE_MINUS_CONSTANT_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ONE_MINUS_CONSTANT_COLOR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ONE_MINUS_DST_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ONE_MINUS_DST_COLOR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ONE_MINUS_SRC_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ONE_MINUS_SRC_COLOR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_OPENGL_11
{ $class-description "" } ;

HELP: RL_OPENGL_21
{ $class-description "" } ;

HELP: RL_OPENGL_33
{ $class-description "" } ;

HELP: RL_OPENGL_43
{ $class-description "" } ;

HELP: RL_OPENGL_ES_20
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_DXT1_RGB
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_ETC1_RGB
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_ETC2_RGB
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_PVRT_RGB
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_R32
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8
{ $class-description "" } ;

HELP: RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
{ $class-description "" } ;

HELP: RL_PROJECTION
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_QUADS
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_SHADER_ATTRIB_FLOAT
{ $class-description "" } ;

HELP: RL_SHADER_ATTRIB_VEC2
{ $class-description "" } ;

HELP: RL_SHADER_ATTRIB_VEC3
{ $class-description "" } ;

HELP: RL_SHADER_ATTRIB_VEC4
{ $class-description "" } ;

HELP: RL_SHADER_LOC_COLOR_AMBIENT
{ $class-description "" } ;

HELP: RL_SHADER_LOC_COLOR_DIFFUSE
{ $class-description "" } ;

HELP: RL_SHADER_LOC_COLOR_SPECULAR
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_ALBEDO
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_BRDF
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_CUBEMAP
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_DIFFUSE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_SHADER_LOC_MAP_EMISSION
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_HEIGHT
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_IRRADIANCE
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_METALNESS
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_NORMAL
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_OCCLUSION
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_PREFILTER
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_ROUGHNESS
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MAP_SPECULAR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_SHADER_LOC_MATRIX_MODEL
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MATRIX_MVP
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MATRIX_NORMAL
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MATRIX_PROJECTION
{ $class-description "" } ;

HELP: RL_SHADER_LOC_MATRIX_VIEW
{ $class-description "" } ;

HELP: RL_SHADER_LOC_VECTOR_VIEW
{ $class-description "" } ;

HELP: RL_SHADER_LOC_VERTEX_COLOR
{ $class-description "" } ;

HELP: RL_SHADER_LOC_VERTEX_NORMAL
{ $class-description "" } ;

HELP: RL_SHADER_LOC_VERTEX_POSITION
{ $class-description "" } ;

HELP: RL_SHADER_LOC_VERTEX_TANGENT
{ $class-description "" } ;

HELP: RL_SHADER_LOC_VERTEX_TEXCOORD01
{ $class-description "" } ;

HELP: RL_SHADER_LOC_VERTEX_TEXCOORD02
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_FLOAT
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_INT
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_IVEC2
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_IVEC3
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_IVEC4
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_SAMPLER2D
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_VEC2
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_VEC3
{ $class-description "" } ;

HELP: RL_SHADER_UNIFORM_VEC4
{ $class-description "" } ;

HELP: RL_SRC_ALPHA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_SRC_ALPHA_SATURATE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_SRC_COLOR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_STATIC_COPY
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_STATIC_DRAW
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_STATIC_READ
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_STREAM_COPY
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_STREAM_DRAW
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_STREAM_READ
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_FILTER_ANISOTROPIC
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_FILTER_ANISOTROPIC_16X
{ $class-description "" } ;

HELP: RL_TEXTURE_FILTER_ANISOTROPIC_4X
{ $class-description "" } ;

HELP: RL_TEXTURE_FILTER_ANISOTROPIC_8X
{ $class-description "" } ;

HELP: RL_TEXTURE_FILTER_BILINEAR
{ $class-description "" } ;

HELP: RL_TEXTURE_FILTER_LINEAR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_FILTER_MIP_LINEAR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_FILTER_MIP_NEAREST
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_FILTER_NEAREST
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_FILTER_POINT
{ $class-description "" } ;

HELP: RL_TEXTURE_FILTER_TRILINEAR
{ $class-description "" } ;

HELP: RL_TEXTURE_MAG_FILTER
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_MIN_FILTER
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_MIPMAP_BIAS_RATIO
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_WRAP_CLAMP
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_WRAP_MIRROR_CLAMP
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_WRAP_MIRROR_REPEAT
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_WRAP_REPEAT
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_WRAP_S
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TEXTURE_WRAP_T
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_TRIANGLES
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_UNSIGNED_BYTE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_VERTEX_SHADER
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RL_ZERO
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: rl-activate-draw-buffers
{ $values
    { "count" object }
}
{ $description "" } ;

HELP: rl-active-texture-slot
{ $values
    { "slot" object }
}
{ $description "" } ;

HELP: rl-begin
{ $values
    { "mode" object }
}
{ $description "" } ;

HELP: rl-bind-image-texture
{ $values
    { "id" object } { "index" object } { "format" object } { "readonly" object }
}
{ $description "" } ;

HELP: rl-bind-shader-buffer
{ $values
    { "id" object } { "index" object }
}
{ $description "" } ;

HELP: rl-check-errors
{ $description "" } ;

HELP: rl-check-render-batch-limit
{ $values
    { "vCount" object }
    { "bool" object }
}
{ $description "" } ;

HELP: rl-clear-color
{ $values
    { "r" object } { "g" object } { "b" object } { "a" object }
}
{ $description "" } ;

HELP: rl-clear-screen-buffers
{ $description "" } ;

HELP: rl-color3f
{ $values
    { "x" object } { "y" object } { "z" object }
}
{ $description "" } ;

HELP: rl-color4f
{ $values
    { "x" object } { "y" object } { "z" object } { "w" object }
}
{ $description "" } ;

HELP: rl-color4ub
{ $values
    { "r" object } { "g" object } { "b" object } { "a" object }
}
{ $description "" } ;

HELP: rl-compile-shader
{ $values
    { "shaderCode" object } { "type" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-compute-shader-dispatch
{ $values
    { "groupX" object } { "groupY" object } { "groupZ" object }
}
{ $description "" } ;

HELP: rl-copy-shader-buffer
{ $values
    { "destId" object } { "srcId" object } { "destOffset" object } { "srcOffset" object } { "count" object }
}
{ $description "" } ;

HELP: rl-cubemap-parameters
{ $values
    { "id" object } { "param" object } { "value" object }
}
{ $description "" } ;

HELP: rl-disable-backface-culling
{ $description "" } ;

HELP: rl-disable-color-blend
{ $description "" } ;

HELP: rl-disable-depth-mask
{ $description "" } ;

HELP: rl-disable-depth-test
{ $description "" } ;

HELP: rl-disable-framebuffer
{ $description "" } ;

HELP: rl-disable-scissor-test
{ $description "" } ;

HELP: rl-disable-shader
{ $description "" } ;

HELP: rl-disable-smooth-lines
{ $description "" } ;

HELP: rl-disable-stereo-render
{ $description "" } ;

HELP: rl-disable-texture
{ $description "" } ;

HELP: rl-disable-texture-cubemap
{ $description "" } ;

HELP: rl-disable-vertex-array
{ $description "" } ;

HELP: rl-disable-vertex-attribute
{ $values
    { "index" object }
}
{ $description "" } ;

HELP: rl-disable-vertex-buffer
{ $description "" } ;

HELP: rl-disable-vertex-buffer-element
{ $description "" } ;

HELP: rl-disable-wire-mode
{ $description "" } ;

HELP: rl-draw-render-batch
{ $values
    { "batch" object }
}
{ $description "" } ;

HELP: rl-draw-render-batch-active
{ $description "" } ;

HELP: rl-draw-vertex-array
{ $values
    { "offset" object } { "count" object }
}
{ $description "" } ;

HELP: rl-draw-vertex-array-elements
{ $values
    { "offset" object } { "count" object } { "buffer" object }
}
{ $description "" } ;

HELP: rl-draw-vertex-array-elements-instanced
{ $values
    { "offset" object } { "count" object } { "buffer" object } { "instances" object }
}
{ $description "" } ;

HELP: rl-draw-vertex-array-instanced
{ $values
    { "offset" object } { "count" object } { "instances" object }
}
{ $description "" } ;

HELP: rl-enable-backface-culling
{ $description "" } ;

HELP: rl-enable-color-blend
{ $description "" } ;

HELP: rl-enable-depth-mask
{ $description "" } ;

HELP: rl-enable-framebuffer
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-enable-scissor-test
{ $description "" } ;

HELP: rl-enable-shader
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-enable-smooth-lines
{ $description "" } ;

HELP: rl-enable-stereo-render
{ $description "" } ;

HELP: rl-enable-texture
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-enable-texture-cubemap
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-enable-vertex-array
{ $values
    { "vaoId" object }
    { "bool" object }
}
{ $description "" } ;

HELP: rl-enable-vertex-attribute
{ $values
    { "index" object }
}
{ $description "" } ;

HELP: rl-enable-vertex-buffer
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-enable-vertex-buffer-element
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-enable-wire-mode
{ $description "" } ;

HELP: rl-enble-depth-test
{ $description "" } ;

HELP: rl-end
{ $description "" } ;

HELP: rl-framebuffer-attach
{ $values
    { "fboId" object } { "texId" object } { "attachType" object } { "texType" object } { "mipLevel" object }
}
{ $description "" } ;

HELP: rl-framebuffer-complete
{ $values
    { "id" object }
    { "bool" object }
}
{ $description "" } ;

HELP: rl-frustum
{ $values
    { "left" object } { "right" object } { "bottom" object } { "top" object } { "znear" object } { "zfar" object }
}
{ $description "" } ;

HELP: rl-gen-texture-mipmaps
{ $values
    { "id" object } { "width" object } { "height" object } { "format" object } { "mipmaps" object }
}
{ $description "" } ;

HELP: rl-get-framebuffer-height
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: rl-get-framebuffer-width
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: rl-get-gl-texture-formats
{ $values
    { "format" object } { "glInternalFormat" object } { "glFormat" object } { "glType" object }
}
{ $description "" } ;

HELP: rl-get-line-width
{ $values
    { "float" object }
}
{ $description "" } ;

HELP: rl-get-location-attrib
{ $values
    { "shaderId" object } { "attribName" object }
    { "int" object }
}
{ $description "" } ;

HELP: rl-get-location-uniform
{ $values
    { "shaderId" object } { "uniformName" object }
    { "int" object }
}
{ $description "" } ;

HELP: rl-get-matrix-modelview
{ $values
    { "Matrix" object }
}
{ $description "" } ;

HELP: rl-get-matrix-projection
{ $values
    { "Matrix" object }
}
{ $description "" } ;

HELP: rl-get-matrix-projection-stereo
{ $values
    { "eye" object }
    { "Matrix" object }
}
{ $description "" } ;

HELP: rl-get-matrix-transform
{ $values
    { "Matrix" object }
}
{ $description "" } ;

HELP: rl-get-matrix-view-offset-stereo
{ $values
    { "eye" object }
    { "Matrix" object }
}
{ $description "" } ;

HELP: rl-get-pixel-format-name
{ $values
    { "format" object }
    { "char*" object }
}
{ $description "" } ;

HELP: rl-get-shader-buffer-size
{ $values
    { "id" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-get-shader-id-default
{ $values
    { "uint" object }
}
{ $description "" } ;

HELP: rl-get-shader-locs-default
{ $values
    { "int*" object }
}
{ $description "" } ;

HELP: rl-get-texture-id-default
{ $values
    { "uint" object }
}
{ $description "" } ;

HELP: rl-get-version
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: rl-gl-close
{ $description "" } ;

HELP: rl-gl-init
{ $values
    { "width" object } { "height" object }
}
{ $description "" } ;

HELP: rl-is-stereo-rendering-enabled
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: rl-load-compute-shader-program
{ $values
    { "shaderId" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-draw-cube
{ $description "" } ;

HELP: rl-load-draw-quad
{ $description "" } ;

HELP: rl-load-extensions
{ $values
    { "loader" object }
}
{ $description "" } ;

HELP: rl-load-framebuffer
{ $values
    { "width" object } { "height" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-identity
{ $description "" } ;

HELP: rl-load-render-batch
{ $values
    { "numBuffers" object } { "bufferElements" object }
    { "rlRenderBatch" object }
}
{ $description "" } ;

HELP: rl-load-shader-buffer
{ $values
    { "size" object } { "data" object } { "usageHint" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-shader-code
{ $values
    { "vsCode" object } { "fsCode" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-shader-program
{ $values
    { "vShaderId" object } { "fShaderId" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-texture
{ $values
    { "data" object } { "width" object } { "height" object } { "format" object } { "mipmapCount" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-texture-cubemap
{ $values
    { "data" object } { "size" object } { "format" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-texture-depth
{ $values
    { "width" object } { "height" object } { "useRenderBuffer" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-vertex-array
{ $values
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-vertex-buffer
{ $values
    { "buffer" object } { "size" object } { "dynamic" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-load-vertex-buffer-element
{ $values
    { "buffer" object } { "size" object } { "dynamic" object }
    { "uint" object }
}
{ $description "" } ;

HELP: rl-matrix-mode
{ $values
    { "mode" object }
}
{ $description "" } ;

HELP: rl-mult-matrixf
{ $values
    { "matf" object }
}
{ $description "" } ;

HELP: rl-normal3f
{ $values
    { "x" object } { "y" object } { "z" object }
}
{ $description "" } ;

HELP: rl-ortho
{ $values
    { "left" object } { "right" object } { "bottom" object } { "top" object } { "znear" object } { "zfar" object }
}
{ $description "" } ;

HELP: rl-pop-matrix
{ $description "" } ;

HELP: rl-push-matrix
{ $description "" } ;

HELP: rl-read-screen-pixels
{ $values
    { "width" object } { "height" object }
    { "uchar*" object }
}
{ $description "" } ;

HELP: rl-read-shader-buffer
{ $values
    { "id" object } { "dest" object } { "count" object } { "offset" object }
}
{ $description "" } ;

HELP: rl-read-texture-pixels
{ $values
    { "id" object } { "width" object } { "height" object } { "format" object }
    { "void*" object }
}
{ $description "" } ;

HELP: rl-rotatef
{ $values
    { "angle" object } { "x" object } { "y" object } { "z" object }
}
{ $description "" } ;

HELP: rl-scalef
{ $values
    { "x" object } { "y" object } { "z" object }
}
{ $description "" } ;

HELP: rl-scissor
{ $values
    { "x" object } { "y" object } { "width" object } { "height" object }
}
{ $description "" } ;

HELP: rl-set-blend-factors
{ $values
    { "glSrcFactor" object } { "glDstFactor" object } { "glEquation" object }
}
{ $description "" } ;

HELP: rl-set-blend-factors-seperate
{ $values
    { "glSrcRGB" object } { "glDstRGB" object } { "glSrcAlpha" object } { "glDstAlpha" object } { "glEqRGB" object } { "glEqAlpha" object }
}
{ $description "" } ;

HELP: rl-set-blend-mode
{ $values
    { "mode" object }
}
{ $description "" } ;

HELP: rl-set-cull-face
{ $values
    { "mode" object }
}
{ $description "" } ;

HELP: rl-set-framebuffer-height
{ $values
    { "height" object }
}
{ $description "" } ;

HELP: rl-set-framebuffer-width
{ $values
    { "width" object }
}
{ $description "" } ;

HELP: rl-set-line-width
{ $values
    { "width" object }
}
{ $description "" } ;

HELP: rl-set-matrix-modelview
{ $values
    { "view" object }
}
{ $description "" } ;

HELP: rl-set-matrix-projection
{ $values
    { "proj" object }
}
{ $description "" } ;

HELP: rl-set-matrix-projection-stereo
{ $values
    { "right" object } { "left" object }
}
{ $description "" } ;

HELP: rl-set-matrix-view-offset-stereo
{ $values
    { "right" object } { "left" object }
}
{ $description "" } ;

HELP: rl-set-render-batch-active
{ $values
    { "batch" object }
}
{ $description "" } ;

HELP: rl-set-shader
{ $values
    { "id" object } { "locs" object }
}
{ $description "" } ;

HELP: rl-set-texture
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-set-uniform
{ $values
    { "locIndex" object } { "value" object } { "uniformType" object } { "count" object }
}
{ $description "" } ;

HELP: rl-set-uniform-matrix
{ $values
    { "locIndex" object } { "mat" object }
}
{ $description "" } ;

HELP: rl-set-uniform-sampler
{ $values
    { "locIndex" object } { "textureId" object }
}
{ $description "" } ;

HELP: rl-set-vertex-attribute
{ $values
    { "index" object } { "compSize" object } { "type" object } { "normalized" object } { "stride" object } { "pointer" object }
}
{ $description "" } ;

HELP: rl-set-vertex-attribute-default
{ $values
    { "locIndex" object } { "value" object } { "attribType" object } { "count" object }
}
{ $description "" } ;

HELP: rl-set-vertex-attribute-divisor
{ $values
    { "index" object } { "divisor" object }
}
{ $description "" } ;

HELP: rl-text-coord2f
{ $values
    { "x" object } { "y" object }
}
{ $description "" } ;

HELP: rl-texture-parameters
{ $values
    { "id" object } { "param" object } { "value" object }
}
{ $description "" } ;

HELP: rl-translatef
{ $values
    { "x" object } { "y" object } { "z" object }
}
{ $description "" } ;

HELP: rl-unload-framebuffer
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-unload-render-batch
{ $values
    { "batch" object }
}
{ $description "" } ;

HELP: rl-unload-shader-buffer
{ $values
    { "ssboId" object }
}
{ $description "" } ;

HELP: rl-unload-shader-program
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-unload-texture
{ $values
    { "id" object }
}
{ $description "" } ;

HELP: rl-unload-vertex-array
{ $values
    { "vaoId" object }
}
{ $description "" } ;

HELP: rl-unload-vertex-buffer
{ $values
    { "vboId" object }
}
{ $description "" } ;

HELP: rl-update-shader-buffer
{ $values
    { "id" object } { "data" object } { "dataSize" object } { "offset" object }
}
{ $description "" } ;

HELP: rl-update-texture
{ $values
    { "id" object } { "offsetX" object } { "offsetY" object } { "width" object } { "height" object } { "format" object } { "data" object }
}
{ $description "" } ;

HELP: rl-update-vetex-buffer
{ $values
    { "bufferId" object } { "data" object } { "dataSize" object } { "offset" object }
}
{ $description "" } ;

HELP: rl-update-vetex-buffer-elements
{ $values
    { "id" object } { "data" object } { "dataSize" object } { "offset" object }
}
{ $description "" } ;

HELP: rl-vertex2f
{ $values
    { "x" object } { "y" object }
}
{ $description "" } ;

HELP: rl-vertex2i
{ $values
    { "x" object } { "y" object }
}
{ $description "" } ;

HELP: rl-vertex3f
{ $values
    { "x" object } { "y" object } { "z" object }
}
{ $description "" } ;

HELP: rl-viewport
{ $values
    { "x" object } { "y" object } { "width" object } { "height" object }
}
{ $description "" } ;

HELP: rlBlendMode
{ $var-description "" } ;

HELP: rlCullMode
{ $var-description "" } ;

HELP: rlDrawCall
{ $class-description "" } ;

HELP: rlFramebufferAttachTextureType
{ $var-description "" } ;

HELP: rlFramebufferAttachType
{ $var-description "" } ;

HELP: rlGlVersion
{ $var-description "" } ;

HELP: rlPixelFormat
{ $var-description "" } ;

HELP: rlRenderBatch
{ $class-description "" } ;

HELP: rlShaderAttributeDataType
{ $var-description "" } ;

HELP: rlShaderLocationIndex
{ $var-description "" } ;

HELP: rlShaderUniformDataType
{ $var-description "" } ;

HELP: rlTextureFilter
{ $var-description "" } ;

HELP: rlTraceLogLevel
{ $var-description "" } ;

HELP: rlVertexBuffer
{ $class-description "" } ;

ARTICLE: "rlgl" "rlgl"
{ $vocab-link "rlgl" }
;

ABOUT: "rlgl"
