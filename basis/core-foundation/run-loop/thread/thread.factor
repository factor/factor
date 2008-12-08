! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: calendar core-foundation.run-loop init kernel threads ;
IN: core-foundation.run-loop.thread

! Load this vocabulary if you need a run loop running.

: run-loop-thread ( -- )
    CFRunLoopDefaultMode 0 f CFRunLoopRunInMode
    kCFRunLoopRunHandledSource = [ 1 seconds sleep ] unless
    run-loop-thread ;

: start-run-loop-thread ( -- )
    [ run-loop-thread t ] "CFRunLoop dispatcher" spawn-server drop ;

[ start-run-loop-thread ] "core-foundation.run-loop.thread" add-init-hook
