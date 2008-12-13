! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: specialized-arrays.int arrays kernel math namespaces make
cocoa cocoa.messages cocoa.classes cocoa.types sequences
continuations accessors ;
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
: NSOpenGLPFAColorFloat  58 ;
: NSOpenGLPFAMultisample 59 ;
: NSOpenGLPFASupersample 60 ;
: NSOpenGLPFASampleAlpha 61 ;
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
: NSOpenGLPFAAllowOfflineRenderers 96 ;
: NSOpenGLPFAVirtualScreenCount 128 ;

: kCGLRendererGenericFloatID HEX: 00020400 ;

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
    ] int-array{ } make underlying>>
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

: NSOpenGLCPSwapInterval 222 ;

LIBRARY: OpenGL

TYPEDEF: int CGLError
TYPEDEF: void* CGLContextObj
TYPEDEF: int CGLContextParameter

FUNCTION: CGLError CGLSetParameter ( CGLContextObj ctx, CGLContextParameter pname, GLint* params ) ;

