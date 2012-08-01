! Copyright (C) 2008, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.syntax calendar
classes.struct combinators core-foundation
core-foundation.file-descriptors core-foundation.strings
core-foundation.time core-foundation.timers deques destructors
heaps kernel math namespaces sequences system threads unix
unix.time ;
FROM: calendar.unix => system-micros ;
IN: core-foundation.run-loop

CONSTANT: kCFRunLoopRunFinished 1
CONSTANT: kCFRunLoopRunStopped 2
CONSTANT: kCFRunLoopRunTimedOut 3
CONSTANT: kCFRunLoopRunHandledSource 4

TYPEDEF: void* CFRunLoopRef
TYPEDEF: void* CFRunLoopSourceRef

FUNCTION: CFRunLoopRef CFRunLoopGetMain ( ) ;
FUNCTION: CFRunLoopRef CFRunLoopGetCurrent ( ) ;

FUNCTION: SInt32 CFRunLoopRunInMode (
    CFStringRef mode,
    CFTimeInterval seconds,
    Boolean returnAfterSourceHandled
) ;

FUNCTION: CFRunLoopSourceRef CFFileDescriptorCreateRunLoopSource (
    CFAllocatorRef allocator,
    CFFileDescriptorRef f,
    CFIndex order
) ;

FUNCTION: void CFRunLoopAddSource (
    CFRunLoopRef rl,
    CFRunLoopSourceRef source,
    CFStringRef mode
) ;

FUNCTION: void CFRunLoopRemoveSource (
    CFRunLoopRef rl,
    CFRunLoopSourceRef source,
    CFStringRef mode
) ;

FUNCTION: void CFRunLoopAddTimer (
    CFRunLoopRef rl,
    CFRunLoopTimerRef timer,
    CFStringRef mode
) ;

FUNCTION: void CFRunLoopRemoveTimer (
    CFRunLoopRef rl,
    CFRunLoopTimerRef timer,
    CFStringRef mode
) ;

CFSTRING: CFRunLoopDefaultMode "kCFRunLoopDefaultMode"

TUPLE: run-loop fds sources timers ;

: <run-loop> ( -- run-loop )
    V{ } clone V{ } clone V{ } clone \ run-loop boa ;

: run-loop ( -- run-loop )
    \ run-loop [ <run-loop> ] initialize-alien ;

: add-source-to-run-loop ( source -- )
    [ run-loop sources>> push ]
    [
        CFRunLoopGetMain
        swap CFRunLoopDefaultMode
        CFRunLoopAddSource
    ] bi ;

: create-fd-source ( CFFileDescriptor -- source )
    f swap 0 CFFileDescriptorCreateRunLoopSource ;

: add-fd-to-run-loop ( fd callback -- )
    [
        <CFFileDescriptor> |CFRelease
        [ enable-all-callbacks ]
        [ run-loop fds>> push ]
        [ create-fd-source |CFRelease add-source-to-run-loop ]
        tri
    ] with-destructors ;

<PRIVATE

: (reset-timer) ( timer timestamp -- )
    >CFAbsoluteTime CFRunLoopTimerSetNextFireDate ;

: reset-timer ( timer -- )
    sleep-time
    [ 1000 /f ] [ 1,000,000 ] if* system-micros +
    (reset-timer) ;

PRIVATE>

: add-timer-to-run-loop ( timer -- )
    [ reset-timer ]
    [ run-loop timers>> push ]
    [
        CFRunLoopGetMain
        swap CFRunLoopDefaultMode
        CFRunLoopAddTimer
    ] tri ;

: invalidate-run-loop-timers ( -- )
    run-loop [
        [ [ CFRunLoopTimerInvalidate ] [ CFRelease ] bi ] each
        V{ } clone
    ] change-timers drop ;

: reset-run-loop ( -- )
    run-loop
    [ timers>> [ reset-timer ] each ]
    [ fds>> [ enable-all-callbacks ] each ] bi ;

: timer-callback ( -- callback )
    void { CFRunLoopTimerRef void* } cdecl
    [ drop reset-timer yield ] alien-callback ;

: init-thread-timer ( -- )
    60 timer-callback <CFTimer> add-timer-to-run-loop ;

: run-one-iteration ( nanos -- handled? )
    reset-run-loop
    CFRunLoopDefaultMode
    swap [ nanoseconds ] [ 5 minutes ] if* >CFTimeInterval
    t CFRunLoopRunInMode kCFRunLoopRunHandledSource = ;
