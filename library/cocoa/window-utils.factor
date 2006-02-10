! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: kernel math objc-NSObject objc-NSWindow ;

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

: <NSWindow> ( title rect -- window )
    NSWindow [alloc] swap
    standard-window-type NSBackingStoreBuffered 1
    [initWithContentRect:styleMask:backing:defer:]
    [ swap <NSString> [setTitle:] ] keep ;
