! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: alien errors gadgets io kernel namespaces objc
objc-NSApplication objc-NSAutoreleasePool objc-NSException
objc-NSNotificationCenter objc-NSObject objc-NSView threads ;

: with-autorelease-pool ( quot -- )
    NSAutoreleasePool [new] slip [release] ; inline

: with-cocoa ( quot -- )
    [
        NSApplication [sharedApplication] drop call
    ] with-autorelease-pool ;

: <NSString> <CFString> [autorelease] ;

: CFRunLoopDefaultMode "kCFRunLoopDefaultMode" <NSString> ;

: next-event ( app -- event )
    0 f CFRunLoopDefaultMode 1
    [nextEventMatchingMask:untilDate:inMode:dequeue:] ;

: do-events ( app -- )
    dup next-event
    [ dupd [sendEvent:] do-events ] [ drop ] if* ;

: event-loop ( -- )
    [
        NSApplication [sharedApplication] do-events world-step
    ] with-autorelease-pool 10 sleep event-loop ;

: add-observer ( observer selector name object -- )
    >r >r >r >r NSNotificationCenter [defaultCenter] r> r>
    sel_registerName r> r> [addObserver:selector:name:object:] ;

IN: errors

: objc-error. ( alien -- )
    "Objective C exception:" print  [reason] CF>string print ;
