! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc-FactorWindowDelegate
DEFER: FactorWindowDelegate

IN: cocoa
USING: gadgets-layouts kernel math objc objc-NSObject
objc-NSView objc-NSWindow sequences ;

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

: <ViewWindow> ( view title -- window )
    over [bounds] <NSWindow>
    [ swap [setContentView:] ] keep
    dup dup [contentView] [setInitialFirstResponder:]
    dup 1 [setAcceptsMouseMovedEvents:]
    dup f [makeKeyAndOrderFront:] ;

: window-root-gadget-pref-dim  [contentView] view pref-dim ;

: frame-rect-for-window-content-rect ( window rect -- rect )
    swap [styleMask] NSWindow -rot
    [frameRectForContentRect:styleMask:] ;

: content-rect-for-window-frame-rect ( window rect -- rect )
    swap [styleMask] NSWindow -rot
    [contentRectForFrameRect:styleMask:] ;

: window-content-rect ( window -- rect )
    dup [frame] content-rect-for-window-frame-rect ;

"NSObject" "FactorWindowDelegate" {
    {
        "windowWillUseStandardFrame:defaultFrame:" "NSRect"
        { "id" "SEL" "id" "NSRect" }
        [
            drop 2nip
            dup window-content-rect NSRect-x-far-y
            pick window-root-gadget-pref-dim first2
            <far-y-NSRect>
            frame-rect-for-window-content-rect
        ]
    }
} { } define-objc-class

: install-window-delegate ( window -- )
    FactorWindowDelegate [alloc] [init] [setDelegate:] ;
