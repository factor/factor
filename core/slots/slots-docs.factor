USING: help.markup help.syntax generic kernel.private parser
words kernel quotations namespaces sequences words arrays
effects generic.standard tuples slots.private classes
strings math ;
IN: slots

ARTICLE: "slots" "Slots"
"A " { $emphasis "slot" } " is a component of an object which can store a value. The " { $vocab-link "slots" } " vocabulary contains words for introspecting the slots of an object."
$nl
{ $link "tuples" } " are composed entirely of slots, and instances of " { $link "builtin-classes" } " consist of slots together with intrinsic data."
$nl
"The " 
"The " { $snippet "\"slots\"" } " word property of built-in and tuple classes holds an array of " { $emphasis "slot specifiers" } " describing the slot layout of each instance."
{ $subsection slot-spec }
"Each slot has a reader word; mutable slots have an optional writer word. All tuple slots are mutable, but some slots on built-in classes are not."
{ $subsection slot-spec-reader }
{ $subsection slot-spec-writer }
"Given a reader or writer word and a class, it is possible to find the slot specifier corresponding to this word:"
{ $subsection slot-of-reader }
{ $subsection slot-of-writer }
"Reader and writer words form classes:"
{ $subsection slot-reader }
{ $subsection slot-writer }
"Slot readers and writers type check, then call unsafe primitives:"
{ $subsection slot }
{ $subsection set-slot } ;

ABOUT: "slots"

HELP: slot-spec
{ $class-description "A slot specification. The " { $snippet "\"slots\"" } " word property of " { $link builtin-class } " and " { $link tuple-class } " instances holds sequences of slot specifications."
$nl
"The slots of a slot specification are:"
{ $list
    { { $link slot-spec-type } " - a " { $link class } " declaring the set of possible values for the slot." }
    { { $link slot-spec-name } " - a " { $link string } " identifying the slot." }
    { { $link slot-spec-offset } " - an " { $link integer } " offset specifying where the slot value is stored inside instances of the relevant class. This is an implementation detail." }
    { { $link slot-spec-reader } " - a " { $link word } " for reading the value of this slot." }
    { { $link slot-spec-writer } " - a " { $link word } " for writing the value of this slot." }
} } ;

HELP: define-typecheck
{ $values { "class" class } { "generic" "a generic word" } { "quot" quotation } }
{ $description
    "Defines a generic word with the " { $link standard-combination } " using dispatch position 0, and having one method on " { $snippet "class" } "."
    $nl
    "This creates a definition analogous to the following code:"
    { $code
        "GENERIC: generic"
        "M: class generic quot ;"
    }
    "It checks if the top of the stack is an instance of " { $snippet "class" } ", and if so, executes the quotation. Delegation is respected."
}
{ $notes "This word is used internally to wrap low-level code that does not do type-checking in safe user-visible words. For example, see how " { $link word-name } " is implemented." } ;

HELP: define-slot-word
{ $values { "class" class } { "slot" "a positive integer" } { "word" word } { "quot" quotation } }
{ $description "Defines " { $snippet "word" } " to be a simple type-checking generic word that receives the slot number on the stack as a fixnum." }
$low-level-note ;

HELP: reader-effect
{ $values { "class" class } { "spec" slot-spec } { "effect" "an instance of " { $link effect } } }
{ $description "The stack effect of slot reader words is " { $snippet "( obj -- value )" } "." } ;

HELP: reader-quot
{ $values { "decl" class } { "quot" "a quotation with stack effect " { $snippet "( obj n -- value )" } } }
{ $description "Outputs a quotation which reads the " { $snippet "n" } "th slot of an object and declares it as an instance of a class." } ;

HELP: slot-reader
{ $class-description "The class of slot reader words." }
{ $examples
    { $example "USING: classes slots ;" "TUPLE: circle center radius ;" "\\ circle-center slot-reader? ." "t" }
} ;

