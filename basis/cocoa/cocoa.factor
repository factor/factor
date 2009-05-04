! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: compiler io kernel cocoa.runtime cocoa.subclassing
cocoa.messages cocoa.types sequences words vocabs parser
core-foundation.bundles namespaces assocs hashtables
compiler.units lexer init ;
IN: cocoa

: (remember-send) ( selector variable -- )
    [ dupd ?set-at ] change-global ;

SYMBOL: sent-messages

: remember-send ( selector -- )
    sent-messages (remember-send) ;

SYNTAX: -> scan dup remember-send parsed \ send parsed ;

SYMBOL: super-sent-messages

: remember-super-send ( selector -- )
    super-sent-messages (remember-send) ;

SYNTAX: SUPER-> scan dup remember-super-send parsed \ super-send parsed ;

SYMBOL: frameworks

frameworks [ V{ } clone ] initialize

[ frameworks get [ load-framework ] each ] "cocoa.messages" add-init-hook

SYNTAX: FRAMEWORK: scan [ load-framework ] [ frameworks get push ] bi ;

SYNTAX: IMPORT: scan [ ] import-objc-class ;

"Compiling Objective C bridge..." print

"cocoa.classes" create-vocab drop

{
    "cocoa" "cocoa.runtime" "cocoa.messages" "cocoa.subclassing"
} [ words ] map concat compile

"Importing Cocoa classes..." print

[
    {
        "NSApplication"
        "NSArray"
        "NSAutoreleasePool"
        "NSBundle"
        "NSData"
        "NSDictionary"
        "NSError"
        "NSEvent"
        "NSException"
        "NSMenu"
        "NSMenuItem"
        "NSMutableDictionary"
        "NSNib"
        "NSNotification"
        "NSNotificationCenter"
        "NSNumber"
        "NSObject"
        "NSOpenGLContext"
        "NSOpenGLPixelFormat"
        "NSOpenGLView"
        "NSOpenPanel"
        "NSPasteboard"
        "NSPropertyListSerialization"
        "NSResponder"
        "NSSavePanel"
        "NSScreen"
        "NSString"
        "NSView"
        "NSWindow"
        "NSWorkspace"
    } [
        [ ] import-objc-class
    ] each
] with-compilation-unit
