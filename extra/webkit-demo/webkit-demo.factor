! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel
cocoa
cocoa.application
cocoa.types
cocoa.classes
cocoa.windows ;
IN: webkit-demo

FRAMEWORK: /System/Library/Frameworks/WebKit.framework
IMPORT: WebView

: rect ( -- rect ) 0 0 700 500 <NSRect> ;

: <WebView> ( -- id )
    WebView -> alloc
    rect f f -> initWithFrame:frameName:groupName: ;

: <WebWindow> ( -- id )
    <WebView> rect <ViewWindow> ;

: load-url ( window url -- )
    [ -> contentView ] [ <NSString> ] bi* -> setMainFrameURL: ;

: webkit-demo ( -- )
    <WebWindow>
    [ -> center ]
    [ f -> makeKeyAndOrderFront: ]
    [ "http://factorcode.org" load-url ] tri ;

: run-webkit-demo ( -- )
    [ webkit-demo ] cocoa-app ;

MAIN: run-webkit-demo
