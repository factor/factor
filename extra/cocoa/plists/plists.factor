! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: strings arrays hashtables assocs sequences
cocoa.messages cocoa.classes cocoa.application cocoa kernel
namespaces io.backend math cocoa.enumeration byte-arrays
combinators alien.c-types ;
IN: cocoa.plists

GENERIC: >plist ( value -- plist )

M: number >plist
    <NSNumber> ;
M: t >plist
    <NSNumber> ;
M: f >plist
    <NSNumber> ;
M: string >plist
    <NSString> ;
M: byte-array >plist
    <NSData> ;
M: hashtable >plist
    [ [ >plist ] bi@ ] assoc-map <NSDictionary> ;
M: sequence >plist
    [ >plist ] map <NSArray> ;

: write-plist ( assoc path -- )
    >r >plist
    r> normalize-path <NSString> 0 -> writeToFile:atomically:
    [ "write-plist failed" throw ] unless ;

DEFER: plist>

: (plist-NSString>) ( NSString -- string )
    -> UTF8String ;

: (plist-NSNumber>) ( NSNumber -- number )
    dup -> doubleValue dup >integer =
    [ -> longLongValue ]
    [ -> doubleValue ] if ;

: (plist-NSData>) ( NSData -- byte-array )
    dup -> length <byte-array> [ -> getBytes: ] keep ;

: (plist-NSArray>) ( NSArray -- vector )
    [ plist> ] NSFastEnumeration-map ;    

: (plist-NSDictionary>) ( NSDictionary -- hashtable )
    dup [ [ -> valueForKey: ] keep swap [ plist> ] bi@ 2array ] with
    NSFastEnumeration-map >hashtable ;

: plist> ( plist -- value )
    {
        { [ dup NSString     -> isKindOfClass: c-bool> ] [ (plist-NSString>)      ] }
        { [ dup NSNumber     -> isKindOfClass: c-bool> ] [ (plist-NSNumber>)      ] }
        { [ dup NSData       -> isKindOfClass: c-bool> ] [ (plist-NSData>)        ] }
        { [ dup NSArray      -> isKindOfClass: c-bool> ] [ (plist-NSArray>)       ] }
        { [ dup NSDictionary -> isKindOfClass: c-bool> ] [ (plist-NSDictionary>)  ] }
        [ ]
    } cond ;
