IN: cocoa-opengl
USING: alien cocoa compiler io kernel math namespaces objc
objc-NSObject objc-NSOpenGLContext objc-NSOpenGLView
objc-NSWindow opengl parser sequences threads ;

: with-gl-context ( context quot -- )
    swap
    [ [makeCurrentContext] call glFlush ] keep
    [flushBuffer] ; inline

: gl-init ( glwin -- )
    GL_SMOOTH glShadeModel
    0 0 0 0 glClearColor
    1 glClearDepth
    GL_DEPTH_TEST glEnable
    GL_LEQUAL glDepthFunc
    GL_PERSPECTIVE_CORRECTION_HINT GL_NICEST glHint
    0 0 600 600 glViewport
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    45 1 0.1 100 gluPerspective
    GL_MODELVIEW glMatrixMode
    glFlush ;

: draw-view ( view -- )
    [openGLContext] dup [
        gl-init
        GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
        0 1 0 1 glColor4d
        glLoadIdentity
        -1.5 0 -6 glTranslatef
        GL_TRIANGLES [
            0 1 0 glVertex3f
            -1 -1 0 glVertex3f
            1 -1 0 glVertex3f
        ] do-state
        3 0 0 glTranslatef
        GL_QUADS [
            -1 1 1 glVertex3f
            1 1 0 glVertex3f
            1 -1 0 glVertex3f
            -1 -1 0 glVertex3f
        ] do-state
    ] with-gl-context ;

: init-FactorView-class
    {
        {
            "drawRect:" "void" { "id" "SEL" "NSRect" } [
                2drop draw-view
            ]
        }
    } { } "NSOpenGLView" "FactorView" define-objc-class drop
    "FactorView" import-objc-class ; parsing

init-FactorView-class

USE: objc-FactorView

: <FactorView>
    FactorView [alloc]
    0 0 100 100 <NSRect> NSOpenGLView [defaultPixelFormat]
    [initWithFrame:pixelFormat:] ;

"OpenGL demo" 10 10 600 600 <NSRect> <NSWindow>
dup

<FactorView>

[setContentView:]

f [makeKeyAndOrderFront:]

event-loop
