! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: strings arrays hashtables assocs sequences
cocoa.messages cocoa.classes cocoa.application cocoa kernel
namespaces io.backend ;
IN: cocoa.plists

: assoc>NSDictionary ( assoc -- alien )
    NSMutableDictionary over assoc-size -> dictionaryWithCapacity:
    [
        [
            spin [ <NSString> ] bi@ -> setObject:forKey:
        ] curry assoc-each
    ] keep ;

: write-plist ( assoc path -- )
    >r assoc>NSDictionary
    r> normalize-path <NSString> 0 -> writeToFile:atomically:
    [ "write-plist failed" throw ] unless ;
