! Copyright (C) 2006, 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: compiler io kernel cocoa.runtime cocoa.subclassing
cocoa.messages cocoa.types sequences words vocabs parser
core-foundation.bundles namespaces assocs hashtables
compiler.units lexer init ;
FROM: cocoa.messages => selector ;
IN: cocoa

: (remember-send) ( selector variable -- )
    [ dupd ?set-at ] change-global ;

SYMBOL: sent-messages

: remember-send ( selector -- )
    sent-messages (remember-send) ;

SYNTAX: -> scan-token dup remember-send suffix! \ send suffix! ;

SYNTAX: SEL:
    scan-token
    [ remember-send ]
    [ <selector> suffix! \ selector suffix! ] bi ;

SYNTAX: SEND:
    scan-token
    [ remember-send ]
    [ <selector> suffix! \ selector suffix! ]
    [ suffix! \ lookup-sender suffix! ] tri ;

SYMBOL: super-sent-messages

: remember-super-send ( selector -- )
    super-sent-messages (remember-send) ;

SYNTAX: SUPER-> scan-token dup remember-super-send suffix! \ super-send suffix! ;

SYMBOL: frameworks

frameworks [ V{ } clone ] initialize

[ frameworks get [ load-framework ] each ] "cocoa" add-startup-hook

SYNTAX: FRAMEWORK: scan-token [ load-framework ] [ frameworks get push ] bi ;

SYNTAX: IMPORT: scan-token [ ] import-objc-class ;

"Importing Cocoa classes..." print

"cocoa.classes" create-vocab drop

[
    {
        "NSAlert"
        "NSApplication"
        "NSArray"
        "NSAutoreleasePool"
        "NSBitmapImageRep"
        "NSBundle"
        "NSColorSpace"
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
        "NSPanel"
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
