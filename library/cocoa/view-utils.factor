! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: arrays kernel objc-NSOpenGLContext objc-NSView opengl ;

: with-gl-context ( context quot -- )
    swap
    [ [makeCurrentContext] call glFlush ] keep
    [flushBuffer] ; inline

: view-dim [bounds] dup NSRect-w swap NSRect-h 0 3array ;

: NSViewFrameDidChangeNotification
    "NSViewFrameDidChangeNotification" <NSString> ;

: add-resize-observer ( view selector -- )
    NSViewFrameDidChangeNotification pick add-observer ;
