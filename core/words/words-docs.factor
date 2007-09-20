USING: definitions help.markup help.syntax kernel
kernel.private parser words.private vocabs classes quotations
strings effects ;
IN: words

ARTICLE: "interned-words" "Looking up and creating words"
"A word is said to be " { $emphasis "interned" } " if it is a member of the vocabulary named by its vocabulary slot. Otherwise, the word is " { $emphasis "uninterned" } "."
$nl
"Words whose names are known at parse time -- that is, most words making up your program -- can be referenced in source code by stating their name. However, the parser itself, and sometimes code you write, will need to create look up words dynamically."
$nl
"Parsing words add definitions to the current vocabulary. When a source file is being parsed, the current vocabulary is initially set to " { $vocab-link "scratchpad" } ". The current vocabulary may be changed with the " { $link POSTPONE: IN: } " parsing word (see " { $link "vocabulary-search" } ")."
{ $subsection create }
{ $subsection create-in }
{ $subsection gensym }
{ $subsection lookup }
"Words can output their name and vocabulary:"
{ $subsection word-name }
{ $subsection word-vocabulary }
"Testing if a word object is part of a vocabulary:"
{ $subsection interned? } ;

ARTICLE: "colon-definition" "Compound definitions"
"A compound definition associates a word name with a quotation that is called when the word is executed."
{ $subsection compound }
{ $subsection compound? }
"Defining compound words at parse time:"
{ $subsection POSTPONE: : }
{ $subsection POSTPONE: ; }
"Defining compound words at run time:"
{ $subsection define-compound }
{ $subsection define-declared }
{ $subsection define-inline }
"Compound definitions should declare their stack effect, unless the definition is completely trivial. See " { $link "effect-declaration" } "." ;

ARTICLE: "symbols" "Symbols"
"A symbol pushes itself on the stack when executed. By convention, symbols are used as variable names (" { $link "namespaces" } ")."
{ $subsection symbol }
{ $subsection symbol? }
"Defining symbols at parse time:"
{ $subsection POSTPONE: SYMBOL: }
"Defining symbols at run time:"
{ $subsection define-symbol } ;

ARTICLE: "primitives" "Primitives"
"Primitives are words defined in the Factor VM. They provide the essential low-level services to the rest of the system."
{ $subsection primitive }
{ $subsection primitive? } ;

ARTICLE: "deferred" "Deferred words and mutual recursion"
"Words cannot be referenced before they are defined; that is, source files must order definitions in a strictly bottom-up fashion. This is done to simplify the implementation, facilitate better parse-time checking and remove some odd corner cases; it also encourages better coding style. Sometimes this restriction gets in the way, for example when defining mutually-recursive words; one way to get around this limitation is to make a forward definition."
{ $subsection POSTPONE: DEFER: }
"The class of forward word definitions:"
{ $subsection undefined }
{ $subsection undefined? } ;

ARTICLE: "declarations" "Declarations"
"Declarations give special behavior to a word. Declarations are parsing words that set a word property in the most recently defined word."
$nl
"The first declaration specifies the time when a word runs. It affects both interpreted and compiled definitions."
{ $subsection POSTPONE: parsing }
"The remaining declarations only affect compiled definitions. They do not change evaluation semantics of a word, but instead declare that the word follows a certain contract, and thus may be compiled differently."
{ $warning "If a generic word is declared " { $link POSTPONE: foldable } " or " { $link POSTPONE: flushable } ", all methods must satisfy the contract, otherwise unpredicable behavior will occur." }
{ $subsection POSTPONE: inline }
{ $subsection POSTPONE: foldable }
{ $subsection POSTPONE: flushable }
"Stack effect declarations are documented in " { $link "effect-declaration" } "." ;

ARTICLE: "word-definition" "Defining words"
"There are two approaches to creating word definitions:"
{ $list
    "using parsing words at parse time,"
    "using defining words at run time."
}
"The latter is a more dynamic feature that can be used to implement code generation and such, and in fact parse time defining words are implemented in terms of run time defining words."
{ $subsection "colon-definition" }
{ $subsection "symbols" }
{ $subsection "primitives" }
{ $subsection "deferred" }
{ $subsection "declarations" }
"Words implement the definition protocol; see " { $link "definitions" } "." ;

