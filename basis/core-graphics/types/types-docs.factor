USING: math help.markup help.syntax ;
IN: core-graphics.types

HELP: <CGRect>
{ $values { "x" real } { "y" real } { "w" real } { "h" real } { "rect" "an " { $snippet "CGRect" } } }
{ $description "Allocates a new " { $snippet "CGRect" } " in the Factor heap." } ;

HELP: <CGPoint>
{ $values { "x" real } { "y" real } { "CGPoint" CGPoint } }
{ $description "Allocates a new " { $snippet "CGPoint" } " in the Factor heap." } ;

HELP: <CGSize>
{ $values { "w" real } { "h" real } { "CGSize" CGSize } }
{ $description "Allocates a new " { $snippet "CGSize" } " in the Factor heap." } ;

ARTICLE: "core-graphics.types" "Core Graphics types"
"The Core Graphics binding defines some common C structs:"
{ $code
    "CGRect"
    "CGPoint"
    "CGSize"
}
"Some words for working with the above:"
{ $subsections
    <CGRect>
    <CGPoint>
    <CGSize>
} ;

ABOUT: "core-graphics.types"
