! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.accessors arrays cocoa cocoa.application
core-foundation.arrays core-foundation.strings kernel sequences
;
IN: cocoa.pasteboard

CONSTANT: NSStringPboardType "NSStringPboardType"

: pasteboard-string? ( pasteboard -- ? )
    NSStringPboardType swap -> types CF>string-array member? ;

: pasteboard-string ( pasteboard -- str )
    NSStringPboardType <NSString> -> stringForType:
    [ CF>string ] ?call ;

: set-pasteboard-types ( seq pasteboard -- )
    swap <CFArray> -> autorelease f -> declareTypes:owner: drop ;

: set-pasteboard-string ( str pasteboard -- )
    NSStringPboardType <NSString>
    dup 1array pick set-pasteboard-types
    [ swap <NSString> ] dip -> setString:forType: drop ;

: pasteboard-error ( error -- f )
    "Pasteboard does not hold a string" <NSString>
    0 set-alien-cell f ;

: ?pasteboard-string ( pboard error -- str/f )
    over pasteboard-string? [
        swap pasteboard-string or* [ pasteboard-error ] unless
    ] [
        nip pasteboard-error
    ] if ;
