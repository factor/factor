USING: help.markup help.syntax ;
IN: cocoa.windows

HELP: <NSWindow>
{ $values { "rect" "an " { $snippet "NSRect" } } { "style" "a style mask" } { "class" "an Objective-C class" } { "window" "an " { $snippet "NSWindow" } } }
{ $description "Creates a new " { $snippet "NSWindow" } " with the specified dimensions." } ;

HELP: <ViewWindow>
{ $values { "view" "an " { $snippet "NSView" } } { "rect" "an " { $snippet "NSRect" } } { "style" "a style mask" } { "window" "an " { $snippet "NSWindow" } } }
{ $description "Creates a new " { $snippet "NSWindow" } " with the specified dimensions, containing the given view." } ;

ARTICLE: "cocoa-window-utils" "Cocoa window utilities"
{ $subsections
    <NSWindow>
    <ViewWindow>
} ;

ABOUT: "cocoa-window-utils"
