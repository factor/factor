USING: alien io kernel parser sequences ;

@{
    @{ [ os "macosx" = ] [ ] }@
    @{ [ os "win32" = ] [
            "gl" "opengl32.dll" "stdcall" add-library
            "glu" "glu32.dll" "stdcall" add-library
    ] }@
    @{ [ t ] [
            "gl" "libGL.so" "cdecl" add-library
            "glu" "libGLU.so" "cdecl" add-library
    ] }@
}@ cond

[
    "/library/opengl/gl.factor"
    "/library/opengl/glu.factor"
    "/library/opengl/opengl-utils.factor"
] [
    dup print run-resource
] each
