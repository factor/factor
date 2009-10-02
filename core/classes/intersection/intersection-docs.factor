USING: generic help.markup help.syntax kernel kernel.private
namespaces sequences words arrays help effects math
layouts classes.private classes compiler.units ;
IN: classes.intersection

ARTICLE: "intersections" "Intersection classes"
"An object is an instance of a intersection class if it is an instance of all of its participants."
{ $subsections POSTPONE: INTERSECTION: }
{ $subsections define-intersection-class }
"Intersection classes can be introspected:"
{ $subsections participants }
"The set of intersection classes is a class:"
{ $subsections
    intersection-class
    intersection-class?
}
"Intersection classes are used to associate a method with objects which are simultaneously instances of multiple different classes, as well as to conveniently define predicates." ;

ABOUT: "intersections"

HELP: define-intersection-class
{ $values { "class" class } { "participants" "a sequence of classes" } }
{ $description "Defines a intersection class with specified participants. This is the run time equivalent of " { $link POSTPONE: INTERSECTION: } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "class" } ;

{ intersection-class define-intersection-class POSTPONE: INTERSECTION: } related-words

HELP: intersection-class
{ $class-description "The class of intersection classes." } ;
