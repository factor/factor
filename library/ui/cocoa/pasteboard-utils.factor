! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: arrays kernel objc-NSPasteboard sequences ;

: NSStringPboardType "NSStringPboardType" ;

: pasteboard-string? ( type id -- seq )
    NSStringPboardType swap [types] CF>string-array member? ;

: pasteboard-string ( id -- str )
    NSStringPboardType <NSString> [stringForType:]
    dup [ CF>string ] when ;

: set-pasteboard-types ( seq id -- )
    swap <NSArray> f [declareTypes:owner:] drop ;

: set-pasteboard-string ( str id -- )
    NSStringPboardType <NSString>
    dup 1array pick set-pasteboard-types
    >r swap <NSString> r> [setString:forType:] drop ;
