USING: help.markup help.syntax kernel classes ;
IN: classes.algebra

ARTICLE: "class-operations" "Class operations"
"Set-theoretic operations on classes:"
{ $subsection class< }
{ $subsection class-and }
{ $subsection class-or }
{ $subsection classes-intersect? }
"Topological sort:"
{ $subsection sort-classes }
{ $subsection min-class }
"Low-level implementation detail:"
{ $subsection class-types }
{ $subsection flatten-class }
{ $subsection flatten-builtin-class }
{ $subsection class-types }
{ $subsection class-tags } ;

HELP: flatten-builtin-class
{ $values { "class" class } { "assoc" "an assoc whose keys are classes" } }
{ $description "Outputs a set of tuple classes whose union is the smallest cover of " { $snippet "class" } " intersected with " { $link tuple } "." } ;

HELP: flatten-class
{ $values { "class" class } { "assoc" "an assoc whose keys are classes" } }
{ $description "Outputs a set of builtin and tuple classes whose union is the smallest cover of " { $snippet "class" } "." } ;

HELP: class-types
{ $values { "class" class } { "seq" "an increasing sequence of integers" } }
{ $description "Outputs a sequence of builtin type numbers whose instances can possibly be instances of the given class." } ;

HELP: class<
{ $values { "first" "a class" } { "second" "a class" } { "?" "a boolean" } }
{ $description "Tests if all instances of " { $snippet "class1" } " are also instances of " { $snippet "class2" } "." }
{ $notes "Classes are partially ordered. This means that if " { $snippet "class1 <= class2" } " and " { $snippet "class2 <= class1" } ", then " { $snippet "class1 = class2" } ". Also, if " { $snippet "class1 <= class2" } " and " { $snippet "class2 <= class3" } ", then " { $snippet "class1 <= class3" } "." } ;

HELP: sort-classes
{ $values { "seq" "a sequence of class" } { "newseq" "a new seqence of classes" } }
{ $description "Outputs a topological sort of a sequence of classes. Larger classes come before their subclasses." } ;

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
