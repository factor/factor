! Copyright (C) 2008 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays fry kernel make math.order math.parser opengl.gl
sequences sets splitting strings system ;
IN: opengl.capabilities

: (require-gl) ( thing require-quot make-error-quot -- )
    [ dupd call [ drop ] ] dip '[ _ " " make throw ] if ; inline

: (has-extension?) ( query-extension(s) available-extensions -- ? )
    over string?  [ member? ] [ [ member? ] curry any? ] if ;

: gl-extensions ( -- seq )
    GL_EXTENSIONS glGetString split-words ;
: has-gl-extensions? ( extensions -- ? )
    gl-extensions [ (has-extension?) ] curry all? ;
: (make-gl-extensions-error) ( required-extensions -- )
    gl-extensions diff
    "Required OpenGL extensions not supported:\n" %
    [ "    " % % "\n" % ] each ;
: require-gl-extensions ( extensions -- )
    [ has-gl-extensions? ]
    [ (make-gl-extensions-error) ]
    (require-gl) ;

: version-seq ( version-string -- version-seq )
    "." split [ string>number ] map ;

: version-before? ( version1 version2 -- ? )
    [ version-seq ] bi@ before=? ;

: (gl-version) ( -- version1 version2 )
    GL_VERSION glGetString " " split1 ;
: gl-version ( -- version ) (gl-version) drop ;
: gl-vendor-version ( -- version ) (gl-version) nip ;
: gl-vendor ( -- vendor ) GL_VENDOR glGetString ;

: has-gl-version? ( version -- ? )
    gl-version [ version-before? ] [ drop f ] if* ;

: (make-gl-version-error) ( required-version -- )
    "Required OpenGL version " % % " not supported (" % gl-version "(null)" or % " available)" %
    os linux = [
        "\nIf you have several libGL.so installed, Factor tried the first one in: ldconfig -p | grep libGL.so$" %
        "\nYou can change the library used like so: LD_LIBRARY_PATH=/usr/lib/fglrx/ ./factor" %
    ] when ;

: require-gl-version ( version -- )
    [ has-gl-version? ]
    [ (make-gl-version-error) ]
    (require-gl) ;

: (glsl-version) ( -- version vendor )
    GL_SHADING_LANGUAGE_VERSION glGetString " " split1 ;
: glsl-version ( -- version ) (glsl-version) drop ;
: glsl-vendor-version ( -- version ) (glsl-version) nip ;
: has-glsl-version? ( version -- ? ) glsl-version version-before? ;

: require-glsl-version ( version -- )
    [ has-glsl-version? ]
    [ "Required GLSL version " % % " not supported (" % glsl-version "(null)" or % " available)" % ]
    (require-gl) ;

: has-gl-version-or-extensions? ( version extensions -- ? )
    has-gl-extensions? swap has-gl-version? or ;

: require-gl-version-or-extensions ( version extensions -- )
    2array [ first2 has-gl-version-or-extensions? ] [
        dup first (make-gl-version-error) "\n" %
        second (make-gl-extensions-error) "\n" %
    ] (require-gl) ;
