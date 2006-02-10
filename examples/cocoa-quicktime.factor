IN: cocoa-quicktime
USING: alien cocoa compiler errors io kernel math objc
objc-NSError objc-NSObject objc-NSURLRequest objc-NSWindow
objc-QTMovie objc-QTMovieView parser sequences threads ;

"/System/Library/Frameworks/QTKit.framework" load-framework

: <QTMovie> ( url -- movie )
    <CFURL> [autorelease]
    QTMovie swap f <void*>
    [ [movieWithURL:error:] [autorelease] ] keep
    *void* [ [localizedDescription] CF>string throw ] when* ;

: <QTMovieView> ( movie -- view )
    QTMovieView [alloc] 0 0 100 100 <NSRect> [initWithFrame:]
    [ swap [setMovie:] ] keep ;

"Quicktime demo" 10 10 100 50 <NSRect> <NSWindow>
dup

"file:///Users/slava/Media/Mixes/shaundoe1year.mp3"
<QTMovie> <QTMovieView>

dup 1 [setControllerVisible:]
[setContentView:]

f [makeKeyAndOrderFront:]

event-loop
