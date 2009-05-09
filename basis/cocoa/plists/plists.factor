! Copyright (C) 2007, 2009 Slava Pestov.
! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: strings arrays hashtables assocs sequences fry macros
cocoa.messages cocoa.classes cocoa.application cocoa kernel
namespaces io.backend math cocoa.enumeration byte-arrays
combinators alien.c-types words core-foundation quotations
core-foundation.data core-foundation.utilities ;
IN: cocoa.plists

: >plist ( value -- plist ) >cf -> autorelease ;

: write-plist ( assoc path -- )
    [ >plist ] [ normalize-path <NSString> ] bi* 0 -> writeToFile:atomically:
    [ "write-plist failed" throw ] unless ;

DEFER: plist>

<PRIVATE

: (plist-NSString>) ( NSString -- string )
    -> UTF8String ;

: (plist-NSNumber>) ( NSNumber -- number )
    dup -> doubleValue dup >integer =
    [ -> longLongValue ] [ -> doubleValue ] if ;

: (plist-NSData>) ( NSData -- byte-array )
    dup -> length <byte-array> [ -> getBytes: ] keep ;

: (plist-NSArray>) ( NSArray -- vector )
    [ plist> ] NSFastEnumeration-map ;

: (plist-NSDictionary>) ( NSDictionary -- hashtable )
    dup [ [ nip ] [ -> valueForKey: ] 2bi [ plist> ] bi@ 2array ] with
    NSFastEnumeration-map >hashtable ;

: (read-plist) ( NSData -- id )
    NSPropertyListSerialization swap kCFPropertyListImmutable f f <void*>
    [ -> propertyListFromData:mutabilityOption:format:errorDescription: ] keep
    *void* [ -> release "read-plist failed" throw ] when* ;

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
        { NSString [ (plist-NSString>) ] }
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
