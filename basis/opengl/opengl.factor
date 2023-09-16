! Copyright (C) 2005, 2009 Slava Pestov.
! Portions copyright (C) 2007 Eduardo Cavazos.
! Portions copyright (C) 2008 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data assocs colors
combinators.smart continuations io kernel math
math.functions math.parser namespaces opengl.gl sequences
sequences.generalizations specialized-arrays system words ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: uint
IN: opengl

SYMBOL: gl-scale-factor

: gl-color ( color -- ) >rgba-components glColor4d ; inline

: gl-clear-color ( color -- ) >rgba-components glClearColor ;

: gl-clear ( color -- )
    gl-clear-color GL_COLOR_BUFFER_BIT glClear ;

: error>string ( n -- string )
    H{
        { 0x0000 "No error" }
        { 0x0501 "Invalid value" }
        { 0x0500 "Invalid enumerant" }
        { 0x0502 "Invalid operation" }
        { 0x0503 "Stack overflow" }
        { 0x0504 "Stack underflow" }
        { 0x0505 "Out of memory" }
        { 0x0506 "Invalid framebuffer operation" }
    } at "Unknown error" or ;

TUPLE: gl-error-tuple function code string ;

: <gl-error> ( function code -- gl-error )
    dup error>string \ gl-error-tuple boa ; inline

: gl-error-code ( -- code/f )
    glGetError dup 0 = [ drop f ] when ; inline

: throw-gl-error? ( -- ? )
    os macosx? [
        ! This is kind of terrible, but we are having
        ! problems on Mac OS X 10.11 where the
        ! default framebuffer seems to be initialized
        ! asynchronously or something, so we should
        ! just log these for now in (gl-error).
        GL_FRAMEBUFFER glCheckFramebufferStatus
        GL_FRAMEBUFFER_UNDEFINED = not
    ] [ t ] if ;

: (gl-error) ( function -- )
    gl-error-code [
        throw-gl-error? [
            <gl-error> throw
        ] [
            [
                [ number>string ] [ error>string ] bi ": " glue
                "OpenGL error: " prepend print flush drop
            ] with-global
        ] if
    ] [ drop ] if* ;

: gl-error ( -- )
    f (gl-error) ; inline

: do-enabled ( what quot -- )
    over glEnable dip glDisable ; inline

: do-enabled-client-state ( what quot -- )
    over glEnableClientState dip glDisableClientState ; inline

: words>values ( word/value-seq -- value-seq )
    [ dup word? [ execute( -- x ) ] when ] map ;

: (all-enabled) ( seq quot -- )
    [ dup [ glEnable ] each ] dip
    dip
    [ glDisable ] each ; inline

: (all-enabled-client-state) ( seq quot -- )
    [ dup [ glEnableClientState ] each ] dip
    dip
    [ glDisableClientState ] each ; inline

MACRO: all-enabled ( seq quot -- quot )
    [ words>values ] dip '[ _ _ (all-enabled) ] ;

MACRO: all-enabled-client-state ( seq quot -- quot )
    [ words>values ] dip '[ _ _ (all-enabled-client-state) ] ;

: do-matrix ( quot -- )
    glPushMatrix call glPopMatrix ; inline

: gl-material ( face pname params -- )
    float-array{ } like glMaterialfv ;

: gl-vertex-pointer ( seq -- )
    [ 2 GL_FLOAT 0 ] dip glVertexPointer ; inline

: gl-color-pointer ( seq -- )
    [ 4 GL_FLOAT 0 ] dip glColorPointer ; inline

: gl-texture-coord-pointer ( seq -- )
    [ 2 GL_FLOAT 0 ] dip glTexCoordPointer ; inline

: (line-vertices) ( a b -- vertices )
    [ first2 [ 0.3 + ] bi@ ] bi@ 4 float-array{ } nsequence ;

: line-vertices ( a b -- )
    (line-vertices) gl-vertex-pointer ;

: gl-line ( a b -- )
    line-vertices GL_LINES 0 2 glDrawArrays ;

:: (rect-vertices) ( loc dim -- vertices )
    ! We use GL_LINE_STRIP with a duplicated first vertex
    ! instead of GL_LINE_LOOP to work around a bug in Apple's
    ! X3100 driver.
    loc first2 [ 0.3 + ] bi@ :> ( x y )
    dim first2 [ 0.6 - ] bi@ :> ( w h )
    [
        x           y
        x w +       y
        x w +       y h +
        x           y h +
        x           y
    ] float-array{ } output>sequence ;

