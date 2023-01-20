! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax calendar.unix core-foundation
core-foundation.time ;
IN: core-foundation.timers

TYPEDEF: void* CFRunLoopTimerRef

CALLBACK: void CFRunLoopTimerCallBack (
   CFRunLoopTimerRef timer,
   void *info
)

TYPEDEF: void* CFRunLoopTimerContext

FUNCTION: CFRunLoopTimerRef CFRunLoopTimerCreate (
   CFAllocatorRef allocator,
   CFAbsoluteTime fireDate,
   CFTimeInterval interval,
   CFOptionFlags flags,
   CFIndex order,
   CFRunLoopTimerCallBack callout,
   CFRunLoopTimerContext* context
)

:: <CFTimer> ( interval callback -- timer )
    f system-micros >CFAbsoluteTime interval 0 0 callback f
    CFRunLoopTimerCreate ;

FUNCTION: void CFRunLoopTimerInvalidate (
   CFRunLoopTimerRef timer
)

FUNCTION: Boolean CFRunLoopTimerIsValid (
   CFRunLoopTimerRef timer
)

FUNCTION: void CFRunLoopTimerSetNextFireDate (
   CFRunLoopTimerRef timer,
   CFAbsoluteTime fireDate
)

FUNCTION: Boolean CFRunLoopTimerDoesRepeat (
   CFRunLoopTimerRef timer
)

FUNCTION: CFTimeInterval CFRunLoopTimerGetInterval (
   CFRunLoopTimerRef timer
)

FUNCTION: CFAbsoluteTime CFRunLoopTimerGetNextFireDate (
   CFRunLoopTimerRef timer
)
