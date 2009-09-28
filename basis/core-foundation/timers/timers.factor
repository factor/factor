! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax system math kernel calendar
core-foundation core-foundation.time ;
IN: core-foundation.timers

TYPEDEF: void* CFRunLoopTimerRef
TYPEDEF: void* CFRunLoopTimerCallBack
TYPEDEF: void* CFRunLoopTimerContext

FUNCTION: CFRunLoopTimerRef CFRunLoopTimerCreate (
   CFAllocatorRef allocator,
   CFAbsoluteTime fireDate,
   CFTimeInterval interval,
   CFOptionFlags flags,
   CFIndex order,
   CFRunLoopTimerCallBack callout,
   CFRunLoopTimerContext* context
) ;

: <CFTimer> ( callback -- timer )
    [ f now >CFAbsoluteTime 60 0 0 ] dip f CFRunLoopTimerCreate ;

FUNCTION: void CFRunLoopTimerInvalidate (
   CFRunLoopTimerRef timer
) ;

FUNCTION: Boolean CFRunLoopTimerIsValid (
   CFRunLoopTimerRef timer
) ;

FUNCTION: void CFRunLoopTimerSetNextFireDate (
   CFRunLoopTimerRef timer,
   CFAbsoluteTime fireDate
) ;
