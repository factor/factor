! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.classes kernel math ;
IN: cocoa.windows

! Window styles
CONSTANT: NSBorderlessWindowMask           0
CONSTANT: NSTitledWindowMask               1
CONSTANT: NSClosableWindowMask             2
CONSTANT: NSMiniaturizableWindowMask       4
CONSTANT: NSResizableWindowMask            8
CONSTANT: NSTexturedBackgroundWindowMask 256

! Additional panel-only styles
CONSTANT: NSUtilityWindowMask       16
CONSTANT: NSDocModalWindowMask      64
CONSTANT: NSNonactivatingPanelMask 128
CONSTANT: NSHUDWindowMask    0x1000

CONSTANT: NSBackingStoreRetained    0
CONSTANT: NSBackingStoreNonretained 1
CONSTANT: NSBackingStoreBuffered    2

: <NSWindow> ( rect style class -- window )
    [ send\ alloc ] curry 2dip NSBackingStoreBuffered 1
    send\ initWithContentRect:styleMask:backing:defer: ;

: class-for-style ( style -- NSWindow/NSPanel )
    0x1ef0 bitand zero? NSWindow NSPanel ? ;

: <ViewWindow> ( view rect style -- window )
    dup class-for-style <NSWindow> [ swap send\ setContentView: ] keep
    dup dup send\ contentView send\ setInitialFirstResponder:
    dup 1 send\ setAcceptsMouseMovedEvents:
    dup 0 send\ setReleasedWhenClosed: ;

: window-content-rect ( window -- rect )
    dup send\ class swap
    [ send\ frame ] [ send\ styleMask ] bi
    send\ contentRectForFrameRect:styleMask: ;
