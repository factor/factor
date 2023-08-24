! Copyright (C) 2008 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
alien.syntax arrays assocs classes.struct combinators
core-foundation core-foundation.arrays core-foundation.run-loop
core-foundation.strings core-foundation.time destructors init
io.encodings.utf8 kernel namespaces sequences
specialized-arrays unix.types ;
IN: core-foundation.fsevents

SPECIALIZED-ARRAY: void*
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: ulonglong

CONSTANT: kFSEventStreamCreateFlagNone 0x00000000
CONSTANT: kFSEventStreamCreateFlagUseCFTypes 0x00000001
CONSTANT: kFSEventStreamCreateFlagNoDefer 0x00000002
CONSTANT: kFSEventStreamCreateFlagWatchRoot 0x00000004
CONSTANT: kFSEventStreamCreateFlagIgnoreSelf 0x00000008
CONSTANT: kFSEventStreamCreateFlagFileEvents 0x00000010
CONSTANT: kFSEventStreamCreateFlagMarkSelf 0x00000020
CONSTANT: kFSEventStreamCreateFlagUseExtendedData 0x00000040
CONSTANT: kFSEventStreamCreateFlagFullHistory 0x00000080

CONSTANT: kFSEventStreamEventFlagNone 0x00000000
CONSTANT: kFSEventStreamEventFlagMustScanSubDirs 0x00000001
CONSTANT: kFSEventStreamEventFlagUserDropped 0x00000002
CONSTANT: kFSEventStreamEventFlagKernelDropped 0x00000004
CONSTANT: kFSEventStreamEventFlagEventIdsWrapped 0x00000008
CONSTANT: kFSEventStreamEventFlagHistoryDone 0x00000010
CONSTANT: kFSEventStreamEventFlagRootChanged 0x00000020
CONSTANT: kFSEventStreamEventFlagMount 0x00000040
CONSTANT: kFSEventStreamEventFlagUnmount 0x00000080
CONSTANT: kFSEventStreamEventFlagItemCreated 0x00000100
CONSTANT: kFSEventStreamEventFlagItemRemoved 0x00000200
CONSTANT: kFSEventStreamEventFlagItemInodeMetaMod 0x00000400
CONSTANT: kFSEventStreamEventFlagItemRenamed 0x00000800
CONSTANT: kFSEventStreamEventFlagItemModified 0x00001000
CONSTANT: kFSEventStreamEventFlagItemFinderInfoMod 0x00002000
CONSTANT: kFSEventStreamEventFlagItemChangeOwner 0x00004000
CONSTANT: kFSEventStreamEventFlagItemXattrMod 0x00008000
CONSTANT: kFSEventStreamEventFlagItemIsFile 0x00010000
CONSTANT: kFSEventStreamEventFlagItemIsDir 0x00020000
CONSTANT: kFSEventStreamEventFlagItemIsSymlink 0x00040000
CONSTANT: kFSEventStreamEventFlagItemOwnEvent 0x00080000
CONSTANT: kFSEventStreamEventFlagItemIsHardlink 0x00100000
CONSTANT: kFSEventStreamEventFlagItemIsLastHardlink 0x00200000
CONSTANT: kFSEventStreamEventFlagItemCloned 0x00400000

TYPEDEF: uint FSEventStreamCreateFlags
TYPEDEF: uint FSEventStreamEventFlags
TYPEDEF: ulonglong FSEventStreamEventId
TYPEDEF: void* FSEventStreamRef

STRUCT: FSEventStreamContext
    { version CFIndex }
    { info void* }
    { retain void* }
    { release void* }
    { copyDescription void* } ;

CALLBACK: void FSEventStreamCallback ( FSEventStreamRef streamRef, void* clientCallBackInfo, size_t numEvents, void* eventPaths, FSEventStreamEventFlags* eventFlags, FSEventStreamEventId* eventIds )

CONSTANT: FSEventStreamEventIdSinceNow 0xFFFFFFFFFFFFFFFF

FUNCTION: FSEventStreamRef FSEventStreamCreate (
    CFAllocatorRef           allocator,
    FSEventStreamCallback    callback,
    FSEventStreamContext*    context,
    CFArrayRef               pathsToWatch,
    FSEventStreamEventId     sinceWhen,
    CFTimeInterval           latency,
    FSEventStreamCreateFlags flags )

FUNCTION: FSEventStreamRef FSEventStreamCreateRelativeToDevice (
    CFAllocatorRef           allocator,
    FSEventStreamCallback    callback,
    FSEventStreamContext*    context,
    dev_t                    deviceToWatch,
    CFArrayRef               pathsToWatchRelativeToDevice,
    FSEventStreamEventId     sinceWhen,
    CFTimeInterval           latency,
    FSEventStreamCreateFlags flags )

FUNCTION: FSEventStreamEventId FSEventStreamGetLatestEventId ( FSEventStreamRef streamRef )

FUNCTION: dev_t FSEventStreamGetDeviceBeingWatched ( FSEventStreamRef streamRef )

FUNCTION: CFArrayRef FSEventStreamCopyPathsBeingWatched ( FSEventStreamRef streamRef )

FUNCTION: FSEventStreamEventId FSEventsGetCurrentEventId ( )

FUNCTION: CFUUIDRef FSEventsCopyUUIDForDevice ( dev_t dev )

FUNCTION: FSEventStreamEventId FSEventsGetLastEventIdForDeviceBeforeTime (
    dev_t          dev,
    CFAbsoluteTime time )

FUNCTION: Boolean FSEventsPurgeEventsForDeviceUpToEventId (
    dev_t                dev,
    FSEventStreamEventId eventId )

FUNCTION: void FSEventStreamRetain ( FSEventStreamRef streamRef )

FUNCTION: void FSEventStreamRelease ( FSEventStreamRef streamRef )

FUNCTION: void FSEventStreamScheduleWithRunLoop (
    FSEventStreamRef streamRef,
    CFRunLoopRef     runLoop,
    CFStringRef      runLoopMode )

FUNCTION: void FSEventStreamUnscheduleFromRunLoop (
    FSEventStreamRef streamRef,
    CFRunLoopRef     runLoop,
    CFStringRef      runLoopMode )

FUNCTION: void FSEventStreamInvalidate ( FSEventStreamRef streamRef )

FUNCTION: Boolean FSEventStreamStart ( FSEventStreamRef streamRef )

FUNCTION: FSEventStreamEventId FSEventStreamFlushAsync ( FSEventStreamRef streamRef )

FUNCTION: void FSEventStreamFlushSync ( FSEventStreamRef streamRef )

FUNCTION: void FSEventStreamStop ( FSEventStreamRef streamRef )

FUNCTION: void FSEventStreamShow ( FSEventStreamRef streamRef )

FUNCTION: CFStringRef FSEventStreamCopyDescription ( FSEventStreamRef streamRef )

: make-FSEventStreamContext ( info -- alien )
    FSEventStreamContext new
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

STARTUP-HOOK: [
    event-stream-callbacks
    [ [ drop expired? ] H{ } assoc-reject-as ] change-global
]

: add-event-source-callback ( quot -- id )
    event-stream-counter <alien>
    [ event-stream-callbacks get set-at ] keep ;

: remove-event-source-callback ( id -- )
    event-stream-callbacks get delete-at ;

:: (master-event-source-callback) ( eventStream info numEvents eventPaths eventFlags eventIds -- )
    eventPaths numEvents void* <c-direct-array> [ utf8 alien>string ] { } map-as
    eventFlags numEvents uint <c-direct-array>
    eventIds numEvents ulonglong <c-direct-array>
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