ARTICLE: "word-props" "Word properties"
"Each word has a hashtable of properties."
{ $subsection word-prop }
{ $subsection set-word-prop }
{ $subsection word-props }
{ $subsection set-word-props }
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

    { { $snippet "\"declared-effect\"" } { $link "effect-declaration" } }
    
    { { { $snippet "\"help\"" } ", " { $snippet "\"help-loc\"" } ", " { $snippet "\"help-parent\"" } } { "Where word help is stored - " { $link "writing-help" } } }

    { { $snippet "\"infer\"" } { $link "compiler-transforms" } }

    { { { $snippet "\"inferred-effect\"" } } { $link "inference" } }

    { { $snippet "\"specializer\"" } { $link "specializers" } }
    
    { { { $snippet "\"intrinsics\"" } ", " { $snippet "\"if-intrinsics\"" } } { $link "generator" } }

    { { $snippet "\"predicating\"" } " Set on class predicates, stores the corresponding class word" }
    
    { { { $snippet "\"constructing\"" } ", " { $snippet "\"constructor-quot\"" } } { $link "tuple-constructors" } }
}
"Properties which are defined for classes only:"
{ $table
    { "Property" "Documentation" }
    { { $snippet "\"class\"" } { "A boolean indicating whether this word is a class - " { $link "classes" } } }

    { { $snippet "\"coercer\"" } { "A quotation for converting the top of the stack to an instance of this class" } }
    
    { { $snippet "\"constructor\"" } { $link "tuple-constructors" } }
    
    { { $snippet "\"slot-names\"" } { $link "tuples" } }
    
    { { $snippet "\"type\"" } { $link "builtin-classes" } }
    
    { { { $snippet "\"superclass\"" } ", " { $snippet "\"predicate-definition\"" } } { $link "predicates" } }
    
    { { $snippet "\"members\"" } { $link "unions" } }

    { { $snippet "\"slots\"" } { $link "slots" } }

    { { $snippet "\"predicate\"" } { "A quotation that tests if the top of the stack is an instance of this class - " { $link "class-predicates" } } }
} ;

ARTICLE: "word.private" "Word implementation details"
"Primitive definition accessors:"
{ $subsection word-def }
{ $subsection set-word-def }
"An " { $emphasis "XT" } " (execution token) is the machine code address of a word:"
{ $subsection word-xt }
{ $subsection update-xt } ;

ARTICLE: "words" "Words"
"Words are the Factor equivalent of functions or procedures; a word is a body of code with a unique name and some additional meta-data. Words are defined in the " { $vocab-link "words" } " vocabulary."
$nl
"A word consists of several parts:"
{ $list
    "a word name,"
    "a vocabulary name,"
    "a definition, specifying the behavior of the word when executed,"
    "a set of word properties, including documentation and other meta-data."
}
"Words are instances of a class."
{ $subsection word }
{ $subsection word? }
{ $subsection "interned-words" }
{ $subsection "word-definition" }
{ $subsection "word.private" }
{ $see-also "vocabularies" "vocabs.loader" "definitions" } ;

ABOUT: "words"

HELP: compiled? ( word -- ? )
{ $values { "word" word } { "?" "a boolean" } }
{ $description "Tests if a word has been compiled." } ;

HELP: execute ( word -- )
{ $values { "word" word } }
{ $description "Executes a word." }
{ $examples
    { $example ": twice dup execute execute ;\n: hello \"Hello\" print ;\n\\ hello twice" "Hello\nHello" }
} ;

HELP: word-props ( word -- props )
{ $values { "word" word } { "props" "an assoc" } }
{ $description "Outputs a word's property table." } ;

HELP: set-word-props ( props word -- )
{ $values { "props" "an assoc" } { "word" word } }
{ $description "Sets a word's property table." }
{ $notes "The given assoc must not be a literal, since it will be mutated by future calls to " { $link set-word-prop } "." }
{ $side-effects "word" } ;

HELP: word-def ( word -- obj )
{ $values { "word" word } { "obj" object } }
{ $description "Outputs a word's primitive definition." } ;

HELP: set-word-def ( obj word -- )
{ $values { "obj" object } { "word" word } }
{ $description "Sets a word's primitive definition." }
$low-level-note
{ $side-effects "word" } ;

HELP: undefined
{ $class-description "The class of undefined words created by " { $link POSTPONE: DEFER: } "." } ;

{ undefined POSTPONE: DEFER: } related-words

HELP: compound
{ $description "The class of compound words created by " { $link POSTPONE: : } "." } ;

HELP: primitive
{ $description "The class of primitive words." } ;

HELP: symbol
{ $description "The class of symbols created by " { $link POSTPONE: SYMBOL: } "." } ;

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

HELP: word-xt
{ $values { "word" word } { "xt" "an execution token integer" } }
{ $description "Outputs the machine code address of the word's definition." } ;

HELP: define
{ $values { "word" word } { "def" object } }
{ $description "Defines a word and updates cross-referencing." }
$low-level-note
{ $side-effects "word" }
{ $see-also define-symbol define-compound } ;

HELP: define-symbol
{ $values { "word" word } }
{ $description "Defines the word to push itself on the stack when executed." }
{ $side-effects "word" } ;

HELP: intern-symbol
{ $values { "word" word } }
{ $description "If the word is undefined, makes it into a symbol which pushes itself on the stack when executed. If the word already has a definition, does nothing." } ;

