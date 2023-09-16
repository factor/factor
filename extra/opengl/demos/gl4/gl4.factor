! upgraded to opengl4 factor port of https://learnopengl.com/Getting-started/Hello-Triangle
USING: accessors alien.c-types alien.data colors game.input
game.input.scancodes game.loop game.worlds kernel literals math
multiline opengl opengl.gl opengl.shaders sequences
specialized-arrays.instances.alien.c-types.float ui
ui.gadgets.worlds ui.pixel-formats ;
IN: opengl.demos.gl4

STRING: testing-vertex-shader
  #version 450 core
  layout (location = 0) in vec3 aPos;
  
  void main () {
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
  }
;

STRING: testing-fragment-shader
  #version 450 core
  out vec4 FragColor;
 
  void main () {
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
  }
;

: ref ( value c-type quot -- value ) 
  -rot [ <ref> ] keep [ drop swap call ] 2keep deref ; inline

TUPLE: gl4demo-world < game-world
  testing-program
  vertices vbo vao ;

M: gl4demo-world begin-game-world 
  testing-vertex-shader testing-fragment-shader <simple-gl-program> >>testing-program 
  float-array{ -0.5 -0.5 0.0   0.5 -0.5 0.0   0.0 0.5 0.0 } >>vertices
  
  1 0 uint [ glCreateVertexArrays ] ref >>vao
  1 0 uint [ glCreateBuffers ] ref >>vbo

  dup [ vbo>> ] [ vertices>> length 4 * ] [ vertices>> ] tri GL_STATIC_DRAW glNamedBufferData
  
  dup [ vao>> 0 ] [ vbo>> ] bi 0 3 4 * glVertexArrayVertexBuffer
  
  dup vao>> 0 glEnableVertexArrayAttrib
  dup vao>> 0 3 GL_FLOAT GL_FALSE 0 glVertexArrayAttribFormat
  
  dup vao>> 0 0 glVertexArrayAttribBinding

  drop ;

M: gl4demo-world end-game-world 
  dup testing-program>> delete-gl-program
  dup vbo>> delete-gl-buffer
  dup vao>> delete-vertex-array
  drop ;

:: handle-input ( world -- )  
  read-keyboard keys>> :> keys
  key-escape keys nth [ world close-window ] when
;

M: gl4demo-world tick-game-world 
  handle-input ;

M: gl4demo-world draw-world*
  COLOR: aqua gl-clear

  dup testing-program>> [
    over vao>> glBindVertexArray
    GL_TRIANGLES 0 3 glDrawArrays drop
  ] with-gl-program drop ;

GAME: gl4demo {
  { world-class gl4demo-world }
  { title "gl4demo" }
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
