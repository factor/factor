USING: classes.private help.markup help.syntax kernel sequences words ;
IN: classes

ARTICLE: "class-predicates" "Class predicate words"
"With a handful of exceptions, each class has a membership predicate word, named " { $snippet { $emphasis "class" } "?" } ". A quotation calling this predicate is stored in the " { $snippet "\"predicate\"" } " word property."
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
"A predicate word holds a reference to the class it is predicating over in the " { $snippet "\"predicating\"" } " word property." $nl
"Implementation of class reloading:"
{ $subsections reset-class forget-class forget-methods } ;

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
{ $subsections class-of }
"Testing if an object is an instance of a class:"
{ $subsections instance? }
"You can ask a class for its superclass:"
{ $subsections
    superclass-of
    superclasses-of
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
    "maybes"
    "mixins"
    "predicates"
    "singletons"
    "enums"
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
{ $class-description "The class of all class words." } ;

HELP: class-members
{ $values { "class" class } { "seq" "a sequence of union members, or " { $link f } } }
{ $description "If " { $snippet "class" } " is a union class, outputs a sequence of its member classes, otherwise outputs " { $link f } "." } ;

HELP: class-of
{ $values { "object" object } { "class" class } }
{ $description "Outputs an object's canonical class. While an object may be an instance of more than one class, the canonical class is either its built-in class, or if the object is a tuple, its tuple class." }
{ $examples { $example "USING: classes prettyprint ;" "1.0 class-of ." "float" } { $example "USING: classes prettyprint ;" "IN: scratchpad" "TUPLE: point x y z ;\nT{ point f 1 2 3 } class-of ." "point" } } ;

HELP: class-usage
{ $values { "class" class } { "seq" sequence } }
{ $description "Lists all classes that uses or depends on this class." } ;

HELP: classes
{ $values { "seq" { $sequence class } } }
{ $description "Finds all class words in the dictionary." } ;

HELP: contained-classes
{ $values { "obj" class } { "members" sequence } }
{ $description "Lists all classes contained in the class." }
{ $see-also all-contained-classes } ;

HELP: define-predicate
{ $values { "class" class } { "quot" { $quotation ( obj -- ? ) } } }
{ $description "Defines a predicate word for a class." }
$low-level-note ;

HELP: metaclass-changed
{ $values { "use" class } { "class" class } }
{ $description "Notifies the class 'class' that its metaclass 'use' has changed." } ;

HELP: predicate-def
{ $values { "obj" "a type object" } { "quot" { $quotation ( obj -- ? ) } } }
{ $description "Outputs a quotation that can be used to check if objects are an instance of the given type." }
{ $examples
  { $example
    "USING: classes math prettyprint ;"
    "fixnum predicate-def ."
    "[ fixnum? ]"
  }
} ;

HELP: predicate-word
{ $values { "word" word } { "predicate" "a predicate word" } }
{ $description "Suffixes the word's name with \"?\" and creates a word with that name in the same vocabulary as the word itself." } ;

HELP: superclass-of
{ $values { "class" class } { "super" class } }
{ $description "Outputs the superclass of a class. All instances of this class are also instances of the superclass." }
{ $examples
    { $example "USING: classes prettyprint ;"
               "t superclass-of ."
               "word"
    }
} ;

HELP: superclasses-of
{ $values
    { "class" class }
    { "supers" sequence } }
{ $description "Outputs a sequence of superclasses of a class along with the class itself." }
{ $examples
    { $example "USING: classes prettyprint ;"
               "t superclasses-of ."
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

HELP: update-map
{ $var-description "Assoc mapping each class to a set of classes defined in terms of this class. The " { $link define-class } " word uses this information to update generic words when classes are redefined." }
{ $see-also class-usage } ;

{ superclass-of superclasses-of subclass-of? } related-words

HELP: class-participants
{ $values { "class" class } { "seq" "a sequence of intersection participants, or " { $link f } } }
{ $description "If " { $snippet "class" } " is an intersection class, outputs a sequence of its participant classes, otherwise outputs " { $link f } "." } ;

HELP: define-class
{ $values { "word" word } { "superclass" class } { "members" { $sequence class } } { "participants" { $sequence class } } { "metaclass" class } }
{ $description "Sets a property indicating this word is a class word, thus making it an instance of " { $link class } ", and registers it with " { $link update-map } "." }
$low-level-note ;

HELP: implementors
{ $values { "class/classes" { $or class { $sequence class } } } { "seq" "a sequence of generic words" } }
{ $description "Finds all generic words in the dictionary implementing methods for the given set of classes." } ;

HELP: instance?
{ $values
    { "object" object } { "class" class }
    { "?" boolean } }
{ $description "Tests whether the input object is a member of the class." } ;

HELP: reset-class
{ $values { "class" class } }
{ $description "Forgets all of words that the class defines, but not words that are defined on the class. For instance, on a tuple class, this word should reset all of the tuple accessors but not things like " { $link nth } " that may be defined on the class elsewhere." } ;

HELP: forget-class
{ $values { "class" class } }
{ $description "Removes a class by forgetting all of the methods defined on that class and all of the methods generated when that class was defined. Also resets any caches that may contain that class." } ;

HELP: forget-methods
{ $values { "class" class } }
{ $description "Forgets all methods defined on a class. In contrast to " { $link reset-class } ", this not only forgets accessors but also any methods at all on the class." } ;
