USING: generic help.markup help.syntax kernel kernel.private
namespaces sequences words arrays help effects math
classes.private classes compiler.units ;
IN: classes.union

ARTICLE: "unions" "Union classes"
"An object is an instance of a union class if it is an instance of one of its members."
{ $subsections
    POSTPONE: UNION:
    define-union-class
}
"Union classes can be introspected:"
{ $subsections class-members }
"The set of union classes is a class:"
{ $subsections
    union-class
    union-class?
}
"Unions are used to define behavior shared between a fixed set of classes, as well as to conveniently define predicates."
{ $see-also "mixins" "tuple-subclassing" } ;

ABOUT: "unions"

HELP: define-union-class
{ $values { "class" class } { "members" "a sequence of classes" } }
{ $description "Defines a union class with specified members. This is the run time equivalent of " { $link POSTPONE: UNION: } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "class" } ;

{ union-class define-union-class POSTPONE: UNION: } related-words

HELP: union-class
{ $class-description "The class of union classes." } ;
