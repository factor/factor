! Copyright (C) 2006, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: assocs cocoa.messages compiler.units core-foundation.bundles
io kernel lexer namespaces sequences vocabs ;
IN: cocoa

SYMBOL: sent-messages

sent-messages [ H{ } clone ] initialize
: remember-send ( selector -- )
    dup sent-messages get set-at ;

SYNTAX: ->
    scan-token dup remember-send
    [ lookup-objc-method suffix! ] [ suffix! ] bi \ send suffix! ;

SYNTAX: ?->
    dup last cache-stubs
    scan-token dup remember-send
    suffix! \ send suffix! ;

SYNTAX: SEL:
    scan-token dup remember-send
    <selector> suffix! \ cocoa.messages:selector suffix! ;

SYMBOL: super-sent-messages

super-sent-messages [ H{ } clone ] initialize

: remember-super-send ( selector -- )
    dup super-sent-messages get set-at ;

SYNTAX: SUPER->
    scan-token dup remember-super-send
    [ lookup-objc-method suffix! ] [ suffix! ] bi \ super-send suffix! ;

SYMBOL: frameworks

frameworks [ V{ } clone ] initialize

STARTUP-HOOK: [ frameworks get [ load-framework ] each ]

SYNTAX: FRAMEWORK: scan-token [ load-framework ] [ frameworks get push ] bi ;

SYNTAX: IMPORT: scan-token [ ] import-objc-class ;

"Importing Cocoa classes..." print

"cocoa.classes" create-vocab drop

[
    {
        "NSAlert"
        "NSAppearance"
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
        "NSFontManager"
        "NSImage"
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
        "NSPopover"
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
