! upgraded to opengl4 factor port of https://learnopengl.com/Guest-Articles/2022/Compute-Shaders/Introduction
USING: accessors alien.c-types alien.data arrays colors
combinators game.input game.input.scancodes game.loop
game.worlds kernel literals math multiline opengl opengl.gl
opengl.shaders opengl.textures sequences
specialized-arrays.instances.alien.c-types.float ui
ui.gadgets.worlds ui.pixel-formats ;
IN: opengl.demos.compute

CONSTANT: TEXTURE_WIDTH 1000
CONSTANT: TEXTURE_HEIGHT 1000

STRING: compute-shader
#version 430 core
layout (local_size_x = 10, local_size_y = 10, local_size_z = 1) in;

layout(rgba32f, binding = 0) uniform image2D imgOutput;

layout (location = 0) uniform float t;
	
void main() {
    vec4 value = vec4(0.0, 0.0, 0.0, 1.0);
    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);
    float speed = 100;
    float width = 1000;

    value.x = mod(float(texelCoord.x) + t * speed, width) / (gl_NumWorkGroups.x);
    value.y = float(texelCoord.y) / (gl_NumWorkGroups.y);
    imageStore(imgOutput, texelCoord, value);
}
;

STRING: vertex-shader
#version 430 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoords;

out vec2 TexCoords;

void main()
{
    TexCoords = aTexCoords;
    gl_Position = vec4(aPos, 1.0);
}
;

STRING: fragment-shader
#version 430 core
out vec4 FragColor;

in vec2 TexCoords;

uniform sampler2D tex;

void main()
{             
    vec3 texCol = texture(tex, TexCoords).rgb;      
    FragColor = vec4(texCol, 1.0);
}
;

: ref ( value c-type quot -- value ) 
  -rot [ <ref> ] keep [ drop swap call ] 2keep deref ; inline

TUPLE: gl4compute-world < game-world
  program compute-program 
  texture vertices vao vbo 
  { frame-count fixnum initial: 0 } ;

M: gl4compute-world begin-game-world
  vertex-shader fragment-shader <simple-gl-program> >>program
  compute-shader <compute-program> >>compute-program

  float-array{ 
    -1.0  1.0  0.0  0.0  1.0
    -1.0 -1.0  0.0  0.0  0.0
     1.0  1.0  0.0  1.0  1.0
     1.0 -1.0  0.0  1.0  0.0 
  } >>vertices

  create-vertex-array >>vao
  create-gl-buffer >>vbo

  dup [ vbo>> ] [ vertices>> length 4 * ] [ vertices>> ] tri GL_STATIC_DRAW glNamedBufferData
  
  dup [ vao>> 0 ] [ vbo>> ] bi 0 5 4 * glVertexArrayVertexBuffer
 
  dup vao>> {
    [ 0 glEnableVertexArrayAttrib ]
    [ 0 3 GL_FLOAT GL_FALSE 0 glVertexArrayAttribFormat ]
    [ 0 0 glVertexArrayAttribBinding ]

    [ 1 glEnableVertexArrayAttrib ]
    [ 1 2 GL_FLOAT GL_FALSE 3 4 * glVertexArrayAttribFormat ]
    [ 1 0 glVertexArrayAttribBinding ]
  } cleave

  GL_TEXTURE_2D create-texture >>texture
  dup texture>> {
    [ 1 GL_RGBA32F TEXTURE_WIDTH TEXTURE_HEIGHT glTextureStorage2D ]
    [ GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTextureParameteri ]
    [ GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTextureParameteri ]
    [ GL_TEXTURE_MAG_FILTER GL_LINEAR glTextureParameteri ]
    [ GL_TEXTURE_MIN_FILTER GL_LINEAR glTextureParameteri ]
  } cleave
  dup texture>> 0 swap 0 GL_FALSE 0 GL_READ_WRITE GL_RGBA32F glBindImageTexture
  drop ;

M: gl4compute-world end-game-world 
  dup compute-program>> delete-gl-program
  dup program>> delete-gl-program
  dup texture>> delete-texture
  dup vbo>> delete-gl-buffer
  dup vao>> delete-vertex-array
  drop ;

:: handle-input ( world -- )  
  read-keyboard keys>> :> keys
  key-escape keys nth [ world close-window ] when
;

M: gl4compute-world tick-game-world 
  dup handle-input 
  dup frame-count>> dup 500 > [ drop 0 ] [ 1 + ] if >>frame-count
  drop ;

M: gl4compute-world draw-world* 
  dup compute-program>> glUseProgram 
  dup [ compute-program>> ] [ compute-program>> "t" glGetUniformLocation ] [ frame-count>> ] tri glProgramUniform1f
  TEXTURE_WIDTH 10 / TEXTURE_HEIGHT 10 / 1 glDispatchCompute
  GL_SHADER_IMAGE_ACCESS_BARRIER_BIT glMemoryBarrier

  GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear

  dup program>> glUseProgram

  dup [ program>> ] [ program>> "tex" glGetUniformLocation ] bi 0 glProgramUniform1i
  dup texture>> 0 swap glBindTextureUnit

  dup vao>> glBindVertexArray
  GL_TRIANGLE_STRIP 0 4 glDrawArrays
  0 glBindVertexArray

  drop ;

GAME: gl4compute {
  { world-class gl4compute-world }
  { title "gl4 compute demo" }
  { pixel-format-attributes { 
    windowed 
    double-buffered
    T{ depth-bits { value 24 } }
  } }
  { use-game-input? t }
  { grab-input? t }
  { pref-dim { 1280 720 } }
  { tick-interval-nanos $[ 60 fps ] }
} ;
