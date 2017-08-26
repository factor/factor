! Copyright (C) 2006, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax cocoa cocoa.classes
cocoa.runtime core-foundation.strings kernel sequences ;
IN: cocoa.application

: <NSString> ( str -- alien ) <CFString> send\ autorelease ;

CONSTANT: NSApplicationDelegateReplySuccess 0
CONSTANT: NSApplicationDelegateReplyCancel  1
CONSTANT: NSApplicationDelegateReplyFailure 2

: with-autorelease-pool ( quot -- )
    NSAutoreleasePool send\ new [ call ] [ send\ release ] bi* ; inline

: NSApp ( -- app ) NSApplication send\ sharedApplication ;

CONSTANT: NSAnyEventMask 0xffffffff

FUNCTION: void NSBeep ( )

: with-cocoa ( quot -- )
    [ NSApp drop call ] with-autorelease-pool ; inline

: add-observer ( observer selector name object -- )
    [
        [ NSNotificationCenter send\ defaultCenter ] 2dip
        sel_registerName
    ] 2dip send\ addObserver:selector:name:object: ;

: remove-observer ( observer -- )
    [ NSNotificationCenter send\ defaultCenter ] dip
    send\ removeObserver: ;

: cocoa-app ( quot -- )
    [ call NSApp send\ run ] with-cocoa ; inline

: install-delegate ( receiver delegate -- )
    send\ alloc send\ init send\ setDelegate: ;

: running.app? ( -- ? )
    ! Test if we're running a .app.
    ".app"
    NSBundle send\ mainBundle send\ bundlePath CF>string
    subseq? ;

: assert.app ( message -- )
    running.app? [
        drop
    ] [
        "The " " requires you to run Factor from an application bundle."
        surround throw
    ] if ;
