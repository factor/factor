! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types arrays kernel cocoa.messages
cocoa.classes cocoa.application cocoa core-foundation
sequences ;
IN: cocoa.pasteboard

: NSStringPboardType "NSStringPboardType" ;

: pasteboard-string? ( pasteboard -- ? )
    NSStringPboardType swap -> types CF>string-array member? ;

: pasteboard-string ( pasteboard -- str )
    NSStringPboardType <NSString> -> stringForType:
    dup [ CF>string ] when ;

: set-pasteboard-types ( seq pasteboard -- )
    swap <NSArray> f -> declareTypes:owner: drop ;

: set-pasteboard-string ( str pasteboard -- )
    NSStringPboardType <NSString>
    dup 1array pick set-pasteboard-types
    >r swap <NSString> r> -> setString:forType: drop ;

: pasteboard-error ( error -- f )
    "Pasteboard does not hold a string" <NSString>
    0 swap rot set-void*-nth f ;

: ?pasteboard-string ( pboard error -- str/f )
    over pasteboard-string? [
        swap pasteboard-string [ ] [ pasteboard-error ] ?if
    ] [
        nip pasteboard-error
    ] if ;
