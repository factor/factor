USING: arrays effects help.markup help.syntax kernel sequences ;
IN: foogle

HELP: foogle-in
{ $values { "effect" effect } { "words" sequence } { "matches" array } }
{ $description "Searches the supplied words for matching stack effects. Input and output counts, termination, and row-variable shape must match. Value names are ignored. Results are sorted by vocabulary and word name."
    $nl
    "Type annotations in the query filter both inputs and outputs to that class or a subclass. An untyped query slot is a wildcard. Candidate types come from explicit stack-effect annotations, then documented values; missing types are treated as " { $link object } ". Nested quotation effects are matched recursively." }
{ $notes "This is a discovery tool. Documentation and declarations are not a proof that a word can safely replace another word. Only the supplied words and already loaded help are searched." } ;

HELP: foogle
{ $values { "effect" effect } { "matches" array } }
{ $description "Searches all loaded words using " { $link foogle-in } ". Load additional vocabularies to include their words in the search." } ;

HELP: foogle.
{ $values { "effect" effect } }
{ $description "Displays " { $link foogle } " results as clickable help links. For example:" }
{ $code "USING: foogle math sequences ;" "( seq: sequence -- n: integer ) foogle." } ;

HELP: foogle-search
{ $class-description "A help topic containing the results of a stack-effect search." } ;

HELP: <foogle-search>
{ $values { "effect" effect } { "foogle-search" foogle-search } }
{ $description "Constructs a browsable stack-effect search topic." } ;

ARTICLE: "foogle" "Searching by stack effect"
"The " { $vocab-link "foogle" } " vocabulary finds loaded words by their declared stack effects and documented types."
{ $subsections foogle. foogle foogle-in } ;
ABOUT: "foogle"
