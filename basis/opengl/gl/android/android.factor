! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: android.ffi alien alien.libraries kernel ;
IN: opengl.gl.android

: gl-function-context ( -- context ) factor_android_gl_context ; inline

: gl-function-address ( name -- address/f )
    dup factor_android_gl_proc [ nip ] [ "GLESv3" library-dll dlsym ] if* ;
