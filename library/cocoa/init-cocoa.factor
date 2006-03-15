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
    "NSSpeechSynthesizer"
    "NSURLRequest"
    "NSView"
    "NSWindow"
} [
    f import-objc-class
] each

{
    "PDFDocument"
    "PDFView"
} [
    [
        "/System/Library/Frameworks/Quartz.framework/Frameworks/PDFKit.framework"
        load-framework
    ] import-objc-class
] each

{
    "QTMovie"
    "QTMovieView"
} [
    [
        "/System/Library/Frameworks/QTKit.framework"
        load-framework
    ] import-objc-class
] each

{
    "WebFrame"
    "WebView"
} [
    [
        "/System/Library/Frameworks/WebKit.framework"
        load-framework
    ] import-objc-class
] each
