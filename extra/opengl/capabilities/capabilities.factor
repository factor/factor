! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces sequences splitting opengl.gl
continuations math.parser math arrays ;
IN: opengl.capabilities

: (require-gl) ( thing require-quot make-error-quot -- )
    >r dupd call
    [ r> 2drop ]
    [ r> " " make throw ]
    if ; inline

: gl-extensions ( -- seq )
    GL_EXTENSIONS glGetString " " split ;
: has-gl-extensions? ( extensions -- ? )
    gl-extensions swap [ over member? ] all? nip ;
: (make-gl-extensions-error) ( required-extensions -- )
    gl-extensions swap seq-diff
    "Required OpenGL extensions not supported:\n" %
    [ "    " % % "\n" % ] each ;
: require-gl-extensions ( extensions -- )
    [ has-gl-extensions? ]
    [ (make-gl-extensions-error) ]
    (require-gl) ;

: version-seq ( version-string -- version-seq )
    "." split [ string>number ] map ;

: version<=> ( version1 version2 -- n )
    swap version-seq swap version-seq <=> ;

: (gl-version) ( -- version vendor )
    GL_VERSION glGetString " " split1 ;
: gl-version ( -- version )
    (gl-version) drop ;
: gl-vendor-version ( -- version )
    (gl-version) nip ;
: has-gl-version? ( version -- ? )
    gl-version version<=> 0 <= ;
: (make-gl-version-error) ( required-version -- )
    "Required OpenGL version " % % " not supported (" % gl-version % " available)" % ;
: require-gl-version ( version -- )
    [ has-gl-version? ]
    [ (make-gl-version-error) ]
    (require-gl) ;

: (glsl-version) ( -- version vendor )
    GL_SHADING_LANGUAGE_VERSION glGetString " " split1 ;
: glsl-version ( -- version )
    (glsl-version) drop ;
: glsl-vendor-version ( -- version )
    (glsl-version) nip ;
: has-glsl-version? ( version -- ? )
    glsl-version version<=> 0 <= ;
: require-glsl-version ( version -- )
    [ has-glsl-version? ]
    [ "Required GLSL version " % % " not supported (" % glsl-version % " available)" % ]
    (require-gl) ;

: has-gl-version-or-extensions? ( version extensions -- ? )
    has-gl-extensions? swap has-gl-version? or ;

: require-gl-version-or-extensions ( version extensions -- )
    2array [ first2 has-gl-version-or-extensions? ] [
        dup first (make-gl-version-error) "\n" %
        second (make-gl-extensions-error) "\n" %
    ] (require-gl) ;
