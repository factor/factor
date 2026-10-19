! Copyright (C) 2008 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: opengl opengl.gl combinators continuations kernel locals
alien.c-types alien.data ;
IN: opengl.framebuffers

: gen-framebuffer ( -- id )
    [ glGenFramebuffers ] (gen-gl-object) ;
: gen-renderbuffer ( -- id )
    [ glGenRenderbuffers ] (gen-gl-object) ;

: delete-framebuffer ( id -- )
    [ glDeleteFramebuffers ] (delete-gl-object) ;
: delete-renderbuffer ( id -- )
    [ glDeleteRenderbuffers ] (delete-gl-object) ;

: framebuffer-incomplete? ( -- status/f )
    GL_DRAW_FRAMEBUFFER glCheckFramebufferStatus
    dup GL_FRAMEBUFFER_COMPLETE = f rot ? ;

: framebuffer-error ( status -- * )
    {
        { GL_FRAMEBUFFER_COMPLETE [ "framebuffer complete" ] }
        { GL_FRAMEBUFFER_UNSUPPORTED [ "framebuffer configuration unsupported" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT [ "framebuffer incomplete (incomplete attachment)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT [ "framebuffer incomplete (missing attachment)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT [ "framebuffer incomplete (dimension mismatch)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT [ "framebuffer incomplete (format mismatch)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER [ "framebuffer incomplete (draw buffer(s) have no attachment)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER [ "framebuffer incomplete (read buffer has no attachment)" ] }
        { GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE [ "framebuffer incomplete (multisample counts don't match)" ] }
        [ drop gl-error "unknown framebuffer error" ]
    } case throw ;

: check-framebuffer ( -- )
    framebuffer-incomplete? [ framebuffer-error ] when* ;

:: with-framebuffer ( id quot -- )
    GL_DRAW_FRAMEBUFFER_BINDING { int } [ glGetIntegerv ] with-out-parameters :> previous
    GL_DRAW_FRAMEBUFFER id glBindFramebuffer
    quot [ GL_DRAW_FRAMEBUFFER previous glBindFramebuffer ] finally ; inline

:: with-draw-read-framebuffers ( draw-id read-id quot -- )
    GL_DRAW_FRAMEBUFFER_BINDING { int } [ glGetIntegerv ] with-out-parameters :> previous-draw
    GL_READ_FRAMEBUFFER_BINDING { int } [ glGetIntegerv ] with-out-parameters :> previous-read
    GL_DRAW_FRAMEBUFFER draw-id glBindFramebuffer
    GL_READ_FRAMEBUFFER read-id glBindFramebuffer
    quot
    [
        GL_DRAW_FRAMEBUFFER previous-draw glBindFramebuffer
        GL_READ_FRAMEBUFFER previous-read glBindFramebuffer
    ] finally ; inline

: framebuffer-attachment ( attachment -- id )
    GL_FRAMEBUFFER swap GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME
    { uint } [ glGetFramebufferAttachmentParameteriv ] with-out-parameters ;
