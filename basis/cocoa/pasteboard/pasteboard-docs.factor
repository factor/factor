USING: help.markup help.syntax kernel strings ;
IN: cocoa.pasteboard

HELP: pasteboard-string?
{ $values { "pasteboard" "an " { $snippet "NSPasteBoard" } } { "?" boolean } }
{ $description "Tests if the pasteboard holds a string." } ;

HELP: pasteboard-string
{ $values { "pasteboard" "an " { $snippet "NSPasteBoard" } } { "str" string } }
{ $description "Outputs the contents of the pasteboard." } ;

HELP: set-pasteboard-string
{ $values { "str" string } { "pasteboard" "an " { $snippet "NSPasteBoard" } } }
{ $description "Sets the contents of the pasteboard." } ;

ARTICLE: "cocoa-pasteboard-utils" "Cocoa pasteboard utilities"
{ $subsections
    pasteboard-string?
    pasteboard-string
    set-pasteboard-string
} ;

ABOUT: "cocoa-pasteboard-utils"
