USING: alien kernel opengl.gl.extensions system tools.test ;
IN: opengl.gl.extensions.tests

{ t } [
    gl-function-calling-convention
    os windows? [ stdcall ] [ cdecl ] if =
] unit-test
