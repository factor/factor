! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa compiler io kernel objc sequences words ;

"Compiling Objective C bridge..." print

{ "cocoa" "objc" } compile-vocabs

"Loading Cocoa frameworks..." print
{
    "/System/Library/Frameworks/WebKit.framework"
    "/System/Library/Frameworks/QTKit.framework"
    "/System/Library/Frameworks/Quartz.framework/Frameworks/PDFKit.framework"
} [
    dup print flush load-framework
] each

"Importing Cocoa classes..." print
{
    "NSApplication"
    "NSAutoreleasePool"
    "NSDate"
    "NSEvent"
    "NSInvocation"
    "NSMethodSignature"
    "NSObject"
    "NSOpenGLView"
    "NSSpeechSynthesizer"
    "NSURLRequest"
    "NSWindow"
    "PDFView"
    "QTMovie"
    "QTMovieView"
    "WebFrame"
    "WebView"
} [
    dup print flush define-objc-class
] each
