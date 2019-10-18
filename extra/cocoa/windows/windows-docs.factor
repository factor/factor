USING: cocoa.windows help.markup help.syntax ;

HELP: <NSWindow>
{ $values { "rect" "an " { $snippet "NSRect" } } { "window" "an " { $snippet "NSWindow" } } }
{ $description "Creates a new " { $snippet "NSWindow" } " with the specified dimensions." } ;

HELP: <ViewWindow>
{ $values { "view" "an " { $snippet "NSView" } } { "rect" "an " { $snippet "NSRect" } } { "window" "an " { $snippet "NSWindow" } } }
{ $description "Creates a new " { $snippet "NSWindow" } " with the specified dimensions, containing the given view." } ;

ARTICLE: "cocoa-window-utils" "Cocoa window utilities"
{ $subsection <NSWindow> }
{ $subsection <ViewWindow> } ;

IN: cocoa.windows
ABOUT: "cocoa-window-utils"
