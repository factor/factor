! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: compiler io kernel cocoa.runtime cocoa.subclassing
cocoa.messages cocoa.types sequences words vocabs parser
core-foundation namespaces assocs hashtables ;
IN: cocoa

: (remember-send) ( selector variable -- )
    global [ dupd ?set-at ] change-at ;

SYMBOL: sent-messages

: remember-send ( selector -- )
    sent-messages (remember-send) ;

: ->
    scan dup remember-send parsed \ send parsed ;
    parsing

SYMBOL: super-sent-messages

: remember-super-send ( selector -- )
    super-sent-messages (remember-send) ;

: SUPER->
    scan dup remember-super-send parsed \ super-send parsed ;
    parsing

"Compiling Objective C bridge..." print

"cocoa.classes" create-vocab drop

{
    "cocoa" "cocoa.runtime" "cocoa.messages" "cocoa.subclassing"
} compile-vocabs

"Importing Cocoa classes..." print
{
    "NSApplication"
    "NSArray"
    "NSAutoreleasePool"
    "NSBundle"
    "NSError"
    "NSEvent"
    "NSException"
    "NSMenu"
    "NSMenuItem"
    "NSNib"
    "NSNotification"
    "NSNotificationCenter"
    "NSObject"
    "NSOpenGLContext"
    "NSOpenGLPixelFormat"
    "NSOpenGLView"
    "NSOpenPanel"
    "NSPasteboard"
    "NSResponder"
    "NSSavePanel"
    "NSView"
    "NSWindow"
    "NSWorkspace"
} [
    [ ] import-objc-class
] each

: <NSString> ( str -- alien ) <CFString> -> autorelease ;

: <NSArray> ( seq -- alien ) <CFArray> -> autorelease ;
