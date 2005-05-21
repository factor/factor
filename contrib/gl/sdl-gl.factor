IN: sdl

USING: alien compiler ;

: SDL_GL_SwapBuffers ( -- )
    "void" "sdl" "SDL_GL_SwapBuffers" [ ] alien-invoke ;

\ SDL_GL_SwapBuffers compile

