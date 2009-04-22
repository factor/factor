USING: help.markup help.syntax words definitions prettyprint
tools.crossref.private math quotations assocs ;
IN: tools.crossref

ARTICLE: "tools.crossref" "Definition cross referencing"
"Definitions can answer a sequence of definitions they directly depend on:"
{ $subsection uses }
"An inverted index of the above:"
{ $subsection get-crossref }
"Words to access it:"
{ $subsection usage }
{ $subsection smart-usage }
"Tools for interactive use:"
{ $subsection usage. }
{ $subsection vocab-uses. }
{ $subsection vocab-usage. }
{ $see-also "definitions" "words" "see" } ;

ABOUT: "tools.crossref"

HELP: uses
{ $values { "defspec" "a definition specifier" } { "seq" "a sequence of definition specifiers" } }
{ $description "Outputs a sequence of definitions directory called by the given definition." }
{ $notes "The sequence might include the definition itself, if it is a recursive word." }
{ $examples
    "We can ask the " { $link sq } " word to produce a list of words it calls:"
    { $unchecked-example "\ sq uses ." "{ dup * }" }
} ;

HELP: crossref
{ $var-description "A graph whose vertices are definition specifiers and edges are usages. See " { $link "graphs" } ". This variable is reset to " { $link f } " every time a definition is added or removed. Call " { $link get-crossref } " to lazily construct the graph instead of using this variable directly." } ;

HELP: get-crossref
{ $values { "crossref" assoc } }
{ $description "Outputs the cross-referencing index, mapping definitions to usages, building it first if necessary." }
{ $notes "This word is used to implement " { $link usage } " and " { $link usage. } "." } ;

HELP: crossref-def
{ $values { "defspec" "a definition specifier" } }
{ $description "Adds a vertex representing this definition, along with edges representing dependencies to the " { $link crossref } " graph." }
$low-level-note ;

HELP: usage
{ $values { "defspec" "a definition specifier" } { "seq" "a sequence of definition specifiers" } }
{ $description "Outputs a sequence of definitions that directly call the given definition." }
{ $notes "The sequence might include the definition itself, if it is a recursive word." } ;

HELP: usage.
{ $values { "word" "a word" } }
{ $description "Prints an list of all callers of a word. This may include the word itself, if it is recursive." }
{ $examples { $code "\\ reverse usage." } } ;

HELP: quot-uses
{ $values { "quot" quotation } { "assoc" "an assoc with words as keys" } }
{ $description "Outputs a set of words referenced by the quotation and any quotations it contains." } ;

{ usage usage. } related-words
