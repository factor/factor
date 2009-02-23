! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math cocoa cocoa.messages cocoa.classes
sequences math.bitwise ;
IN: cocoa.windows

CONSTANT: NSBorderlessWindowMask     0
CONSTANT: NSTitledWindowMask         1
CONSTANT: NSClosableWindowMask       2
CONSTANT: NSMiniaturizableWindowMask 4
CONSTANT: NSResizableWindowMask      8

CONSTANT: NSBackingStoreRetained    0
CONSTANT: NSBackingStoreNonretained 1
CONSTANT: NSBackingStoreBuffered    2

: standard-window-type ( -- n )
    {
        NSTitledWindowMask
        NSClosableWindowMask
        NSMiniaturizableWindowMask
        NSResizableWindowMask
    } flags ; inline

: <NSWindow> ( rect -- window )
    NSWindow -> alloc swap
    standard-window-type NSBackingStoreBuffered 1
    -> initWithContentRect:styleMask:backing:defer: ;

: <ViewWindow> ( view rect -- window )
    <NSWindow> [ swap -> setContentView: ] keep
    dup dup -> contentView -> setInitialFirstResponder:
    dup 1 -> setAcceptsMouseMovedEvents:
    dup 0 -> setReleasedWhenClosed: ;

: window-content-rect ( window -- rect )
    [ NSWindow ] dip
    [ -> frame ] [ -> styleMask ] bi
    -> contentRectForFrameRect:styleMask: ;