HELP: define-reader
{ $values { "class" class } { "spec" slot-spec } }
{ $description "Defines a generic word " { $snippet "reader" } " to read a slot from instances of " { $snippet "class" } "." }
$low-level-note ;

HELP: writer-effect
{ $values { "class" class } { "spec" slot-spec } { "effect" "an instance of " { $link effect } } }
{ $description "The stack effect of slot writer words is " { $snippet "( value obj -- )" } "." } ;

HELP: slot-writer
{ $class-description "The class of slot writer words." }
{ $examples
    { $example "USING: classes slots ;" "TUPLE: circle center radius ;" "\\ set-circle-center slot-writer? ." "t" }
} ;

HELP: define-writer
{ $values { "class" class } { "spec" slot-spec } }
{ $description "Defines a generic word " { $snippet "writer" } " to write a new value to a slot in instances of " { $snippet "class" } "." }
$low-level-note ;

HELP: define-slot
{ $values { "class" class } { "spec" slot-spec } }
{ $description "Defines a pair of generic words for reading and writing a slot value in instances of " { $snippet "class" } "." }
$low-level-note ;

HELP: define-slots
{ $values { "class" class } { "specs" "a sequence of " { $link slot-spec } " instances" } }
{ $description "Defines a set of slot reader/writer words." }
$low-level-note ;

HELP: simple-slots
{ $values { "class" class } { "slots" "a sequence of strings" } { "base" "a slot number" } { "specs" "a sequence of " { $link slot-spec } " instances" } }
{ $description "Constructs a slot specification for " { $link define-slots } " where each slot is named by an element of " { $snippet "slots" } " prefixed by the name of the class. Slots are numbered consecutively starting from " { $snippet "base" } ". Reader and writer words are defined in the current vocabulary, with the reader word having the same name as the slot, and the writer word name prefixed by " { $snippet "\"set-\"" } "." }
{ $notes "This word is used by " { $link define-tuple-class } " and " { $link POSTPONE: TUPLE: } "." } ;

HELP: slot ( obj m -- value )
{ $values { "obj" object } { "m" "a non-negative fixnum" } { "value" object } }
{ $description "Reads the object stored at the " { $snippet "n" } "th slot of " { $snippet "obj" } "." }
{ $warning "This word is in the " { $vocab-link "slots.private" } " vocabulary because it does not perform type or bounds checks, and slot numbers are implementation detail." } ;

HELP: set-slot ( value obj n -- )
{ $values { "value" object } { "obj" object } { "n" "a non-negative fixnum" } }
{ $description "Writes " { $snippet "value" } " to the " { $snippet "n" } "th slot of " { $snippet "obj" } "." }
{ $warning "This word is in the " { $vocab-link "slots.private" } " vocabulary because it does not perform type or bounds checks, and slot numbers are implementation detail." } ;

HELP: slot-of-reader
{ $values { "reader" slot-reader } { "specs" "a sequence of " { $link slot-spec } " instances" } { "spec/f" "a " { $link slot-spec } " or " { $link f } } }
{ $description "Outputs the " { $link slot-spec } " whose " { $link slot-spec-reader } " is equal to " { $snippet "reader" } "." } ;

HELP: slot-of-writer
{ $values { "writer" slot-writer } { "specs" "a sequence of " { $link slot-spec } " instances" } { "spec/f" "a " { $link slot-spec } " or " { $link f } } }
{ $description "Outputs the " { $link slot-spec } " whose " { $link slot-spec-writer } " is equal to " { $snippet "writer" } "." } ;

HELP: reader-word
{ $values { "class" string } { "name" string } { "vocab" string } { "word" word } }
{ $description "Creates a word named " { $snippet { $emphasis "class" } "-" { $emphasis "name" } } " in the " { $snippet "vocab" } " vocabulary." } ;

HELP: writer-word
{ $values { "class" string } { "name" string } { "vocab" string } { "word" word } }
{ $description "Creates a word named " { $snippet "set-" { $emphasis "class" } "-" { $emphasis "name" } } " in the " { $snippet "vocab" } " vocabulary." } ;
