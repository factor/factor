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

! --- GL3 Mode Hooks ---
! These hooks allow GL3 backends to override rendering behavior
SYMBOL: gl-color-hook
SYMBOL: gl-fill-rect-hook
SYMBOL: gl-rect-hook
SYMBOL: gl-line-hook
SYMBOL: gl-translate-hook
SYMBOL: with-translation-hook
SYMBOL: gl-scale-2d-hook
SYMBOL: gl-rectf-hook
SYMBOL: with-matrix-hook
SYMBOL: gl-draw-lines-hook

: gl-color ( color -- )
    gl-color-hook get-global
    [ call( color -- ) ] [ >rgba-components glColor4d ] if* ; inline

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
    os macos? [
        ! This is kind of terrible, but we are having
        ! problems on macOS 10.11 where the
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

: with-matrix ( quot -- )
    with-matrix-hook get-global
    [ call( quot -- ) ] [ do-matrix ] if* ; inline

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

: gl-line-legacy ( a b -- )
    line-vertices GL_LINES 0 2 glDrawArrays ;

: gl-line ( a b -- )
    gl-line-hook get-global
    [ call( a b -- ) ] [ gl-line-legacy ] if* ;

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

: gl-rect-legacy ( loc dim -- )
    rect-vertices (gl-rect) ;

: gl-rect ( loc dim -- )
    gl-rect-hook get-global
    [ call( loc dim -- ) ] [ gl-rect-legacy ] if* ;

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

: gl-fill-rect-legacy ( loc dim -- )
    fill-rect-vertices (gl-fill-rect) ;

: gl-fill-rect ( loc dim -- )
    gl-fill-rect-hook get-global
    [ call( loc dim -- ) ] [ gl-fill-rect-legacy ] if* ;

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

: gl-translate-legacy ( point -- ) first2 0.0 glTranslated ;

: gl-translate ( point -- )
    gl-translate-hook get-global
    [ call( point -- ) ] [ gl-translate-legacy ] if* ;

: delete-dlist ( id -- ) 1 glDeleteLists ;

: with-translation-legacy ( loc quot -- )
    [ [ gl-translate ] dip call ] do-matrix ; inline

: with-translation ( loc quot -- )
    with-translation-hook get-global
    [ call( loc quot -- ) ] [ with-translation-legacy ] if* ; inline

: gl-scale-2d-legacy ( sx sy -- ) 1.0 glScalef ;

: gl-scale-2d ( sx sy -- )
    gl-scale-2d-hook get-global
    [ call( sx sy -- ) ] [ gl-scale-2d-legacy ] if* ; inline

: gl-rectf-legacy ( x1 y1 x2 y2 -- ) glRectf ;

: gl-rectf ( x1 y1 x2 y2 -- )
    gl-rectf-hook get-global
    [ call( x1 y1 x2 y2 -- ) ] [ gl-rectf-legacy ] if* ; inline

: gl-draw-lines-legacy ( vertices n -- )
    [ gl-vertex-pointer GL_LINES 0 ] dip glDrawArrays ;

: gl-draw-lines ( vertices n -- )
    gl-draw-lines-hook get-global
    [ call( vertices n -- ) ] [ gl-draw-lines-legacy ] if* ; inline

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
