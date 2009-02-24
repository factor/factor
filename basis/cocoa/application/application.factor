! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax io kernel namespaces core-foundation
core-foundation.arrays core-foundation.data
core-foundation.strings cocoa.messages cocoa cocoa.classes
cocoa.runtime sequences threads init summary kernel.private
assocs ;
IN: cocoa.application

: <NSString> ( str -- alien ) <CFString> -> autorelease ;
: <NSArray> ( seq -- alien ) <CFArray> -> autorelease ;
: <NSNumber> ( number -- alien ) <CFNumber> -> autorelease ;
: <NSData> ( byte-array -- alien ) <CFData> -> autorelease ;
: <NSDictionary> ( assoc -- alien )
    NSMutableDictionary over assoc-size -> dictionaryWithCapacity:
    [
        [
            spin -> setObject:forKey:
        ] curry assoc-each
    ] keep ;

CONSTANT: NSApplicationDelegateReplySuccess 0
CONSTANT: NSApplicationDelegateReplyCancel  1
CONSTANT: NSApplicationDelegateReplyFailure 2

: with-autorelease-pool ( quot -- )
    NSAutoreleasePool -> new slip -> release ; inline

: NSApp ( -- app ) NSApplication -> sharedApplication ;

: NSAnyEventMask ( -- mask ) HEX: ffffffff ; inline

FUNCTION: void NSBeep ( ) ;

: with-cocoa ( quot -- )
    [ NSApp drop call ] with-autorelease-pool ; inline

: add-observer ( observer selector name object -- )
    [
        [ NSNotificationCenter -> defaultCenter ] 2dip
        sel_registerName
    ] 2dip -> addObserver:selector:name:object: ;

: remove-observer ( observer -- )
    [ NSNotificationCenter -> defaultCenter ] dip
    -> removeObserver: ;

: cocoa-app ( quot -- ) [ call NSApp -> run ] with-cocoa ; inline

: install-delegate ( receiver delegate -- )
    -> alloc -> init -> setDelegate: ;

TUPLE: objc-error alien reason ;

: objc-error ( alien -- * )
    dup -> reason CF>string \ objc-error boa throw ;

M: objc-error summary ( error -- )
    drop "Objective C exception" ;

[ [ objc-error ] 19 setenv ] "cocoa.application" add-init-hook

: running.app? ( -- ? )
    #! Test if we're running a .app.
    ".app"
    NSBundle -> mainBundle -> bundlePath CF>string
    subseq? ;

: assert.app ( message -- )
    running.app? [
        drop
    ] [
        "The " " requires you to run Factor from an application bundle."
        surround throw
    ] if ;
