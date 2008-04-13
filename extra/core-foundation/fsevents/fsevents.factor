! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax kernel math sequences
namespaces assocs init accessors continuations combinators
core-foundation core-foundation.run-loop ;
IN: core-foundation.fsevents

! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
! FSEventStream API, Leopard only !
! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !

: kFSEventStreamCreateFlagUseCFTypes 2 ; inline
: kFSEventStreamCreateFlagWatchRoot 4 ; inline

: kFSEventStreamEventFlagMustScanSubDirs 1 ; inline
: kFSEventStreamEventFlagUserDropped 2 ; inline
: kFSEventStreamEventFlagKernelDropped 4 ; inline
: kFSEventStreamEventFlagEventIdsWrapped 8 ; inline
: kFSEventStreamEventFlagHistoryDone 16 ; inline
: kFSEventStreamEventFlagRootChanged 32 ; inline
: kFSEventStreamEventFlagMount 64 ; inline
: kFSEventStreamEventFlagUnmount 128 ; inline

TYPEDEF: int FSEventStreamCreateFlags
TYPEDEF: int FSEventStreamEventFlags
TYPEDEF: longlong FSEventStreamEventId
TYPEDEF: void* FSEventStreamRef

C-STRUCT: FSEventStreamContext
    { "CFIndex" "version" }
    { "void*" "info" }
    { "void*" "retain" }
    { "void*" "release" }
    { "void*" "copyDescription" } ;

! callback(FSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]);
TYPEDEF: void* FSEventStreamCallback

: FSEventStreamEventIdSinceNow HEX: FFFFFFFFFFFFFFFF ; inline

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
    "FSEventStreamContext" <c-object>
    [ set-FSEventStreamContext-info ] keep ;

: <FSEventStream> ( callback info paths latency flags -- event-stream )
    >r >r >r >r >r
    f ! allocator
    r> ! callback
    r> make-FSEventStreamContext
    r> <CFStringArray> ! paths
    FSEventStreamEventIdSinceNow ! sinceWhen
    r> ! latency
    r> ! flags
    FSEventStreamCreate ;

: kCFRunLoopCommonModes ( -- string )
    "kCFRunLoopCommonModes" f dlsym *void* ;

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

: event-stream-counter \ event-stream-counter counter ;

[
    event-stream-callbacks global
    [ [ drop expired? not ] assoc-subset H{ } assoc-like ] change-at
] "core-foundation" add-init-hook

: add-event-source-callback ( quot -- id )
    event-stream-counter <alien>
    [ event-stream-callbacks get set-at ] keep ;

: remove-event-source-callback ( id -- )
    event-stream-callbacks get delete-at ;

: >event-triple ( n eventPaths eventFlags eventIds -- triple )
    [
        >r >r >r dup dup
        r> char*-nth ,
        r> int-nth ,
        r> longlong-nth ,
    ] { } make ;

: master-event-source-callback ( -- alien )
    "void"
    {
        "FSEventStreamRef"
        "void*"                     ! info
        "size_t"                    ! numEvents
        "void*"                     ! eventPaths
        "FSEventStreamEventFlags*"
        "FSEventStreamEventId*"
    }
    "cdecl" [
        [ >event-triple ] 3curry map
        swap event-stream-callbacks get at
        dup [ call drop ] [ 3drop ] if
    ] alien-callback ;

TUPLE: event-stream info handle closed ;

: <event-stream> ( quot paths latency flags -- event-stream )
    >r >r >r
    add-event-source-callback dup
    >r master-event-source-callback r>
    r> r> r> <FSEventStream>
    dup enable-event-stream
    f event-stream construct-boa ;

M: event-stream dispose
    dup closed>> [ drop ] [
        t >>closed
        {
            [ info>> remove-event-source-callback ]
            [ handle>> disable-event-stream ]
            [ handle>> FSEventStreamInvalidate ]
            [ handle>> FSEventStreamRelease ]
        } cleave
    ] if ;
