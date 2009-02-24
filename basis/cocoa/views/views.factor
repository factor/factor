! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: specialized-arrays.int arrays kernel math namespaces make
cocoa cocoa.messages cocoa.classes cocoa.types sequences
continuations accessors ;
IN: cocoa.views

CONSTANT: NSOpenGLPFAAllRenderers 1
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
CONSTANT: NSOpenGLPFAVirtualScreenCount 128

CONSTANT: kCGLRendererGenericFloatID HEX: 00020400

<PRIVATE

SYMBOL: +software-renderer+
SYMBOL: +multisample+

PRIVATE>

: with-software-renderer ( quot -- )
    t +software-renderer+ pick with-variable ; inline
: with-multisample ( quot -- )
    t +multisample+ pick with-variable ; inline

: <PixelFormat> ( attributes -- pixelfmt )
    NSOpenGLPixelFormat -> alloc swap [
        %
        NSOpenGLPFADepthSize , 16 ,
        +software-renderer+ get [
            NSOpenGLPFARendererID , kCGLRendererGenericFloatID ,
        ] when
        +multisample+ get [
            NSOpenGLPFASupersample ,
            NSOpenGLPFASampleBuffers , 1 ,
            NSOpenGLPFASamples , 8 ,
        ] when
        0 ,
    ] int-array{ } make
    -> initWithAttributes:
    -> autorelease ;

: <GLView> ( class dim -- view )
    [ -> alloc 0 0 ] dip first2 <NSRect>
    NSOpenGLPFAWindow NSOpenGLPFADoubleBuffer 2array <PixelFormat>
    -> initWithFrame:pixelFormat:
    dup 1 -> setPostsBoundsChangedNotifications:
    dup 1 -> setPostsFrameChangedNotifications: ;

: view-dim ( view -- dim )
    -> bounds
    dup NSRect-w >fixnum
    swap NSRect-h >fixnum 2array ;

: mouse-location ( view event -- loc )
    [
        -> locationInWindow f -> convertPoint:fromView:
        [ NSPoint-x ] [ NSPoint-y ] bi
    ] [ drop -> frame NSRect-h ] 2bi
    swap - 2array ;

USE: opengl.gl
USE: alien.syntax

CONSTANT: NSOpenGLCPSwapInterval 222

LIBRARY: OpenGL

TYPEDEF: int CGLError
TYPEDEF: void* CGLContextObj
TYPEDEF: int CGLContextParameter

FUNCTION: CGLError CGLSetParameter ( CGLContextObj ctx, CGLContextParameter pname, GLint* params ) ;

