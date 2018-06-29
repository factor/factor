! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: cocoa cocoa.application cocoa.classes kernel parser
multiline words ;
IN: cocoa.apple-script

<PRIVATE
CONSTANT: apple-script-charmap H{
    { "\n" "\\n" }
    { "\r" "\\r" }
    { "\t" "\\t" }
    { "\"" "\\\"" }
    { "\\" "\\\\" }
}
PRIVATE>

: quote-apple-script ( str -- str' )
    [
      1string [ apple-script-charmap at ] [ ] bi or
    ] { } map-as
    "" join "\"" dup surround ;

: run-apple-script ( str -- )
    [ NSAppleScript -> alloc ] dip
    <NSString> -> initWithSource: -> autorelease
    f -> executeAndReturnError: drop ;

SYNTAX: APPLESCRIPT:
    scan-new-word scan-object
    [ run-apple-script ] curry ( -- ) define-declared ;
