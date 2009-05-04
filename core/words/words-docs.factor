USING: definitions help.markup help.syntax kernel parser
kernel.private vocabs classes quotations
strings effects compiler.units ;
IN: words

ARTICLE: "interned-words" "Looking up and creating words"
"A word is said to be " { $emphasis "interned" } " if it is a member of the vocabulary named by its vocabulary slot. Otherwise, the word is " { $emphasis "uninterned" } "."
$nl
"Words whose names are known at parse time -- that is, most words making up your program -- can be referenced in source code by stating their name. However, the parser itself, and sometimes code you write, will need to create look up words dynamically."
$nl
"Parsing words add definitions to the current vocabulary. When a source file is being parsed, the current vocabulary is initially set to " { $vocab-link "scratchpad" } ". The current vocabulary may be changed with the " { $link POSTPONE: IN: } " parsing word (see " { $link "vocabulary-search" } ")."
{ $subsection create }
{ $subsection create-in }
{ $subsection lookup } ;

ARTICLE: "uninterned-words" "Uninterned words"
"A word that is not a member of any vocabulary is said to be " { $emphasis "uninterned" } "."
$nl
"There are several ways of creating an uninterned word:"
{ $subsection <word> }
{ $subsection gensym }
{ $subsection define-temp } ;

ARTICLE: "colon-definition" "Colon definitions"
"Every word has an associated quotation definition that is called when the word is executed. A " { $emphasis "colon definition" } " is a word where this quotation is supplied directly by the user. This is the simplest and most common type of word definition."
$nl
"Defining words at parse time:"
{ $subsection POSTPONE: : }
{ $subsection POSTPONE: ; }
"Defining words at run time:"
{ $subsection define }
{ $subsection define-declared }
{ $subsection define-inline }
"Word definitions must declare their stack effect. See " { $link "effects" } "."
$nl
"All other types of word definitions, such as " { $link "words.symbol" } " and " { $link "generic" } ", are just special cases of the above." ;

ARTICLE: "primitives" "Primitives"
"Primitives are words defined in the Factor VM. They provide the essential low-level services to the rest of the system."
{ $subsection primitive }
{ $subsection primitive? } ;

ARTICLE: "deferred" "Deferred words and mutual recursion"
"Words cannot be referenced before they are defined; that is, source files must order definitions in a strictly bottom-up fashion. This is done to simplify the implementation, facilitate better parse time checking and remove some odd corner cases; it also encourages better coding style."
$nl
"Sometimes this restriction gets in the way, for example when defining mutually-recursive words; one way to get around this limitation is to make a forward definition."
{ $subsection POSTPONE: DEFER: }
"The class of deferred word definitions:"
{ $subsection deferred }
{ $subsection deferred? }
"Deferred words throw an error when called:"
{ $subsection undefined }
"Deferred words are just compound definitions in disguise. The following two lines are equivalent:"
{ $code
    "DEFER: foo"
    ": foo undefined ;"
} ;

ARTICLE: "declarations" "Compiler declarations"
"Compiler declarations are parsing words that set a word property in the most recently defined word. They appear after the final " { $link POSTPONE: ; } " of a word definition:"
{ $code ": cubed ( x -- y ) dup dup * * ; foldable" }
"Compiler declarations assert that the word follows a certain contract, enabling certain optimizations that are not valid in general."
{ $subsection POSTPONE: inline }
{ $subsection POSTPONE: foldable }
{ $subsection POSTPONE: flushable }
{ $subsection POSTPONE: recursive }
"It is entirely up to the programmer to ensure that the word satisfies the contract of a declaration. Furthermore, if a generic word is declared " { $link POSTPONE: foldable } " or " { $link POSTPONE: flushable } ", all methods must satisfy the contract. Unspecified behavior may result if a word does not follow the contract of one of its declarations."
{ $see-also "effects" } ;

