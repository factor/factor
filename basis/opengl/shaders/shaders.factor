! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel opengl.gl alien.c-types continuations namespaces
assocs alien alien.strings libc opengl math sequences combinators
macros arrays io.encodings.ascii fry specialized-arrays.uint
destructors accessors ;
IN: opengl.shaders

: with-gl-shader-source-ptr ( string quot -- )
    swap ascii malloc-string [ <void*> swap call ] keep free ; inline

: <gl-shader> ( source kind -- shader )
    glCreateShader dup rot
    [ 1 swap f glShaderSource ] with-gl-shader-source-ptr
    [ glCompileShader ] keep
    gl-error ;

: (gl-shader?) ( object -- ? )
    dup integer? [ glIsShader c-bool> ] [ drop f ] if ;

: gl-shader-get-int ( shader enum -- value )
    0 <int> [ glGetShaderiv ] keep *int ;

: gl-shader-ok? ( shader -- ? )
    GL_COMPILE_STATUS gl-shader-get-int c-bool> ;

: <vertex-shader> ( source -- vertex-shader )
    GL_VERTEX_SHADER <gl-shader> ; inline

: (vertex-shader?) ( object -- ? )
    dup (gl-shader?)
    [ GL_SHADER_TYPE gl-shader-get-int GL_VERTEX_SHADER = ]
    [ drop f ] if ;

: <fragment-shader> ( source -- fragment-shader )
    GL_FRAGMENT_SHADER <gl-shader> ; inline

: (fragment-shader?) ( object -- ? )
    dup (gl-shader?)
    [ GL_SHADER_TYPE gl-shader-get-int GL_FRAGMENT_SHADER = ]
    [ drop f ] if ;

: gl-shader-info-log-length ( shader -- log-length )
    GL_INFO_LOG_LENGTH gl-shader-get-int ; inline

: gl-shader-info-log ( shader -- log )
    dup gl-shader-info-log-length dup [
        1 calloc &free
        [ 0 <int> swap glGetShaderInfoLog ] keep
        ascii alien>string
    ] with-destructors ;

: check-gl-shader ( shader -- shader )
    dup gl-shader-ok? [ dup gl-shader-info-log throw ] unless ;

: delete-gl-shader ( shader -- ) glDeleteShader ; inline

PREDICATE: gl-shader < integer (gl-shader?) ;
PREDICATE: vertex-shader < gl-shader (vertex-shader?) ;
PREDICATE: fragment-shader < gl-shader (fragment-shader?) ;

! Programs

: <gl-program> ( shaders -- program )
    glCreateProgram swap
    [ dupd glAttachShader ] each
    [ glLinkProgram ] keep
    gl-error ;
    
: (gl-program?) ( object -- ? )
    dup integer? [ glIsProgram c-bool> ] [ drop f ] if ;

: gl-program-get-int ( program enum -- value )
    0 <int> [ glGetProgramiv ] keep *int ;

: gl-program-ok? ( program -- ? )
    GL_LINK_STATUS gl-program-get-int c-bool> ;

: gl-program-info-log-length ( program -- log-length )
    GL_INFO_LOG_LENGTH gl-program-get-int ; inline

: gl-program-info-log ( program -- log )
    dup gl-program-info-log-length dup [
        1 calloc &free
        [ 0 <int> swap glGetProgramInfoLog ] keep
        ascii alien>string
    ] with-destructors ;

: check-gl-program ( program -- program )
    dup gl-program-ok? [ dup gl-program-info-log throw ] unless ;

: gl-program-shaders-length ( program -- shaders-length )
    GL_ATTACHED_SHADERS gl-program-get-int ; inline

! On some macosx-x86-64 graphics drivers, glGetAttachedShaders tries to treat the
! shaders parameter as a ulonglong array rather than a GLuint array as documented.
! We hack around this by allocating a buffer twice the size and sifting out the zero
! values

: gl-program-shaders ( program -- shaders )
    dup gl-program-shaders-length 2 *
    0 <int>
    over <uint-array>
    [ glGetAttachedShaders ] keep [ zero? not ] filter ;

: delete-gl-program-only ( program -- )
    glDeleteProgram ; inline

: detach-gl-program-shader ( program shader -- )
    glDetachShader ; inline

: delete-gl-program ( program -- )
    dup gl-program-shaders [
        2dup detach-gl-program-shader delete-gl-shader
    ] each delete-gl-program-only ;

: with-gl-program ( program quot -- )
    over glUseProgram [ 0 glUseProgram ] [ ] cleanup ; inline

PREDICATE: gl-program < integer (gl-program?) ;

: <simple-gl-program> ( vertex-shader-source fragment-shader-source -- program )
    [ <vertex-shader> check-gl-shader ]
    [ <fragment-shader> check-gl-shader ] bi*
    2array <gl-program> check-gl-program ;

