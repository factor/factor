! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.strings alien.syntax
kernel math sequences namespaces make assocs init accessors
continuations combinators io.encodings.utf8 destructors locals
arrays specialized-arrays classes.struct core-foundation
core-foundation.arrays core-foundation.run-loop
core-foundation.strings core-foundation.time unix.types ;
FROM: namespaces => change-global ;
IN: core-foundation.fsevents

SPECIALIZED-ARRAY: void*
SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: longlong

CONSTANT: kFSEventStreamCreateFlagUseCFTypes 2
CONSTANT: kFSEventStreamCreateFlagWatchRoot 4

CONSTANT: kFSEventStreamEventFlagMustScanSubDirs 1
CONSTANT: kFSEventStreamEventFlagUserDropped 2
CONSTANT: kFSEventStreamEventFlagKernelDropped 4
CONSTANT: kFSEventStreamEventFlagEventIdsWrapped 8
CONSTANT: kFSEventStreamEventFlagHistoryDone 16
CONSTANT: kFSEventStreamEventFlagRootChanged 32
CONSTANT: kFSEventStreamEventFlagMount 64
CONSTANT: kFSEventStreamEventFlagUnmount 128

TYPEDEF: int FSEventStreamCreateFlags
TYPEDEF: int FSEventStreamEventFlags
TYPEDEF: ulonglong FSEventStreamEventId
TYPEDEF: void* FSEventStreamRef

STRUCT: FSEventStreamContext
    { version CFIndex }
    { info void* }
    { retain void* }
    { release void* }
    { copyDescription void* } ;

CALLBACK: void FSEventStreamCallback ( FSEventStreamRef streamRef, void* clientCallBackInfo, size_t numEvents, void* eventPaths, FSEventStreamEventFlags* eventFlags, FSEventStreamEventId* eventIds ) ;

CONSTANT: FSEventStreamEventIdSinceNow 0xFFFFFFFFFFFFFFFF

FUNCTION: FSEventStreamRef FSEventStreamCreate (
    CFAllocatorRef           allocator,
    FSEventStreamCallback    callback,
    FSEventStreamContext*    context,
    CFArrayRef               pathsToWatch,
    FSEventStreamEventId     sinceWhen,
    CFTimeInterval           latency,
    FSEventStreamCreateFlags flags ) ;

FUNCTION: FSEventStreamRef FSEventStreamCreateRelativeToDevice (
    CFAllocatorRef           allocator,
    FSEventStreamCallback    callback,
    FSEventStreamContext*    context,
    dev_t                    deviceToWatch,
    CFArrayRef               pathsToWatchRelativeToDevice,
    FSEventStreamEventId     sinceWhen,
    CFTimeInterval           latency,
    FSEventStreamCreateFlags flags ) ;

FUNCTION: FSEventStreamEventId FSEventStreamGetLatestEventId ( FSEventStreamRef streamRef ) ;

FUNCTION: dev_t FSEventStreamGetDeviceBeingWatched ( FSEventStreamRef streamRef ) ;

FUNCTION: CFArrayRef FSEventStreamCopyPathsBeingWatched ( FSEventStreamRef streamRef ) ;

FUNCTION: FSEventStreamEventId FSEventsGetCurrentEventId ( ) ;

FUNCTION: CFUUIDRef FSEventsCopyUUIDForDevice ( dev_t dev ) ;

FUNCTION: FSEventStreamEventId FSEventsGetLastEventIdForDeviceBeforeTime (
    dev_t          dev,
    CFAbsoluteTime time ) ;

FUNCTION: Boolean FSEventsPurgeEventsForDeviceUpToEventId (
    dev_t                dev,
    FSEventStreamEventId eventId ) ;

FUNCTION: void FSEventStreamRetain ( FSEventStreamRef streamRef ) ;

FUNCTION: void FSEventStreamRelease ( FSEventStreamRef streamRef ) ;

