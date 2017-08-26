! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.application cocoa.types cocoa.classes cocoa.windows
core-graphics.types kernel math.bitwise literals ;
IN: webkit-demo

FRAMEWORK: /System/Library/Frameworks/WebKit.framework
IMPORT: WebView

: rect ( -- rect ) 0 0 700 500 <CGRect> ;

: <WebView> ( -- id )
    WebView send\ alloc
    rect f f send\ initWithFrame:frameName:groupName: ;

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
    [ send\ contentView ] [ <NSString> ] bi* send\ setMainFrameURL: ;

: webkit-demo ( -- )
    <WebWindow>
    [ send\ center ]
    [ f send\ makeKeyAndOrderFront: ]
    [ "http://factorcode.org" load-url ] tri ;

: run-webkit-demo ( -- )
    [ webkit-demo ] cocoa-app ;

MAIN: run-webkit-demo
