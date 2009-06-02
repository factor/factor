! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: opengl opengl.gl combinators continuations kernel
alien.c-types ;
IN: opengl.framebuffers

: gen-framebuffer ( -- id )
    [ glGenFramebuffersEXT ] (gen-gl-object) ;
: gen-renderbuffer ( -- id )
    [ glGenRenderbuffersEXT ] (gen-gl-object) ;

: delete-framebuffer ( id -- )
    [ glDeleteFramebuffersEXT ] (delete-gl-object) ;
: delete-renderbuffer ( id -- )
    [ glDeleteRenderbuffersEXT ] (delete-gl-object) ;

: framebuffer-incomplete? ( -- status/f )
    GL_FRAMEBUFFER_EXT glCheckFramebufferStatusEXT
    dup GL_FRAMEBUFFER_COMPLETE_EXT = f rot ? ;

: framebuffer-error ( status -- * )
    { 
        { GL_FRAMEBUFFER_COMPLETE_EXT [ "framebuffer complete" ] }
        { GL_FRAMEBUFFER_UNSUPPORTED_EXT [ "framebuffer configuration unsupported" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT [ "framebuffer incomplete (incomplete attachment)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT [ "framebuffer incomplete (missing attachment)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT [ "framebuffer incomplete (dimension mismatch)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT [ "framebuffer incomplete (format mismatch)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT [ "framebuffer incomplete (draw buffer(s) have no attachment)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT [ "framebuffer incomplete (read buffer has no attachment)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_EXT [ "framebuffer incomplete (multisample counts don't match)" ] }
        [ drop gl-error "unknown framebuffer error" ]
    } case throw ;

: check-framebuffer ( -- )
    framebuffer-incomplete? [ framebuffer-error ] when* ;

: with-framebuffer ( id quot -- )
    [ GL_FRAMEBUFFER_EXT swap glBindFramebufferEXT ] dip
    [ GL_FRAMEBUFFER_EXT 0 glBindFramebufferEXT ] [ ] cleanup ; inline

: with-draw-read-framebuffers ( draw-id read-id quot -- )
    [
        [ GL_DRAW_FRAMEBUFFER_EXT swap glBindFramebufferEXT ]
        [ GL_READ_FRAMEBUFFER_EXT swap glBindFramebufferEXT ] bi*
    ] dip
    [ 
        GL_DRAW_FRAMEBUFFER_EXT 0 glBindFramebufferEXT
        GL_READ_FRAMEBUFFER_EXT 0 glBindFramebufferEXT
    ] [ ] cleanup ; inline

: framebuffer-attachment ( attachment -- id )
    GL_FRAMEBUFFER_EXT swap GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME_EXT
    0 <uint> [ glGetFramebufferAttachmentParameterivEXT ] keep *uint ;