: rect-vertices ( loc dim -- )
    (rect-vertices) gl-vertex-pointer ;

: (gl-rect) ( -- )
    GL_LINE_STRIP 0 5 glDrawArrays ;

: gl-rect ( loc dim -- )
    rect-vertices (gl-rect) ;

:: (fill-rect-vertices) ( loc dim -- vertices )
    loc first2 :> ( x y )
    dim first2 :> ( w h )
    [
        x      y
        x w +  y
        x w +  y h +
        x      y h +
    ] float-array{ } output>sequence ;

: fill-rect-vertices ( loc dim -- )
    (fill-rect-vertices) gl-vertex-pointer ;

: (gl-fill-rect) ( -- )
    GL_QUADS 0 4 glDrawArrays ;

: gl-fill-rect ( loc dim -- )
    fill-rect-vertices (gl-fill-rect) ;

: do-attribs ( bits quot -- )
    swap glPushAttrib call glPopAttrib ; inline

: (gen-gl-object) ( quot -- id )
    [ 1 { uint } ] dip with-out-parameters ; inline

: (delete-gl-object) ( id quot -- )
    [ 1 swap uint <ref> ] dip call ; inline

: gen-gl-buffer ( -- id )
    [ glGenBuffers ] (gen-gl-object) ;

: create-gl-buffer ( -- id )
    [ glCreateBuffers ] (gen-gl-object) ;

: delete-gl-buffer ( id -- )
    [ glDeleteBuffers ] (delete-gl-object) ;

:: with-gl-buffer ( binding id quot -- )
    binding id glBindBuffer
    quot [ binding 0 glBindBuffer ] finally ; inline

: with-array-element-buffers ( array-buffer element-buffer quot -- )
    [ GL_ELEMENT_ARRAY_BUFFER ] 2dip '[
        GL_ARRAY_BUFFER swap _ with-gl-buffer
    ] with-gl-buffer ; inline

: gen-vertex-array ( -- id )
    [ glGenVertexArrays ] (gen-gl-object) ;

: create-vertex-array ( -- id )
    [ glCreateVertexArrays ] (gen-gl-object) ;

: delete-vertex-array ( id -- )
    [ glDeleteVertexArrays ] (delete-gl-object) ;

:: with-vertex-array ( id quot -- )
    id glBindVertexArray
    quot [ 0 glBindVertexArray ] finally ; inline

: <gl-buffer> ( target data hint -- id )
    pick gen-gl-buffer [
        [
            [ [ byte-length ] keep ] dip glBufferData
        ] with-gl-buffer
    ] keep ;

: buffer-offset ( int -- alien )
    <alien> ; inline

: bind-texture-unit ( id target unit -- )
    glActiveTexture swap glBindTexture gl-error ;

: (set-draw-buffers) ( buffers -- )
    [ length ] [ uint >c-array ] bi glDrawBuffers ;

MACRO: set-draw-buffers ( buffers -- quot )
    words>values '[ _ (set-draw-buffers) ] ;

: gen-dlist ( -- id ) 1 glGenLists ;

: make-dlist ( type quot -- id )
    [ gen-dlist ] 2dip '[ _ glNewList @ glEndList ] keep ; inline

: gl-translate ( point -- ) first2 0.0 glTranslated ;

: delete-dlist ( id -- ) 1 glDeleteLists ;

: with-translation ( loc quot -- )
    [ [ gl-translate ] dip call ] do-matrix ; inline

: gl-scale ( m -- n )
    gl-scale-factor get-global [ * ] when* ; inline

: gl-unscale ( m -- n )
    gl-scale-factor get-global [ / ] when* ; inline

: gl-floor ( m -- n )
    gl-scale floor gl-unscale ; inline

: gl-ceiling ( m -- n )
    gl-scale ceiling gl-unscale ; inline

: gl-round ( m -- n )
    gl-scale round gl-unscale ; inline

: fix-coordinates ( point1 point2 -- x1 y1 x2 y2 )
    [ first2 [ gl-scale >fixnum ] bi@ ] bi@ ;

: gl-set-clip ( loc dim -- )
    fix-coordinates glScissor ;

: gl-viewport ( loc dim -- )
    fix-coordinates glViewport ;

: init-matrices ( -- )
    ! Leaves with matrix mode GL_MODELVIEW
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity ;

STARTUP-HOOK: [ f gl-scale-factor set-global ]
