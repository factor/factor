! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: arrays kernel objc-NSObject objc-NSOpenGLContext
objc-NSOpenGLView objc-NSView opengl sequences ;

: <GLView> ( class dim -- view )
    >r [alloc] 0 0 r> first2 <NSRect>
    NSOpenGLView [defaultPixelFormat]
    [initWithFrame:pixelFormat:] [autorelease]
    dup 1 [setPostsBoundsChangedNotifications:]
    dup 1 [setPostsFrameChangedNotifications:] ;

: with-gl-context ( context quot -- )
    swap
    [ [makeCurrentContext] call glFlush ] keep
    [flushBuffer] ; inline

: with-gl-view ( view quot -- | quot: view -- )
    >r dup [openGLContext] r> with-gl-context ; inline

: view-dim [bounds] dup NSRect-w swap NSRect-h 0 3array ;

: NSViewFrameDidChangeNotification
    "NSViewFrameDidChangeNotification" <NSString> ;

: add-resize-observer ( view selector -- )
    NSViewFrameDidChangeNotification pick add-observer ;
