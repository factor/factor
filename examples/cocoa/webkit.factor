IN: cocoa-webkit
USING: alien cocoa compiler io kernel math objc objc-NSObject
objc-NSURLRequest objc-NSWindow objc-WebFrame objc-WebView
parser sequences threads ;

"/System/Library/Frameworks/WebKit.framework" load-framework

: <NSURLRequest> ( string -- id )
    NSURLRequest swap <CFURL> [requestWithURL:] ;

: <WebView> ( -- view )
    WebView [alloc] 0 0 100 100 <NSRect> f f [initWithFrame:frameName:groupName:] ;

"WebKit demo" 10 10 600 600 <NSRect> <NSWindow>
dup

<WebView>

dup [mainFrame] "http://factorcode.org" <NSURLRequest> [loadRequest:]

[setContentView:]

dup f [makeKeyAndOrderFront:]

event-loop
