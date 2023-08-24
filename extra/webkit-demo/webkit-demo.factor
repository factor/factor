! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.application cocoa.types cocoa.classes cocoa.windows
core-graphics.types kernel math.bitwise literals ;
IN: webkit-demo

FRAMEWORK: /System/Library/Frameworks/WebKit.framework
IMPORT: WebView

: rect ( -- rect ) 0 0 700 500 <CGRect> ;

: <WebView> ( -- id )
    WebView -> alloc
    rect f f -> initWithFrame:frameName:groupName: ;

CONSTANT: window-style
    flags{
        NSClosableWindowMask
        NSMiniaturizableWindowMask
        NSResizableWindowMask
        NSTitledWindowMask
    }

: <WebWindow> ( -- id )
    <WebView> rect window-style <ViewWindow> ;

: load-url ( window url -- )
    [ -> contentView ] [ <NSString> ] bi* -> setMainFrameURL: ;

: webkit-demo ( -- )
    <WebWindow>
    [ -> center ]
    [ f -> makeKeyAndOrderFront: ]
    [ "https://factorcode.org" load-url ] tri ;

: run-webkit-demo ( -- )
    [ webkit-demo ] cocoa-app ;

MAIN: run-webkit-demo
