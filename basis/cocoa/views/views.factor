! Copyright (C) 2006, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays cocoa core-graphics.types kernel math
sequences ;
IN: cocoa.views

CONSTANT: NSOpenGLPFAAllRenderers 1
CONSTANT: NSOpenGLPFATripleBuffer 3
CONSTANT: NSOpenGLPFADoubleBuffer 5
CONSTANT: NSOpenGLPFAStereo 6
CONSTANT: NSOpenGLPFAAuxBuffers 7
CONSTANT: NSOpenGLPFAColorSize 8
CONSTANT: NSOpenGLPFAAlphaSize 11
CONSTANT: NSOpenGLPFADepthSize 12
CONSTANT: NSOpenGLPFAStencilSize 13
CONSTANT: NSOpenGLPFAAccumSize 14
CONSTANT: NSOpenGLPFAMinimumPolicy 51
CONSTANT: NSOpenGLPFAMaximumPolicy 52
CONSTANT: NSOpenGLPFAOffScreen 53
CONSTANT: NSOpenGLPFAFullScreen 54
CONSTANT: NSOpenGLPFASampleBuffers 55
CONSTANT: NSOpenGLPFASamples 56
CONSTANT: NSOpenGLPFAAuxDepthStencil 57
CONSTANT: NSOpenGLPFAColorFloat  58
CONSTANT: NSOpenGLPFAMultisample 59
CONSTANT: NSOpenGLPFASupersample 60
CONSTANT: NSOpenGLPFASampleAlpha 61
CONSTANT: NSOpenGLPFARendererID 70
CONSTANT: NSOpenGLPFASingleRenderer 71
CONSTANT: NSOpenGLPFANoRecovery 72
CONSTANT: NSOpenGLPFAAccelerated 73
CONSTANT: NSOpenGLPFAClosestPolicy 74
CONSTANT: NSOpenGLPFARobust 75
CONSTANT: NSOpenGLPFABackingStore 76
CONSTANT: NSOpenGLPFAMPSafe 78
CONSTANT: NSOpenGLPFAWindow 80
CONSTANT: NSOpenGLPFAMultiScreen 81
CONSTANT: NSOpenGLPFACompliant 83
CONSTANT: NSOpenGLPFAScreenMask 84
CONSTANT: NSOpenGLPFAPixelBuffer 90
CONSTANT: NSOpenGLPFAAllowOfflineRenderers 96
CONSTANT: NSOpenGLPFAAcceleratedCompute 97
CONSTANT: NSOpenGLPFAOpenGLProfile 99
CONSTANT: NSOpenGLPFAVirtualScreenCount 128

CONSTANT: NSOpenGLCPSwapInterval 222
CONSTANT: NSOpenGLCPSurfaceOrder 235
CONSTANT: NSOpenGLCPSurfaceOpacity 236
CONSTANT: NSOpenGLCPSurfaceBackingSize 304
CONSTANT: NSOpenGLCPReclaimResources 308
CONSTANT: NSOpenGLCPCurrentRendererID 309
CONSTANT: NSOpenGLCPGPUVertexProcessing 310
CONSTANT: NSOpenGLCPGPUFragmentProcessing 311
CONSTANT: NSOpenGLCPHasDrawable 314
CONSTANT: NSOpenGLCPMPSwapsInFlight 315

CONSTANT: NSOpenGLProfileVersionLegacy 0x1000
CONSTANT: NSOpenGLProfileVersion3_2Core 0x3200
CONSTANT: NSOpenGLProfileVersion4_1Core 0x4100

: <GLView> ( class dim pixel-format -- view )
    [ -> alloc ]
    [ [ 0 0 ] dip first2 <CGRect> ]
    [ handle>> ] tri*
    -> initWithFrame:pixelFormat:
    dup 1 -> setPostsBoundsChangedNotifications:
    dup 1 -> setPostsFrameChangedNotifications: ;

: view-dim ( view -- dim )
    -> bounds
    [ CGRect-w >fixnum ] [ CGRect-h >fixnum ] bi
    2array ;

: mouse-location ( view event -- loc )
    [
        -> locationInWindow f -> convertPoint:fromView:
        [ x>> ] [ y>> ] bi
    ] [ drop -> frame CGRect-h ] 2bi
    swap - [ >integer ] bi@ 2array ;
