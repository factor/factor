! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: cocoa cocoa.application cocoa.classes kernel ;

IN: cocoa.apple-script

: run-apple-script ( str -- )
    [ NSAppleScript -> alloc ] dip
    <NSString> -> initWithSource: -> autorelease
    f -> executeAndReturnError: drop ;