ARTICLE: "word-props" "Word properties"
"Each word has a hashtable of properties."
{ $subsection word-prop }
{ $subsection set-word-prop }
"The stack effect of the above two words is designed so that it is most convenient when " { $snippet "name" } " is a literal pushed on the stack right before executing this word."
$nl
"The following are some of the properties used by the library:"
{ $table
    { "Property" "Documentation" }
    { { $snippet "\"parsing\"" } { $link "parsing-words" } }

    { { { $snippet "\"inline\"" } ", " { $snippet "\"foldable\"" } ", " { $snippet "flushable" } } { $link "declarations" } }

    { { $snippet "\"loc\"" } { "Location information - " { $link where } } }
    
    { { { $snippet "\"methods\"" } ", " { $snippet "\"combination\"" } } { "Set on generic words - " { $link "generic" } } }
    
    { { { $snippet "\"reading\"" } ", " { $snippet "\"writing\"" } } { "Set on slot accessor words - " { $link "slots" } } }

    { { $snippet "\"declared-effect\"" } { $link "effects" } }
    
    { { { $snippet "\"help\"" } ", " { $snippet "\"help-loc\"" } ", " { $snippet "\"help-parent\"" } } { "Where word help is stored - " { $link "writing-help" } } }

    { { $snippet "\"specializer\"" } { $link "hints" } }
    
    { { $snippet "\"predicating\"" } " Set on class predicates, stores the corresponding class word" }
}
"Properties which are defined for classes only:"
{ $table
    { "Property" "Documentation" }
    { { $snippet "\"class\"" } { "A boolean indicating whether this word is a class - " { $link "classes" } } }

    { { $snippet "\"coercer\"" } { "A quotation for converting the top of the stack to an instance of this class" } }
    
    { { $snippet "\"constructor\"" } { $link "tuple-constructors" } }
    
    { { $snippet "\"type\"" } { $link "builtin-classes" } }
    
    { { { $snippet "\"superclass\"" } ", " { $snippet "\"predicate-definition\"" } } { $link "predicates" } }
    
    { { $snippet "\"members\"" } { $link "unions" } }

    { { $snippet "\"slots\"" } { $link "slots" } }

    { { $snippet "\"predicate\"" } { "A quotation that tests if the top of the stack is an instance of this class - " { $link "class-predicates" } } }
} ;

ARTICLE: "word.private" "Word implementation details"
"The " { $snippet "def" } " slot of a word holds a " { $link quotation } " instance that is called when the word is executed."
$nl
"An " { $emphasis "XT" } " (execution token) is the machine code address of a word:"
{ $subsection word-xt } ;

ARTICLE: "words.introspection" "Word introspection"
"Word introspection facilities and implementation details are found in the " { $vocab-link "words" } " vocabulary."
$nl
"Word objects contain several slots:"
{ $table
    { { $snippet "name" } "a word name" }
    { { $snippet "vocabulary" } "a word vocabulary name" }
    { { $snippet "def" } "a definition quotation" }
    { { $snippet "props" } "an assoc of word properties, including documentation and other meta-data" }
}
"Words are instances of a class."
{ $subsection word }
{ $subsection word? }
"Words implement the definition protocol; see " { $link "definitions" } "."
{ $subsection "interned-words" }
{ $subsection "uninterned-words" }
{ $subsection "word-props" }
{ $subsection "word.private" } ;

ARTICLE: "words" "Words"
"Words are the Factor equivalent of functions or procedures; a word is essentially a named quotation."
$nl
"There are two ways of creating word definitions:"
{ $list
    "using parsing words at parse time,"
    "using defining words at run time."
}
"The latter is a more dynamic feature that can be used to implement code generation and such, and in fact parse time defining words are implemented in terms of run time defining words."
$nl
"Types of words:"
{ $subsection "colon-definition" }
{ $subsection "words.symbol" }
{ $subsection "words.alias" }
{ $subsection "words.constant" }
{ $subsection "primitives" }
"Advanced topics:"
{ $subsection "deferred" }
{ $subsection "declarations" }
{ $subsection "words.introspection" }
{ $see-also "vocabularies" "vocabs.loader" "definitions" "see" } ;

ABOUT: "words"

HELP: deferred
{ $class-description "The class of deferred words created by " { $link POSTPONE: DEFER: } "." } ;

{ deferred POSTPONE: DEFER: } related-words

HELP: primitive
{ $description "The class of primitive words." } ;

HELP: word-prop
{ $values { "word" word } { "name" "a property name" } { "value" "a property value" } }
{ $description "Retrieves a word property. Word property names are conventionally strings." } ;

HELP: set-word-prop
{ $values { "word" word } { "value" "a property value" } { "name" "a property name" } }
{ $description "Stores a word property. Word property names are conventionally strings." }
{ $side-effects "word" } ;

HELP: remove-word-prop
{ $values { "word" word } { "name" "a property name" } }
{ $description "Removes a word property, so future lookups will output " { $link f } " until it is set again. Word property names are conventionally strings." }
{ $side-effects "word" } ;

HELP: word-xt ( word -- start end )
{ $values { "word" word } { "start" "the word's start address" } { "end" "the word's end address" } }
{ $description "Outputs the machine code address of the word's definition." } ;

HELP: define
{ $values { "word" word } { "def" quotation } }
{ $description "Defines the word to call a quotation when executed. This is the run time equivalent of " { $link POSTPONE: : } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "word" } ;

HELP: reset-props
{ $values { "word" word } { "seq" "a sequence of word property names" } }
{ $description "Removes all listed word properties from the word." }
{ $side-effects "word" } ;

HELP: reset-word
{ $values { "word" word } }
{ $description "Reset word declarations." }
$low-level-note
{ $side-effects "word" } ;

HELP: reset-generic
{ $values { "word" word } }
{ $description "Reset word declarations and generic word properties." }
$low-level-note
{ $side-effects "word" } ;

