IN: cocoa
USING: kernel sequences objc-NSPasteboard ;

: NSStringPboardType "NSStringPboardType" <NSString> ;

: pasteboard-type? ( type id -- seq )
    NSStringPboardType swap [types] CF>array member? ;

: pasteboard-string ( id -- str )
    NSStringPboardType [stringForType:] dup [ CF>string ] when ;

: set-pasteboard-types ( seq id -- )
    swap <NSArray> f [declareTypes:owner:] ;

: set-pasteboard-string ( str id -- )
    swap <NSString> NSStringPboardType [setString:forType:] ;
