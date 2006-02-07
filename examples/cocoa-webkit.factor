IN: webkit-test
USING: alien compiler io kernel math objc parser sequences ;

! Very rough Cocoa bridge demo.

! Problems:
! - does not release many objects; need to support autorelease
! - you cannot return to the REPL after, because we don't
!   support Cocoa events yet.

! Core Foundation utilities -- will be moved elsewhere
: kCFURLPOSIXPathStyle 0 ;

: kCFStringEncodingMacRoman 0 ;

FUNCTION: void* CFURLCreateWithFileSystemPath ( void* allocator, void* filePath, int pathStyle, bool isDirectory ) ; compiled

FUNCTION: void* CFURLCreateWithString ( void* allocator, void* string, void* base ) ; compiled

FUNCTION: void* CFStringCreateWithCString ( void* allocator, char* cStr, int encoding ) ; compiled

FUNCTION: void* CFBundleCreate ( void* allocator, void* bundleURL ) ; compiled

FUNCTION: void* CFBundleGetFunctionPointerForName ( void* bundle, void* functionName ) ; compiled

FUNCTION: bool CFBundleLoadExecutable ( void* bundle ) ; compiled

FUNCTION: void CFRelease ( void* cf ) ; compiled

: <CFString> ( string -- cf )
    f swap kCFStringEncodingMacRoman CFStringCreateWithCString ;

: <CFFileSystemURL> ( string dir? -- cf )
    >r <CFString> f over kCFURLPOSIXPathStyle
    r> CFURLCreateWithFileSystemPath swap CFRelease ;

: <CFURL> ( string -- cf )
    <CFString>
    [ f swap f CFURLCreateWithString ] keep
    CFRelease ;

: <CFBundle> ( string -- cf )
    t <CFFileSystemURL> f over CFBundleCreate swap CFRelease ;

! Cocoa, WebKit classes and messages

! We do this at parse time so that the following code can see
! the new words
: init-cocoa
    "/System/Library/Frameworks/WebKit.framework" <CFBundle>
    CFBundleLoadExecutable drop
    {
        "NSObject" "NSWindow"
        "NSURLRequest" "NSApplication" "%NSURL"
        "WebView" "WebFrame"
    } [ dup define-objc-class "objc-" swap append use+ ] each ;
    parsing

init-cocoa

! This will move elsewhere really soon...
BEGIN-STRUCT: NSRect
    FIELD: float x
    FIELD: float y
    FIELD: float w
    FIELD: float h
END-STRUCT

TYPEDEF: NSRect _NSRect

: <NSRect>
    "NSRect" <c-object>
    [ set-NSRect-h ] keep
    [ set-NSRect-w ] keep
    [ set-NSRect-y ] keep
    [ set-NSRect-x ] keep ;

: NSBorderlessWindowMask     0 ; inline
: NSTitledWindowMask         1 ; inline
: NSClosableWindowMask       2 ; inline
: NSMiniaturizableWindowMask 4 ; inline
: NSResizableWindowMask      8 ; inline

: NSBackingStoreRetained    0 ; inline
: NSBackingStoreNonretained 1 ; inline
: NSBackingStoreBuffered    2 ; inline

: <NSURLRequest> ( string -- id )
    NSURLRequest swap <CFURL> [requestWithURL:] ;

! The ugliest colon definition ever
: webkit-test
    NSWindow [alloc]
    10 10 600 600 <NSRect>
    NSTitledWindowMask NSClosableWindowMask NSMiniaturizableWindowMask NSResizableWindowMask bitor bitor bitor
    NSBackingStoreBuffered 1 [initWithContentRect:styleMask:backing:defer:]
    dup "Hello world" <CFString> [setTitle:]
    dup
    
    WebView [alloc] 10 10 600 600 <NSRect> f f [initWithFrame:frameName:groupName:]
    
    dup [mainFrame] "http://factorcode.org" <NSURLRequest> [loadRequest:]
    
    [setContentView:]
    
    dup f [makeKeyAndOrderFront:]
    NSApplication [sharedApplication] [run] ;

\ webkit-test compile

webkit-test
