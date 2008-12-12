! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax ;
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

FUNCTION: void CFRunLoopTimerInvalidate (
   CFRunLoopTimerRef timer
);

FUNCTION: void CFRunLoopTimerSetNextFireDate (
   CFRunLoopTimerRef timer,
   CFAbsoluteTime fireDate
) ;
