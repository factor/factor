! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien io kernel namespaces core-foundation cocoa.messages
cocoa cocoa.classes cocoa.runtime sequences threads debugger ;
IN: cocoa.application

: NSApplicationDelegateReplySuccess 0 ;
: NSApplicationDelegateReplyCancel  1 ;
: NSApplicationDelegateReplyFailure 2 ;

: with-autorelease-pool ( quot -- )
    NSAutoreleasePool -> new slip -> release ; inline

: NSApp ( -- app ) NSApplication -> sharedApplication ;

: with-cocoa ( quot -- )
    [ NSApp drop call ] with-autorelease-pool ;

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

PREDICATE: kernel-error objc-error second 18 = ;

M: objc-error error. ( error -- )
    "Objective C exception:" print
    third -> reason CF>string print ;

: running.app? ( -- ? )
    #! Test if we're running a .app.
    ".app"
    NSBundle -> mainBundle -> bundlePath CF>string
    subseq? ;

: assert.app ( message -- )
    running.app? [
        drop
    ] [
        "The " swap " requires you to run Factor from an application bundle."
        3append throw
    ] if ;
