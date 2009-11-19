! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.syntax kernel math
namespaces sequences destructors combinators threads heaps
deques calendar core-foundation core-foundation.strings
core-foundation.file-descriptors core-foundation.timers
core-foundation.time ;
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
        [ run-loop fds>> push ]
        [ create-fd-source |CFRelease add-source-to-run-loop ]
        bi
    ] with-destructors ;

: add-timer-to-run-loop ( timer -- )
    [ run-loop timers>> push ]
    [
        CFRunLoopGetMain
        swap CFRunLoopDefaultMode
        CFRunLoopAddTimer
    ] bi ;

<PRIVATE

: ((reset-timer)) ( timer counter timestamp -- )
    nip >CFAbsoluteTime CFRunLoopTimerSetNextFireDate ;

: (reset-timer) ( timer counter -- )
    yield {
        { [ dup 0 = ] [ now ((reset-timer)) ] }
        { [ run-queue deque-empty? not ] [ 1 - (reset-timer) ] }
        { [ sleep-queue heap-empty? ] [ 5 minutes hence ((reset-timer)) ] }
        [ sleep-queue heap-peek nip micros>timestamp ((reset-timer)) ]
    } cond ;

: reset-timer ( timer -- )
    10 (reset-timer) ;

PRIVATE>

: reset-run-loop ( -- )
    run-loop
    [ timers>> [ reset-timer ] each ]
    [ fds>> [ enable-all-callbacks ] each ] bi ;

: timer-callback ( -- callback )
    void { CFRunLoopTimerRef void* } "cdecl"
    [ 2drop reset-run-loop yield ] alien-callback ;

: init-thread-timer ( -- )
    timer-callback <CFTimer> add-timer-to-run-loop ;

: run-one-iteration ( nanos -- handled? )
    reset-run-loop
    CFRunLoopDefaultMode
    swap [ nanoseconds ] [ 5 minutes ] if* >CFTimeInterval
    t CFRunLoopRunInMode kCFRunLoopRunHandledSource = ;
