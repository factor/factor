! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa compiler io kernel objc sequences words ;

"Compiling Objective C bridge..." print

{ "cocoa" "objc" } compile-vocabs

"Importing Cocoa classes..." print
{
    "NSApplication"
    "NSAutoreleasePool"
    "NSError"
    "NSEvent"
    "NSException"
    "NSMenu"
    "NSMenuItem"
    "NSNotificationCenter"
    "NSObject"
    "NSOpenGLContext"
    "NSOpenGLView"
    "NSOpenPanel"
    "NSPasteboard"
    "NSSavePanel"
    "NSView"
    "NSWindow"
} [
    f import-objc-class
] each