FUNCTION: void FSEventStreamScheduleWithRunLoop (
    FSEventStreamRef streamRef,
    CFRunLoopRef     runLoop,
    CFStringRef      runLoopMode ) ;

FUNCTION: void FSEventStreamUnscheduleFromRunLoop (
    FSEventStreamRef streamRef,
    CFRunLoopRef     runLoop,
    CFStringRef      runLoopMode ) ;

FUNCTION: void FSEventStreamInvalidate ( FSEventStreamRef streamRef ) ;

FUNCTION: Boolean FSEventStreamStart ( FSEventStreamRef streamRef ) ;

FUNCTION: FSEventStreamEventId FSEventStreamFlushAsync ( FSEventStreamRef streamRef ) ;

FUNCTION: void FSEventStreamFlushSync ( FSEventStreamRef streamRef ) ;

FUNCTION: void FSEventStreamStop ( FSEventStreamRef streamRef ) ;

FUNCTION: void FSEventStreamShow ( FSEventStreamRef streamRef ) ;

FUNCTION: CFStringRef FSEventStreamCopyDescription ( FSEventStreamRef streamRef ) ;

: make-FSEventStreamContext ( info -- alien )
    FSEventStreamContext <struct>
        swap >>info ;

:: <FSEventStream> ( callback info paths latency flags -- event-stream )
    f ! allocator
    callback
    info make-FSEventStreamContext
    paths <CFStringArray>
    FSEventStreamEventIdSinceNow ! sinceWhen
    latency
    flags
    FSEventStreamCreate ;

C-GLOBAL: void* kCFRunLoopCommonModes

: schedule-event-stream ( event-stream -- )
    CFRunLoopGetMain
    kCFRunLoopCommonModes
    FSEventStreamScheduleWithRunLoop ;

: unschedule-event-stream ( event-stream -- )
    CFRunLoopGetMain
    kCFRunLoopCommonModes
    FSEventStreamUnscheduleFromRunLoop ;

: enable-event-stream ( event-stream -- )
    dup
    schedule-event-stream
    dup FSEventStreamStart [
        drop
    ] [
        dup unschedule-event-stream
        FSEventStreamRelease
        "Cannot enable FSEventStream" throw
    ] if ;

: disable-event-stream ( event-stream -- )
    dup FSEventStreamStop
    unschedule-event-stream ;

SYMBOL: event-stream-callbacks

: event-stream-counter ( -- n )
    \ event-stream-counter counter ;

[
    event-stream-callbacks
    [ [ drop expired? not ] assoc-filter H{ } assoc-like ] change-global
] "core-foundation" add-startup-hook

: add-event-source-callback ( quot -- id )
    event-stream-counter <alien>
    [ event-stream-callbacks get set-at ] keep ;

: remove-event-source-callback ( id -- )
    event-stream-callbacks get delete-at ;

:: (master-event-source-callback) ( eventStream info numEvents eventPaths eventFlags eventIds -- )
    eventPaths numEvents void* <c-direct-array> [ utf8 alien>string ] { } map-as
    eventFlags numEvents int <c-direct-array>
    eventIds numEvents longlong <c-direct-array>
    3array flip
    info event-stream-callbacks get at [ drop ] or call( changes -- ) ;

: master-event-source-callback ( -- alien )
    [ (master-event-source-callback) ] FSEventStreamCallback ;

TUPLE: event-stream < disposable info handle ;

: <event-stream> ( quot paths latency flags -- event-stream )
    [
        add-event-source-callback
        [ master-event-source-callback ] keep
    ] 3dip <FSEventStream>
    dup enable-event-stream
    event-stream new-disposable swap >>handle swap >>info ;

M: event-stream dispose*
    {
        [ info>> remove-event-source-callback ]
        [ handle>> disable-event-stream ]
        [ handle>> FSEventStreamInvalidate ]
        [ handle>> FSEventStreamRelease ]
    } cleave ;
