! Copyright (C) 2006, 2007 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
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
    [ -> alloc ] curry 2dip NSBackingStoreBuffered 1
    -> initWithContentRect:styleMask:backing:defer: ;

: class-for-style ( style -- NSWindow/NSPanel )
    0x1ef0 bitand zero? NSWindow NSPanel ? ;

: <ViewWindow> ( view rect style -- window )
    dup class-for-style <NSWindow> [ swap -> setContentView: ] keep
    dup dup -> contentView -> setInitialFirstResponder:
    dup 1 -> setAcceptsMouseMovedEvents:
    dup 0 -> setReleasedWhenClosed: ;

: window-content-rect ( window -- rect )
    dup -> class swap
    [ -> frame ] [ -> styleMask ] bi
    -> contentRectForFrameRect:styleMask: ;
