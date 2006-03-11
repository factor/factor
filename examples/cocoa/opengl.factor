IN: cocoa-opengl
USING: alien cocoa compiler io kernel math objc objc-NSObject objc-NSOpenGLView objc-NSWindow parser sequences
threads ;

: init-FactorView-class
    {
        {
            "drawRect:" "void" { "NSRect" }
            [ 3drop "drawRect: called" print ]
        }
    } { } "NSOpenGLView" "FactorView" define-objc-class drop
    "FactorView" import-objc-class ; parsing

init-FactorView-class

USE: objc-FactorView

: <FactorView>
    NSOpenGLView [alloc]
    0 0 100 100 <NSRect> NSOpenGLView [defaultPixelFormat]
    [initWithFrame:pixelFormat:] ;

"OpenGL demo" 10 10 600 600 <NSRect> <NSWindow>
dup

<FactorView>

[setContentView:]

f [makeKeyAndOrderFront:]

event-loop
