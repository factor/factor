USING: kernel opengl.gl.gtk3 system tools.test ;

! Resolving libepoxy's dispatch pointers does not require a current context.
os linux? [
    { t } [ "glGetString" gl-function-address >boolean ] unit-test
    { t } [ "glClear" gl-function-address >boolean ] unit-test
    { f } [ "glFactorMissingFunction" gl-function-address ] unit-test
] when
