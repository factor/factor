! upgraded to opengl4 factor port of https://learnopengl.com/Getting-started/Hello-Triangle
USING: accessors alien.c-types alien.data colors game.input
game.input.scancodes game.loop game.worlds kernel literals math
multiline opengl opengl.capabilities opengl.gl opengl.shaders sequences
specialized-arrays.instances.alien.c-types.float ui
ui.gadgets.worlds ui.pixel-formats ;
IN: opengl.demos.gl4

STRING: testing-vertex-shader
  #version 150
  in vec3 aPos;
  
  void main () {
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
  }
;

STRING: testing-fragment-shader
  #version 150
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
  "3.2" require-gl-version
  testing-vertex-shader testing-fragment-shader <simple-gl-program> >>testing-program 
  float-array{ -0.5 -0.5 0.0   0.5 -0.5 0.0   0.0 0.5 0.0 } >>vertices
  
  gen-vertex-array >>vao
  gen-gl-buffer >>vbo

  dup vao>> glBindVertexArray
  dup vbo>> GL_ARRAY_BUFFER swap glBindBuffer
  dup [ vertices>> length 4 * ] [ vertices>> ] bi
  [ GL_ARRAY_BUFFER ] 2dip GL_STATIC_DRAW glBufferData
  
  dup testing-program>> "aPos" glGetAttribLocation
  dup glEnableVertexAttribArray
  3 GL_FLOAT GL_FALSE 0 f glVertexAttribPointer
  GL_ARRAY_BUFFER 0 glBindBuffer
  0 glBindVertexArray

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
  { title "OpenGL Triangle" }
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
