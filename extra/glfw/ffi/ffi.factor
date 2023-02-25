USING: alien alien.c-types alien.libraries alien.syntax combinators system ;

IN: glfw.ffi

<<
"glfw" {
    { [ os windows? ] [ "glfw.dll" ] }
    { [ os macosx? ] [ "glfw.dylib" ] }
    { [ os unix? ] [ "libglfw.so" ] }
} cond cdecl add-library
>>

LIBRARY: glfw

FUNCTION: void* glfwGetCurrentContext (  )
FUNCTION: void glfwMakeContextCurrent ( void* window )
