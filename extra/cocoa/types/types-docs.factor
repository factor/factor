USING: cocoa.types math help.markup help.syntax ;

HELP: <NSRect>
{ $values { "x" real } { "y" real } { "w" real } { "h" real } { "rect" "an " { $snippet "NSRect" } } }
{ $description "Allocates a new " { $snippet "NSRect" } " in the Factor heap." } ;

HELP: <NSPoint>
{ $values { "x" real } { "y" real } { "point" "an " { $snippet "NSPoint" } } }
{ $description "Allocates a new " { $snippet "NSPoint" } " in the Factor heap." } ;

HELP: <NSSize>
{ $values { "w" real } { "h" real } { "size" "an " { $snippet "NSSize" } } }
{ $description "Allocates a new " { $snippet "NSSize" } " in the Factor heap." } ;

ARTICLE: "cocoa-types" "Cocoa types"
"The Cocoa binding defines some common C structs:"
{ $code
    "NSRect"
    "NSPoint"
    "NSSize"
}
"Some words for working with the above:"
{ $subsection <NSRect> }
{ $subsection <NSPoint> }
{ $subsection <NSSize> } ;

IN: cocoa.types
ABOUT: "cocoa-types"
