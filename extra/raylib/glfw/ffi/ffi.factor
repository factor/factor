USING: alien alien.c-types alien.libraries alien.syntax combinators system ;

IN: raylib.glfw.ffi

<<
"glfw" {
    { [ os windows? ] [ "glfw.dll" ] }
    { [ os macosx? ] [ "glfw.dylib" ] }
    { [ os unix? ] [ "libglfw.so" ] }
} cond cdecl add-library
>>

LIBRARY: glfw
FUNCTION-ALIAS: glfw-get-current-context void* glfwGetCurrentContext (  )
FUNCTION-ALIAS: glfw-make-context-current void glfwMakeContextCurrent ( void* window )
