! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc-classes
DEFER: FactorWindowDelegate

IN: cocoa
USING: arrays gadgets kernel math objc sequences ;

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

: <ViewWindow> ( view bounds -- window )
    <NSWindow> [ swap -> setContentView: ] keep
    dup dup -> contentView -> setInitialFirstResponder:
    dup 1 -> setAcceptsMouseMovedEvents: ;

: window-pref-dim -> contentView window pref-dim ;

: frame-content-rect ( window rect -- rect )
    swap -> styleMask NSWindow -rot
    -> frameRectForContentRect:styleMask: ;

: window-content-rect ( window -- rect )
    NSWindow over -> frame rot -> styleMask
    -> contentRectForFrameRect:styleMask: ;

"NSObject" "FactorWindowDelegate" {
    ! {
    !     "windowWillUseStandardFrame:defaultFrame:" "NSRect"
    !     { "id" "SEL" "id" "NSRect" }
    !     [
    !         drop 2nip
    !         dup window-content-rect NSRect-x-far-y
    !         pick window-pref-dim first2 <far-y-NSRect>
    !         frame-content-rect
    !     ]
    ! }

    {
        "windowDidMove:" "void" { "id" "SEL" "id" } [
            2nip -> object
            dup window-content-rect NSRect-x-y 2array
            swap -> contentView window set-world-loc
        ]
    }

    {
        "windowDidBecomeKey:" "void" { "id" "SEL" "id" } [
            2nip -> object -> contentView window focus-world
        ]
    }

    {
        "windowDidResignKey:" "void" { "id" "SEL" "id" } [
            2nip -> object -> contentView window unfocus-world
        ]
    }
} { } define-objc-class

: install-window-delegate ( window -- )
    FactorWindowDelegate install-delegate ;
