USING: generic help.markup help.syntax kernel kernel.private
namespaces sequences words arrays layouts help effects math
layouts classes.private classes.union classes.mixin
classes.predicate ;
IN: classes

ARTICLE: "builtin-classes" "Built-in classes"
"Every object is an instance of to exactly one canonical " { $emphasis "built-in class" } " which defines its layout in memory and basic behavior."
$nl
"Corresponding to every built-in class is a built-in type number. An object can be asked for its built-in type number:"
{ $subsection type }
"Built-in type numbers can be converted to classes, and vice versa:"
{ $subsection type>class }
{ $subsection type-number }
"The set of built-in classes is a class:"
{ $subsection builtin-class }
{ $subsection builtin-class? }
"See " { $link "type-index" } " for a list of built-in classes." ;

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
{ $subsection types }
{ $subsection flatten-class }
{ $subsection flatten-builtin-class }
{ $subsection flatten-union-class } ;

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
{ $examples { $example "USE: classes" "1.0 class ." "float" } { $example "USE: classes" "TUPLE: point x y z ;\nT{ point f 1 2 3 } class ." "point" } } ;

HELP: classes
{ $values { "seq" "a sequence of class words" } }
{ $description "Finds all class words in the dictionary." } ;

HELP: builtin-class
{ $class-description "The class of built-in classes." }
{ $examples
    "The class of arrays is a built-in class:"
    { $example "USE: classes" "array builtin-class? ." "t" }
    "However, a literal array is not a built-in class; it is not even a class:"
    { $example "USE: classes" "{ 1 2 3 } builtin-class? ." "f" }
} ;

HELP: tuple-class
{ $class-description "The class of tuple class words." }
{ $examples { $example "USE: classes\nTUPLE: name title first last ;\nname tuple-class? ." "t" } } ;

HELP: typemap
{ $var-description "Hashtable mapping unions to class words, used to implement " { $link class-and } " and " { $link class-or } "." } ;

HELP: builtins
{ $var-description "Vector mapping type numbers to builtin class words." } ;

HELP: class<map
{ $var-description "Hashtable mapping each class to a set of classes which are contained in that class under the " { $link (class<) } " relation. The " { $link class< } " word uses this hashtable to avoid frequent expensive calls to " { $link (class<) } "." } ;

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
{ $values { "class" class } { "predicate" "a predicate word" } { "quot" "a quotation" } }
{ $description
    "Defines a predicate word. This is identical to a compound definition associating " { $snippet "quot" } " with " { $snippet "predicate" } " with the added perk that three word properties are set:"
    { $list
        { "the class word's " { $snippet "\"predicate\"" } " property is set to a quotation that calls the predicate" }
        { "the predicate word's " { $snippet "\"predicating\"" } " property is set to the class word" }
        { "the predicate word's " { $snippet "\"declared-effect\"" } " word property is set to a descriptive " { $link effect } }
    }
    "These properties are used by method dispatch and the help system."
}
$low-level-note ;

HELP: superclass
{ $values { "class" class } { "super" class } }
{ $description "Outputs the superclass of a class. All instances of this class are also instances of the superclass." }
{ $notes "If " { $link class< } " yields that one class is a subtype of another, it does not imply that a superclass relation is involved. The superclass relation is a technical implementation detail of predicate and tuple classes." } ;

HELP: members
{ $values { "class" class } { "seq" "a sequence of union members, or " { $link f } } }
{ $description "If " { $snippet "class" } " is a union class, outputs a sequence of its member classes, otherwise outputs " { $link f } "." } ;

HELP: flatten-union-class
{ $values { "class" class } { "assoc" "an assoc whose keys are classes" } }
{ $description "Outputs the set of classes whose union is equal to " { $snippet "class" } ". Unions are expanded recursively so the output assoc does not contain any union classes. However, it may contain predicate classes whose superclasses are unions." } ;

HELP: flatten-builtin-class
{ $values { "class" class } { "assoc" "an assoc whose keys are classes" } }
{ $description "Outputs a set of tuple classes whose union is the smallest cover of " { $snippet "class" } " intersected with " { $link tuple } "." } ;

