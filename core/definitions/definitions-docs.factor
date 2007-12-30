USING: help.markup help.syntax words math source-files
parser quotations ;
IN: definitions

ARTICLE: "definition-protocol" "Definition protocol"
"A common protocol is used to build generic tools for working with all definitions."
$nl
"Definitions must know what source file they were loaded from, and provide a way to set this:"
{ $subsection where }
{ $subsection set-where }
"Definitions can be removed:"
{ $subsection forget }
"Definitions can answer a sequence of definitions they directly depend on:"
{ $subsection uses }
"When a definition is changed, all definitions which depend on it are notified via a hook:"
{ $subsection redefined* }
"Definitions must implement a few operations used for printing them in human and computer-readable form:"
{ $subsection synopsis* }
{ $subsection definer }
{ $subsection definition } ;

ARTICLE: "definition-crossref" "Definition cross referencing"
"A common cross-referencing system is used to track definition usages:"
{ $subsection crossref }
{ $subsection xref }
{ $subsection unxref }
{ $subsection delete-xref }
{ $subsection usage } ;

ARTICLE: "definition-checking" "Definition sanity checking"
"When a source file is reloaded, the parser compares the previous list of definitions with the current list; any definitions which are no longer present in the file are removed by a call to " { $link forget } ". A warning message is printed if any other definitions still depend on the removed definitions."
$nl
"The parser also catches forward references when reloading source files. This is best illustrated with an example. Suppose we load a source file " { $snippet "a.factor" } ":"
{ $code
    "USING: io sequences ;"
    "IN: a"
    ": hello \"Hello\" ;"
    ": world \"world\" ;"
    ": hello-world hello " " world 3append print ;"
}
"The definitions for " { $snippet "hello" } ", " { $snippet "world" } ", and " { $snippet "hello-world" } " are in the dictionary."
$nl
"Now, after some heavily editing and refactoring, the file looks like this:"
{ $code
    "USING: namespaces ;"
    "IN: a"
    ": hello \"Hello\" % ;"
    ": hello-world [ hello " " % world ] \"\" make ;"
    ": world \"world\" % ;"
}
"Note that the developer has made a mistake, placing the definition of " { $snippet "world" } " " { $emphasis "after" } " its usage in " { $snippet "hello-world" } "."
$nl
"If the parser did not have special checks for this case, then the modified source file would still load, because when the definition of " { $snippet "hello-world" } " on line 4 is being parsed, the " { $snippet "world" } " word is already present in the dictionary from an earlier run. The developer would then not discover this mistake until attempting to load the source file into a fresh image."
$nl
"Since this is undesirable, the parser explicitly raises an error if a source file refers to a word which is in the dictionary, but defined after it is used."
{ $subsection forward-error }
"If a source file raises a " { $link forward-error } " when loaded into a development image, then it would have raised a " { $link no-word } " error when loaded into a fresh image."
$nl
"The parser also catches duplicate definitions. If an artifact is defined twice in the same source file, the earlier definition will never be accessible, and this is almost always a mistake, perhaps due to a bad choice of word names, or a copy and paste error. The parser raises an error in this case."
{ $subsection redefine-error } ;

ARTICLE: "compilation-units" "Compilation units"
"A " { $emphasis "compilation unit" } " scopes a group of related definitions. They are compiled and entered into the system in one atomic operation."
$nl
"The parser groups all definitions in a source file into one compilation unit, and parsing words do not need to concern themselves with compilation units. However, if definitions are being created at run-time, a compilation unit must be created explicitly:"
{ $subsection with-compilation-unit }
"Words called to associate a definition with a source file location:"
{ $subsection remember-definition }
{ $subsection remember-class }
"Forward reference checking (see " { $link "definition-checking" } "):"
{ $subsection forward-reference? }
"A hook to be called at the end of the compilation unit. If the optimizing compiler is loaded, this compiles new words with the " { $link "compiler" } ":"
{ $subsection recompile-hook } ;

ARTICLE: "definitions" "Definitions"
"A " { $emphasis "definition" } " is an artifact read from a source file. This includes words, methods, and help articles. Words for working with definitions are found in the " { $vocab-link "definitions" } " vocabulary. Implementations of the definition protocol include pathnames, words, methods, and help articles."
{ $subsection "definition-protocol" }
{ $subsection "definition-crossref" }
{ $subsection "definition-checking" }
{ $subsection "compilation-units" }
{ $see-also "parser" "source-files" "words" "generic" "help-impl" } ;

