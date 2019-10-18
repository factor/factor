IN: cocoa-pdfkit
USING: alien cocoa compiler errors io kernel math objc
objc-NSObject objc-NSWindow objc-PDFDocument objc-PDFView ;

: <PDFDocument> ( url -- document )
    <CFURL> [autorelease]
    PDFDocument [alloc] swap [initWithURL:] [autorelease] ;

: <PDFView> ( document -- view )
    PDFView [alloc] 0 0 500 500 <NSRect> [initWithFrame:]
    [ swap [setDocument:] ] keep ;

"PDFKit demo" 10 10 500 500 <NSRect> <NSWindow>
dup

"http://factorcode.org/handbook.pdf" <PDFDocument> <PDFView>

[setContentView:]

f [makeKeyAndOrderFront:]

event-loop