HELP: flatten-class
{ $values { "class" class } { "assoc" "an assoc whose keys are classes" } }
{ $description "Outputs a set of builtin and tuple classes whose union is the smallest cover of " { $snippet "class" } "." } ;

HELP: types
{ $values { "class" class } { "seq" "an increasing sequence of integers" } }
{ $description "Outputs a sequence of builtin type numbers whose instances can possibly be instances of the given class." } ;

HELP: class-empty?
{ $values { "class" "a class" } { "?" "a boolean" } }
{ $description "Tests if a class is a union class with no members." }
{ $examples { $example "USE: classes" "null class-empty? ." "t" } } ;

HELP: (class<)
{ $values { "class1" "a class" } { "class2" "a class" } { "?" "a boolean" } }
{ $description "Performs the calculation for " { $link class< } ". There is never any reason to call this word from user code since " { $link class< } " outputs identical values and caches results for better performance." } ;

HELP: class<
{ $values { "class1" "a class" } { "class2" "a class" } { "?" "a boolean" } }
{ $description "Tests if all instances of " { $snippet "class1" } " are also instances of " { $snippet "class2" } "." }
{ $notes "Classes are partially ordered. This means that if " { $snippet "class1 <= class2" } " and " { $snippet "class2 <= class1" } ", then " { $snippet "class1 = class2" } ". Also, if " { $snippet "class1 <= class2" } " and " { $snippet "class2 <= class3" } ", then " { $snippet "class1 <= class3" } "." } ;

HELP: sort-classes
{ $values { "seq" "a sequence of class" } { "newseq" "a new seqence of classes" } }
{ $description "Outputs a topological sort of a sequence of classes. Larger classes come before their subclasses." } ;

{ sort-classes methods order } related-words

HELP: lookup-union
{ $values { "classes" "a hashtable mapping class words to themselves" } { "class" class } }
{ $description "Given a set of classes represented as a hashtable with equal keys and values, looks up a previously-defined union class having those members. If no union is defined, outputs " { $link object } "." } ;

{ class-and class-or lookup-union } related-words

HELP: class-or
{ $values { "class1" class } { "class2" class } { "class" class } }
{ $description "Outputs the smallest known class containing both " { $snippet "class1" } " and " { $snippet "class2" } "." } ;

HELP: class-and
{ $values { "class1" class } { "class2" class } { "class" class } }
{ $description "Outputs the largest known class contained in both " { $snippet "class1" } " and " { $snippet "class2" } ". If the intersection is non-empty but no union class with those exact members is defined, outputs " { $link object } ". If the intersection is empty, outputs " { $link null } "." } ;

HELP: classes-intersect?
{ $values { "class1" class } { "class2" class } { "?" "a boolean" } }
{ $description "Tests if two classes have a non-empty intersection. If the intersection is empty, no object can be an instance of both classes at once." } ;

HELP: min-class
{ $values { "class" class } { "seq" "a sequence of class words" } { "class/f" "a class word or " { $link f } } }
{ $description "If all classes in " { $snippet "seq" } " that intersect " { $snippet "class" } " are subtypes of " { $snippet "class" } ", outputs the last such element of " { $snippet "seq" } ". If any conditions fail to hold, outputs " { $link f } "." } ;

HELP: define-class
{ $values { "word" word } { "members" "a sequence of class words" } { "superclass" class } { "metaclass" class } }
{ $description "Sets a property indicating this word is a class word, thus making it an instance of " { $link class } ", and registers it with " { $link typemap } " and " { $link class<map } "." }
$low-level-note ;

: $predicate ( element -- )
    { { "object" object } { "?" "a boolean" } } $values
    [
        "Tests if the object is an instance of the " ,
        first "predicating" word-prop \ $link swap 2array ,
        " class." ,
    ] { } make $description ;

M: predicate word-help* drop \ $predicate ;

HELP: $predicate
{ $values { "element" "a markup element of the form " { $snippet "{ word }" } } }
{ $description "Prints the boilerplate description of a class membership predicate word such as " { $link array? } " or " { $link integer? } "." } ;
