USING: classes classes.algebra.private classes.private help.markup
help.syntax kernel math sequences ;
IN: classes.algebra

ARTICLE: "class-operations" "Class operations"
"Set-theoretic operations on classes:"
{ $subsections
    class=
    class<
    class<=
    class-and
    class-or
    classes-intersect?
    flatten-class
} ;

ARTICLE: "class-linearization" "Class linearization"
"Classes have an intrinsic partial order; given two classes A and B, we either have that A is a subset of B, B is a subset of A, A and B are equal as sets, or they are incomparable. The last two situations present difficulties for method dispatch:"
{ $list
    "If a generic word defines a method on a mixin class A and another on class B, and B is the only instance of A, there is an ambiguity because A and B are equal as sets; any object that is an instance of one is an instance of both."
    { "If a generic word defines methods on two union classes which are incomparable but not disjoint, for example " { $link sequence } " and " { $link number } ", there is an ambiguity because the generic word may be called on an object that is an instance of both unions." }
}
"The first ambiguity is resolved with a tie-breaker that compares metaclasses. The intrinsic meta-class order, from most-specific to least-specific:"
{ $list
    "Built-in classes and tuple classes"
    "Predicate classes"
    "Union classes"
    "Mixin classes"
}
"This means that in the above example, the generic word with methods on a mixin and its sole instance will always call the method for the sole instance, since it is more specific than a mixin class."
$nl
"The second problem is resolved with another tie-breaker. When performing the topological sort of classes, if there are multiple candidates at any given step of the sort, lexicographical order on the class name is used."
$nl
"Operations:"
{ $subsections
    class<
    sort-classes
    smallest-class
}
"Metaclass order:"
{ $subsections rank-class } ;

HELP: flatten-class
{ $values { "class" class } { "seq" { $sequence class } } }
{ $description "Outputs a set of builtin and tuple classes whose union is the smallest cover of " { $snippet "class" } "." } ;

HELP: class<=
{ $values { "first" class } { "second" class } { "?" boolean } }
{ $description "Tests if all instances of " { $snippet "class1" } " are also instances of " { $snippet "class2" } "." }
{ $notes "Classes are partially ordered. This means that if " { $snippet "class1 <= class2" } " and " { $snippet "class2 <= class1" } ", then " { $snippet "class1 <= class2" } ". Also, if " { $snippet "class1 <= class2" } " and " { $snippet "class2 <= class3" } ", then " { $snippet "class1 <= class3" } "." } ;

HELP: class-and
{ $values { "first" class } { "second" class } { "class" class } }
{ $description "Outputs the largest anonymous class contained in both " { $snippet "class1" } " and " { $snippet "class2" } "." } ;

HELP: class-not
{ $values { "class" class } { "complement" class } }
{ $description "Outputs the complement class of 'class'." } ;

HELP: class-or
{ $values { "first" class } { "second" class } { "class" class } }
{ $description "Outputs the smallest anonymous class containing both " { $snippet "class1" } " and " { $snippet "class2" } "." } ;

HELP: classes-intersect?
{ $values { "first" class } { "second" class } { "?" boolean } }
{ $description "Tests if two classes have a non-empty intersection. If the intersection is empty, no object can be an instance of both classes at once." } ;

HELP: normalize-class
{ $values { "class" class } { "class'" class } }
{ $description "Normalizes a class in such a way that it becomes easier to perform algebra on it." } ;

HELP: smallest-class
{ $values { "classes" "a sequence of class words" } { "class/f" { $maybe class } } }
{ $description "Outputs a minimum class from the given sequence." } ;

HELP: sort-classes
{ $values { "seq" { $sequence class } } { "newseq" { $sequence class } } }
{ $description "Outputs a linear sort of a sequence of classes. Larger classes come before their subclasses." } ;
