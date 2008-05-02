USING: help.markup help.syntax kernel classes words
checksums checksums.crc32 sequences math ;
IN: classes.algebra

ARTICLE: "class-operations" "Class operations"
"Set-theoretic operations on classes:"
{ $subsection class< }
{ $subsection class<= }
{ $subsection class-and }
{ $subsection class-or }
{ $subsection classes-intersect? }
{ $subsection min-class }
"Low-level implementation detail:"
{ $subsection class-types }
{ $subsection flatten-class }
{ $subsection flatten-builtin-class }
{ $subsection class-types }
{ $subsection class-tags } ;

ARTICLE: "class-linearization" "Class linearization"
"Classes have an intrinsic partial order; given two classes A and B, we either have that A is a subset of B, B is a subset of A, A and B are equal as sets, or they are incomparable. The last two situations present difficulties for method dispatch:"
{ $list
    "If a generic word defines a method on a mixin class A and another class B, and B is the only instance of A, there is an ambiguity because A and B are equal as sets; any object that is an instance of one is an instance of both."
    { "If a generic word defines methods on two union classes which are incomparable but not disjoint, for example " { $link sequence } " and " { $link number } ", there is an ambiguity because the generic word may be called on an object that is an instance of both unions." }
}
"These difficulties are resolved by imposing a linear order on classes, computed as follows for two classes A and B:"
{ $list
    "If A and B are the same class (not just equal as sets), then comparison stops."
    "If A is a proper subset of B, or B is a proper subset of A, then comparison stops."
    { "Next, the metaclasses of A and B are compared, with intrinsic meta-class order, from most-specific to least-specific:"
        { $list
            "Built-in classes and tuple classes"
            "Predicate classes"
            "Union classes"
            "Mixin classes"
        }
    "If this yields an unambiguous answer, comparison stops."
    }
    "If the metaclasses of A and B occupy the same position in the order, then the vocabularies of A and B are compared lexicographically. If this yields an unambiguous answer, comparison stops."
    "If A and B belong to the same vocabulary, their names are compared lexicographically. This must yield an unambiguous result, since if the names equal they must be the same class and this case was already handled in the first step."
}
"Some examples:"
{ $list
    { { $link integer } " precedes " { $link number } " because it is a strict subset" }
    { { $link number } " precedes " { $link sequence } " because the " { $vocab-link "math" } " vocabulary precedes the " { $vocab-link "sequences" } " vocabulary" }
    { { $link crc32 } " precedes " { $link checksum } ", even if it were the only instance, because " { $link crc32 } " is a singleton class which is more specific than a mixin class" }
}
"Operations:"
{ $subsection class<=> }
{ $subsection sort-classes }
"Metaclass order:"
{ $subsection rank-class } ;

HELP: flatten-builtin-class
{ $values { "class" class } { "assoc" "an assoc whose keys are classes" } }
{ $description "Outputs a set of tuple classes whose union is the smallest cover of " { $snippet "class" } " intersected with " { $link tuple } "." } ;

HELP: flatten-class
{ $values { "class" class } { "assoc" "an assoc whose keys are classes" } }
{ $description "Outputs a set of builtin and tuple classes whose union is the smallest cover of " { $snippet "class" } "." } ;

HELP: class-types
{ $values { "class" class } { "seq" "an increasing sequence of integers" } }
{ $description "Outputs a sequence of builtin type numbers whose instances can possibly be instances of the given class." } ;

HELP: class<=
{ $values { "first" "a class" } { "second" "a class" } { "?" "a boolean" } }
{ $description "Tests if all instances of " { $snippet "class1" } " are also instances of " { $snippet "class2" } "." }
{ $notes "Classes are partially ordered. This means that if " { $snippet "class1 <= class2" } " and " { $snippet "class2 <= class1" } ", then " { $snippet "class1 = class2" } ". Also, if " { $snippet "class1 <= class2" } " and " { $snippet "class2 <= class3" } ", then " { $snippet "class1 <= class3" } "." } ;

HELP: sort-classes
{ $values { "seq" "a sequence of class" } { "newseq" "a new seqence of classes" } }
{ $description "Outputs a linear sort of a sequence of classes. Larger classes come before their subclasses." } ;

{ sort-classes class<=> } related-words

HELP: class-or
{ $values { "first" class } { "second" class } { "class" class } }
{ $description "Outputs the smallest anonymous class containing both " { $snippet "class1" } " and " { $snippet "class2" } "." } ;

HELP: class-and
{ $values { "first" class } { "second" class } { "class" class } }
{ $description "Outputs the largest anonymous class contained in both " { $snippet "class1" } " and " { $snippet "class2" } "." } ;

HELP: classes-intersect?
{ $values { "first" class } { "second" class } { "?" "a boolean" } }
{ $description "Tests if two classes have a non-empty intersection. If the intersection is empty, no object can be an instance of both classes at once." } ;

HELP: min-class
{ $values { "class" class } { "seq" "a sequence of class words" } { "class/f" "a class word or " { $link f } } }
{ $description "If all classes in " { $snippet "seq" } " that intersect " { $snippet "class" } " are subtypes of " { $snippet "class" } ", outputs the last such element of " { $snippet "seq" } ". If any conditions fail to hold, outputs " { $link f } "." } ;

HELP: class<=>
{ $values { "first" class } { "second" class } { "n" symbol } }
{ $description "Compares two classes with the class linearization order." } ;