HELP: <word> ( name vocab -- word )
{ $values { "name" string } { "vocab" string } { "word" word } }
{ $description "Allocates an uninterned word with the specified name and vocabulary, and a blank word property hashtable. User code should call " { $link gensym } " to create uninterned words and " { $link create } " to create interned words." } ;

HELP: gensym
{ $values { "word" word } }
{ $description "Creates an uninterned word that is not equal to any other word in the system." }
{ $examples { $unchecked-example "gensym ." "G:260561" } }
{ $notes "Gensyms are often used as placeholder values that have no meaning of their own but must be unique. For example, the compiler uses gensyms to label sections of code." } ;

HELP: bootstrapping?
{ $var-description "Set by the library while bootstrap is in progress. Some parsing words need to behave differently during bootstrap." } ;

HELP: word
{ $values { "word" word } }
{ $description "Outputs the most recently defined word." }
{ $class-description "The class of words. One notable subclass is " { $link class } ", the class of class words." } ;

{ word set-word save-location } related-words

HELP: set-word
{ $values { "word" word } }
{ $description "Sets the recently defined word." } ;

HELP: lookup
{ $values { "name" string } { "vocab" string } { "word" "a word or " { $link f } } }
{ $description "Looks up a word in the dictionary. If the vocabulary or the word is not defined, outputs " { $link f } "." } ;

HELP: reveal
{ $values { "word" word } }
{ $description "Adds a newly-created word to the dictionary. Usually this word does not need to be called directly, and is only called as part of " { $link create } "." } ;

HELP: check-create
{ $values { "name" string } { "vocab" string } }
{ $description "Throws a " { $link check-create } " error if " { $snippet "name" } " or " { $snippet "vocab" } " is not a string." }
{ $error-description "Thrown if " { $link create } " is called with invalid parameters." } ;

HELP: create
{ $values { "name" string } { "vocab" string } { "word" word } }
{ $description "Creates a new word. If the vocabulary already contains a word with the requested name, outputs the existing word. The vocabulary must exist already; if it does not, you must call " { $link create-vocab } " first." } ;

HELP: constructor-word
{ $values { "name" string } { "vocab" string } { "word" word } }
{ $description "Creates a new word, surrounding " { $snippet "name" } " in angle brackets." }
{ $examples { $example "USING: prettyprint words ;" "\"salmon\" \"scratchpad\" constructor-word ." "<salmon>" } } ;

{ POSTPONE: FORGET: forget forget* forget-vocab } related-words

HELP: target-word
{ $values { "word" word } { "target" word } }
{ $description "Looks up a word with the same name and vocabulary as the given word. Used during bootstrap to transfer host words to the target dictionary." } ;

HELP: bootstrap-word
{ $values { "word" word } { "target" word } }
{ $description "Looks up a word with the same name and vocabulary as the given word, performing a transformation to handle parsing words in the target dictionary. Used during bootstrap to transfer host words to the target dictionary." } ;

HELP: parsing-word?
{ $values { "object" object } { "?" "a boolean" } }
{ $description "Tests if an object is a parsing word declared by " { $link POSTPONE: SYNTAX: } "." }
{ $notes "Outputs " { $link f } " if the object is not a word." } ;

HELP: define-declared
{ $values { "word" word } { "def" quotation } { "effect" effect } }
{ $description "Defines a word and declares its stack effect." }
{ $side-effects "word" } ;

HELP: define-temp
{ $values { "quot" quotation } { "effect" effect } { "word" word } }
{ $description "Creates an uninterned word that will call " { $snippet "quot" } " when executed." }
{ $notes
    "The following phrases are equivalent:"
    { $code "[ 2 2 + . ] call" }
    { $code "[ 2 2 + . ] (( -- )) define-temp execute" }
    "This word must be called from inside " { $link with-compilation-unit } "."
} ;

HELP: delimiter?
{ $values { "obj" object } { "?" "a boolean" } }
{ $description "Tests if an object is a delimiter word declared by " { $link POSTPONE: delimiter } "." }
{ $notes "Outputs " { $link f } " if the object is not a word." } ;

HELP: make-flushable
{ $values { "word" word } }
{ $description "Declares a word as " { $link POSTPONE: flushable } "." }
{ $side-effects "word" } ;

HELP: make-foldable
{ $values { "word" word } }
{ $description "Declares a word as " { $link POSTPONE: foldable } "." }
{ $side-effects "word" } ;

HELP: make-inline
{ $values { "word" word } }
{ $description "Declares a word as " { $link POSTPONE: inline } "." }
{ $side-effects "word" } ;

HELP: define-inline
{ $values { "word" word } { "def" quotation } { "effect" effect } }
{ $description "Defines a word and makes it " { $link POSTPONE: inline } "." }
{ $side-effects "word" } ;
