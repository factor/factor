! Copyright (C) 2006, 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: assocs cocoa.messages compiler.units core-foundation.bundles
hashtables init io kernel lexer namespaces sequences vocabs ;
IN: cocoa

INITIALIZED-SYMBOL: sent-messages [ H{ } clone ]

: remember-send ( selector -- )
    dup sent-messages get set-at ;

SYNTAX: \send:
    scan-token unescape-token dup remember-send
    [ lookup-method suffix! ] [ suffix! ] bi \ send suffix! ;

SYNTAX: \?send:
    dup last cache-stubs
    scan-token unescape-token dup remember-send
    suffix! \ send suffix! ;

SYNTAX: \selector:
    scan-token unescape-token
    [ remember-send ]
    [ <selector> suffix! \ cocoa.messages:selector suffix! ] bi ;

INITIALIZED-SYMBOL: super-sent-messages [ H{ } clone ]

: remember-super-send ( selector -- )
    dup super-sent-messages get set-at ;

SYNTAX: \super:
    scan-token unescape-token dup remember-super-send
    [ lookup-method suffix! ] [ suffix! ] bi \ super-send suffix! ;

INITIALIZED-SYMBOL: frameworks [ V{ } clone ]

[ frameworks get [ load-framework ] each ] "cocoa" add-startup-hook

SYNTAX: \FRAMEWORK: scan-token [ load-framework ] [ frameworks get push ] bi ;

SYNTAX: \IMPORT: scan-token [ ] import-objc-class ;

"Importing Cocoa classes..." print

"cocoa.classes" create-vocab drop

[
    {
        "NSAlert"
        "NSAppleScript"
        "NSApplication"
        "NSArray"
        "NSAutoreleasePool"
        "NSBitmapImageRep"
        "NSBundle"
        "NSButton"
        "NSColorSpace"
        "NSCustomTouchBarItem"
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
        "NSTouchBar"
        "NSTouchBarItem"
        "NSView"
        "NSWindow"
        "NSWorkspace"
    } [
        [ ] import-objc-class
    ] each
] with-compilation-unit
