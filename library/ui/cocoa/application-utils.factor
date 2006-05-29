! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: alien errors gadgets io kernel namespaces objc
objc-classes sequences threads ;

: NSApplicationDelegateReplySuccess 0 ;
: NSApplicationDelegateReplyCancel  1 ;
: NSApplicationDelegateReplyFailure 2 ;

: with-autorelease-pool ( quot -- )
    NSAutoreleasePool -> new slip -> release ; inline

: NSApp NSApplication -> sharedApplication ;

: with-cocoa ( quot -- )
    [ NSApp drop call ] with-autorelease-pool ;

: <NSString> ( str -- alien ) <CFString> -> autorelease ;

: <NSArray> ( seq -- alien ) <CFArray> -> autorelease ;

: CFRunLoopDefaultMode "kCFRunLoopDefaultMode" <NSString> ;

: next-event ( app -- event )
    0 f CFRunLoopDefaultMode 1
    -> nextEventMatchingMask:untilDate:inMode:dequeue: ;

: do-event ( app -- ? )
    [
        dup next-event [ -> sendEvent: t ] [ drop f ] if*
    ] with-autorelease-pool ;

: do-events ( app -- )
    dup do-event [ do-events ] [ drop ] if ;

: event-loop ( -- )
    [ NSApp do-events ui-step ] with-autorelease-pool
    event-loop ;

: add-observer ( observer selector name object -- )
    >r >r >r >r NSNotificationCenter -> defaultCenter
    r> r> sel_registerName
    r> r> -> addObserver:selector:name:object: ;

: remove-observer ( observer -- )
    >r NSNotificationCenter -> defaultCenter r>
    -> removeObserver: ;

: finish-launching ( -- ) NSApp -> finishLaunching ;

: install-delegate ( receiver delegate -- )
    -> alloc -> init -> setDelegate: ;

IN: errors

: objc-error. ( error -- )
    "Objective C exception:" print
    third -> reason CF>string print ;
