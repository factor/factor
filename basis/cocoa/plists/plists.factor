! Copyright (C) 2007, 2009 Slava Pestov.
! Copyright (C) 2008 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data arrays byte-arrays cocoa
cocoa.application cocoa.classes cocoa.enumeration combinators
core-foundation.data core-foundation.strings
core-foundation.utilities io.backend kernel math
quotations sequences ;
IN: cocoa.plists

: >plist ( value -- plist ) >cf -> autorelease ;

: write-plist ( assoc path -- )
    [ >plist ] [ normalize-path <NSString> ] bi* 0 -> writeToFile:atomically:
    [ "write-plist failed" throw ] unless ;

DEFER: plist>

<PRIVATE

: (plist-NSNumber>) ( NSNumber -- number )
    dup -> doubleValue dup >integer =
    [ -> longLongValue ] [ -> doubleValue ] if ;

: (plist-NSData>) ( NSData -- byte-array )
    dup -> length <byte-array> [ -> getBytes: ] keep ;

: (plist-NSArray>) ( NSArray -- vector )
    [ plist> ] NSFastEnumeration-map ;

: (plist-NSDictionary>) ( NSDictionary -- hashtable )
    dup [ [ nip ] [ -> valueForKey: ] 2bi [ plist> ] bi@ ] with
    NSFastEnumeration>hashtable ;

: (read-plist) ( NSData -- id )
    NSPropertyListSerialization swap kCFPropertyListImmutable f
    { void* }
    [ -> propertyListFromData:mutabilityOption:format:errorDescription: ]
    with-out-parameters
    [ -> release "read-plist failed" throw ] when* ;

MACRO: objc-class-case ( alist -- quot )
    [
        dup callable?
        [ first2 [ '[ dup _ execute -> isKindOfClass: c-bool> ] ] dip 2array ]
        unless
    ] map '[ _ cond ] ;

PRIVATE>

ERROR: invalid-plist-object object ;

: plist> ( plist -- value )
    {
        { NSString [ CF>string ] }
        { NSNumber [ (plist-NSNumber>) ] }
        { NSData [ (plist-NSData>) ] }
        { NSArray [ (plist-NSArray>) ] }
        { NSDictionary [ (plist-NSDictionary>) ] }
        { NSObject [ ] }
        [ invalid-plist-object ]
    } objc-class-case ;

: read-plist ( path -- assoc )
    normalize-path <NSString>
    NSData swap -> dataWithContentsOfFile:
    [ (read-plist) plist> ] [ "read-plist failed" throw ] if* ;
