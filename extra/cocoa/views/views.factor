! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types arrays kernel math namespaces cocoa
cocoa.messages cocoa.classes cocoa.types sequences ;
IN: cocoa.views

: NSOpenGLPFAAllRenderers 1 ;
: NSOpenGLPFADoubleBuffer 5 ;
: NSOpenGLPFAStereo 6 ;
: NSOpenGLPFAAuxBuffers 7 ;
: NSOpenGLPFAColorSize 8 ;
: NSOpenGLPFAAlphaSize 11 ;
: NSOpenGLPFADepthSize 12 ;
: NSOpenGLPFAStencilSize 13 ;
: NSOpenGLPFAAccumSize 14 ;
: NSOpenGLPFAMinimumPolicy 51 ;
: NSOpenGLPFAMaximumPolicy 52 ;
: NSOpenGLPFAOffScreen 53 ;
: NSOpenGLPFAFullScreen 54 ;
: NSOpenGLPFASampleBuffers 55 ;
: NSOpenGLPFASamples 56 ;
: NSOpenGLPFAAuxDepthStencil 57 ;
: NSOpenGLPFARendererID 70 ;
: NSOpenGLPFASingleRenderer 71 ;
: NSOpenGLPFANoRecovery 72 ;
: NSOpenGLPFAAccelerated 73 ;
: NSOpenGLPFAClosestPolicy 74 ;
: NSOpenGLPFARobust 75 ;
: NSOpenGLPFABackingStore 76 ;
: NSOpenGLPFAMPSafe 78 ;
: NSOpenGLPFAWindow 80 ;
: NSOpenGLPFAMultiScreen 81 ;
: NSOpenGLPFACompliant 83 ;
: NSOpenGLPFAScreenMask 84 ;
: NSOpenGLPFAPixelBuffer 90 ;
: NSOpenGLPFAVirtualScreenCount 128 ;

: <PixelFormat> ( -- pixelfmt )
    NSOpenGLPixelFormat -> alloc [
        NSOpenGLPFAWindow ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFADepthSize , 16 ,
        0 ,
    ] { } make >c-int-array
    -> initWithAttributes:
    -> autorelease ;

: <GLView> ( class dim -- view )
    >r -> alloc 0 0 r> first2 <NSRect> <PixelFormat>
    -> initWithFrame:pixelFormat:
    dup 1 -> setPostsBoundsChangedNotifications:
    dup 1 -> setPostsFrameChangedNotifications: ;

: view-dim ( view -- dim )
    -> bounds
    dup NSRect-w >fixnum
    swap NSRect-h >fixnum 2array ;

: mouse-location ( view event -- loc )
    over >r
    -> locationInWindow f -> convertPoint:fromView:
    dup NSPoint-x swap NSPoint-y
    r> -> frame NSRect-h swap - 2array ;
