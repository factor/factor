! Copyright (C) 2008, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.syntax
core-foundation core-foundation.file-descriptors
core-foundation.strings core-foundation.time
core-foundation.timers destructors init kernel math namespaces
sequences threads ;
FROM: calendar.unix => system-micros ;
IN: core-foundation.run-loop

CONSTANT: kCFRunLoopRunFinished 1
CONSTANT: kCFRunLoopRunStopped 2
CONSTANT: kCFRunLoopRunTimedOut 3
CONSTANT: kCFRunLoopRunHandledSource 4

TYPEDEF: void* CFRunLoopRef
TYPEDEF: void* CFRunLoopSourceRef

FUNCTION: CFRunLoopRef CFRunLoopGetMain ( )
FUNCTION: CFRunLoopRef CFRunLoopGetCurrent ( )

FUNCTION: SInt32 CFRunLoopRunInMode (
    CFStringRef mode,
    CFTimeInterval seconds,
    Boolean returnAfterSourceHandled
)

FUNCTION: CFRunLoopSourceRef CFFileDescriptorCreateRunLoopSource (
    CFAllocatorRef allocator,
    CFFileDescriptorRef f,
    CFIndex order
)

FUNCTION: void CFRunLoopAddSource (
    CFRunLoopRef rl,
    CFRunLoopSourceRef source,
    CFStringRef mode
)

FUNCTION: void CFRunLoopRemoveSource (
    CFRunLoopRef rl,
    CFRunLoopSourceRef source,
    CFStringRef mode
)

FUNCTION: void CFRunLoopAddTimer (
    CFRunLoopRef rl,
    CFRunLoopTimerRef timer,
    CFStringRef mode
)

FUNCTION: void CFRunLoopRemoveTimer (
    CFRunLoopRef rl,
    CFRunLoopTimerRef timer,
    CFStringRef mode
)

CFSTRING: CFRunLoopDefaultMode "kCFRunLoopDefaultMode"

TUPLE: run-loop-state fds sources timers ;

SYMBOL: run-loop

: <run-loop> ( -- run-loop )
    V{ } clone V{ } clone V{ } clone \ run-loop-state boa ;

: get-run-loop ( -- run-loop )
    \ run-loop [ <run-loop> ] initialize-alien ;

: add-source-to-run-loop ( source -- )
    [ get-run-loop sources>> push ]
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
        [ get-run-loop fds>> push ]
        [ create-fd-source |CFRelease add-source-to-run-loop ]
        tri
    ] with-destructors ;

: add-timer-to-run-loop ( timer -- )
    [ get-run-loop timers>> push ]
    [
        CFRunLoopGetMain
        swap CFRunLoopDefaultMode
        CFRunLoopAddTimer
    ] bi ;

: invalidate-run-loop-timers ( -- )
    get-run-loop [
        [ [ CFRunLoopTimerInvalidate ] [ CFRelease ] bi ] each
        V{ } clone
    ] change-timers drop ;

SYMBOL: thread-timer

STARTUP-HOOK: [ f thread-timer set-global ]

: (reset-thread-timer) ( timer -- )
    sleep-time
    [ 1000 /f ] [ 1,000,000 ] if* system-micros +
    >CFAbsoluteTime CFRunLoopTimerSetNextFireDate ;

: reset-thread-timer ( -- )
    thread-timer get-global [ (reset-thread-timer) ] when* ;

: thread-timer-callback ( -- callback )
    [ drop (reset-thread-timer) yield ] CFRunLoopTimerCallBack ;

: init-thread-timer ( -- )
    60 thread-timer-callback <CFTimer>
    [ add-timer-to-run-loop ]
    [ thread-timer set-global ] bi ;

: run-one-iteration ( nanos -- handled? )
    CFRunLoopDefaultMode
    swap [ 1,000,000,000 /f ] [ 300 ] if*
    t CFRunLoopRunInMode kCFRunLoopRunHandledSource = ;
