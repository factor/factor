! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math cocoa cocoa.messages cocoa.classes
sequences ;
IN: cocoa.windows

: NSBorderlessWindowMask     0 ; inline
: NSTitledWindowMask         1 ; inline
: NSClosableWindowMask       2 ; inline
: NSMiniaturizableWindowMask 4 ; inline
: NSResizableWindowMask      8 ; inline

: NSBackingStoreRetained    0 ; inline
: NSBackingStoreNonretained 1 ; inline
: NSBackingStoreBuffered    2 ; inline

: standard-window-type
    NSTitledWindowMask
    NSClosableWindowMask bitor
    NSMiniaturizableWindowMask bitor
    NSResizableWindowMask bitor ; inline

: <NSWindow> ( rect -- window )
    NSWindow -> alloc swap
    standard-window-type NSBackingStoreBuffered 1
    -> initWithContentRect:styleMask:backing:defer: ;

: <ViewWindow> ( view rect -- window )
    <NSWindow> [ swap -> setContentView: ] keep
    dup dup -> contentView -> setInitialFirstResponder:
    dup 1 -> setAcceptsMouseMovedEvents: ;

: window-content-rect ( window -- rect )
    NSWindow over -> frame rot -> styleMask
    -> contentRectForFrameRect:styleMask: ;
