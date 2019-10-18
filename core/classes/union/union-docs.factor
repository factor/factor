USING: generic help.markup help.syntax kernel kernel.private
namespaces sequences words arrays layouts help effects math
layouts classes.private classes ;
IN: classes.union

ARTICLE: "unions" "Union classes"
"An object is an instance of a union class if it is an instance of one of its members. Union classes are used to associate the same method with several different classes, as well as to conveniently define predicates."
{ $subsection POSTPONE: UNION: }
{ $subsection define-union-class }
"Union classes can be introspected:"
{ $subsection members }
"The set of union classes is a class:"
{ $subsection union-class }
{ $subsection union-class? } ;

ABOUT: "unions"

HELP: define-union-class
{ $values { "class" class } { "members" "a sequence of classes" } }
{ $description "Defines a union class with specified members." } ;

{ union-class define-union-class POSTPONE: UNION: } related-words

HELP: union-class
{ $class-description "The class of union classes." } ;