ABOUT: "definitions"

HELP: where
{ $values { "defspec" "a definition specifier" } { "loc" "a " { $snippet "{ path line# }" } " pair" } }
{ $description "Outputs the location of a definition. If the location is not known, will output " { $link f } "." } ;

HELP: set-where
{ $values { "loc" "a " { $snippet "{ path line# }" } " pair" } { "defspec" "a definition specifier" } }
{ $description "Sets the definition's location." }
{ $notes "This word is used by the parser." } ;

HELP: forget
{ $values { "defspec" "a definition specifier" } }
{ $description "Forgets about a definition. For example, if it is a word, it will be removed from its vocabulary." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." } ;

HELP: forget-all
{ $values { "definitions" "a sequence of definition specifiers" } }
{ $description "Forgets every definition in a sequence." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." } ;

HELP: uses
{ $values { "defspec" "a definition specifier" } { "seq" "a sequence of definition specifiers" } }
{ $description "Outputs a sequence of definitions directory called by the given definition." }
{ $notes "The sequence might include the definition itself, if it is a recursive word." }
{ $examples
    "We can ask the " { $link sq } " word to produce a list of words it calls:"
    { $unchecked-example "\ sq uses ." "{ dup * }" }
} ;

HELP: crossref
{ $var-description "A graph whose vertices are definition specifiers and edges are usages. See " { $link "graphs" } "." } ;

HELP: xref
{ $values { "defspec" "a definition specifier" } }
{ $description "Adds a vertex representing this definition, along with edges representing dependencies to the " { $link crossref } " graph." }
$low-level-note ;

HELP: usage
{ $values { "defspec" "a definition specifier" } { "seq" "a sequence of definition specifiers" } }
{ $description "Outputs a sequence of definitions that directly call the given definition." }
{ $notes "The sequence might include the definition itself, if it is a recursive word." } ;

HELP: redefined*
{ $values { "defspec" "a definition specifier" } }
{ $contract "Updates the definition to cope with a callee being redefined." }
$low-level-note ;

HELP: unxref
{ $values { "defspec" "a definition specifier" } }
{ $description "Remove edges leaving the vertex which represents the definition from the " { $link crossref } " graph." }
{ $notes "This word is called before a word is redefined." } ;

HELP: delete-xref
{ $values { "defspec" "a definition specifier" } }
{ $description "Remove the vertex which represents the definition from the " { $link crossref } " graph." }
{ $notes "This word is called before a word is forgotten." }
{ $see-also forget } ;

HELP: redefine-error
{ $values { "definition" "a definition specifier" } }
{ $description "Throws a " { $link redefine-error } "." }
{ $error-description "Indicates that a single source file contains two definitions for the same artifact, one of which shadows the other. This is an error since it indicates a likely mistake, such as two words accidentally named the same by the developer; the error is restartable." } ;

HELP: remember-definition
{ $values { "definition" "a definition specifier" } { "loc" "a " { $snippet "{ path line# }" } " pair" } }
{ $description "Saves the location of a definition and associates this definition with the current source file."
$nl
"This is the book-keeping required to detect " { $link redefine-error } " and " { $link forward-error } "." } ;

HELP: old-definitions
{ $var-description "Stores an assoc where the keys form the set of definitions which were defined by " { $link file } " the most recent time it was loaded." } ;

HELP: new-definitions
{ $var-description "Stores an assoc where the keys form the set of definitions which were defined so far by the current parsing of " { $link file } "." } ;

HELP: forward-error
{ $values { "word" word } }
{ $description "Throws a " { $link forward-error } "." }
{ $description "Indicates a word is being referenced prior to the location of its most recent definition. This can only happen if a source file is loaded, and subsequently edited such that two dependent definitions are reversed." } ;

HELP: with-compilation-unit
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new compilation unit. The quotation can define new words and classes, as well as forget words. When the quotation returns, any changed words are recompiled and applied atomically." }
{ $notes "Compilation units may be nested. The parser wraps every source file in a compilation unit, so parsing words may define new words without having to perform extra work; to define new words at any other time, you must wrap your defining code with this combinator." } ;

HELP: recompile-hook
{ $var-description "Quotation with stack effect " { $snippet "( words -- )" } ", called at the end of " { $link with-compilation-unit } "." } ;
