USING: help.markup help.syntax words math ;
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

ARTICLE: "definitions" "Definitions"
"A " { $emphasis "definition" } " is an artifact read from a source file. This includes words, methods, and help articles. Words for working with definitions are found in the " { $vocab-link "definitions" } " vocabulary."
{ $subsection "definition-protocol" }
"A common cross-referencing system is used to track definition usages:"
{ $subsection crossref }
{ $subsection xref }
{ $subsection unxref }
{ $subsection delete-xref }
{ $subsection usage }
"Implementations of the definition protocol include pathnames, words, methods, and help articles."
{ $see-also "source-files" "words" "generic" "help-impl" } ;

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
{ $description "Forgets about a definition. For example, if it is a word, it will be removed from its vocabulary." } ;

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
