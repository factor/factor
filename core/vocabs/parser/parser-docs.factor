USING: help.markup help.syntax parser strings words assocs vocabs ;
IN: vocabs.parser

ARTICLE: "word-search-errors"  "Word lookup errors"
"If the parser cannot not find a word in the current vocabulary search path, it attempts to look for the word in all loaded vocabularies."
$nl
"If " { $link auto-use? } " mode is off, a restartable error is thrown with a restart for each vocabulary in question, together with a restart which defers the word in the current vocabulary, as if " { $link POSTPONE: DEFER: } " was used."
$nl
"If " { $link auto-use? } " mode is on and only one vocabulary has a word with this name, the vocabulary is added to the search path and parsing continues."
$nl
"If any restarts were invoked, or if " { $link auto-use? } " is on, the parser will print the correct " { $link POSTPONE: USING: } " after parsing completes. This form can be copy and pasted back into the source file."
{ $subsection auto-use? } ;

ARTICLE: "word-search-syntax" "Syntax to control word lookup"
"Parsing words which make all words in a vocabulary available:"
{ $subsection POSTPONE: USE: }
{ $subsection POSTPONE: USING: }
{ $subsection POSTPONE: QUALIFIED: }
{ $subsection POSTPONE: QUALIFIED-WITH: }
"Parsing words which make a subset of all words in a vocabulary available:"
{ $subsection POSTPONE: FROM: }
{ $subsection POSTPONE: EXCLUDE: }
{ $subsection POSTPONE: RENAME: }
"Removing vocabularies from the search path:"
{ $subsection POSTPONE: UNUSE: }
"In the listener, the " { $vocab-link "scratchpad" } " is the default vocabulary for new word definitions. In source files, there is no default vocabulary. Defining words before declaring a vocabulary with " { $link POSTPONE: IN: } " results in an error."
{ $subsection POSTPONE: IN: } ;

ARTICLE: "word-search-semantics" "Resolution of ambiguous word names"
"There is a distinction between parsing words which perform “open” imports versus “closed” imports. An open import introduces all words from a vocabulary as identifiers, except possibly a finite set of exclusions. The " { $link POSTPONE: USE: } ", " { $link POSTPONE: USING: } " and " { $link POSTPONE: EXCLUDE: } " words perform open imports. A closed import only adds a fixed set of identifiers. The " { $link POSTPONE: FROM: } ", " { $link POSTPONE: RENAME: } ", " { $link POSTPONE: QUALIFIED: } " and " { $link POSTPONE: QUALIFIED-WITH: } " words perform closed imports. Note that the latter two are considered as closed imports, due to the fact that all identifiers they introduce are unambiguously qualified with a prefix. The " { $link POSTPONE: IN: } " parsing word also performs a closed import of the newly-created vocabulary."
$nl
"When the parser encounters a reference to a word, it first searches the closed imports, in order. Closed imports are searched from the most recent to least recent. If the word could not be found this way, it searches open imports. Unlike closed imports, with open imports, the order does not matter -- instead, if more than one vocabulary defines a word with this name, an error is thrown."
{ $subsection ambiguous-use-error }
"To resolve the error, add a closed import, using " { $link POSTPONE: FROM: } ", " { $link POSTPONE: QUALIFIED: } " or " { $link POSTPONE: QUALIFIED-WITH: } ". The closed import will then take precedence over the open imports, and the ambiguity will be resolved."
$nl
"The rationale for this behavior is as follows. Open imports are named such because they are open to future extension; if a future version of a vocabulary that you use adds new words, those new words will now be in scope in your source file, too. To avoid problems, any references to the new word have to be resolved since the parser cannot safely determine which vocabulary was meant. This problem can be avoided entirely by using only closed imports, but this leads to additional verbosity."
$nl
"In practice, a small set of guidelines helps avoid name clashes:"
{ $list
  "Keep vocabularies small"
  { "Hide internal words using " { $link POSTPONE: <PRIVATE } }
  { "Make good use of " { $link POSTPONE: FROM: } ", " { $link POSTPONE: QUALIFIED: } " or " { $link POSTPONE: QUALIFIED-WITH: } }
} ;

ARTICLE: "word-search-private" "Private words"
"Words which only serve as implementation detail should be defined in a private code block. Words in a private code blocks get defined in a vocabulary whose name is the name of the current vocabulary suffixed with " { $snippet ".private" } ". Privacy is not enforced by the system; private words can be called from other vocabularies, and from the listener. However, this should be avoided where possible."
{ $subsection POSTPONE: <PRIVATE }
{ $subsection POSTPONE: PRIVATE> } ;

ARTICLE: "word-search" "Parse-time word lookup"
"When the parser reads a word name, it resolves the word at parse-time, looking up the " { $link word } " instance in the right vocabulary and adding it to the parse tree."
$nl
"Initially, only words from the " { $vocab-link "syntax" } " vocabulary are available in source files. Since most files will use words in other vocabularies, they will need to make those words available using a set of parsing words."
{ $subsection "word-search-syntax" }
{ $subsection "word-search-private" }
{ $subsection "word-search-semantics" }
{ $subsection "word-search-errors" }
{ $see-also "words" } ;