HELP: define-compound
{ $values { "word" word } { "def" quotation } }
{ $description "Defines the word to call a quotation when executed." }
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

HELP: <word>
{ $values { "name" string } { "vocab" string } { "word" word } }
{ $description "Allocates an uninterned word with the specified name and vocabulary, and a blank word property hashtable. User code should call " { $link gensym } " to create uninterned words and " { $link create } " to create interned words." } ;

HELP: gensym
{ $values { "word" word } }
{ $description "Creates an uninterned word that is not equal to any other word in the system. Gensyms have an automatically-generated name based on a prefix and an incrementing counter." }
{ $examples { $unchecked-example "gensym ." "G:260561" } }
{ $notes "Gensyms are often used as placeholder values that have no meaning of their own but must be unique. For example, the compiler uses gensyms to label sections of code." } ;

HELP: define-temp
{ $values { "quot" quotation } { "word" word } }
{ $description "Creates an uninterned word that will call " { $snippet "quot" } " when executed." }
{ $notes
    "The following phrases are equivalent:"
    { $code "[ 2 2 + . ] call" }
    { $code "[ 2 2 + . ] define-temp execute" }
} ;

HELP: bootstrapping?
{ $var-description "Set by the library while bootstrap is in progress. Some parsing words need to behave differently during bootstrap." } ;

HELP: word
{ $values { "word" word } }
{ $description "Outputs the most recently defined word." }
{ $class-description "The class of words. One notable subclass is " { $link class } ", the class of class words." } ;

{ word set-word save-location } related-words

HELP: set-word
{ $values { "word" word } }
{ $description "Sets the recently defined word. Usually you would call " { $link save-location } " on a newly-defined word instead, which will in turn call this word." } ;

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
{ $examples { $example "\"salmon\" \"scratchpad\" constructor-word ." "<salmon>" } } ;

HELP: forget-word
{ $values { "word" word } }
{ $description "Removes a word from its vocabulary. User code should call " { $link forget } " instead, since it also does the right thing when forgetting class words." } ;

{ POSTPONE: FORGET: forget forget-word forget-vocab } related-words

HELP: target-word
{ $values { "word" word } { "target" word } }
{ $description "Looks up a word with the same name and vocabulary as the given word. Used during bootstrap to transfer host words to the target dictionary." } ;

HELP: bootstrap-word
{ $values { "word" word } { "target" word } }
{ $description "Looks up a word with the same name and vocabulary as the given word, performing a transformation to handle parsing words in the target dictionary. Used during bootstrap to transfer host words to the target dictionary." } ;

HELP: update-xt ( word -- )
{ $values { "word" word } }
{ $description "Updates a word's execution token based on the value of the " { $link word-def } " slot. If the word was compiled by the optimizing compiler, this forces the word to revert to its unoptimized definition." }
{ $side-effects "word" } ;

HELP: parsing?
{ $values { "obj" object } { "?" "a boolean" } }
{ $description "Tests if an object is a parsing word declared by " { $link POSTPONE: parsing } "." }
{ $notes "Outputs " { $link f } " if the object is not a word." } ;

HELP: word-changed?
{ $values { "word" word } { "?" "a boolean" } }
{ $description "Tests if a word needs to be recompiled." } ;

HELP: changed-word
{ $values { "word" word } }
{ $description "Marks a word as needing recompilation by adding it to the " { $link changed-words } " assoc." }
$low-level-note ;

HELP: unchanged-word
{ $values { "word" word } }
{ $description "Marks a word as no longer needing recompilation by removing it from the " { $link changed-words } " assoc." }
$low-level-note ;

HELP: define-declared
{ $values { "word" word } { "def" quotation } { "effect" effect } }
{ $description "Defines a compound word and declares its stack effect." }
{ $side-effects "word" } ;

HELP: quot-uses
{ $values { "quot" quotation } { "assoc" "an assoc with words as keys" } }
{ $description "Outputs a set of words referenced by the quotation and any quotations it contains." } ;

HELP: delimiter?
{ $values { "obj" object } { "?" "a boolean" } }
{ $description "Tests if an object is a delimiter word declared by " { $link POSTPONE: delimiter } "." }
{ $notes "Outputs " { $link f } " if the object is not a word." } ;

HELP: interned
{ $class-description "The class of words defined in the " { $link dictionary } "." }
{ $examples
    { $example "\\ + interned? ." "t" }
    { $example "gensym interned? ." "f" }
} ;

HELP: rename-word
{ $values { "word" word } { "newname" string } { "newvocab" string } }
{ $description "Changes the name and vocabulary of a word, and adds it to its new vocabulary." }
{ $side-effects "word" } ;

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
{ $values { "word" word } { "quot" quotation } }
{ $description "Defines a compound word and makes it " { $link POSTPONE: inline } "." }
{ $side-effects "word" } ;
