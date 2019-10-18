USING: alien kernel opengl.gl.extensions system tools.test ;

{ t } [
    gl-function-calling-convention
    os windows? [ stdcall ] [ cdecl ] if =
] unit-test
