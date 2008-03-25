USING: help.markup help.syntax kernel kernel.private
namespaces sequences words arrays layouts help effects math
layouts classes.private classes.union classes.mixin
classes.predicate quotations ;
IN: classes

ARTICLE: "builtin-classes" "Built-in classes"
"Every object is an instance of exactly one canonical " { $emphasis "built-in class" } " which defines its layout in memory and basic behavior."
$nl
"The set of built-in classes is a class:"
{ $subsection builtin-class }
{ $subsection builtin-class? }
"See " { $link "type-index" } " for a list of built-in classes." ;

ARTICLE: "class-predicates" "Class predicate words"
"With a handful of exceptions, each class has a membership predicate word, named " { $snippet { $emphasis "class" } "?" } " . A quotation calling this predicate is stored in the " { $snippet "\"predicate\"" } " word property."
$nl
"When it comes to predicates, the exceptional classes are:"
{ $table
    { "Class" "Predicate" "Explanation" }
    { { $link f } { $snippet "[ not ]" } { "The conventional name for a word which outputs true when given false is " { $link not } "; " { $snippet "f?" } " would be confusing." } }
    { { $link object } { $snippet "[ drop t ]" } { "All objects are instances of " { $link object } } }
    { { $link null } { $snippet "[ drop f ]" } { "No object is an instance of " { $link null } } }
    { { $link general-t } { $snippet "[ ]" } { "All objects with a true value are instances of " { $link general-t } } }
}
"The set of class predicate words is a class:"
{ $subsection predicate }
{ $subsection predicate? }
"A predicate word holds a reference to the class it is predicating over in the " { $snippet "\"predicating\"" } " word property." ;

ARTICLE: "classes" "Classes"
"Conceptually, a " { $snippet "class" } " is a set of objects whose members can be identified with a predicate, and on which generic words can specialize methods. Classes are organized into a general partial order, and an object may be an instance of more than one class."
$nl
"At the implementation level, a class is a word with certain word properties set."
$nl
"Words for working with classes are found in the " { $vocab-link "classes" } " vocabulary."
$nl
"Classes themselves form a class:"
{ $subsection class? }
"You can ask an object for its class:"
{ $subsection class }
"There is a universal class which all objects are an instance of, and an empty class with no instances:"
{ $subsection object }
{ $subsection null }
"Obtaining a list of all defined classes:"
{ $subsection classes }
"Other sorts of classes:"
{ $subsection "builtin-classes" }
{ $subsection "unions" }
{ $subsection "mixins" }
{ $subsection "predicates" }
"Classes can be inspected and operated upon:"
{ $subsection "class-operations" }
{ $see-also "class-index" } ;

ABOUT: "classes"

HELP: class
{ $values { "object" object } { "class" class } }
{ $description "Outputs an object's canonical class. While an object may be an instance of more than one class, the canonical class is either its built-in class, or if the object is a tuple, its tuple class." }
{ $class-description "The class of all class words. Subclasses include " { $link builtin-class } ", " { $link union-class } ", " { $link mixin-class } ", " { $link predicate-class } " and " { $link tuple-class } "." }
{ $examples { $example "USING: classes prettyprint ;" "1.0 class ." "float" } { $example "USING: classes prettyprint ;" "TUPLE: point x y z ;\nT{ point f 1 2 3 } class ." "point" } } ;

HELP: classes
{ $values { "seq" "a sequence of class words" } }
{ $description "Finds all class words in the dictionary." } ;

HELP: builtin-class
{ $class-description "The class of built-in classes." }
{ $examples
    "The class of arrays is a built-in class:"
    { $example "USING: arrays classes prettyprint ;" "array builtin-class? ." "t" }
    "However, an instance of the array class is not a built-in class; it is not even a class:"
    { $example "USING: classes prettyprint ;" "{ 1 2 3 } builtin-class? ." "f" }
} ;

HELP: tuple-class
{ $class-description "The class of tuple class words." }
{ $examples { $example "USING: classes prettyprint ;" "TUPLE: name title first last ;" "name tuple-class? ." "t" } } ;

HELP: builtins
{ $var-description "Vector mapping type numbers to builtin class words." } ;

HELP: update-map
{ $var-description "Hashtable mapping each class to a set of classes defined in terms of this class. The " { $link define-class } " word uses this information to update generic words when classes are redefined." } ;

HELP: type>class
{ $values { "n" "a non-negative integer" } { "class" class } }
{ $description "Outputs a builtin class whose instances are precisely those having a given pointer tag." }
{ $notes "The parameter " { $snippet "n" } " must be between 0 and the return value of " { $link num-types } "." } ;

HELP: predicate-word
{ $values { "word" "a word" } { "predicate" "a predicate word" } }
{ $description "Suffixes the word's name with \"?\" and creates a word with that name in the same vocabulary as the word itself." } ;

HELP: define-predicate
{ $values { "class" class } { "quot" quotation } }
{ $description "Defines a predicate word for a class." }
$low-level-note ;

HELP: superclass
{ $values { "class" class } { "super" class } }
{ $description "Outputs the superclass of a class. All instances of this class are also instances of the superclass." } ;

HELP: members
{ $values { "class" class } { "seq" "a sequence of union members, or " { $link f } } }
{ $description "If " { $snippet "class" } " is a union class, outputs a sequence of its member classes, otherwise outputs " { $link f } "." } ;

HELP: define-class
{ $values { "word" word } { "members" "a sequence of class words" } { "superclass" class } { "metaclass" class } }
{ $description "Sets a property indicating this word is a class word, thus making it an instance of " { $link class } ", and registers it with " { $link update-map } "." }
$low-level-note ;
