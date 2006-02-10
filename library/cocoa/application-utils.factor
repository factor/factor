! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: errors kernel objc-NSApplication objc-NSAutoreleasePool
objc-NSObject threads ;

: with-autorelease-pool ( quot -- )
    NSAutoreleasePool [new] [
        [ call ] keep
    ] [
        drop [release]
    ] cleanup ; inline

: <NSString> <CFString> [autorelease] ;

: next-event ( app -- )
    0 f "NSDefaultRunLoopMode" 1
    [nextEventMatchingMask:untilDate:inMode:dequeue:] ;

: do-events ( app -- )
    dup dup next-event [ [sendEvent:] do-events ] [ drop ] if* ;

: event-loop ( -- )
    [
        NSApplication [sharedApplication] do-events
    ] with-autorelease-pool 10 sleep event-loop ;
