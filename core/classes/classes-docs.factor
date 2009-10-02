USING: help.markup help.syntax kernel kernel.private
namespaces sequences words arrays effects math
classes.private classes.union classes.mixin
classes.predicate quotations ;
IN: classes

ARTICLE: "class-predicates" "Class predicate words"
"With a handful of exceptions, each class has a membership predicate word, named " { $snippet { $emphasis "class" } "?" } " . A quotation calling this predicate is stored in the " { $snippet "\"predicate\"" } " word property."
$nl
"When it comes to predicates, the exceptional classes are:"
{ $table
    { "Class" "Predicate" "Explanation" }
    { { $link f } { $snippet "[ not ]" } { "The conventional name for a word which outputs true when given false is " { $link not } "; " { $snippet "f?" } " would be confusing." } }
    { { $link object } { $snippet "[ drop t ]" } { "All objects are instances of " { $link object } } }
    { { $link null } { $snippet "[ drop f ]" } { "No object is an instance of " { $link null } } }
}
"The set of class predicate words is a class:"
{ $subsections
    predicate
    predicate?
}
"A predicate word holds a reference to the class it is predicating over in the " { $snippet "\"predicating\"" } " word property." ;

ARTICLE: "classes" "Classes"
"Conceptually, a " { $snippet "class" } " is a set of objects whose members can be identified with a predicate, and on which generic words can specialize methods. Classes are organized into a general partial order, and an object may be an instance of more than one class."
$nl
"At the implementation level, a class is a word with certain word properties set."
$nl
"Words for working with classes are found in the " { $vocab-link "classes" } " vocabulary."
$nl
"Classes themselves form a class:"
{ $subsections class? }
"You can ask an object for its class:"
{ $subsections class }
"Testing if an object is an instance of a class:"
{ $subsections instance? }
"You can ask a class for its superclass:"
{ $subsections
    superclass
    superclasses
    subclass-of?
}
"Class predicates can be used to test instances directly:"
{ $subsections "class-predicates" }
"There is a universal class which all objects are an instance of, and an empty class with no instances:"
{ $subsections
    object
    null
}
"Obtaining a list of all defined classes:"
{ $subsections classes }
"There are several sorts of classes:"
{ $subsections
    "builtin-classes"
    "unions"
    "intersections"
    "mixins"
    "predicates"
    "singletons"
}
{ $link "tuples" } " are documented in their own section."
$nl
"Classes can be inspected and operated upon:"
{ $subsections
    "class-operations"
    "class-linearization"
}
{ $see-also "class-index" } ;

ABOUT: "classes"

HELP: class
{ $values { "object" object } { "class" class } }
{ $description "Outputs an object's canonical class. While an object may be an instance of more than one class, the canonical class is either its built-in class, or if the object is a tuple, its tuple class." }
{ $class-description "The class of all class words." }
{ $examples { $example "USING: classes prettyprint ;" "1.0 class ." "float" } { $example "USING: classes prettyprint ;" "IN: scratchpad" "TUPLE: point x y z ;\nT{ point f 1 2 3 } class ." "point" } } ;

HELP: classes
{ $values { "seq" "a sequence of class words" } }
{ $description "Finds all class words in the dictionary." } ;

HELP: update-map
{ $var-description "Assoc mapping each class to a set of classes defined in terms of this class. The " { $link define-class } " word uses this information to update generic words when classes are redefined." } ;

HELP: predicate-word
{ $values { "word" "a word" } { "predicate" "a predicate word" } }
{ $description "Suffixes the word's name with \"?\" and creates a word with that name in the same vocabulary as the word itself." } ;

HELP: define-predicate
{ $values { "class" class } { "quot" quotation } }
{ $description "Defines a predicate word for a class." }
$low-level-note ;

HELP: superclass
{ $values { "class" class } { "super" class } }
{ $description "Outputs the superclass of a class. All instances of this class are also instances of the superclass." }
{ $examples 
    { $example "USING: classes prettyprint ;"
               "t superclass ."
               "word"
    }
} ;

HELP: superclasses
{ $values
     { "class" class }
     { "supers" sequence } }
{ $description "Outputs a sequence of superclasses of a class along with the class itself." }
{ $examples 
    { $example "USING: classes prettyprint ;"
               "t superclasses ."
               "{ word t }"
    }
} ;

HELP: subclass-of?
{ $values
    { "class" class }
    { "superclass" class }
    { "?" boolean }
}
{ $description "Outputs a boolean value indicating whether " { $snippet "class" } " is at any level a subclass of " { $snippet "superclass" } "." }
{ $examples 
    { $example "USING: classes classes.tuple prettyprint words ;"
               "tuple-class \\ class subclass-of? ."
               "t"
    }
} ;

{ superclass superclasses subclass-of? } related-words

HELP: members
{ $values { "class" class } { "seq" "a sequence of union members, or " { $link f } } }
{ $description "If " { $snippet "class" } " is a union class, outputs a sequence of its member classes, otherwise outputs " { $link f } "." } ;

HELP: participants
{ $values { "class" class } { "seq" "a sequence of intersection participants, or " { $link f } } }
{ $description "If " { $snippet "class" } " is an intersection class, outputs a sequence of its participant classes, otherwise outputs " { $link f } "." } ;

HELP: define-class
{ $values { "word" word } { "superclass" class } { "members" "a sequence of class words" } { "participants" "a sequence of class words" } { "metaclass" class } }
{ $description "Sets a property indicating this word is a class word, thus making it an instance of " { $link class } ", and registers it with " { $link update-map } "." }
$low-level-note ;

HELP: implementors
{ $values { "class/classes" "a class or a sequence of classes" } { "seq" "a sequence of generic words" } }
{ $description "Finds all generic words in the dictionary implementing methods for the given set of classes." } ;

HELP: instance?
{ $values
     { "object" object } { "class" class }
     { "?" "a boolean" } }
{ $description "Tests whether the input object is a member of the class." } ;
