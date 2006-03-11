IN: cocoa-opengl
USING: alien cocoa compiler io kernel math objc objc-NSObject
objc-NSOpenGLView objc-NSWindow parser sequences threads ;

{
    { "drawRect:" "void" { "int" "int" "int" "int" } [ drop ] }
} { }
"NSOpenGLView" "FactorView" define-objc-class
"FactorView" import-objc-class

: <NSOpenGLView>
    NSOpenGLView [alloc]
    0 0 100 100 <NSRect> NSOpenGLView [defaultPixelFormat]
    [initWithFrame:pixelFormat:] ;

"OpenGL demo" 10 10 600 600 <NSRect> <NSWindow>
dup

<NSOpenGLView>

[setContentView:]

dup f [makeKeyAndOrderFront:]

event-loop
