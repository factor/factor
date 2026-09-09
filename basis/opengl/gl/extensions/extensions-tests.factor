USING: alien arrays assocs continuations hashtables kernel locals
namespaces opengl.gl.extensions system tools.test ;

IN: opengl.gl.extensions.tests

{ t } [
    gl-function-calling-convention
    os windows? [ stdcall ] [ cdecl ] if =
] unit-test

! Numeric binding IDs can collide across counter resets. Seed the cache
! so this regression needs no active context or graphics driver lookup.
:: colliding-gl-function-ids ( -- first second )
    +gl-function-pointers+ get-global :> old-cache
    [
        4 <hashtable> +gl-function-pointers+ set-global
        11 { "first-test-function" } gl-function-cache-key
        +gl-function-pointers+ get-global set-at
        22 { "second-test-function" } gl-function-cache-key
        +gl-function-pointers+ get-global set-at
        { "first-test-function" } 228 gl-function-pointer
        { "second-test-function" } 228 gl-function-pointer
    ] [ old-cache +gl-function-pointers+ set-global ] finally ;

{ 11 22 } [ colliding-gl-function-ids ] unit-test
