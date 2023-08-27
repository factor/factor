! Copyright (C) 2006, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax cocoa cocoa.classes
cocoa.runtime core-foundation.strings kernel sequences ;
IN: cocoa.application

: <NSString> ( str -- alien ) <CFString> -> autorelease ;

CONSTANT: NSApplicationDelegateReplySuccess 0
CONSTANT: NSApplicationDelegateReplyCancel  1
CONSTANT: NSApplicationDelegateReplyFailure 2

: with-autorelease-pool ( quot -- )
    NSAutoreleasePool -> new [ call ] [ -> release ] bi* ; inline

: NSApp ( -- app ) NSApplication -> sharedApplication ;

CONSTANT: NSAnyEventMask 0xffffffff

FUNCTION: void NSBeep ( )

: with-cocoa ( quot -- )
    [ NSApp drop call ] with-autorelease-pool ; inline

: add-observer ( observer selector name object -- )
    [
        [ NSNotificationCenter -> defaultCenter ] 2dip
        sel_registerName
    ] 2dip -> addObserver:selector:name:object: ;

: remove-observer ( observer -- )
    [ NSNotificationCenter -> defaultCenter ] dip
    -> removeObserver: ;

: cocoa-app ( quot -- )
    [ call NSApp -> run ] with-cocoa ; inline

: install-delegate ( receiver delegate -- )
    -> alloc -> init -> setDelegate: ;

: running.app? ( -- ? )
    ! Test if we're running a .app.
    NSBundle -> mainBundle -> bundlePath CF>string
    ".app" subseq-of? ;

: assert.app ( message -- )
    running.app? [
        drop
    ] [
        "The " " requires you to run Factor from an application bundle."
        surround throw
    ] if ;
