! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: alien errors gadgets io kernel namespaces
objc-NSApplication objc-NSAutoreleasePool objc-NSException
objc-NSObject objc-NSView threads ;

: with-autorelease-pool ( quot -- )
    NSAutoreleasePool [new] slip [release] ; inline

: with-cocoa ( quot -- )
    [
        NSApplication [sharedApplication] drop
        call
    ] with-autorelease-pool ; inline

: <NSString> <CFString> [autorelease] ;

: CFRunLoopDefaultMode "kCFRunLoopDefaultMode" <NSString> ;

: next-event ( app -- event )
    0 f CFRunLoopDefaultMode 1
    [nextEventMatchingMask:untilDate:inMode:dequeue:] ;

: do-events ( app -- )
    dup next-event [ dupd [sendEvent:] do-events ] [ drop ] if* ;

: (event-loop) ( -- )
    [
        NSApplication [sharedApplication] do-events world-step
    ] with-autorelease-pool 10 sleep (event-loop) ;

: event-loop ( -- )
    \ NSApplication get expired? [
        NSApplication [sharedApplication]
        \ NSApplication set-global
        [ (event-loop) ] in-thread
    ] when ;

IN: errors

: objc-error. ( alien -- )
    "Objective C exception:" print  [reason] CF>string print ;

IN: gadgets

: redraw-world ( gadgets -- )
    world-handle 1 [setNeedsDisplay:] ;