ARTICLE: "word-search-parsing" "Word lookup in parsing words"
"The parsing words described in " { $link "word-search-syntax" } " are implemented using the below words, which you can also call from your own parsing words."
$nl
"The current state used for word search is stored in a " { $emphasis "manifest" } ":"
{ $subsection manifest }
"Words for working with the current manifest:"
{ $subsection use-vocab }
{ $subsection unuse-vocab }
{ $subsection add-qualified }
{ $subsection add-words-from }
{ $subsection add-words-excluding }
"Words used to implement " { $link POSTPONE: IN: } ":"
{ $subsection current-vocab }
{ $subsection set-current-vocab }
"Words used to implement " { $link "word-search-private" } ":"
{ $subsection begin-private }
{ $subsection end-private } ;

ABOUT: "word-search"

HELP: manifest
{ $var-description "The current manifest. Only set at parse time." }
{ $class-description "Encapsulates the current vocabulary, as well as the vocabulary search path." } ;

HELP: <manifest>
{ $values { "manifest" manifest } }
{ $description "Creates a new manifest." } ;

HELP: set-current-vocab
{ $values { "name" string } }
{ $description "Sets the current vocabulary where new words will be defined, creating the vocabulary first if it does not exist." }
{ $notes "This word is used to implement " { $link POSTPONE: IN: } "." } ;

HELP: no-current-vocab
{ $error-description "Thrown when a new word is defined in a source file that does not have an " { $link POSTPONE: IN: } " form." } ;

HELP: current-vocab
{ $values { "vocab" vocab } }
{ $description "Returns the current vocabulary, where new words will be defined." }
{ $errors "Throws an error if the current vocabulary has not been set." } ;

HELP: begin-private
{ $description "Begins a block of private word definitions. Private word definitions are placed in the current vocabulary name, suffixed with " { $snippet ".private" } "." }
{ $notes "This word is used to implement " { $link POSTPONE: <PRIVATE } "." } ;

HELP: end-private
{ $description "Ends a block of private word definitions." }
{ $notes "This word is used to implement " { $link POSTPONE: PRIVATE> } "." } ;

HELP: use-vocab
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Adds a vocabulary to the current manifest." }
{ $notes "This word is used to implement " { $link POSTPONE: USE: } "." } ;

HELP: unuse-vocab
{ $values { "vocab" "a vocabulary specifier" } }
{ $description "Removes a vocabulary from the current manifest." }
{ $notes "This word is used to implement " { $link POSTPONE: UNUSE: } "." } ;

HELP: add-qualified
{ $values { "vocab" "a vocabulary specifier" } { "prefix" string } }
{ $description "Adds the vocabulary's words, prefixed with the given string, to the current manifest." }
{ $notes "If adding the vocabulary introduces ambiguity, the vocabulary will take precedence when resolving any ambiguous names. See the example in " { $link POSTPONE: QUALIFIED: } " for further explanation." } ;

HELP: add-words-from
{ $values { "vocab" "a vocabulary specifier" } { "words" "a sequence of word names" } }
{ $description "Adds " { $snippet "words" } " from " { $snippet "vocab" } " to the current manifest." }
{ $notes "This word is used to implement " { $link POSTPONE: FROM: } "." } ;

HELP: add-words-excluding
{ $values { "vocab" "a vocabulary specifier" } { "words" "a sequence of word names" } }
{ $description "Adds all words except for " { $snippet "words" } " from " { $snippet "vocab" } "  to the manifest." }
{ $notes "This word is used to implement " { $link POSTPONE: EXCLUDE: } "." } ;

HELP: add-renamed-word
{ $values { "word" string } { "vocab" "a vocabulary specifier" } { "new-name" string } }
{ $description "Imports " { $snippet "word" } " from " { $snippet "vocab" } ", but renamed to " { $snippet "new-name" } "." }
{ $notes "This word is used to implement " { $link POSTPONE: RENAME: } "." } ;

HELP: use-words
{ $values { "assoc" assoc } }
{ $description "Adds an assoc mapping word names to words to the current manifest." }
{ $notes "This word is used by " { $link "locals" } " to implement lexically-scoped names." } ;

HELP: unuse-words
{ $values { "assoc" assoc } }
{ $description "Removes an assoc mapping word names to words from the current manifest." }
{ $notes "This word is used by " { $link "locals" } " to implement lexically-scoped names." } ;

HELP: ambiguous-use-error
{ $error-description "Thrown when a word name referenced in source file is available in more than one vocabulary in the manifest. Such cases must be explicitly disambiguated using " { $link POSTPONE: FROM: } ", " { $link POSTPONE: EXCLUDE: } ", " { $link POSTPONE: QUALIFIED: } ", or " { $link POSTPONE: QUALIFIED-WITH: } "." } ;

HELP: search-manifest
{ $values { "name" string } { "manifest" manifest } { "word/f" { $maybe word } } }
{ $description "Searches for a word by name in the given manifest. If no such word could be found, outputs " { $link f } "." } ;

HELP: search
{ $values { "name" string } { "word/f" { $maybe word } } }
{ $description "Searches for a word by name in the current manifest. If no such word could be found, outputs " { $link f } "." }
$parsing-note ;
