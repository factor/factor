! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel threads init namespaces alien
core-foundation calendar ;
IN: core-foundation.run-loop

: kCFRunLoopRunFinished 1 ; inline
: kCFRunLoopRunStopped 2 ; inline
: kCFRunLoopRunTimedOut 3 ; inline
: kCFRunLoopRunHandledSource 4 ; inline

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

: CFRunLoopDefaultMode ( -- alien )
    #! Ugly, but we don't have static NSStrings
    \ CFRunLoopDefaultMode get-global dup expired? [
        drop
        "kCFRunLoopDefaultMode" <CFString>
        dup \ CFRunLoopDefaultMode set-global
    ] when ;

: run-loop-thread ( -- )
    CFRunLoopDefaultMode 0 f CFRunLoopRunInMode
    kCFRunLoopRunHandledSource = [ 1 seconds sleep ] unless
    run-loop-thread ;

: start-run-loop-thread ( -- )
    [ run-loop-thread t ] "CFRunLoop dispatcher" spawn-server drop ;
